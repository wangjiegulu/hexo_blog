---
title: 在Ubuntu上安装Hadoop（单机模式）步骤
tags: []
date: 2014-02-17 15:49:00
---

1\. 安装jdk：
sudo apt-get install openjdk-6-jdk

2\. 配置ssh：
安装ssh：
apt-get install openssh-server

为运行hadoop的用户生成一个SSH key：
$ ssh-keygen -t rsa -P ""

让你可以通过新生成的key来登录本地机器：
$ cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

3\. 安装hadoop：
下载hadoop tar.gz包
并解压：
tar -zxvf hadoop-2.2.0.tar.gz

4\. 配置：
- 在~/.bashrc文件中添加：
export HADOOP_HOME=/usr/local/hadoop
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64
export PATH=$PATH:$HADOOP_HOME/bin
在修改完成后保存，重新登录，相应的环境变量就配置好了。

- 配置hadoop-env.sh：
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64

- 配置hdfs-site.xml：
&lt;property&gt;

	&lt;name&gt;hadoop.tmp.dir&lt;/name&gt;

	&lt;value&gt;/app/hadoop/tmp&lt;/value&gt;
	&lt;description&gt;A base for other temporary directories.&lt;/description&gt;

&lt;/property&gt;

&lt;property&gt;
	&lt;name&gt;fs.default.name&lt;/name&gt;

	&lt;value&gt;hdfs://localhost:9000&lt;/value&gt;
	&lt;description&gt;The name of the default file system.  A URI whose
  scheme and 

authority determine the FileSystem implementation.  The
  uri's scheme determines the 

config property (fs.SCHEME.impl) naming
  the FileSystem implementation class.  The uri's 

authority is used to
  determine the host, port, etc. for a filesystem.&lt;/description&gt;
&lt;/property&gt;

- 配置mapred-site.xml：
&lt;property&gt;
  &lt;name&gt;mapred.job.tracker&lt;/name&gt;
  &lt;value&gt;localhost:9001&lt;/value&gt;
  &lt;description&gt;The host and port that the MapReduce job tracker runs
  at.  If "local", then jobs are run in-process as a single map
  and reduce task.
  &lt;/description&gt;
&lt;/property&gt;

- 配置hdfs-site.xml：
&lt;property&gt;

	&lt;name&gt;dfs.replication&lt;/name&gt;

	&lt;value&gt;1&lt;/value&gt;
	&lt;description&gt;Default block replication.
  The actual number of replications can be 

specified when the file is created.
  The default is used if replication is not specified 

in create time.
  &lt;/description&gt;

&lt;/property&gt;

5\. 通过 NameNode 来格式化 HDFS 文件系统
$ /usr/local/hadoop/bin/hadoop namenode -format

6\. 运行hadoop
$ /usr/local/hadoop/sbin/start-all.sh

7\. 检查hadoop的运行状况
- 使用jps来检查hadoop的运行状况：
$ jps

- 使用netstat 命令来检查 hadoop 是否正常运行：
$ sudo netstat -plten | grep java

8\. 停止运行hadoop：
$ /usr/local/hadoop/bins/stop-all.sh