# cherry pick

在 Hotfix 、仓库迁移 等场景中，往往需要在其他分支重放某次 commit 的更改，就需要使用 cherry pick。

对于单个项目内的 cherry pick, 只需要切换到新的分支，然后 `git cherry-pick <commit-id>` 就行了。

对于不同项目的 cherry pick, 假设 A 仓库 develop 分支上有一个 commit 想在 B 仓库重放，可以

```sh
git remote add A git@.../A.git # 将 A 的仓库地址添加到 B 的 Remote
git fetch A develop:cherry-pick-branch # 将 A 仓库的 develop 分支拉取到 B 的 cherry-pick-branch
git cherry-pick <commit-id> # 现在 B 仓库就可以顺利 cherry-pick 了
```

## ref

<https://www.jianshu.com/p/275c298dc6a2>
