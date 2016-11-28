# 
# CreateDocumentationTask.ps1 
# 
[CmdletBinding(DefaultParameterSetName = 'None')] 
 param( 
[Parameter(Mandatory=$true)]
[string] $SiteURL = "http://<server>/sites/<user>",
[Parameter(Mandatory=$true)]
[string] $File = "C:\development\<test>.app",
[Parameter(Mandatory=$true)]
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
 
.$PSScriptRoot\SharePointUpload.ps1 -SiteURL $SiteURL -File $File -DocLibName $DocLibName
