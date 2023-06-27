# VS Code 查看上 or 下一个文件

做项目的时候有需求，希望能快速浏览 VSCode Remote 服务器中的图片。但是 VSCode 浏览图片必须先把焦点移动到文件列表，再鼠标点击下一个文件；或者按一下 down 再按 space。这样操作起来很麻烦。

本来打算写一个 VSCode Extension 来实现这个功能，后来发现只用添加一个键盘快捷方式就行了。

将以下内容粘贴到 `keybindings.json`

```json
[
  {
    "key": "pageup",
    "command": "runCommands",
    "args": {
      "commands": [
        "workbench.files.action.focusFilesExplorer",
        "list.focusUp",
        "filesExplorer.openFilePreserveFocus"
      ]
    }
  },
  {
    "key": "pagedown",
    "command": "runCommands",
    "args": {
      "commands": [
        "workbench.files.action.focusFilesExplorer",
        "list.focusDown",
        "filesExplorer.openFilePreserveFocus"
      ]
    }
  }
]
```
