# Github Wiki 插入图片

以 <https://github.com/117503445/experiment-helper-core/wiki/%E5%AE%9E%E9%AA%8C%E8%AF%AD%E6%B3%95-%E6%96%87%E6%A1%A3-v0.0.1> 为例

在 Github 的 Wiki 编辑上，是无法直接插入图片的。

此时可以 `git clone git@github.com:117503445/experiment-helper-core.wiki.git`

克隆 wiki 对应的 repo

把图片放到 repo 里 `/images/1.png` 再 commit

最后在 wiki 中 就可以使用 `https://raw.githubusercontent.com/wiki/117503445/experiment-helper-core/images/1.png` 引用了
