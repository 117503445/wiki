<!--
 * @Author: HaoTian Qi
 * @Date: 2021-11-27 20:20:47
 * @Description: 
 * @LastEditTime: 2021-11-27 20:20:48
 * @LastEditors: HaoTian Qi
-->

# Bat 请求管理员权限

ref <https://www.zhihu.com/question/34541107/answer/1000449825>

`@echo off&(cd/d "%~dp0")&(cacls "%SystemDrive%\System Volume Information" >nul 2>&1)||(start "" mshta vbscript:CreateObject^("Shell.Application"^).ShellExecute^("%~snx0"," %*","","runas",1^)^(window.close^)&exit /b)`
