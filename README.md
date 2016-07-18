# vsts-extensions

This VSTS-Extension creates exactly one build-task with the name CreateDocumentationTask. It creates a Zip File with all files in the `docs.json` file.

> This Extension can convert docx to pdf if office is installed correctly on the server.

## build

`
npm install
npm run build
`

After the build the files vsix will be available under the dist folder.


## How to use this extionsion

After the extension is created create a docs.json in the source repository. In this json file you will write what files should be moved into resulting zip.

### Settings

#### ConfigPath
Here is the json with the files to put into the documentation zip

#### Version
Version that will replace ${Version} in all paths

> Version can be overwritten with a variable with the name DocVersion

#### OutputFolder
Is the temp output folder of all files

#### InputRootFolder
This is the root path to all files in the docs.json

#### OutputZipName
Here you can specify how your zip output should look like