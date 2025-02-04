$get_env=$args[0]
$get_env1=$args[1]

# Define the folder path and file name
$folderPath = "C:\PAC\PAC_Monitor"

# Create the folder if it doesn't exist
if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
}

#clean out old files except the config file
Get-ChildItem -Path  $folderPath -Recurse -exclude "Clbc.PacPortal.Monitor.dll.config" | Remove-Item -force -recurse

# Define the URL and the destination path
     $url= "https://ccpacadminscripts.blob.core.windows.net/pacautomationfiles/PAC_monitor.zip"
    
    $destinationPath = "$folderPath\monitor-$get_env.zip"

# Define the new URL based on environment
switch ($get_env) {
    "dev" { $newUrl = "https://cc-dev-pacman-alpha.azurewebsites.net/api/" }
    "test" { $newUrl = "https://cc-dev-pacman-beta.azurewebsites.net/api/" }
    default { $newUrl = "https://j2c-dev2-webapp-win-site.azurewebsites.net/api/" }
}

# # Download the file
Invoke-WebRequest -Uri $url -OutFile $destinationPath

#Unzip archive
Expand-Archive $destinationPath -DestinationPath $folderPath -Force



$monitorConfigPath = "$folderPath\Clbc.PacPortal.Monitor.dll.config"

# Load the XML file
[xml]$XmlContent = Get-Content $monitorConfigPath

# Update values
$XmlContent.configuration.appSettings.add | Where-Object { $_.key -eq "PacPortalApi" } | ForEach-Object { $_.value = "$newUrl" }
$XmlContent.configuration.appSettings.add | Where-Object { $_.key -eq "Version" } | ForEach-Object { $_.value = "$get_env1" }

# Save the updated XML file
$XmlContent.Save($monitorConfigPath)

Write-Host "Config file updated successfully!"

#delete zip archive
Remove-Item -force $destinationPath