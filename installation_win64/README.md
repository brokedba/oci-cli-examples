## Installation for Windows 10 64bit to avoid Python deprecation warning 
- learn more on my  blog http://www.brokedba.com/2023/04/oci-cli-python-warning-on-windows-10-my.html

## Install command as admin
- From a command terminal 
```
powershell -NoProfile -ExecutionPolicy Bypass -Command "~\install.ps1"
```
- From a Powershell command terminal
```
PS C:\Users\BrokDB> Set-ExecutionPolicy RemoteSigned
PS C:\Users\BrokDB> powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/brokedba/oci-cli-examples/blob/master/installation_win64/install.ps1'))" 
```
 Reference issue in Github: https://github.com/oracle/oci-cli/issues/639 
