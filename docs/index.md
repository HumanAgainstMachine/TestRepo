# LocalModules

**LocalModules** allows you to easily install and uninstall PowerShell (PS) modules that are still under development and not yet ready for publishing. This streamlines the development and testing process.

## Intro

In this context, a local module is a Powershell module under development with a file layout like this:

    MyModuleName/ # The folder containing files
        MyModuleName.psm1 # The code file.
        MyModuleName.psd1 # The manifest.
        ...             # Other files, e.g. manifest file.

While developing a PowerShell module on your computer, you will often need to install it on your system to test it. Installing from a repository requires you to go through the long process of first publishing the module.

There is a shortcut to install a local module bypassing repositories, this involves copying the module folder and files to a directory on your Windows computer.

!!! quote "As Microsoft says:"
    To install and run your module, save the module to one of the appropriate PowerShell paths [...]. The paths where you can install your module are located in the `$env:PSModulePath` global variable.

    :material-cursor-default-click: [How to Write a PowerShell Script Module](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-script-module?view=powershell-7.4).



So the directory must be one listed in the `$env:PSModulePath` global variable, a good one for developing purposes is the user-specific directory `$HOME\Documents\PowerShell\Modules`.

## How it works

**LocalModules** speeds up this installation process, handles removing the previously installed local module before copying the new one and avoids mixing up local and repo modules.

**LocalModules** installs the under-development module in your user-specific Powershell path and allows you to `install`, `uninstall` and, `list` modules that have not been yet published in a repository, facilitating a quicker development and testing cycle.


## Installation

Install **LocalModules** from [Powershell Gallery](https://www.powershellgallery.com/packages/LocalModules).

```powershell
Install-Module -Name LocalModules
```

## Cmdlets overview

`#!powershell Install-LModule  -Path <path_to_my_module>`
:   Install the local module specified by `-Path` parameter, it can be an absolute or relative path.  
No need to uninstall the previous installation.


`#!powershell Get-LInstalledModule`
:   List all local modules installed with `#!powershell Install-LModule`.


`#!powershell Uninstall-LModule -Name <my_mod_name>`
:   Uninstall the local module specified by `-Name` parameter and previously installed with `#!powershell Install-LModule`