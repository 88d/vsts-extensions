# vsts-extensions

This VSTS-Extension creates exactly one build-task with the name CreateDocumentationTask. It creates a Zip File with all files in the `docs.json` file.

> This Extension can convert docx to pdf if office is installed correctly on the server.

## build

`
npm install
npm run build
`

After the build the files vsix will be available under the dist folder.


## How to use this extension

After the extension is created create a docs.json in the source repository. A sample of docs.json is found [here](./CreateDocumentationTask/docs.json). In this json file you will write what files should be moved into resulting zip.

### Settings

#### ConfigPath
Set the path to the docs.json file

#### Version
Version that will replace `${Version}` in all paths

> Version can be overwritten with a variable with the name DocVersion

#### OutputFolder
A folder were all files will be copied to and the zip file will be created

#### InputRootFolder
This is the root path to all files in the docs.json

#### OutputZipName
Specify the name of your output zip file name
