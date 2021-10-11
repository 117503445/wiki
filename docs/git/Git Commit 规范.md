# Git Commit 规范

## Git Commit Template

[Git Commit Template](https://plugins.jetbrains.com/plugin/9861-git-commit-template) 是一个 Jetbrain 的插件，可以快速、标准地生成 Git Commit 记录。

## Commit message格式

```text
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

注意冒号后面有空格。

### type 类型

用于说明 commit 的类别，只允许使用下面 11 个标识。

- feat: feature 新功能 / 功能变动
- fix: 修补bug
- docs: documentation 更新了 文档/注释
- style: 格式调整，比如执行了format、更改了tab显示等
- refactor: 重构，指的是代码结构的调整，比如使用了一些设计模式重新组织了代码，既不是新增功能，也不是修改bug的代码变动
- perf: 对项目或者模块进行了性能优化。比如一些jvm的参数改动，把stringbuffer改为stringbuilder等
- test: 测试代码
- build: 影响编译的一些更改，比如修改 maven 中 pom.xml 规则
- ci: 持续集成方面的更改，比如 Dockerfile / Github Action 的 yml 等
- chore: 构建过程或辅助工具的变动
- revert: 回滚了一些前面的代码

### scope 范围

scope是范围的意思，主要指的是代码的影响面。

scope并没有要求强制，但团队可以按照自己的理解进行设计。通常由技术维度和业务维度两种划分方式。比如按照技术分为：controller、dto、service、dao等。但因为一个功能提交，会涉及到多个scope（都不喜欢非常细粒度的提交），所以按照技术维度分的情况比较少。按照业务模块进行划分，也是比较不错的选择。比如分为user、order等划分，可以很容易看出是影响用户模块还是order模块。如果你实在不知道怎么填，那就留空。

### subject 主题

这个体现的是总结概括能力，没得跑。一句话能够说明主要的提交是什么。subject也是众多git管理工具默认显示的一行。如果你写的标准，那么提交记录看起来就很漂亮很规整。

### body 正文

主要填写详细的改动记录。可以列上1234，但如果你的subject写的非常好，正文可以直接弱化。但如果时间充裕，填写上重要记录的前因后果，需求背景，是一个好的习惯。

### footer 尾部

添加一些额外的hook，比如提交记录之后，自动关闭jira的工单（JIRA和gitlab等是可以联动的）。在比如触发一些文档编译或者其他动作。

这部分自定义行也是比较强的。

### skip CI 跳过持续集成

最后还有一个skip CI选项。一般的ci工具，都可以设置提交代码时自动触发编译。但你可以告诉它忽略本次提交。这可能是因为你提前预判到了一些构建风险，或者就是不想编译。

## Ref

[80%的程序员，不会写commit记录](https://zhuanlan.zhihu.com/p/358003490)
