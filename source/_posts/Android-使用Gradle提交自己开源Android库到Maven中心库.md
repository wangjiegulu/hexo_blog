---
title: '[Android]使用Gradle提交自己开源Android库到Maven中心库'
tags: [android, maven, open source, gradle, uploadArchive]
date: 2015-04-02 19:38:00
---

此文针对开源爱好者。

如果你想让别人使用你的Android开源库，第一种方法是，提供你的Github地址，让别人clone一份，然后让别人import到他的项目中。另一种更简单的方式就是直接让别人在他的Gradle中添加你的库依赖，如下：

<div class="cnblogs_code">
<pre>compile 'com.github.wangjiegulu:AndroidBucket:1.0.1'</pre>
</div>

如果想使用第二种方式，你需要将你的项目提交到公共的中心库。

这里介绍使用sonatype来把你的开源库（snapshot或release）提交到Maven的中心库。**
**

1\. 首先，在[https://issues.sonatype.org](https://issues.sonatype.org)中注册账号。

2\. 然后在[https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&amp;pid=10134](https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&amp;pid=10134)中新建一个&ldquo;Project ticket&rdquo;。

－Summary：填写项目名称<span class="aui-icon icon-required">
</span>

－Description：填写描述

－Group Id：域名反转，如果没有域名，就直接使用github反转（如github.com/wangjiegulu --&gt; com.github.wangjiegulu），具体看[http://central.sonatype.org/pages/choosing-your-coordinates.html](http://central.sonatype.org/pages/choosing-your-coordinates.html)<span class="aui-icon icon-required">
</span>

－Project URL：项目的url，可以是项目的github地址。如[https://github.com/wangjiegulu/AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)

－SCM url：版本控制的uri，如[https://github.com/wangjiegulu/AndroidBucket.git](https://github.com/wangjiegulu/AndroidBucket.git)

3\. 创建完毕后就等待状态变为&ldquo;resolved&rdquo;，然后你就可以使用Gradle上传项目了。

4\. 上传前需要进行GPG签名，所以先去下载GPG（[https://www.gnupg.org/download/index.html](https://www.gnupg.org/download/index.html)），然后打开

![](http://images.cnitblog.com/blog2015/378300/201504/021841366545243.png)

新建一个Keychain，完成后右键&ldquo;Send Public Key to Key Server&rdquo;，这样就能把你的public key发送到服务端。

5\. 然后我们再打包项目的aar文件，intellij idea和android studio使用gradle构建后，会在build中自动生成该文件，直接把他拷出来即可。

6\. 然后新建build.gradle来进行我们的上传操作，大概内容如下：

<div class="cnblogs_code">
<pre><span style="color: #008000;">//</span><span style="color: #008000;"> *********************************************************************</span><span style="color: #000000;">
apply plugin: </span>'maven'<span style="color: #000000;">
apply plugin: </span>'signing' <span style="color: #008000;">//</span><span style="color: #008000;">使用signing plugin做数字签名

</span><span style="color: #008000;">//</span><span style="color: #008000;">定义GroupID和Version，ArtefactID会自动使用Project名</span>
group = 'com.github.wangjiegulu'<span style="color: #000000;">
version </span>= '1.0.1'
<span style="color: #000000;">
repositories {
    mavenCentral();
}

artifacts {
    archives file(</span>'AndroidBucket.aar'<span style="color: #000000;">)
}
signing {
    sign configurations.archives
}</span>
<span style="color: #000000;">
uploadArchives {
    repositories {
        mavenDeployer {
            </span><span style="color: #008000;">//</span><span style="color: #008000;">为Pom文件做数字签名</span>
            beforeDeployment { MavenDeployment deployment -&gt;<span style="color: #000000;"> signing.signPom(deployment) }

            </span><span style="color: #008000;">//</span><span style="color: #008000;">指定项目部署到的中央库地址，UserName和Password就是Part 1中注册的账号。</span>
            repository(url: "https://oss.sonatype.org/service/local/staging/deploy/maven2/"<span style="color: #000000;">) {
                authentication(userName: ossrhUsername, password: ossrhPassword)
            }
            snapshotRepository(url: </span>"https://oss.sonatype.org/content/repositories/snapshots/"<span style="color: #000000;">) {
                authentication(userName: ossrhUsername, password: ossrhPassword)
            }

            </span><span style="color: #008000;">//</span><span style="color: #008000;">构造项目的Pom文件，参见Part 2中Pom文件的规范，不要遗漏必填项</span>
<span style="color: #000000;">            pom.project {
                name project.name
                packaging </span>'aar'<span style="color: #000000;">
                description </span>'Android开发常用整理'<span style="color: #000000;">
                url </span>'https://github.com/wangjiegulu/AndroidBucket'<span style="color: #000000;">

                scm {
                    url </span>'scm:git@github.com:wangjiegulu/AndroidBucket.git'<span style="color: #000000;">
                    connection </span>'scm:git@github.com:wangjiegulu/AndroidBucket.git'<span style="color: #000000;">
                    developerConnection </span>'git@github.com:wangjiegulu/AndroidBucket.git'<span style="color: #000000;">
                }

                licenses {
                    license {
                        name </span>'The Apache Software License, Version 2.0'<span style="color: #000000;">
                        url </span>'http://www.apache.org/licenses/LICENSE-2.0.txt'<span style="color: #000000;">
                        distribution </span>'wangjie'<span style="color: #000000;">
                    }
                }

                developers {
                    developer {
                        id </span>'wangjie'<span style="color: #000000;">
                        name </span>'Wagn Jie'<span style="color: #000000;">
                        email </span>'tiantian.china.2@gmail.com'<span style="color: #000000;">
                    }
                }
            }
        }
    }
}</span></pre>
</div>

archives file('AndroidBucket.aar') 表示指定上传的aar文件。

<div class="cnblogs_code">
<pre><span style="color: #000000;">signing {
    sign configurations.archives
}</span></pre>
</div>

表示对内容进行gpg签名，既然需要签名，那需要在gradle.properites中配置key的信息，还有上传的账号密码：

<div class="cnblogs_code">
<pre>signing.keyId=<span style="color: #000000;">XXXXXXXXX
signing.password</span>=XXXXXXXXX<span style="color: #000000;">
signing.secretKeyRingFile</span>=/Users/wangjie/.gnupg/secring.gpg</pre>

&nbsp; ossrhUsername=oss.sonatype.org或者issues.sonatype.org的账号（同一个）
&nbsp; ossrhPassword=oss.sonatype.org或者issues.sonatype.org的密码（同一个）

</div>

所有配置完毕后执行gradle&nbsp;uploadArchives进行上传操作。

7\. 登录[https://oss.sonatype.org](https://oss.sonatype.org)，点击左边的&ldquo;Staging Repositories&rdquo;，然后刚刚上传的项目名称为com.github.wangjiegulu去掉点-数字

选中后点击&ldquo;Close&rdquo;，如果成功，则再点击&ldquo;Release&rdquo;按钮发布。

然后再等待2小时，就可以在Maven中心库中搜索到了。

&nbsp;

注意：以后如果需要再上传其它项目的时候，直接从第4步开始即可，因为你的groupId已经申请过了，以后新的artifacts可以直接部署到这个groupId中。

&nbsp;

参考：[http://central.sonatype.org/pages/ossrh-guide.html](http://central.sonatype.org/pages/ossrh-guide.html)

