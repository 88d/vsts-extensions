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

Import-Module $PSScriptRoot\ps_modules\VstsTaskSdk
. $PSScriptRoot\DownloadBuildArtifacts.ps1


function GetVstsInputField([string]$path){
    $value = Get-VstsInput -Name "$path"
    Write-Host "$($path): $value"
    return $value
}

$ProjectUrl = GetVstsInputField "ProjectUrl"
$BuildDefinitionId = GetVstsInputField "BuildDefinitionId"
$ArtifactNames = GetVstsInputField "ArtifactNames"
$OutputFolder = GetVstsInputField "OutputFolder"

$artifactNames = $ArtifactNames.Split(',')

DownloadLatestBuildArtifacts $ProjectUrl $BuildDefinitionId $OutputFolder $artifactNames