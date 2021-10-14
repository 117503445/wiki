# go 升级所有 modules

## 方法1

`go get -u && go mod tidy`

ref <https://stackoverflow.com/questions/67201708/go-update-all-modules>

## 方法2

删掉 go.mod 和 go.sum

打开 goland，点击自动生成依赖
