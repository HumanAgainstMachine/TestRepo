# LocalModules

While developing your PowerShell module, you will often need to install it on your system to test it. This involves copying the module files (e.g., the .psm1 file, the module manifest, and any other associated files) to a directory on your Windows computer.

The directory must be one listed in the PSModulePath environment variable.

To speed up the installation process, you can use LocalModules, which handles removing the previously installed module and copying the new one.

LocalModules installs the module in your user-specific Modules directory, located at:

`$HOME\Documents\WindowsPowerShell\Modules\<Module Folder>\<Module Files>`

LocalModules allows you to `install`, `uninstall` and `list` modules that are not yet published to a repository, facilitating a quicker development and testing cycle.

Additionally, it enables you to set up a local repository for testing PS module publishing.


# Installation

Install LocalModules from [Powershell Gallery](https://www.powershellgallery.com/packages/LocalModules)

```powershell
Install-Module -Name LocalModules
```

# Usage

## Install-LocalModule

### SYNOPSIS
Install a local module bypassing repositories

### SYNTAX

```
Install-LocalModule [-Path] <String>
```

### DESCRIPTION
This cmdlet installs an under development module bypassing repositories.
Before uninstalls previous module if exists.


### PARAMETERS

#### -Path
Path to the module folder


## Uninstall-LocalModule

### SYNOPSIS
Uninstall a local module

### SYNTAX

```
Uninstall-LocalModule [-Name] <String>
```

### DESCRIPTION
This cmdlet uninstalls the local module with given Name.


### PARAMETERS

#### -Name
Name of the Module to uninstall

## Get-LocalInstalledModule

### SYNOPSIS
Get locally installed modules

### SYNTAX

```
Get-LocalInstalledModule
```

### DESCRIPTION
This cmdlet gets the list of modules not installed from a repository


## Set-LocalRepo

### SYNOPSIS
Set up LocalRepo repository on the file system

### SYNTAX

```
Set-LocalRepo [-WhatIf] [-Confirm]
```

### DESCRIPTION
This cmdlet registers the repository located at %USERPROFILE%\LocalRepo

### PARAMETERS

#### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

#### -Confirm
Prompts you for confirmation before running the cmdlet.

## Remove-LocalRepo

### SYNOPSIS
Remove LocalRepo repository from the file system

### SYNTAX

```
Remove-LocalRepo [-WhatIf] [-Confirm]
```

### DESCRIPTION
This cmdlet unregisters the repository and remove LocalRepo folder with its content


### PARAMETERS

#### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

#### -Confirm
Prompts you for confirmation before running the cmdlet.