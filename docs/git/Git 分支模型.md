# Git 分支模型

目前主流的分支模型包括 Git Flow, Github Flow, Gitlab Flow

[一文弄懂 Gitflow、Github flow、Gitlab flow 的工作流](https://cloud.tencent.com/developer/article/1646937)

## Git Flow

比较复杂的分支模型，适用于比较长期的交付以及多版本的支持服务。

不是很适合现在 敏捷开发、持续集成 的需求。

[原文](https://nvie.com/posts/a-successful-git-branching-model)

[翻译](https://zhuanlan.zhihu.com/p/36085631)

## Github Flow

非常轻量的分支模型

省流：永远保持 main 分支是可以上生产的，每个新增的功能 从 main 分支 创建一个新的分支，写完代码后通过 PR 请求合并到 main 分支。

[英文教程](https://guides.github.com/introduction/flow/)

[中文教程](https://docs.github.com/cn/get-started/quickstart/github-flow)

[英文原文](https://githubflow.github.io/)

## Gitlab Flow

Git Flow 和 Github Flow 的折衷
