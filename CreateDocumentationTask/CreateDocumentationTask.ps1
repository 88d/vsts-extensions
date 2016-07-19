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

function GetVstsInputField([string]$path){
    $value = Get-VstsInput -Name "$path"
    Write-Host "$($path): $value"
    return $value
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

function CreateOutputPath([string]$path){
    New-Item -ItemType File -Force $path| Out-Null
    Remove-Item $path -Force | Out-Null
}

$ConfigPath = GetVstsInputField "ConfigPath"
$Version = GetVstsInputField "Version"
$OutputFolder = GetVstsInputField "OutputFolder"
$InputRootFolder = GetVstsInputField "InputRootFolder"
$OutputZipName = GetVstsInputField "OutputZipName"

$TaskVersion = Get-VstsTaskVariable -Name "DocVersion"
if($TaskVersion -ne ""){
    Write-Output "Version is overwritten with Variable 'DocVersion' to $TaskVersion"
    $Version = $TaskVersion
}

Write-VstsTaskVerbose "Starting CreateDocumentationTask"

try {
    Write-VstsTaskDebug "Read config file from $ConfigPath"

    # read json config
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

    Write-VstsTaskVerbose "Found $($config.documents.Count) entries in $ConfigPath"

    $fileList = @();
    $fileConversationList = @();
    # fill the fileList and the fileConversationList
    Foreach($doc in $config.documents){
        if($doc.GetType().Name -eq "String"){
            # array entry is simple file and will simply copied as is
            $in = Get-InputPath $doc
            $out = Get-OutputPath $doc
            Write-VstsTaskDebug "Add $doc to fileList"
            $fileList += (@{in=$in;out=$out});
        } else {
            $in = Get-InputPath $doc.in;
            $out = Get-OutputPath $doc.out;
            if($in.EndsWith(".docx") -and $out.EndsWith(".pdf")){
                # Add file to conversation list
                Write-VstsTaskDebug "Add $in as $out to fileConversationList"
                $fileConversationList += (@{in=$in;out=$out});
            } else {
                # copy files that don't need conversation
                Write-VstsTaskDebug "Add $in as $out to fileList"
                $fileList += (@{in=$in;out=$out});
            }
        }
    }

    $totalFileCount = $fileConversationList.Count + $fileList.Count
    Write-VstsTaskVerbose "A total of $totalFileCount files will be copied/created"
    
    if(Test-Path $OutputFolder) {
        Write-VstsTaskVerbose "$OutputFolder does already exist and will be deleted"
        Remove-Item $OutputFolder -Recurse -Force
    }

    $fileNumber = 0;
    if($fileConversationList.Count -gt 0){
        Write-VstsTaskVerbose "Files to convert found"
        try{    
            Write-VstsTaskVerbose "Starting Word for Converting docx to pdf"    
            $WordApp = New-Object -ComObject Word.Application
            Foreach ($file in $fileConversationList){
                $fileNumber += 1;
                Write-VstsTaskVerbose "Converting $($file.in) to $($file.out)"
                if(Test-Path $file.in){
                    CreateOutputPath $file.out
                    $docFile = $WordApp.Documents.Open($file.in)
                    $pdfOutputName = $file.out
                    $docFile.SaveAs($pdfOutputName, 17)
                    $docFile.Close()   
                    Write-Host "Converted $($file.in) to $($file.out)"
                } else {
                    Write-VstsTaskError "File $($file.in) not found!"
                }             
                Write-VstsSetProgress (($fileNumber / $totalFileCount) * 100)                
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
        Write-VstsTaskVerbose "Files to copy found"
        Foreach($file in $fileList){            
            $fileNumber += 1;
            Write-VstsTaskVerbose "Copy $($file.in) to $($file.out)"
            if(Test-Path $file.in){       
                CreateOutputPath $file.out
                Copy-Item $file.in $file.out -Recurse -Force | Out-Null
                Write-Host "Copied $($file.in) to $($file.out)"
            } else {
                Write-VstsTaskError "File $($file.in) not found!"            
            }            
            Write-VstsSetProgress (($fileNumber / $totalFileCount) * 100)
        }
    }

    Write-VstsTaskVerbose "Copied/Converted $fileNumber of $totalFileCount files"

    $zipOutputPath = Get-OutputPath $OutputZipName
    # remove zip if this exists
    if(Test-Path $zipOutputPath){
        Remove-Item $zipOutputPath
    }
    Write-VstsTaskVerbose "Creating $zipOutputPath"
    Compress-Archive -Path $OutputFolder\* -DestinationPath $zipOutputPath -Force 
    Write-Host "Created $zipOutputPath"
} catch {
    Write-VstsTaskError "An Error happend in CreateDocumentationTask"
    throw
}

Write-VstsTaskVerbose "Ending CreateDocumentationTask"