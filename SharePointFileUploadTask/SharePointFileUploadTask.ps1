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

 
function GetVstsInputField([string]$path){ 
    $value = Get-VstsInput -Name "$path" 
    Write-Host "$($path): $value" 
     return $value 
 } 

$SiteURL =  GetVstsInputField "SiteURL" 
$File =  GetVstsInputField "File" 
$DocLibName =  GetVstsInputField "DocLibName" 
 
.$PSScriptRoot\SharePointUpload.ps1 -SiteURL $SiteURL -File $File -DocLibName $DocLibName -Credentials $Credentials
