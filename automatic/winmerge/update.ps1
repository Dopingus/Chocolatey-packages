﻿$ErrorActionPreference = 'Stop'
import-module au

$releases = 'https://github.com/WinMerge/winmerge/releases'

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(^[$]url32\s*=\s*)('.*')"      = "`$1'$($Latest.URL32)'"
            "(^[$]checksum32\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
            "(^[$]checksumType32\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
            "(^[$]url64\s*=\s*)('.*')"      = "`$1'$($Latest.URL64)'"
            "(^[$]checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
            "(^[$]checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
        }
    }
}

function global:au_GetLatest {
    $installers = ((Invoke-WebRequest -Uri $releases -UseBasicParsing).Links | Where-Object {$_.href -match ".exe$"} | Where-Object {$_.href -notmatch "PerUser"}).href
    $url32 = "https://github.com$($installers.Where({$_ -match "(?<!64)-Setup\.exe$"}, 1))";
    $url64 = "https://github.com$($installers.Where({$_ -like "*-X64-Setup.exe"}, 1))";

    $version = $url32.split('-') | select-object -Last 1 -Skip 1
    if($version -eq '2.16.14') { $version = '2.16.14.20210829' }
    $tags = Invoke-WebRequest 'https://api.github.com/repos/WinMerge/winmerge/releases' -UseBasicParsing | ConvertFrom-Json
    foreach ($tag in $tags) {
        if($tag.tag_name -match $version) {
            if($tag.prerelease -match "true") {
                $clnt = new-object System.Net.WebClient;
                $clnt.OpenRead("https://github.com$($installer[0])").Close();
                $date = $([datetime]$clnt.ResponseHeaders["Last-Modified"];).ToString("yyyyMMdd")
                $version = "$version-pre$($date)"
            }
        }
    }

    return @{ URL32 = $url32; URL64 = $url64; Version = $version }
}

update-package
