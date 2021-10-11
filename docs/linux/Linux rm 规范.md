# Linux rm 规范

rm 指令相当于 Windows 的强制删除，基本没有后悔药，所以需要谨慎的使用。

## 使用 trash-cli

<https://github.com/andreafrancia/trash-cli>

使用移动代替删除，起到回收站的作用。

```sh
pip install trash-cli
trash 1.txt # delete file
trash 2/ # delete dir
trash-list
trash-restore
trash-empty 7 # Remove the files that have been deleted more than 7 days ago:
```

## rm 规范

- 被删除文件使用绝对路径，避免意料之外的 pwd 导致删除了其他目录。
- 单次删除，使用 -i 参数，逐一确认要删除的文件。
- 重复的删除任务，将删除指令编写为 sh 脚本，避免多次重复时出现意外。
