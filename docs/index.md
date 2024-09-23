# LocalModules

## Intro

In this context, a local module is a module under development with a file layout like this:

    ModName/
        ModName.psm1 # The code file.
        ...          # Other files, e.g. manifest file.

While developing a PowerShell module on your computer, you will often need to install it on your system to test it. Installing from a repository requires you to go through the long process of first publishing the module. 

There is a shortcut to install a local module bypassing repositories, this involves copying the module folder and files to a directory on your Windows computer. 

As Microsoft says<sup>1</sup>:

>To install and run your module, save the module to one of the appropriate PowerShell paths [...]. The paths where you can install your module are located in the `$env:PSModulePath` global variable.

So the directory must be one listed in the `$env:PSModulePath` global variable, a good one for developing purposes is the user-specific directory `$HOME\Documents\PowerShell\Modules`.

## How it works

LocalModules speeds up this installation process, handles removing the previously installed local module before copying the new one and avoids mixing up local and repo modules.

LocalModules installs the module in your user-specific Powershell path and allows you to `install`, `uninstall` and, `list` modules that have not been yet published in a repository, facilitating a quicker development and testing cycle.




## Installation

Install LocalModules from [Powershell Gallery](https://www.powershellgallery.com/packages/LocalModules).

```powershell
Install-Module -Name LocalModules
```

## Usage

Install specifying an absolute or relative path to the local module folder.

```powershell
Install-LocalModule  -Path <path_to_dev_module_dir>
```
List all installed local modules.

```powershell
Get-LocalInstalledModule
```
Uninstall specifying the local module name to remove.

```powershell
Uninstall-LocalModule -Name <dev_mod_name>
```

## Local Repo extra feature

When you are ready to publish your module officially, for example, to powershellgallery.com, you want to test the publishing process and you can do this with a local *file share repository*<sup>2</sup>.

LocalModules Powershell module additionally enables you to set up a local repository on your system to the folder `$HOME\LocalRepo`.

### Usage

Set up a local *file share* repository named LocalRepo.

```powershell
Set-LocalRepo
```

Remove the LocalRepo repository and all modules that are contained.

```powershell
Remove-LocalRepo
```

### Examples

Check out LocalRepo:

```powershell
PS:> Get-PSRepository

Name                      InstallationPolicy   SourceLocation
----                      ------------------   --------------
PSGallery                 Untrusted            https://www.powershellgallery.com/api/v2
LocalRepo                 Trusted              C:\Users\<youser>\LocalRepo
```

For publish to and install from LocalRepo specify it in commands:

```powershell
PS:> Publish-Module -Name <dev_mod_name> -Repository LocalRepo
```

```powershell
PS:> Install-Module -Name <dev_mod_name> -Repository LocalRepo
```

---

## Endnotes
1. [How to Write a PowerShell Script Module](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-script-module?view=powershell-7.4).
2. [Kevin Marquette's article about file share repositories](https://powershellexplained.com/2017-05-30-Powershell-your-first-PSScript-repository/).
