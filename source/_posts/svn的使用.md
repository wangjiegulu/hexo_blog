---
title: svn的使用
tags: [svn]
date: 2013-02-27 09:58:00
---

**转载请注明：[http://www.cnblogs.com/tiantianbyconan/archive/2013/02/27/2934628.html](http://www.cnblogs.com/tiantianbyconan/archive/2013/02/27/2934628.html)**

新建如下结构的文件夹：
sv_workspace
	|--svn_repos
	|--svn_imports
	|--svn_checkouts

svn_repos：中创建各种版本库（一个项目使用一个版本库）
svn_imports：导入最初始的项目
svn_checkouts：从版本库中检出的项目，真正的工作目录

1.先在svn_repos中新建版本库，如：infolife_repo，右键在此创建版本库。
2.在svn_imports文件夹中新建对应的文件夹检出，如：infolife_import。
右键检出，此时该文件夹会生成branches、tags、trunk和一个.svn的文件夹
3。.在eclipse中新建项目后，把项目复制到svn_imports目录的truck目录下，

然后右键导入，url写版本库的truck目录

4.最后在工作目录（svn_checkouts）新建一个目录比如c:\svnclient\rolex

\trunk，然后在trunk上checkout出svn://IP/infolife/trunk上的内容。
或者在使用eclipse的import，检出目录选择svn_checkouts即可

