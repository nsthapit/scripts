$get_env=$args[0]

write-host " Install .NET Runtime $get_env" -ForegroundColor Green
write-host " don't close this window, it will be close automatically" -ForegroundColor red
write-host "_________________________________________________________"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
#$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
#    if ($ResolveWingetPath){
#           $WingetPath = $ResolveWingetPath[-1].Path
#    }

$config
# cd $wingetpathexit
cmd.exe /c "winget.exe install Microsoft.DotNet.DesktopRuntime.$get_env --silent --accept-package-agreements --accept-source-agreements --force"

write-host " Install .NET Runtime $get_env Complete" -ForegroundColor Green
exit
