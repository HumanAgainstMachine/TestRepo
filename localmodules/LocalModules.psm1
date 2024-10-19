<#
.SYNOPSIS
    Local modules management

.DESCRIPTION
    Cmdlets to manage a local modules for current user
#>

# The folder where are under development modules
$localModulesPath = 'C:\Users\Admin\works' # to be used later ...

$localRepoPath = Join-Path -Path $env:USERPROFILE -ChildPath 'LocalRepo'

# Get path to user-specific installed modules
$userModulesPath = $env:PSModulePath -split ';' | Where-Object { $_ -like [Environment]::GetFolderPath('MyDocuments')+'*'}

if (-not ($userModulesPath)) {
    Write-Host "User-specific module path " -NoNewline -ForegroundColor Red
    Write-Host $userModulesPath -NoNewline -ForegroundColor DarkGray
    Write-Host " not found in PSModulePath." -ForegroundColor Red
    Exit 2    
}

$RepoInstalledModules = (Get-InstalledModule).Name

function Install-LocalModule {
    <#
    .SYNOPSIS
        Install a local module bypassing repositories

    .DESCRIPTION
        This cmdlet installs an under-development module bypassing repositories, before uninstalls previous installed local module if exists.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, HelpMessage="Enter Module Path")]
        [String]$Path
    )

    if (Test-Path -Path $Path -PathType Container) {

        # Get module name from folder name
        $moduleName = Split-Path -Path $Path -Leaf        

        if ($RepoInstalledModules -contains $moduleName) {# Local module installed from a repo check
            Write-Host "$moduleName already installed from a repository" -ForegroundColor Red
            Write-Host "Uninstall any version installed from a repository before continuing" -ForegroundColor DarkYellow
        } 
        else {
            # Uninstall previous local module if exist
            $ver0ModulePath = Join-Path $userModulesPath $moduleName '0.0.0'
            Remove-Item -Path $ver0ModulePath -Recurse -Force -ErrorAction SilentlyContinue

            # Install current local module
            New-Item -Path $ver0ModulePath -ItemType Directory -Force | Out-Null
            Copy-Item -Path "$Path\*" -Destination $ver0ModulePath -Recurse -Force

            # Path to installed manifest file
            $ver0ManifestPath = Join-Path $ver0ModulePath "$moduleName.psd1"

            # Set ver to 0.0.0 if manifest exist
            if (Test-Path -Path $ver0ManifestPath) {
                $outputLines = @()

                # Read manifest file line by line
                $manifestContent = Get-Content -Path $ver0ManifestPath

                # Loop through each line and replace the line starting with 'ModuleVersion'
                foreach ($line in $manifestContent) {

                    if ($line -match '^ModuleVersion') {
                        $outputLines += "ModuleVersion = '0.0.0'"
                    } else {
                        $outputLines += $line
                    }
                }

                # Save the updated content back to the .psd1 file
                $outputLines | Set-Content -Path $ver0ManifestPath
            }
            else {# Create a minimal ver 0.0.0 manifest if NOT exist
                New-ModuleManifest -Path $ver0ManifestPath -RootModule ".\$moduleName.psm1" -ModuleVersion '0.0.0'
                Write-Host "A minimal manifest has been installed because you don't have one" -ForegroundColor DarkYellow
            } 
            
            Import-Module -Name $moduleName -Force
            Write-Host "$moduleName module successfully installed" -ForegroundColor Green            
        }
    } 
    else {   
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

    # $ver0ModulePath = Join-Path -Path $userModulesPath -ChildPath $Name
    $ver0ModulePath = Join-Path $userModulesPath $Name '0.0.0'

    # Local module installed check
    if (Test-Path -Path $ver0ModulePath -PathType Container) {

        if ($RepoInstalledModules -contains $Name) {# Local module installed from a repo check
            Write-Host "$Name is installed from a repository. Use cmdlet Uninstall-Module to uninstall it"
        } else {
            Remove-Item -Path $ver0ModulePath -Recurse -Force
            Write-Host "$Name module successfully uninstalled" -ForegroundColor Green
        }        
    } else {
        Write-Host "$Name module not found" -ForegroundColor Red
    }    
}

function Get-LocalInstalledModule {
    <#
    .SYNOPSIS
        Get locally installed modules
    .DESCRIPTION
        Gets the list of modules not installed from a repository
    #>
    [CmdletBinding()]
    param ()
    # Get all directories in user modules path
    $installedModules = (Get-ChildItem -Path $userModulesPath -Directory).Name
    $localInstalledModules = Compare-Object -ReferenceObject $installedModules -DifferenceObject $RepoInstalledModules -PassThru | 
    Where-Object { $_.SideIndicator -eq "<=" }

    if ($localInstalledModules.Count -eq 0) {
        Write-Host "No local modules found." -ForegroundColor DarkYellow
    } else {
        Write-Host "`nName`n----" -ForegroundColor Green
        Write-Host $localInstalledModules -Separator "`n"
        Write-Host " "
    }
}

function Set-LocalRepo {
    <#
    .SYNOPSIS
        Set up LocalRepo repository on the file system
    
    .DESCRIPTION
        This cmdlet registers the repository at location %USERPROFILE%\LocalRepo
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    
    if($PSCmdlet.ShouldProcess($localRepoPath, 'Set LocalRepo')){
        try {    
            # Create LocalRepo folder if not exist
            New-Item -Path $localRepoPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null        
    
            Register-PSRepository -Name 'LocalRepo' -SourceLocation $localRepoPath -InstallationPolicy 'Trusted' -ErrorAction Stop
            Write-Host "LocalRepo successfully set at location $localRepoPath" -ForegroundColor Green
        }
        catch {
            Write-Host "LocalRepo is already set" -ForegroundColor DarkYellow
        }
    }    
}

function Remove-LocalRepo {
    <#
    .SYNOPSIS
        Remove LocalRepo repository from the file system
    
    .DESCRIPTION
        This cmdlet unregisters the repository and remove LocalRepo folder with its content
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    if($PSCmdlet.ShouldProcess($localRepoPath, 'Remove LocalRepo')){    
        try {
            # Check if LocalRepo exists
            Get-PSRepository -Name "LocalRepo" -ErrorAction Stop | Out-Null

            Unregister-PSRepository -Name 'LocalRepo'

            # Remove folder and its content if exist
            Remove-Item -Path $localRepoPath -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
            
            Write-Host "LocalRepo removed" -ForegroundColor Green
        }
        catch {
            Write-Host "LocalRepo not found" -ForegroundColor DarkYellow
        }
    }
}