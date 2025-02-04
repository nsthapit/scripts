New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

# pacdoc Protocol for Word
New-Item -Path "HKCR:\pacedge" -Force
New-ItemProperty -Path "HKCR:\pacedge" -Name "URL Protocol" -Value ""
New-Item -Path "HKCR:\pacedge\shell" -Force
New-Item -Path "HKCR:\pacedge\shell\open" -Force
New-Item -Path "HKCR:\pacedge\shell\open\command" -Force
New-ItemProperty -Path "HKCR:\pacedge\shell\open\command" -Name "(Default)" -Value '"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "%1"' -Force

# pacdoc Protocol for Word
New-Item -Path "HKCR:\pacdoc" -Force
New-ItemProperty -Path "HKCR:\pacdoc" -Name "URL Protocol" -Value ""
New-Item -Path "HKCR:\pacdoc\shell" -Force
New-Item -Path "HKCR:\pacdoc\shell\open" -Force
New-Item -Path "HKCR:\pacdoc\shell\open\command" -Force
New-ItemProperty -Path "HKCR:\pacdoc\shell\open\command" -Name "(Default)" -Value '"C:\Program Files\Microsoft Office\Root\Office16\winword.exe"' -Force


# pacsheets Protocol for Excel
New-Item -Path "HKCR:\pacsheets" -Force
New-ItemProperty -Path "HKCR:\pacsheets" -Name "URL Protocol" -Value ""
New-Item -Path "HKCR:\pacsheets\shell" -Force
New-Item -Path "HKCR:\pacsheets\shell\open" -Force
New-Item -Path "HKCR:\pacsheets\shell\open\command" -Force
New-ItemProperty -Path "HKCR:\pacsheets\shell\open\command" -Name "(Default)" -Value '"C:\Program Files\Microsoft Office\Root\Office16\excel.exe"' -Force

# pacpdf Protocol for Adobe Acrobat
New-Item -Path "HKCR:\pacpdf" -Force
New-ItemProperty -Path "HKCR:\pacpdf" -Name "URL Protocol" -Value ""
New-Item -Path "HKCR:\pacpdf\shell" -Force
New-Item -Path "HKCR:\pacpdf\shell\open" -Force
New-Item -Path "HKCR:\pacpdf\shell\open\command" -Force
New-ItemProperty -Path "HKCR:\pacpdf\shell\open\command" -Name "(Default)" -Value '"C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe"' -Force

# pacpdf Protocol for Adobe Acrobat
New-Item -Path "HKCR:\pacfile" -Force
New-ItemProperty -Path "HKCR:\pacfile" -Name "URL Protocol" -Value ""
New-Item -Path "HKCR:\pacfile\shell" -Force
New-Item -Path "HKCR:\pacfile\shell\open" -Force
New-Item -Path "HKCR:\pacfile\shell\open\command" -Force
New-ItemProperty -Path "HKCR:\pacfile\shell\open\command" -Name "(Default)" -Value '"C:\PAC\filebrowser.exe"' -Force

Write-Host "Custom URLs added"
Write-Host "###########################"
# Define the registry path (Mandatory)
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

# Define the value name and the JSON data to be stored as a string
$valueName = "AutoLaunchProtocolsFromOrigins"

# Define the JSON data that will be written to the registry
$autoLaunchProtocolsFromOrigins = @(
    @{
        "allowed_origins" = @("*")
        "protocol" = "pacdoc"
    },
    @{
        "allowed_origins" = @("*")
        "protocol" = "pacsheets"
    },
    @{
        "allowed_origins" = @("*")
        "protocol" = "pacpdf"
    },
    @{
        "allowed_origins" = @("*")
        "protocol" = "pacedge"
    },
    @{
        "allowed_origins" = @("*")
        "protocol" = "pacnote"
    },
    @{
        "allowed_origins" = @("*")
        "protocol" = "pacfile"
    }
)

# Convert the data to a JSON string
$jsonData = $autoLaunchProtocolsFromOrigins | ConvertTo-Json -Compress

# Ensure the registry key exists
if (-not (Test-Path -Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    Write-Host "Created registry key: $registryPath"
}

# Add the JSON data as a string (REG_SZ) to the registry
try {
    New-ItemProperty -Path $registryPath -Name $valueName -Value $jsonData -PropertyType String -Force
    Write-Host "Successfully added $valueName policy to the registry with value: $jsonData"
    
} catch {
    Write-Host "Error adding data to the registry: $_"
}

Write-Host "###########################"

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


    Write-Host "Path: $registryKeyPath"
    Write-Host "Name: $valueName"
    Write-Host "Value: $valueData"

    Write-Host "Taskbar Registry key added successfully."

Write-Host "###########################"



reg unload "HKU\$userSID" | Out-Null



} else {
    Write-Host "User $usernameToSearch not found."
}
