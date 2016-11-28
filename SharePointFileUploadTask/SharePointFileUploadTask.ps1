# 
# CreateDocumentationTask.ps1 
# 
[CmdletBinding(DefaultParameterSetName = 'None')] 
param(
    [string] $SiteURL = "http://<server>/sites/<user>",
    [string] $File = "C:\development\<test>.app",
    [string] $DocLibName = "App Packages",
    $Credentials = $null
) 

$ErrorActionPreference = "Stop"  
 
Import-Module $PSScriptRoot\ps_modules\VstsTaskSdk
. $PSScriptRoot\SharePointUpload.ps1

function GetVstsInputField([string]$path){ 
$value = Get-VstsInput -Name "$path" 
Write-Host "$($path): $value" 
    return $value 
} 

$SiteURL =  GetVstsInputField "SiteURL" 
$File = GetVstsInputField "File" 
$DocLibName =  GetVstsInputField "DocLibName" 

# CreateClientContext for access to SharePoint
$ClientContext = CreateSharePointClientContext $SiteURL $Credentials

$FileList = Find-VstsFiles -LegacyPattern $File

foreach($file in $FileList){
    # Upload File To SharePoint
    Write-Host "Upload file $file to $DocLibName"
    UploadFileToSharePointList $ClientContext $file $DocLibName
}

