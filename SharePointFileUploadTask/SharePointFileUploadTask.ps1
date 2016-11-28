# 
# CreateDocumentationTask.ps1 
# 
[CmdletBinding(DefaultParameterSetName = 'None')] 
 param( 
 	[string] $ProjectUrl = "https://tfs:8080/tfs/DefaultCollection/DefaultProject", 
    [string] $BuildDefinitionId = "1", 
    [string] $ArtifactNames ="build,setup", 
    [string] $OutputFolder = '$(Build.ArtifactStagingDirectory)\\build' 
 ) 
 
 
 $ErrorActionPreference = "Stop" 
 
 
 Import-Module $PSScriptRoot\SharePointUpload.ps1 

 
function GetVstsInputField([string]$path){ 
    $value = Get-VstsInput -Name "$path" 
    Write-Host "$($path): $value" 
     return $value 
 } 

$SiteURL =  GetVstsInputField "SiteURL" 
$File =  GetVstsInputField "File" 
$DocLibName =  GetVstsInputField "DocLibName" 
 
./SharPointUpload.ps1 -SiteURL $SiteURL -File $File -DocLibName $DocLibName
