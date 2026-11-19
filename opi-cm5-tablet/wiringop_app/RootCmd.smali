.class public final Lcom/example/demo/RootCmd;
.super Ljava/lang/Object;
.source "RootCmd.java"

.method static constructor <clinit>()V
    .locals 1
    const-string v0, "WiringOP"
    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    return-void
.end method

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method private static native execNative(Ljava/lang/String;)Ljava/lang/String;
.end method

.method private static native statusNative(Ljava/lang/String;)I
.end method

.method public static execRootCmd(Ljava/lang/String;)[Ljava/lang/String;
    .locals 2
    invoke-static {p0}, Lcom/example/demo/RootCmd;->execNative(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :empty
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z
    move-result v1
    if-nez v1, :empty
    const-string v1, "\n"
    invoke-virtual {v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v0
    return-object v0
    :empty
    const/4 v0, 0x0
    new-array v0, v0, [Ljava/lang/String;
    return-object v0
.end method

.method public static execRootCmdSilent(Ljava/lang/String;)I
    .locals 1
    invoke-static {p0}, Lcom/example/demo/RootCmd;->statusNative(Ljava/lang/String;)I
    move-result v0
    return v0
.end method
