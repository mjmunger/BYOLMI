FOR /F "USEBACKQ" %%A IN (`REG QUERY HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318} /K /F "*"`) DO (REG QUERY %%A /V DriverDesc | (FIND "TAP-Win" && REG ADD %%A /V *NdisDeviceType /T REG_DWORD /D 1 /F))
netsh interface set interface name="VPN" admin=disabled
netsh interface set interface name="VPN" admin=enabled