$ErrorActionPreference = 'Stop'
import-module au

$releases = 'https://node.minepi.com/node/'

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]url\s*=\s*)('.*')"      		= "`$1'$($Latest.URL32)'"
			"(^[$]checksum\s*=\s*)('.*')" 		= "`$1'$($Latest.Checksum32)'"
			"(^[$]checksumType\s*=\s*)('.*')" 	= "`$1'$($Latest.ChecksumType32)'"
		}
	}
}

function global:au_GetLatest {
	$url = ((Invoke-WebRequest -Uri $releases -UseBasicParsing).Links | Where-Object {$_ -match ".exe"}).href
	[version]$version=$link.replace("%20"," ").Split(" ")[-1].replace('.exe','')

	$Latest = @{ URL32 = $url; Version = $version }
	return $Latest
}

update -ChecksumFor 32