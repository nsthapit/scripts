$get_env=$args[0]
$get_env1=$args[1]

# Define the folder path and name for registry edits
$folderPath = "C:\PAC\PAC_Shell\"
# $profileuser = "user"
# $profile_path = "c:\users\$profileuser\ntuser.dat"

# Create the folder if it doesn't exist
if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
}

#clean out old files except the config file
Get-ChildItem -Path  $folderPath -Recurse | Remove-Item -force -recurse

    $url = "https://ccpacadminscripts.blob.core.windows.net/pacautomationfiles/PAC_shell.zip"
    $destinationPath = "$folderPath\Shell-$get_env.zip"

# # Download the file
Invoke-WebRequest -Uri $url -OutFile $destinationPath

#extract downloaded zip file
Expand-Archive $destinationPath -DestinationPath $folderPath -Force

## start create appsetttings file for console app ##

# Define the new URL based on environment
switch ($get_env) {
    "dev" { $newUrl = "https://cc-dev-pacman-alpha.azurewebsites.net/api/" }
    "test" { $newUrl = "https://cc-dev-pacman-beta.azurewebsites.net/api/" }
    default { $newUrl = "https://j2c-dev2-webapp-win-site.azurewebsites.net/api/" }
}
# Specify the path to the JSON file
$jsonFilePath = "$folderPath\appsettings.json"

# Read the JSON content
$JsonContent = Get-Content $jsonFilePath -Raw | ConvertFrom-Json

# Update the values
$JsonContent.PacPortalApi.Url = "$newUrl"
$JsonContent.Version = "$get_env1"

# Convert back to JSON with proper formatting
$JsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath

# Define the shortcut details
$Shortcuts = @(
    @{
        Name       = "StartShell.lnk"
        TargetPath = "C:\PAC\PAC_Shell\Clbc.PacPortal.Shell.exe"
        Arguments  = "/logon"
        IconLocation = "C:\PAC\PAC_Browser\Clbc.PacPortal.Browser.exe"
    }
)

# Create the WScript.Shell COM object for shortcut creation
$WScriptShell = New-Object -ComObject WScript.Shell

foreach ($shortcut in $Shortcuts) {
    # Construct the full path for the shortcut file
    $ShortcutPath = Join-Path -Path $folderPath -ChildPath $shortcut.Name

    # Create the shortcut object
    $ShortcutObject = $WScriptShell.CreateShortcut($ShortcutPath)
    
    # Set the target executable, command-line arguments, and icon location
    $ShortcutObject.TargetPath = $shortcut.TargetPath
    $ShortcutObject.Arguments = $shortcut.Arguments
    $ShortcutObject.IconLocation = $shortcut.IconLocation
    
    # Save the shortcut
    $ShortcutObject.Save()
    
    Write-Host "Shortcut created: $ShortcutPath"
}

Write-Host "All shortcuts created successfully!"


$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$propertyName = "StartShell"
$propertyValue = '"C:\PAC\PAC_Shell\Clbc.PacPortal.Shell.exe" "/logon"'

New-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue -PropertyType String -Force

#remove installer artifacts
Remove-Item -force $destinationPath
