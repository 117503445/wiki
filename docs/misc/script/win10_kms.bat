@ECHO OFF&PUSHD %~DP0

setlocal EnableDelayedExpansion&color 3e & cd /d "%~dp0"
title Windows KMS

%1 %2
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :runas","","runas",1)(window.close)&goto :eof
:runas

slmgr.vbs /upk
slmgr.vbs /skms kms.03k.org
slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
slmgr.vbs /ato
slmgr.vbs /xpr