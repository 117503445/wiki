# Goland 引用搜索过滤单测

在查找 Golang 变量的引用时，经常会查找出单测文件中的引用，而这些引用对分析程序逻辑没什么用。在 Goland 中可以通过下述方法进行过滤。

Settings - Appearance & Behavior - Scopes

添加一个 Scope, Pattern 为 `!file:*_test.go`
