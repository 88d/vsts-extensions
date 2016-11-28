#How do use this script
#Enter parameters in Param
# $SiteUrl - the url for the sharpoint-side
#            eg. http://<server>/sites/<userName" for the local sharepoint-site
# $File    - path to the Share.app (fullPath including file-name)
# $DocLibName - Name of the sharepoint list where the file should be added to
#               e.g "App Packages" for the local developer site
#               "Apps for SharePoint"  develop machine
# $Credentials e.g. (new-object -typename System.Management.Automation.PSCredential -argumentlist "<userName>", (convertTo-SecureString '<pwd>' -asplaintext -force))

#Add references to SharePoint client assemblies and authenticate to Office 365 site – required for CSOM
try
{
    Add-Type -Path ($PSScriptRoot + "\Microsoft.SharePoint.Client.dll")
    Add-Type -Path ($PSScriptRoot + "\Microsoft.SharePoint.Client.Runtime.dll")
}
catch
{
    # type already installed
}

function CreateSharePointClientContext([String]$siteURL, $credentials) {
    #Bind to site collection
    $context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
    #Load Cretentials
    if ($credentials)
    {
        $context.Credentials = $credentials
    }
    return $context;
}

function UploadFileToSharePointList ([Microsoft.SharePoint.Client.ClientContext]$clientContext, [String]$file, [String]$docLibName) {
    #Retrieve list
    $List = $clientContext.Web.Lists.GetByTitle($docLibName)
    $clientContext.Load($List)
    $clientContext.ExecuteQuery()
    #Upload file
    if (Test-Path $file)
    {
        $fileItem = Get-ChildItem $file
        $FileStream = New-Object IO.FileStream($file,[System.IO.FileMode]::Open)
        $FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
        $FileCreationInfo.Overwrite = $true
        $FileCreationInfo.ContentStream = $FileStream
        $FileCreationInfo.URL = $fileItem.Name
        $Upload = $List.RootFolder.Files.Add($FileCreationInfo)
        $clientContext.Load($Upload)
        $clientContext.ExecuteQuery()
        $FileStream.Close()
    }
    else
    {
        throw "File not found"
    }    
}