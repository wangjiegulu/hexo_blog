---
title: NDK配置
tags: [android, ndk, jni]
date: 2017-04-11 12:09:00
hidden: true
---

# NDK 配置

Android SDK中下载`NDK`, `LLDB`

## Android.mk 和 Application.mk

简单来说

- Android.mk 用来描述需要生成哪些模块的 .so 文件
- Application.mk 用来描述如何生成 .so 文件，生成静态库还是动态库

<!-- more -->

这里给出示例文件

Android.mk

```
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := gaussianBlur
LOCAL_SRC_FILES := blur.cpp
LOCAL_LDLIBS := -llog
include $(BUILD_SHARED_LIBRARY)

```
- 宏函数 my-dir 是由编译系统提供的，会返回当前目录的路径（当前目录指的是包含 Android.mk 的目录）

- CLEAR_VARS 这个变量也是由编译系统提供的，会清除很多 LOCAL_XXX 变量

- 以上两行命令基本上是固定的，不需要去动

- LOCAL_MODULE 指定模块名称，会自动生成相应的 libgaussianBlur.so 文件

- LOCAL_SRC_FILES 指定这个模块要编译的 C++ 文件

- LOCAL_LDLIBS 指定这个模块里会用到哪些原生 API, 详见 Android NDK Native APIs

- BUILD_SHARED_LIBRARY 根据你之前定义的 LOCAL_XXX 变量，决定要编译啥，如何去编译，这行命令一般也不需要动，固定的

Application.mk

```
APP_STL := gnustl_static
```
- APP_STL 指定使用哪些 C++ 运行时, 详见 C++ Library Support

Android.mk 和 Application.mk 都放在 jni 目录下,，
项目文件结构如下

```
|____app
| |____src
| | |____main
| | | |____jni
| | | | |____Android.mk
| | | | |____Application.mk
| | | | |____blur.cpp

```

### 如何使用 C++ 代码?

前面已经给出了 Android.mk 和 Application.mk 的示例，下面在 build.gradle 里配置 externalNativeBuild 就可以自动编译 C++ 代码了

示例内容如下

```groovy
defaultConfig {
	applicationId "com.example.app"
	minSdkVersion 16
	targetSdkVersion 24
	versionCode 102
	versionName "0.2"
	externalNativeBuild {
		ndkBuild {
			arguments "NDK_APPLICATION_MK:=src/main/jni/Application.mk"
			cFlags "-DTEST_C_FLAG1", "-DTEST_C_FLAG2"
			cppFlags "-DTEST_CPP_FLAG2", "-DTEST_CPP_FLAG2"
			abiFilters "armeabi-v7a", "armeabi"
		}
	}
}
externalNativeBuild {
	ndkBuild {
		path "src/main/jni/Android.mk"
	}
}
```

- path 用来指定 Android.mk 的路径
- arguments 用来指定 Application.mk 的路径
- abiFilters 用来指定生成哪些平台的 .so 文件
- cFlags 和 cppFlags 是用来设置环境变量的, 一般不需要动，和示例一样就好，
好了，现在运行项目，就可以将 blur.cpp 自动编译为 libgaussianBlur.so 文件了

### 手动生成 .so 文件

如果能直接引用生成好的 .so 文件，可以避免重复编译 .so 文件，从而加快应用 build 速度

下面是手动生成 .so 文件的步骤

#### 进入 main 目录

```
cd app/src/main
```

#### 生成 .so 文件

```
/Users/lee/Library/Android/sdk/ndk-bundle/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=./jni/Application.mk NDK_LIBS_OUT=./jniLibs
```

执行这个命令后，会在 app/src/main/jniLibs 目录生成各个平台的 .so 文件
如果需要把 .so 文件共享给其他人，把这些平台下的 .so 文件发给其他人就好了

- NDK_PROJECT_PATH 指定项目路径, 会自动读取这个目录下的 jni/Android.mk 文件
- NDK_APPLICATION_MK 指定 Application.mk 的位置
- NDK_LIBS_OUT 指定将生成的 .so 文件放到哪个目录，默认 Android Studio 会读取 jniLibs 目录下的 .so 文件, 所以我们把 .so 文件生成到这

测试结果: （测试均在 clean 项目后进行）
引用 .so 文件前平均耗时 1m 27s
引用 .so 文件后平均耗时 47s
我们可以看到 build 速度快了将近一倍

调试 NDK
让 NDK_LOG 变量为1，就可以打印日志信息

ndk-build -e NDK_LOG=1

## 参考

http://jk2k.com/2016/09/how-to-use-ndk-and-generate-so-file-in-android-studio/

