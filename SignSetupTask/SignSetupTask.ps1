#
# SignSetupTask.ps1
#
[CmdletBinding(DefaultParameterSetName = 'None')]
param(
	[string] $CertificatePath = "C:\PathToCertificate",
    [string] $CertificatePassword = "Password",
    [string] $SetupFolderPath ='$(Build.SourcesDirectory)\setup\bin\Release'
)

$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\ps_modules\VstsTaskSdk

function GetVstsInputField([string]$path){
    $value = Get-VstsInput -Name "$path"
    Write-Host "$($path): $value"
    return $value
}

$CertificatePath = GetVstsInputField "CertificatePath"
$CertificatePassword = GetVstsInputField "CertificatePassword"
$SetupFolderPath = GetVstsInputField "SetupFolderPath"
$SignToolPath = GetVstsInputField "SignToolPath"
$SetupFileExtensions = @("*.msi","*.exe")


if(-not $CertificatePassword){
    Write-Error '$ENV:CERTIFICATE_PASSWORD needs to be set!'
    exit 1
}

if (-not $SignToolPath){
    $SignToolPath = "$PSScriptRoot\signtool.exe"
}


$filesToSign = Get-ChildItem $SetupFolderPath -Include $SetupFileExtensions -Recurse | Select -ExpandProperty FullName

foreach ($file in $filesToSign){
    $arguments = "sign /f $CertificatePath /p $CertificatePassword /fd sha256 /tr http://sha256timestamp.ws.symantec.com/sha256/timestamp /v $file"
    start-process $SignToolPath $arguments -Wait -NoNewWindow
}