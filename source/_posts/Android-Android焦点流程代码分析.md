---
title: '[Android]Android焦点流程代码分析'
tags: [android, source code, focus]
date: 2017-08-04 18:08:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/7286503.html>
**</font>

通过View的`View::focusSearch`进行焦点搜索对应方向上的下一个可以获取焦点的View：

<!-- more -->

```java
public View focusSearch(@FocusRealDirection int direction) {
   if (mParent != null) {
       return mParent.focusSearch(this, direction);
   } else {
       return null;
   }
}
```

<span id="focusSearch"/>
不断地调用父控件来进行搜索，focusSearch有两个实现：`ViewGroup`和`RecyclerView`，先看`ViewGroup`：

```java
@Override
public View focusSearch(View focused, int direction) {
   if (isRootNamespace()) {
       // root namespace means we should consider ourselves the top of the
       // tree for focus searching; otherwise we could be focus searching
       // into other tabs.  see LocalActivityManager and TabHost for more info
       return FocusFinder.getInstance().findNextFocus(this, focused, direction);
   } else if (mParent != null) {
       return mParent.focusSearch(focused, direction);
   }
   return null;
}
```
<span id="FocusFinder.findNextFocus"/>
如果是最顶层，则直接调用`FocusFinder::findNextFocus`方法进行搜索；否则调用父控件的`focusSearch`。`FocusFinder::findNextFocus`如下：

```java
private View findNextFocus(ViewGroup root, View focused, Rect focusedRect, int direction) {
   View next = null;
   if (focused != null) {
       next = findNextUserSpecifiedFocus(root, focused, direction);
   }
   if (next != null) {
       return next;
   }
   ArrayList<View> focusables = mTempList;
   try {
       focusables.clear();
       root.addFocusables(focusables, direction);
       if (!focusables.isEmpty()) {
           next = findNextFocus(root, focused, focusedRect, direction, focusables);
       }
   } finally {
       focusables.clear();
   }
   return next;
}
```
上面的`root`参数代表的是最顶层的view。

首先，通过尝试通过`findNextUserSpecifiedFocus`来查找下一个“指定的”可获得焦点的View，这个指定是开发者通过SDK自带的`setNextFocusLeftId`等方法进行手动设置的。如果查找到指定的下一个可获得焦点的View，则返回该View；否则，执行`View::addFocusables`方法，通过这个最顶层的View去拿到所有直接或间接的`Focusable`的子View，并添加到`ArrayList<View> focusables`中。

`View::addFolcusables`方法中有4种实现：

第一种是View中默认实现：

```java
public void addFocusables(ArrayList<View> views, @FocusDirection int direction,
            @FocusableMode int focusableMode) {
        if (views == null) {
            return;
        }
        if (!isFocusable()) {
            return;
        }
        if ((focusableMode & FOCUSABLES_TOUCH_MODE) == FOCUSABLES_TOUCH_MODE
                && !isFocusableInTouchMode()) {
            return;
        }
        views.add(this);
    }
```
如果自己是focusable的话，直接把自己添加进去。

第二种是`ViewGroup`实现：

```java
@Override
public void addFocusables(ArrayList<View> views, int direction, int focusableMode) {
   final int focusableCount = views.size();

   final int descendantFocusability = getDescendantFocusability();

   if (descendantFocusability != FOCUS_BLOCK_DESCENDANTS) {
       if (shouldBlockFocusForTouchscreen()) {
           focusableMode |= FOCUSABLES_TOUCH_MODE;
       }

       final int count = mChildrenCount;
       final View[] children = mChildren;

       for (int i = 0; i < count; i++) {
           final View child = children[i];
           if ((child.mViewFlags & VISIBILITY_MASK) == VISIBLE) {
               child.addFocusables(views, direction, focusableMode);
           }
       }
   }

   // we add ourselves (if focusable) in all cases except for when we are
   // FOCUS_AFTER_DESCENDANTS and there are some descendants focusable.  this is
   // to avoid the focus search finding layouts when a more precise search
   // among the focusable children would be more interesting.
   if ((descendantFocusability != FOCUS_AFTER_DESCENDANTS
           // No focusable descendants
           || (focusableCount == views.size())) &&
           (isFocusableInTouchMode() || !shouldBlockFocusForTouchscreen())) {
       super.addFocusables(views, direction, focusableMode);
   }
}
```

> 先会处理自身ViewGroup与它后代的关系(descendantFocusability)，前面提到过，可能的几种情况：
>
> - **FOCUS_BEFORE_DESCENDANTS**: ViewGroup本身先对焦点进行处理，如果没有处理则分发给child View进行处理
> - **FOCUS_AFTER_DESCENDANTS**: 先分发给Child View进行处理，如果所有的Child View都没有处理，则自己再处理
> - **FOCUS_BLOCK_DESCENDANTS**: ViewGroup本身进行处理，不管是否处理成功，都不会分发给ChildView进行处理

所以，以上：

1\. 如果不是`FOCUS_BLOCK_DESCENDANTS`，则首先检查`blockForTouchscreen`并重置掉`focusableMode`，然后遍历所有的子View，调用`child::addFocusables`。
2\. 如果不是`FOCUS_AFTER_DESCENDANTS`或者没有focusable的子View时自己处理，所以把自己加入到`views`中。

第三种是`ViewPager`实现：

```java
@Override
public void addFocusables(ArrayList<View> views, int direction, int focusableMode) {
   final int focusableCount = views.size();

   final int descendantFocusability = getDescendantFocusability();

   if (descendantFocusability != FOCUS_BLOCK_DESCENDANTS) {
       for (int i = 0; i < getChildCount(); i++) {
           final View child = getChildAt(i);
           if (child.getVisibility() == VISIBLE) {
               ItemInfo ii = infoForChild(child);
               if (ii != null && ii.position == mCurItem) {
                   child.addFocusables(views, direction, focusableMode);
               }
           }
       }
   }

   // we add ourselves (if focusable) in all cases except for when we are
   // FOCUS_AFTER_DESCENDANTS and there are some descendants focusable.  this is
   // to avoid the focus search finding layouts when a more precise search
   // among the focusable children would be more interesting.
   if (descendantFocusability != FOCUS_AFTER_DESCENDANTS
           || (focusableCount == views.size())) { // No focusable descendants
       // Note that we can't call the superclass here, because it will
       // add all views in.  So we need to do the same thing View does.
       if (!isFocusable()) {
           return;
       }
       if ((focusableMode & FOCUSABLES_TOUCH_MODE) == FOCUSABLES_TOUCH_MODE
               && isInTouchMode() && !isFocusableInTouchMode()) {
           return;
       }
       if (views != null) {
           views.add(this);
       }
   }
}
```

与`ViewGroup`基本一致，在`descendantFocusability`不是`FOCUS_BLOCK_DESCENDANTS`时，遍历子View时判断view是否属于当前的page，如果是才加进去。如果不是`FOCUS_AFTER_DESCENDANTS`或者没有focusable的子View时自己处理，所以把自己加入到`views`中。

第四种是`RecyclerView`实现：

```java
@Override
public void addFocusables(ArrayList<View> views, int direction, int focusableMode) {
   if (mLayout == null || !mLayout.onAddFocusables(this, views, direction, focusableMode)) {
       super.addFocusables(views, direction, focusableMode);
   }
}
```

通过`LayoutManager::onAddFocusables`来进行管理，如果返回false，则直接调用父类`ViewGroup`的方法，看下`LayoutManager::onAddFocusables`的实现：

```java
public boolean onAddFocusables(RecyclerView recyclerView, ArrayList<View> views,
      int direction, int focusableMode) {
  return false;
}
```

直接返回false，并且没有看到相关的`LayoutManager`对该方法的重写，所以，这里应该是直接调用了父类`ViewGroup`的方法。

`addFocusables`方法完毕，回到 [FocusFinder::findNextFocus](#FocusFinder.findNextFocus) 方法中通过`root.addFocusables(focusables, direction);`加入所有可获取焦点的View之后，在非空的情况下调用如下代码：

```java
next = findNextFocus(root, focused, focusedRect, direction, focusables);
```

所以重点是`FocusFinder::findNextFocus`方法的实现：

```java
private View findNextFocus(ViewGroup root, View focused, Rect focusedRect,
       int direction, ArrayList<View> focusables) {
   if (focused != null) {
       if (focusedRect == null) {
           focusedRect = mFocusedRect;
       }
       // fill in interesting rect from focused
       focused.getFocusedRect(focusedRect);
       root.offsetDescendantRectToMyCoords(focused, focusedRect);
   } else {
       if (focusedRect == null) {
           focusedRect = mFocusedRect;
           // make up a rect at top left or bottom right of root
           switch (direction) {
               case View.FOCUS_RIGHT:
               case View.FOCUS_DOWN:
                   setFocusTopLeft(root, focusedRect);
                   break;
               case View.FOCUS_FORWARD:
                   if (root.isLayoutRtl()) {
                       setFocusBottomRight(root, focusedRect);
                   } else {
                       setFocusTopLeft(root, focusedRect);
                   }
                   break;

               case View.FOCUS_LEFT:
               case View.FOCUS_UP:
                   setFocusBottomRight(root, focusedRect);
                   break;
               case View.FOCUS_BACKWARD:
                   if (root.isLayoutRtl()) {
                       setFocusTopLeft(root, focusedRect);
                   } else {
                       setFocusBottomRight(root, focusedRect);
                   break;
               }
           }
       }
   }

   switch (direction) {
       case View.FOCUS_FORWARD:
       case View.FOCUS_BACKWARD:
           return findNextFocusInRelativeDirection(focusables, root, focused, focusedRect,
                   direction);
       case View.FOCUS_UP:
       case View.FOCUS_DOWN:
       case View.FOCUS_LEFT:
       case View.FOCUS_RIGHT:
           return findNextFocusInAbsoluteDirection(focusables, root, focused,
                   focusedRect, direction);
       default:
           throw new IllegalArgumentException("Unknown direction: " + direction);
   }
}
```

- 如果focused不是null，说明当前获取到焦点的View存在，则获得绘制焦点的Rect到focusedRect，然后根据rootView遍历所有ParentView从子View纠正坐标到根View坐标。
- 如果focused是null，则说明当前没有View获取到焦点，则把focusedRect根据不同的direction重置为“一点”。

最后根据direction调用`FocusFinder::findNextFocusInAbsoluteDirection`方法进行对比查找“下一个”View。

```java
View findNextFocusInAbsoluteDirection(ArrayList<View> focusables, ViewGroup root, View focused,
       Rect focusedRect, int direction) {
   // initialize the best candidate to something impossible
   // (so the first plausible view will become the best choice)
   mBestCandidateRect.set(focusedRect);
   switch(direction) {
       case View.FOCUS_LEFT:
           mBestCandidateRect.offset(focusedRect.width() + 1, 0);
           break;
       case View.FOCUS_RIGHT:
           mBestCandidateRect.offset(-(focusedRect.width() + 1), 0);
           break;
       case View.FOCUS_UP:
           mBestCandidateRect.offset(0, focusedRect.height() + 1);
           break;
       case View.FOCUS_DOWN:
           mBestCandidateRect.offset(0, -(focusedRect.height() + 1));
   }

   View closest = null;

   int numFocusables = focusables.size();
   for (int i = 0; i < numFocusables; i++) {
       View focusable = focusables.get(i);

       // only interested in other non-root views
       if (focusable == focused || focusable == root) continue;

       // get focus bounds of other view in same coordinate system
       focusable.getFocusedRect(mOtherRect);
       root.offsetDescendantRectToMyCoords(focusable, mOtherRect);

       if (isBetterCandidate(direction, focusedRect, mOtherRect, mBestCandidateRect)) {
           mBestCandidateRect.set(mOtherRect);
           closest = focusable;
       }
   }
   return closest;
}
```

首先把最优选择mBestCandidateRect设置为focusedRect，根据方向做1像素的偏移便于对比。遍历所有刚刚查询出来的`focusables`，拿到每一个的`focusedRect`区域并进行转换，然后通过`FocusFinder::isBetterCandidate`方法进行对比，然后拿到更好的，遍历完成后就是最优选择。接下来看下`FocusFinder::isBetterCandidate`方法来了解下是怎么做对比的：

下面代码意思是：以source这个rect来说，作为对应derection上下一个focus view，rect1是否比rect2更优？

<span id="FocusFinder.isBetterCandidate"/>

```java
boolean isBetterCandidate(int direction, Rect source, Rect rect1, Rect rect2) {

   // to be a better candidate, need to at least be a candidate in the first
   // place :)
   if (!isCandidate(source, rect1, direction)) {
       return false;
   }

   // we know that rect1 is a candidate.. if rect2 is not a candidate,
   // rect1 is better
   if (!isCandidate(source, rect2, direction)) {
       return true;
   }

   // if rect1 is better by beam, it wins
   if (beamBeats(direction, source, rect1, rect2)) {
       return true;
   }

   // if rect2 is better, then rect1 cant' be :)
   if (beamBeats(direction, source, rect2, rect1)) {
       return false;
   }

   // otherwise, do fudge-tastic comparison of the major and minor axis
   return (getWeightedDistanceFor(
                   majorAxisDistance(direction, source, rect1),
                   minorAxisDistance(direction, source, rect1))
           < getWeightedDistanceFor(
                   majorAxisDistance(direction, source, rect2),
                   minorAxisDistance(direction, source, rect2)));
}
```

首先确定rect1是否`isCandidate`？`isCandidate`做的逻辑简单来说就是确定rect是否满足给定的derection作为下一个focus view这个条件，它的判断依据如下：

```java
boolean isCandidate(Rect srcRect, Rect destRect, int direction) {
   switch (direction) {
       case View.FOCUS_LEFT:
           return (srcRect.right > destRect.right || srcRect.left >= destRect.right) 
                   && srcRect.left > destRect.left;
       case View.FOCUS_RIGHT:
           return (srcRect.left < destRect.left || srcRect.right <= destRect.left)
                   && srcRect.right < destRect.right;
       case View.FOCUS_UP:
           return (srcRect.bottom > destRect.bottom || srcRect.top >= destRect.bottom)
                   && srcRect.top > destRect.top;
       case View.FOCUS_DOWN:
           return (srcRect.top < destRect.top || srcRect.bottom <= destRect.top)
                   && srcRect.bottom < destRect.bottom;
   }
   throw new IllegalArgumentException("direction must be one of "
           + "{FOCUS_UP, FOCUS_DOWN, FOCUS_LEFT, FOCUS_RIGHT}.");
}
```

代码比较简单。再回到 [FocusFinder::isBetterCandidate](#FocusFinder.isBetterCandidate) 的代码逻辑：

- 如果rect1不满足基本条件，则肯定返回false（基本的条件都不满足）
- 如果rect2不满足基本条件，则返回true，认为rect1更优
- 如果都满足基本条件的情况下，通过`FocusFinder::beamBeats`方法来判断哪种更优

接下来看下`FocusFinder::beamBeats`的实现：

```java
boolean beamBeats(int direction, Rect source, Rect rect1, Rect rect2) {
   final boolean rect1InSrcBeam = beamsOverlap(direction, source, rect1);
   final boolean rect2InSrcBeam = beamsOverlap(direction, source, rect2);

   // if rect1 isn't exclusively in the src beam, it doesn't win
   if (rect2InSrcBeam || !rect1InSrcBeam) {
       return false;
   }

   // we know rect1 is in the beam, and rect2 is not

   // if rect1 is to the direction of, and rect2 is not, rect1 wins.
   // for example, for direction left, if rect1 is to the left of the source
   // and rect2 is below, then we always prefer the in beam rect1, since rect2
   // could be reached by going down.
   if (!isToDirectionOf(direction, source, rect2)) {
       return true;
   }

   // for horizontal directions, being exclusively in beam always wins
   if ((direction == View.FOCUS_LEFT || direction == View.FOCUS_RIGHT)) {
       return true;
   }        

   // for vertical directions, beams only beat up to a point:
   // now, as long as rect2 isn't completely closer, rect1 wins
   // e.g for direction down, completely closer means for rect2's top
   // edge to be closer to the source's top edge than rect1's bottom edge.
   return (majorAxisDistance(direction, source, rect1)
           < majorAxisDistanceToFarEdge(direction, source, rect2));
}
```

首先通过`beamsOverlap`方法来判断两个rect与source是否重叠等等。**注意的是，在水平情况下，如果rect1重叠，则就是最优解（为什么？比较奇怪）**，最后**如果是竖直情况**，通过`FocusFinder::majorAxisDistance`方法来判断哪个离source最近。如果还是比较不出，则通过`getWeightedDistanceFor`方法来通过“主要距离”和“次要距离”做一个综合的比较。

## RecyclerView

继续 [focusSearch](#focusSearch) 代码的分析，刚刚只跟了`ViewGroup`，还有一个实现是`RecyclerView`的实现：

```java
@Override
public View focusSearch(View focused, int direction) {
   View result = mLayout.onInterceptFocusSearch(focused, direction);
   if (result != null) {
       return result;
   }
   // ...
}
```

首先通过`onInterceptFocusSearch`进行拦截，如果返回具体的focus View，则直接返回；否则继续往下；`onInterceptFocusSearch`实现如下：

```java
public View onInterceptFocusSearch(View focused, int direction) {
    return null;
}
```
默认为空实现，返回null，也没有其它的子类进行重写，所以暂时不管这个处理，继续看`focusSearch`：

```java
@Override
public View focusSearch(View focused, int direction) {
   View result = mLayout.onInterceptFocusSearch(focused, direction);
   if (result != null) {
       return result;
   }
   final boolean canRunFocusFailure = mAdapter != null && mLayout != null
           && !isComputingLayout() && !mLayoutFrozen;

   final FocusFinder ff = FocusFinder.getInstance();
   if (canRunFocusFailure
           && (direction == View.FOCUS_FORWARD || direction == View.FOCUS_BACKWARD)) {
       // convert direction to absolute direction and see if we have a view there and if not
       // tell LayoutManager to add if it can.
       boolean needsFocusFailureLayout = false;
       if (mLayout.canScrollVertically()) {
           final int absDir =
                   direction == View.FOCUS_FORWARD ? View.FOCUS_DOWN : View.FOCUS_UP;
           final View found = ff.findNextFocus(this, focused, absDir);
           needsFocusFailureLayout = found == null;
           if (FORCE_ABS_FOCUS_SEARCH_DIRECTION) {
               // Workaround for broken FOCUS_BACKWARD in API 15 and older devices.
               direction = absDir;
           }
       }
       if (!needsFocusFailureLayout && mLayout.canScrollHorizontally()) {
           boolean rtl = mLayout.getLayoutDirection() == ViewCompat.LAYOUT_DIRECTION_RTL;
           final int absDir = (direction == View.FOCUS_FORWARD) ^ rtl
                   ? View.FOCUS_RIGHT : View.FOCUS_LEFT;
           final View found = ff.findNextFocus(this, focused, absDir);
           needsFocusFailureLayout = found == null;
           if (FORCE_ABS_FOCUS_SEARCH_DIRECTION) {
               // Workaround for broken FOCUS_BACKWARD in API 15 and older devices.
               direction = absDir;
           }
       }
       if (needsFocusFailureLayout) {
           consumePendingUpdateOperations();
           final View focusedItemView = findContainingItemView(focused);
           if (focusedItemView == null) {
               // panic, focused view is not a child anymore, cannot call super.
               return null;
           }
           eatRequestLayout();
           mLayout.onFocusSearchFailed(focused, direction, mRecycler, mState);
           resumeRequestLayout(false);
       }
       result = ff.findNextFocus(this, focused, direction);
   } else {
       result = ff.findNextFocus(this, focused, direction);
       if (result == null && canRunFocusFailure) {
           consumePendingUpdateOperations();
           final View focusedItemView = findContainingItemView(focused);
           if (focusedItemView == null) {
               // panic, focused view is not a child anymore, cannot call super.
               return null;
           }
           eatRequestLayout();
           result = mLayout.onFocusSearchFailed(focused, direction, mRecycler, mState);
           resumeRequestLayout(false);
       }
   }
   if (result != null && !result.hasFocusable()) {
       if (getFocusedChild() == null) {
           // Scrolling to this unfocusable view is not meaningful since there is no currently
           // focused view which RV needs to keep visible.
           return super.focusSearch(focused, direction);
       }
       // If the next view returned by onFocusSearchFailed in layout manager has no focusable
       // views, we still scroll to that view in order to make it visible on the screen.
       // If it's focusable, framework already calls RV's requestChildFocus which handles
       // bringing this newly focused item onto the screen.
       requestChildOnScreen(result, null);
       return focused;
   }
   return isPreferredNextFocus(focused, result, direction)
           ? result : super.focusSearch(focused, direction);
}
```

我们暂时只考虑`direction`为left，top，right，down的情况，则进入最外面if的else分支：

```java
public View focusSearch(View focused, int direction) {
    // ...
    result = ff.findNextFocus(this, focused, direction);
    if (result == null && canRunFocusFailure) {
     consumePendingUpdateOperations();
     final View focusedItemView = findContainingItemView(focused);
     if (focusedItemView == null) {
         // panic, focused view is not a child anymore, cannot call super.
         return null;
     }
     eatRequestLayout();
     result = mLayout.onFocusSearchFailed(focused, direction, mRecycler, mState);
     resumeRequestLayout(false);
    }
    // ...
}
```

首先通过`FocusFinder::findNextFocus`方法来获取下一个应该获得焦点的View，这里获取的结果与 [FocusFinder::findNextFocus](#FocusFinder.findNextFocus) 逻辑一致。

