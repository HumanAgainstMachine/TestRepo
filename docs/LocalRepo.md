# The Local Repo 

**LocalModules** additionally supports setting up a local repository for testing PS module publishing.

## Intro

When you are ready to publish your module officially, for example to powershellgallery.com, you want to test the publishing process and you can do this with a local *file share repository* (1).
{ .annotate }

1. :material-cursor-default-click: 2. [Kevin Marquette's article about file share repositories](https://powershellexplained.com/2017-05-30-Powershell-your-first-PSScript-repository/).

LocalModules Powershell module additionally enables you to set up a local repository on your system to the folder `$HOME\LocalRepo`.

### Local Repo cmdlets overview

`#!powershell Set-LRepo`
:   Set up a local *file share* repository named LocalRepo.

`#!powershell Remove-LRepo`
:   Remove the LocalRepo repository and all modules that are contained.


### Examples

Setting up the repo:
```powershell
PS:> Set-LRepo
```
Checking out LocalRepo:

```powershell
PS:> Get-PSRepository

Name                      InstallationPolicy   SourceLocation
----                      ------------------   --------------
PSGallery                 Untrusted            https://www.powershellgallery.com/api/v2
LocalRepo                 Trusted              C:\Users\<youser>\LocalRepo
```

Publishing to LocalRepo:

```powershell
PS:> Publish-Module -Path <Path/to/modulefolder> -Repository LocalRepo
```

Installing a module from LocalRepo:

```powershell
PS:> Install-Module -Name <my_mod_name> -Repository LocalRepo
```

Removing the repo
```powershell
PS:> Remove-LRepo
```