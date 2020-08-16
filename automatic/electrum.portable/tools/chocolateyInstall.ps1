﻿$ErrorActionPreference = 'Stop'
$packageName = '{{PackageName}}'
$url = 'https://download.electrum.org/4.0.2/electrum-4.0.2-portable.exe'
$checksum = '2e04699258027df8dd66335ae58567f81b45d01f5d2d2ab69da9ae037f39d1d2'
$checksumType = 'sha256'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$installFile = Join-Path $toolsDir "electrum.exe"
try {
  Get-ChocolateyWebFile -PackageName "$packageName" `
                        -FileFullPath "$installFile" `
                        -Url "$url" `
                        -Checksum "$checksum" `
                        -ChecksumType "$checksumType"
  # create an empty sidecar metadata file for closed-source shimgen.exe to prevent blank black window
  Set-Content -Path ("$installFile.gui") `
              -Value $null
} catch {
  throw $_.Exception
}
