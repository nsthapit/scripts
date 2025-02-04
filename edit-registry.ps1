# Define the folder path and file name
$folderPath = "C:\PAC\Registry"
# Define the URL and the destination path
# $url= "https://ccpacadminscripts.blob.core.windows.net/pacautomationfiles/PAC_regfiles.zip"
$url = "https://ccpacadminscripts.blob.core.windows.net/pacautomationfiles/PAC_registry.zip"

$destinationPath = "$folderPath\reg.zip"

# Create the folder if it doesn't exist
if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
}

# # Download the file
Invoke-WebRequest -Uri $url -OutFile $destinationPath

Expand-Archive $destinationPath -DestinationPath $folderPath -Force

$SID1 = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value
$regPath = "Registry::HKEY_USERS\$SID1\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cRecentFolders"
 $SID = "user"
# Remove old entries
Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue

# Recreate entries
New-Item -Path "$regPath\c1" -Force
Set-ItemProperty -Path "$regPath\c1" -Name "sDI" -Type Binary -Value ([byte[]](0x2f,0x50,0x2f,0x00))
Set-ItemProperty -Path "$regPath\c1" -Name "tDIText" -Type String -Value "/P/"
Set-ItemProperty -Path "$regPath\c1" -Name "tDisplayText" -Type String -Value "Downloads (P:)"
Set-ItemProperty -Path "$regPath\c1" -Name "aFS" -Type String -Value "DOS"

Write-Host "Adobe Registry modifications completed."

#combine taskbar icons 
# Define variables
$usernameToSearch = "PAC User"
$profileDirectory = "C:\Users\user"
$ntuserPath = "$profileDirectory\ntuser.dat"
$registryKeyPath = "HKU\$userSID\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$valueName = "TaskbarGlomLevel"
$valueData = 2

# Retrieve the specific local user account
$localUser = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True' AND Name='$usernameToSearch'"

if ($localUser) {
    # Retrieve the SID of the user
    $userSID = $localUser.SID
    Write-Host "User SID: $userSID"

    # Load the user's registry hive
    reg load "HKU\$userSID" $ntuserPath | Out-Null

#     # Ensure the HKU registry drive exists
    if (-not (Get-PSDrive -Name HKU -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
    }

    # # Set the registry value
    # New-Item -Path $registryKeyPath -Force | Out-Null
    # Set-ItemProperty -Path $registryKeyPath -Name $valueName -Value $valueData

    # Ensure the registry key path exists and set the value using reg.exe
    $command = "reg add ""HKU\$userSID\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"" /v $valueName /t REG_DWORD /d $valueData /f"
    cmd.exe /c $command | Out-Null

    Write-Host "Taskbar combine Registry key added successfully."

Write-Host "Path: $registryKeyPath"
Write-Host "Name: $valueName"
Write-Host "Value: $valueData"

reg unload "HKU\$userSID" | Out-Null

} else {
    Write-Host "User $usernameToSearch not found."
}

Copy-Item -Path "$folderPath\Preferences", "$folderPath\Secure Preferences"  -Destination "C:\Users\$SID\AppData\Local\Microsoft\Edge\User Data\Default" -Recurse -Force

 Write-Host "Importing: Edge configuration complete"

#Remove-Item -Path $folderPath -Recurse -Force

 # Import the modified .reg fi
# Load the registry hive for the current user
$regHivePath = "C:\Users\$SID\NTUSER.DAT"
reg load "HKU\$SID" "$regHivePath"

# Run additional .reg files and replace %SID% with the actual SID
$regFiles = @("$folderPath\taskbandicons.reg", "$folderPath\usbautoplay.reg","$folderPath\wallpaper.reg") # Update with actual file paths

foreach ($file in $regFiles) {
    if (Test-Path $file) {
        Write-Host "Importing: $file"
        
        # Read the content of the .reg file and replace %SID% with the actual SID
        $regContent = Get-Content $file -Raw
        $regContent = $regContent -replace '%SID%', $SID

        # Write the updated content to a temporary file
        $tempRegFile = [System.IO.Path]::GetTempFileName()
        Set-Content -Path $tempRegFile -Value $regContent

        # Import the modified .reg file
        Start-Process regedit.exe -ArgumentList "/s `"$tempRegFile`"" -Wait -NoNewWindow

        # Clean up the temporary file
        Remove-Item -Path $tempRegFile -Force
    } else {
        Write-Host "File not found: $file"
    }
}

reg unload "HKU\$SID"
# Remove-Item -Path $folderPath -Recurse -Force

Remove-Item -Path $folderPath -Recurse -Force

    $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    $Name         = 'AutoAdminLogon'
    $Value        = '1'

    # $Name1         = 'ForceAutoLogon'
    # $Value1        = '0'

    $Name2         = 'DefaultUserName'
    $Value2        = 'PAC User'

    $Name3         = 'DefaultPassword'
    $Value3        = 'clbc'
Write-Output "Regsitry keys modified and restarting."


If (-NOT (Test-Path $RegistryPath)) {
New-Item -Path $RegistryPath -Force | Out-Null
}
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force
# New-ItemProperty -Path $RegistryPath -Name $Name1 -Value $Value1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name $Name2 -Value $Value2 -PropertyType String -Force
New-ItemProperty -Path $RegistryPath -Name $Name3 -Value $Value3 -PropertyType String -Force
# Define the user profile and the registry path

# end set autologin for pac user ##
 
