# LocalModules

LocalModules allows you to `install` and `uninstall` PowerShell (PS) modules that are not yet published to a repository, facilitating a quicker development and testing cycle.

Additionally, it enables you to set up a local repository for testing PS module publishing.


# Installation

Install LocalModules from [Powershell Gallery](https://www.powershellgallery.com/packages/LocalModules)

```powershell
PS C:\> Install-Module -Name LocalModules
```


# Install-LocalModule

## SYNOPSIS
Install a local module bypassing repositories

## SYNTAX

```
Install-LocalModule [-Path] <String>
```

## DESCRIPTION
This cmdlet installs an under development module bypassing repositories.
Before uninstalls previous module if exists.

## EXAMPLES

### Example 1
```powershell
PS C:\> Install-LocalModule -Path .\MyModule
```

## PARAMETERS

### -Path
Path to the module folder

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

# Uninstall-LocalModule

## SYNOPSIS
Uninstall a local module

## SYNTAX

```
Uninstall-LocalModule [-Name] <String>
```

## DESCRIPTION
This cmdlet uninstalls the local module with given Name.

## EXAMPLES

### Example 1
```powershell
PS C:\> Uninstall-LocalModule -Name MyModule
```

## PARAMETERS

### -Name
Name of the Module to uninstall

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
# Get-LocalInstalledModule

## SYNOPSIS
Get locally installed modules

## SYNTAX

```
Get-LocalInstalledModule
```

## DESCRIPTION
This cmdlet gets the list of modules not installed from a repository

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-LocalInstalledModule
```

# Set-LocalRepo

## SYNOPSIS
Set up LocalRepo repository on the file system

## SYNTAX

```
Set-LocalRepo [-WhatIf] [-Confirm]
```

## DESCRIPTION
This cmdlet registers the repository located at %USERPROFILE%\LocalRepo

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-LocalRepo
```

## PARAMETERS

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

# Remove-LocalRepo

## SYNOPSIS
Remove LocalRepo repository from the file system

## SYNTAX

```
Remove-LocalRepo [-WhatIf] [-Confirm]
```

## DESCRIPTION
This cmdlet unregisters the repository and remove LocalRepo folder with its content

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-LocalRepo
```

## PARAMETERS

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```