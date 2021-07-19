@REM https://heipg.cn/tutorial/solving-time-sync-problem.html
@REM need admin
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1
pause
