$get_env=$args[0]
$get_env1=$args[1]

# Define the folder path and file name
$folderPath = "C:\PAC\PAC_Browser"
$filebrowserpath = "C:\PAC\"

# Create the folder if it doesn't exist
if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
}

#clean out old files except the config file
Get-ChildItem -Path  $folderPath -Recurse -exclude "Clbc.PacPortal.Browser.dll.config" | Remove-Item -force -recurse

#clean out old files except the config file
# Get-ChildItem -Path  $folderPath -Recurse -exclude "Clbc.PacPortal.Monitor.dll.config" | Remove-Item -force -recurse

# Define the URL and the destination path
    # $url= "https://ccpacadminscripts.blob.core.windows.net/pacautomationfiles/Portal_browser_new.zip"
    $url = "https://ccpacadminscripts.blob.core.windows.net/pacautomationfiles/PAC_browser.zip"
    $filebrowser= "https://ccpacadminscripts.blob.core.windows.net/pacautomationfiles/FileBrowser.zip"
    $destinationPath = "$folderPath\browser-$get_env.zip"
    $destinationPath1 = "$folderPath\filebrowser.zip"

    
# Define the new URL based on environment
switch ($get_env) {
    "dev" { $newUrl = "https://cc-dev-pacman-alpha.azurewebsites.net/api/" }
    "test" { $newUrl = "https://cc-dev-pacman-beta.azurewebsites.net/api/" }
    default { $newUrl = "https://j2c-dev2-webapp-win-site.azurewebsites.net/api/" }
}

# # Download the file
Invoke-WebRequest -Uri $url -OutFile $destinationPath
Invoke-WebRequest -Uri $filebrowser -OutFile $destinationPath1

Expand-Archive $destinationPath -DestinationPath $folderPath -Force
Expand-Archive $destinationPath1 -DestinationPath $filebrowserpath -Force


$browserConfigPath = "$folderPath\Clbc.PacPortal.Browser.dll.config"

# Load the XML file
[xml]$XmlContent = Get-Content $browserConfigPath

# Update values
$XmlContent.configuration.appSettings.add | Where-Object { $_.key -eq "PacPortalApi" } | ForEach-Object { $_.value = "$newUrl" }
$XmlContent.configuration.appSettings.add | Where-Object { $_.key -eq "Version" } | ForEach-Object { $_.value = "$get_env1" }

# Save the updated XML file
$XmlContent.Save($browserConfigPath)

Write-Host "Config file updated successfully!"

Remove-Item -force $destinationPath
Remove-Item -force $destinationPath1


# Define shortcut details
$Shortcuts = @(
    @{
        Name = "Launch Page.lnk"
        TargetPath = "C:\PAC\PAC_Browser\Clbc.PacPortal.Browser.exe"
        IconLocation = "C:\PAC\PAC_Browser\Clbc.PacPortal.Browser.exe"
    },
    @{
        Name = "File Explorer.lnk"
        TargetPath = "P:\"
        IconLocation = "C:\Windows\System32\shell32.dll,3"
    }
)

# Define shortcut locations
$ShortcutLocations = @(
    "C:\users\user\Desktop\$ShortcutName",        # Shortcut on Desktop
    "$env:USERPROFILE\Desktop\$ShortcutName"  # Shortcut in Start Menu
)

# Create shortcuts
$WScriptShell = New-Object -ComObject WScript.Shell

foreach ($shortcut in $Shortcuts) {
    foreach ($location in $ShortcutLocations) {
        $ShortcutPath = "$location\$($shortcut.Name)"
        $ShortcutObject = $WScriptShell.CreateShortcut($ShortcutPath)
        $ShortcutObject.TargetPath = $shortcut.TargetPath
        $ShortcutObject.IconLocation = $shortcut.IconLocation
        $ShortcutObject.Save()
        
        Write-Host "Shortcut created: $ShortcutPath"
    }
}

Write-Host "All shortcuts created successfully!"