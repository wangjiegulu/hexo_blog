---
title: Git Note
tags: [git, tips]
date: 2016-08-24 17:36:00
---

# Git

> 参考 <http://chengshiwen.com/article/head-first-git/>

## 文件状态

- **Git目录**: （git directory），亦即Git仓库，一般对应项目根目录下的.git目录。该目录非常重要，每次克隆镜像仓库的时候，实际拷贝的就是这个目录里面的数据。

- **工作目录**:（working directory）是项目某个版本的签出（The working directory is a single checkout of one version of the project） ，也就是本地项目目录，其包含该版本的所有文件（不包括Git目录）。这些文件都是从Git目录中取出的，我们可以在工作目录中修改它们(modify)、删除它们(remove)或添加新文件(add)——这些称之为改动（Changes）。

- **暂存区域**:（staging area）是工作目录和Git目录之间的临时中转区，存储着工作目录中部分改动文件的快照，该快照将在下次提交时被永久地保存到Git目录中。暂存区域也叫索引（index），实际是Git目录下的index文件（`.git/index`），其存放了与当前暂存内容相关的信息，包括暂存的文件名、文件内容的SHA-1哈希值和文件访问权限，使用`git ls-files --stage`命令可查看其内容。

## 初始化

### 查看配置信息

`git config --list`

`git config [--system/--global/--local] user.name`

### 初始化新仓库

`git init`

### 从现有仓库克隆

从现有的项目仓库（如远程服务器上自己的项目，或者其它某个开源项目）克隆到本地，Git接收的是项目历史的所有数据（包括每一个文件的每一个版本）。

`git clone <repo> [<dir>]`

克隆时可以在上面的命令末尾指定新的名字，来定义要新建的项目目录名称（仅目录名称不同），例如：

`git clone git@github.com:jquery/jquery.git myjquery`

Git支持`git://`，`http(s)://`，`ssh://`等多种数据传输协议。

## Git的基本工作流程

- 改动文件：在工作目录中修改、删除或添加某些文件

- 暂存文件：对改动后的文件进行快照，保存至暂存区域

- 提交快照：将保存在暂存区域的文件快照永久转储到Git目录中

### 查看工作目录下当前文件的状态

`git status`

### 暂存文件

其作用是把目标文件快照放入暂存区域（add file into staged area）。

|命令|新文件|被修改文件|被删除文件
|---|---|---|---|
|`git add`|Y|Y|N|
|`git add -u`|N|Y|Y|
|`git add -A`|Y|Y|Y|

#### 取消已修改或已暂存文件

`git checkout [<commit>] [--] <file>...`

- 省略commit: 暂存区域 覆盖工作目录 的文件

- 指定commit: 指定commit 覆盖暂存区域和工作目录

两者不会改变HEAD指针，其中--用于分隔指定文件，防止该文件与分支重名造成分支误操作。

```java
$ git checkout -- grep.py   # 放弃grep.py文件未暂存的改动
$ git checkout .            # 放弃所有未暂存的改动
$ git checkout HEAD *.txt   # 放弃本次所有txt文件作的改动（包括工作目录和暂存区域）
$ git checkout HEAD .       # 放弃所有已暂存改动和未暂存改动，即完全重置到最近的提交状态
```

#### 文件重置为最近提交时的状态

`git reset HEAD <file>`

#### 从暂存区域移除文件

`git rm --cached <file>`

### 差异比较

|命令|描述|
|---|---|
|`git diff`|工作目录 / 暂存区域快照|
|`git diff [--] <path>...`|工作目录 / 暂存区域快照(指定文件或目录)|
|`git diff --cached`|暂存区域快照 / 上次提交|
|`git diff --cached [--] <path>...`|暂存区域快照 / 上次提交(指定文件或目录)|
|`git diff HEAD`|工作目录 / 上次提交|
|`git diff <commit>`|工作目录 / commit|
|`git diff <commit> [--] <path>...`|工作目录 / commit(指定文件或目录)|
|`git diff --cached HEAD`|暂存区域快照 / 上次提交|
|`git diff --cached <commit>`|暂存区域快照 / commit|
|`git diff --cached <commit> [--] <path>...`|暂存区域快照 / commit(指定文件或目录)|
|`git diff <commit1> <commit2>`|commit1 / commit2|
|`git diff --check`|列出所有的尾随空白符|

### 提交快照

把暂存区域内的文件快照提交至Git目录中:
`git commit -m "Fix Bug #182: Fix benchmarks for speed"`

把所有已经跟踪过的文件暂存起来一并提交:
`git commit -a -m "added new benchmarks"`

以新作者提交:`git commit --author wjhook<wjhook@gmail.com>`

将指定文件和已暂存文件一并提交:`git commit -i <file>...`

只提交指定文件:`git commit -o <file>...`

修改最后一次提交:

- 重新编辑提交说明: `git commit --amend -m <message>`
- 重新编辑提交作者: `git commit --amend --author wjhook<wjhook@gmail.com>`

### Git的基本工作扩展

#### 查看提交历史

`git log --pretty=format:"%h [%an]<%ae>(%ad) message -> %s" --after="2016-08-12 15:26:00" --before="2016-08-25" --graph --author= wangjie -p -- *android/alibaba/member*FragmentMemberSignIn.java  -3`

按照"hash [作者]<邮箱>(时间) message -> 提交说明"的格式查看提交时间在2016-08-12 15:26:00 ~ 2016-08-25 之间的、作者为wangjie的关于`*android/alibaba/member*FragmentMemberSignIn.java`文件的log并显示提交差异。

```
%H	：提交对象（commit）的完整哈希字串
%h	：提交对象的简短哈希字串
%an：作者（author）的名字
%ae：作者的电子邮件地址
%ad：作者修订日期（可以用 -date= 选项定制格式）
%ar：作者修订日期，按多久以前的方式显示
%s：提交说明
```

`git log --diff-filter=[A/D] --summary`：
列出版本库中曾添加/删除过文件的提交

`git log --diff-filter=[A/D] --summary | grep create`：
列出所有添加/删除过的历史文件

`git log branch1..branch2`：属于branch2，不属于branch1的提交

##### 暂存栈

> <stash> -> stash@{0/1/2/3...}

`git stash [save <message>]`: 当前工作保存到暂存栈中

`git stash pop [<stash>]`: 恢复暂存栈中引用为<stash>的工作，并从暂存栈中删除

`git stash apply [<stash>]`: 恢复暂存栈中引用为<stash>的工作，暂存栈中不删除

`git stash drop [<stash>]`: 删除暂存栈中引用为<stash>的工作

`git stash list`: 列出暂存栈中的所有工作

`git stash show [<stash>]`: 显示暂存栈中引用为<stash>的工作的改动记录

`git stash clear`: 清除暂存栈中所有保留的工作

`git stash branch <branchname> [<stash>]`: 基于指定工作创建新分支，完全恢复该工作被保存前的状态（新建一个最新提交为<stash>创建时所在的提交、名为<branchname>的分支，同时切换到该分支，恢复暂存栈中引用为<stash>的工作，并将其从暂存栈中删除）

##### 删除文件

`rm <file>...`：从工作目录中删除指定文件，但不从暂存区域移除

`git rm <file>...`：从工作目录中删除指定文件，同时将其从暂存区域移除

`git rm --cached <file>...`：仅仅将文件从暂存区域中移除（其状态变为未跟踪），不对该文件进行其它操作

`git rm -f <file>...`：强制删除

`git rm -r <file>...`：递归删除（用于删除目录）

##### 移动或重命名文件

`git mv <file_from> <file_to>`

其等价于

```
$ mv <file_from> <file_to>
$ git rm <file_from>
$ git add <file_to
```

##### 清除未跟踪文件

`git clean -n`: 显示将要清除的文件和目录

`git clean -f`：强制清除文件（不包括目录）

`git clean -df`：强制清除所有文件和目录

若要同时再移除被忽略的文件或目录，加上-x参数；若只移除被忽略的文件或目录，加上-X参数。

##### 合并

`git merge -m <msg> <commit>`：如果产生新的合并提交，则附加msg说明

`git merge --no-commit <commit>`：合并成功后不会自动产生新的提交，用户可以在下次提交前对这次的合并结果进行修改和调整

`git merge --abort`：遇到合并冲突时，此命令将终止合并，并恢复未合并之前的状态

##### 分支挑捡

如果不需要合并某个分支的全部提交,而只需要该分支的某个或某些提交,使用git cherry-pick命令，它会将指定的commit重新应用到当前分支，命令格式为：

`$ git cherry-pick <commit>...`

### 远程交互

##### 查看远程仓库

`git remote`

加上`-v`选项，显示对应的克隆地址：`git remote -v`

##### 添加远程仓库

`git remote add <shortname> <url>`

`git remote add upstream https://github.com/xgenvn/InputHelper.git`

拉取所有xgenvn有的，但本地仓库没有的信息

`git fetch upstream`

`git remote rename <old> <new>`：重命名远程仓库

`git remote rm <name>`：删除名为name的远程仓库

`git remote [-v] show <name>`：查看远程仓库信息

`git remote prune <name>`：删除不存在对应远程分支的本地分支

##### 推送提交到远程仓库

`git push <remote> <branch>`

`git push <remote> <lbranch>:[<rbranch>]`：将本地lbranch分支推送到remote远程仓库的rbranch分支。若rbranch缺省则默认为lbranch，等同于git push <remote> <lbranch>

`git push <remote> :<branch>`：将空推送到remote远程仓库的branch分支，即删除remote远程仓库的branch分支

`git push <remote> --delete <branch>`：删除remote远程仓库的branch分支

`git push <remote> -f <lbranch>:[<rbranch>]`：将本地lbranch分支强制推送到remote远程仓库的rbranch分支

##### 从远程仓库拉取最新改动

基本命令为`git fetch`，其作用是到远程仓库中拉取所有本地仓库中还没有的最新改动，但不会自动将这些改动合并到当前工作分支

`git fetch [<remote>]`：到remote远程仓库拉取所有本地仓库中还没有的最新改动，不指定remote则默认为origin

`git fetch <remote> <branch>`：将remote远程仓库的branch分支拉取到本地，同时用FETCH_HEAD指针指向它

`git fetch --all`：拉取所有远程仓库

`git fetch -p`：删除不存在对应远程分支的本地分支

##### 从远程仓库拉取最新改动并合并

基本命令为`git pull`，其作用是从远程仓库自动拉取最新改动到本地（Fetch），然后将远程分支自动合并到本地仓库中的当前分支(Merge)

`git pull <remote> <branch>`

其将remote远程仓库的branch分支拉取到本地，然后将其合并到本地当前分支。

`git pull <remote> <rbranch>:<lbranch>`：将remote远程仓库的rbranch分支拉取到本地，然后将其合并到本地lbranch分支

##### 重置

基本命令为git reset，其作用是将当前分支指针（HEAD指针）重置为指定状态

`git reset [<commit>] [--] <paths>...`

将暂存区域中指定路径的文件重置为指定commit（不指定则默认为HEAD）时的状态，但不会改变工作目录及当前分支，其相当于git add <paths>的反向操作。该命令执行后，自从commit以来指定文件的所有改动都显示在Changes not staged for commit中，而这些改动的反向改动会显示在Changes to be committed中。

`git reset (--soft|--mixed|--hard) [<commit>]`

