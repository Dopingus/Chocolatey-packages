﻿$packageName   = 'miktex'
$fileType = 'EXE'
$url32 = ''
$url64 = ''
$checksum32 = ''
$checksum64 = ''
$silentArgs = '--unattended --shared'
$scriptPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)

$install32 = Join-Path $scriptPath 'basic-miktex.exe'
$install64 = Join-Path $scriptPath 'basic-miktex-x64.exe'
$filePath = @{32=$install32;64=$install64}[(Get-ProcessorBits)]

# The package installer is very picky about its own file name and silent 
# installation. See for more information:
# https://github.com/AnthonyMastrean/chocolateypackages/issues/143#issuecomment-143379145
# 
# will be fixed when issue is resolved:
# https://github.com/chocolatey/choco/issues/435

Get-ChocolateyWebFile $packageName $filePath $Url $Url64 -Checksum $checksum -ChecksumType 'sha256' -Checksum64 $checksumx64 -ChecksumType64 'sha256'


Install-ChocolateyInstallPackage $packageName $fileType $silentArgs $filePath

Remove-Item $filePath -Force

#add AutoInstall=1

$uninstallPath = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, 
HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
    Get-ItemProperty |
        Where-Object {$_.DisplayName -match "miktex" } |
            Select-Object -Property DisplayName, UninstallString
			
$temp=($uninstallPath.uninstallstring -split "`" `"")[0]
$installLocation = ($temp -Split("internal"))[0]
$installLocation = ($installLocation -Split("`""))[1]
$installLocation = $installLocation -replace '/','\'
$autoInstall = Join-Path $installLocation "initexmf.exe"
& $autoInstall --set-config-value=[MPM]AutoInstall=1
