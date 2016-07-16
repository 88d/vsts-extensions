#
# CreateDocumentationTask.ps1
#
[CmdletBinding(DefaultParameterSetName = 'None')]
param(
	[string] $ConfigPath = "docs.json",
    [string] $Version = "5.2",
    [string] $OutputFolder = "D:\tempOutput",
    [string] $InputRootFolder = "D:\tempInput",
    [string] $OutputZipName = '${Version}_Documentation.zip'
)

$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\ps_modules\VstsTaskSdk

$ConfigPath = Get-VstsInput -Name "ConfigPath"
Write-Output "ConfigPath:      $ConfigPath" 
$Version = Get-VstsInput -Name "Version"
Write-Output "Version:         $Version" 
$OutputFolder = Get-VstsInput -Name "OutputFolder"
Write-Output "OutputFolder:    $OutputFolder" 
$InputRootFolder = Get-VstsInput -Name "InputRootFolder"
Write-Output "InputRootFolder: $InputRootFolder" 
$OutputZipName = Get-VstsInput -Name "OutputZipName"
Write-Output "OutputZipName:   $OutputZipName"

$TaskVersion = Get-VstsTaskVariable -Name "DocVersion"
if($TaskVersion -ne ""){
    Write-Output "Version is overwritten with Variable 'DocVersion' to $TaskVersion"
    $Version = $TaskVersion
}

function ReplaceParameters([string]$name) {
    return $name.Replace('${Version}',$Version)
}

function Get-InputPath($name) {
    $correctName = ReplaceParameters $name
    return Join-Path $InputRootFolder $correctName
}

function Get-OutputPath($name) {
    $correctName = ReplaceParameters $name
    return Join-Path $OutputFolder $correctName
}

Write-VstsTaskVerbose "Starting CreateDocumentationTask"

try {
    Write-VstsTaskDebug "Read config file from $ConfigPath"

    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

    Write-Host "Found $($config.documents.Count) documents in $ConfigPath"

    $fileList = @();
    $fileConvertList = @();
    Foreach($doc in $config.documents){
        if($doc.GetType().Name -eq "String"){
            $in = Get-InputPath $doc
            $out = Get-OutputPath $doc
            Write-VstsTaskDebug "Add $doc to fileList"
            $fileList += (@{
                in=$in
                out=$out});
        } else {
            $in = Get-InputPath $doc.in;
            $out = Get-OutputPath $doc.out;
            if($in.EndsWith(".docx") -and $out.EndsWith(".pdf")){
                Write-VstsTaskDebug "Add $in as $out to fileConvertList"
                $fileConvertList += (@{
                    in=$in
                    out=$out
                });
            } else {
                Write-VstsTaskDebug "Add $in as $out to fileList"
                $fileList += (@{
                in=$in
                out=$out});
            }
        }
    }

    $totalFileCount = $fileConvertList.Count + $fileList.Count
    Write-VstsTaskVerbose "A total of $totalFileCount files will be copied/created"
    
    if(Test-Path $OutputFolder) {
        Write-VstsTaskVerbose "$OutputFolder does already exist and will be deleted"
        Remove-Item $OutputFolder -Recurse -Force
    }

    $fileNumber = 1;
    if($fileConvertList.Count -gt 0){
        try{    
            Write-VstsTaskVerbose "Starting Word for Converting docx to pdf"    
            $WordApp = New-Object -ComObject Word.Application
            Foreach ($file in $fileConvertList){
                Write-VstsTaskVerbose "Converting $($file.in) to $($file.out)"
                if(Test-Path $file.in){
                    New-Item -ItemType File -Force $file.out | Out-Null
                    Remove-Item $file.out -Force | Out-Null
                } else {
                    Write-VstsTaskError "File $($file.in) not found!"
                }
                $docFile = $WordApp.Documents.Open($file.in)
                $pdfName = $file.out
                $docFile.SaveAs($pdfName, 17)
                $docFile.Close()                
                Write-VstsSetProgress (($fileNumber / $totalFileCount) * 100)
                $fileNumber += 1;
            }
        }
        catch {
            Write-VstsTaskError "Could not convert Word files to PDF"
            throw
        }
        finally{
            Write-VstsTaskDebug "Stopping Word"
            if($WordApp -ne $null){            
                $WordApp.Quit()            
            }
        }    
    }

    if($fileList.Count -gt 0){
        Write-VstsTaskVerbose "Starting file copy"
        Foreach($file in $fileList){
            Write-VstsTaskVerbose "Copy $($file.in) to $($file.out)"
            if(Test-Path $file.in){       
                # This creates a new folder in the structure         
                New-Item -Type File -Force $file.out | Out-Null
                Copy-Item $file.in $file.out -Recurse -Force | Out-Null
            } else {
                Write-VstsTaskError "File $($file.in) not found!"            
            }            
            Write-VstsSetProgress (($fileNumber / $totalFileCount) * 100)
            $fileNumber += 1;
        }
    }

    Write-VstsTaskVerbose "Copied/Created $($fileNumber-1) of $totalFileCount files"

    $zipOutputPath = Get-OutputPath $OutputZipName
    if(Test-Path $zipOutputPath){
        Remove-Item $zipOutputPath
    }
    Write-VstsTaskVerbose "Creating $zipOutputPath"
    Compress-Archive -Path $OutputFolder\* -DestinationPath $zipOutputPath -Force

} catch {
    Write-VstsTaskError "An Error happend in CreateDocumentationTask"
    throw
}

Write-VstsTaskVerbose "Ending CreateDocumentationTask"