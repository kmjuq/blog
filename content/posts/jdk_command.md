---
title: "jdk_command"
date: 2023-02-25T22:50:52+08:00
draft: true
---

## Java 命令行工具
- jar 

    create an archive for classes and resources, and manipulate or restore individual classes or resources from an archive
- jarsigner

    sign and verify Java Archive (JAR) files
- java 
    
    launch a Java application
- javac 

    read Java class and interface definitions and compile them into bytecode and class files
- javadoc 

    generate HTML pages of API documentation from Java source files
- javap 

    disassemble one or more class files
- jcmd 

    send diagnostic command requests to a running Java Virtual Machine (JVM)
- jconsole 

    图形化工具,主要看内存使用和线程堆栈信息.
- jdb 

    Debugger调试工具
- jdeprscan 

    `jdeprscan -h` 查看帮助,命令功能为扫描程序是否使用了过时的 API.
- jdeps 

    launch the Java class dependency analyzer
- jfr 

    parse and print Flight Recorder files
- jhsdb 

    attach to a Java process or launch a postmortem debugger to analyze the content of a core dump from a crashed Java Virtual Machine (JVM)
- jinfo 

    generate Java configuration information for a specified Java process
- jlink 

    assemble and optimize a set of modules and their dependencies into a custom runtime image
- jmap 

    print details of a specified process
- jmod 

    create JMOD files and list the content of existing JMOD files
- jpackage 

    package a self-contained Java application
- jps 

    list the instrumented JVMs on the target system
- jrunscript 

    run a command-line script shell that supports interactive and batch modes
- jshell 

    交互式解释器.类似浏览器控制台,可以实时执行代码.
- jstack 

    print Java stack traces of Java threads for a specified Java process
- jstat 
    
    monitor JVM statistics
- jstatd 

    monitor the creation and termination of instrumented Java HotSpot VMs
- jwebserver 

    可以快速搭建局域网文件服务传递文件
- keytool 

    manage a keystore (database) of cryptographic keys, X.509 certificate chains, and trusted certificates
- rmiregistry 

    create and start a remote object registry on the specified port on the current host
- serialver 

    return the `serialVersionUID` for one or more classes in a form suitable for copying into an evolving class

### jstat
查看 jvm 虚拟机的内存年代分配和垃圾回收情况.通过 `jstat -options` 命令可以查看能够查看的报表种类;
常用命令为 `jstat -gcutil 9847 1000`
### jcmd
jcmd 是监控门面集合, jps,jstack,jmap,jinfo 等命令的功能都有.通过 jcmd 获取 jvm pid 后,可以通过此命令 `jcmd pid help` 查看帮助,也可以通过 `jcmd 0 help` 查看所有.

