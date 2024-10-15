# 双系统时修改 Windows 为 UTF 时间

```powershell
# with admin
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1
```

ref <https://sspai.com/post/55983>