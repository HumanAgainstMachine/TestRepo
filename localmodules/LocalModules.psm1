<#
.SYNOPSIS
    Local modules management

.DESCRIPTION
    Cmdlets to manage a local modules for current user
#>

#--- Init code

$localRepoPath = Join-Path -Path $env:USERPROFILE -ChildPath 'LocalRepo'

# current user's modules path
$doc = [Environment]::GetFolderPath('MyDocuments')
$userModulesPath = Join-Path -Path $doc -ChildPath "PowerShell\Modules"
# all PS module paths
$ModulePaths = $env:PSModulePath -split ';'

if (-Not ($ModulePaths -contains $userModulesPath)) {
    Write-Host "Current user's module path not found in PSModulePath." -ForegroundColor Red
    Exit 2
}

$RepoInstalledModules = (Get-InstalledModule).Name

function Install-LocalModule {
    <#
    .SYNOPSIS
        Install a local module bypassing repositories

    .DESCRIPTION
        This cmdlet installs an under development module bypassing repositories. Before uninstalls previous module if exists.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, HelpMessage="Enter Module Path")]
        [String]$Path
    )

    # Infer the module name
    $moduleName = Split-Path -Path $Path -Leaf

    # Check if local module folder exist
    if (Test-Path -Path $Path -PathType Container) {
        # Check if local module is already installed from a repo
        if ($RepoInstalledModules -contains $moduleName) {
            Write-Host "$moduleName is already installed from a repository"
        } else {
            # Silently uninstall old version local module if exist
            $installedModulePath = Join-Path -Path $userModulesPath -ChildPath $moduleName
            Remove-Item -Path $installedModulePath -Recurse -Force -ErrorAction SilentlyContinue
            # Install current version local module
            Copy-Item -Path "$Path\" -Destination $installedModulePath -Recurse -Force
            Import-Module -Name $moduleName -Force
            Write-Host "$moduleName module successfully installed" -ForegroundColor Green            
        }
    } else {
        Write-Host "Local Module not found at path $path" -ForegroundColor Red
    }
}


function Uninstall-LocalModule {
    <#
    .SYNOPSIS
        Uninstall a local module 
    .DESCRIPTION
        This cmdlet uninstall the local module with given Name.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, HelpMessage="Enter Module Name")]
        [String]$Name
    )

    $installedModulePath = Join-Path -Path $userModulesPath -ChildPath $Name
    # Check if given module is installed
    if (Test-Path -Path $installedModulePath -PathType Container) {
        # Check if given module is installed from a repo
        if ($RepoInstalledModules -contains $Name) {
            Write-Host "$Name is installed from a repository. Use Uninstall-Module -Name $Name"
        } else {
            Remove-Item -Path $installedModulePath -Recurse -Force
            Write-Host "$Name module successfully uninstalled" -ForegroundColor Green
        }        
    } else {
        Write-Host "$Name module not found" -ForegroundColor Red
    }    
}

function Get-LocalInstalledModule {
    <#
    .SYNOPSIS
        Get local installed modules
    .DESCRIPTION
        Gets the list of modules installed not from a repository
    #>
    [CmdletBinding()]
    param ()
    # Get all directories in user modules path
    $installedModules = (Get-ChildItem -Path $userModulesPath -Directory).Name
    $localInstalledModules = Compare-Object -ReferenceObject $installedModules -DifferenceObject $RepoInstalledModules -PassThru | 
    Where-Object { $_.SideIndicator -eq "<=" }

    if ($localInstalledModules.Count -eq 0) {
        Write-Host "No local modules found." 
    } else {
        Write-Host $localInstalledModules -Separator "`n" -ForegroundColor DarkYellow
    }
}

function Set-LocalRepo {
    <#
    .SYNOPSIS
        Set up a local repository named LocalRepo on the file system 
    
    .DESCRIPTION
        This cmdlet registers the repository at location %USERPROFILE%\LocalRepo
    #>
    [CmdletBinding()]
    param ()
    
    # Create LocalRepo folder if not exist
    if (-Not (Test-Path -Path $localRepoPath -PathType Container)) {
        New-Item -Path $localRepoPath -ItemType Directory | Out-Null
    }

    try {
        Register-PSRepository -Name 'LocalRepo' -SourceLocation $localRepoPath -InstallationPolicy 'Trusted' -ErrorAction Stop
        Write-Host "LocalRepo successfully set at $localRepoPath" -ForegroundColor Green
    }
    catch {
        Write-Host "LocalRepo already exist" -ForegroundColor Red
    }
}

function Remove-LocalRepo {
    <#
    .SYNOPSIS
        Remove LocalRepo repository
    
    .DESCRIPTION
        This cmdlet unregisters the repository and remove LocalRepo folder with its content
    #>
    [CmdletBinding()]
    param ()

    try {
        Unregister-PSRepository -Name 'LocalRepo' -ErrorAction Stop
        if (Test-Path -Path $localRepoPath -PathType Container) {
            Remove-Item -Path $localRepoPath -Force -Recurse
        }
        Write-Host "LocalRepo removed" -ForegroundColor Green
    }
    catch {
        Write-Host "LocalRepo not exist" -ForegroundColor Red
    }
}