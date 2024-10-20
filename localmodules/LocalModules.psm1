<#
.SYNOPSIS
    Local modules management

.DESCRIPTION
    Cmdlets to manage a local modules for current user
#>

$localRepoPath = Join-Path -Path $env:USERPROFILE -ChildPath 'LocalRepo'

# From all available paths, select only the user-specific path to installed modules
$myModulePath = $env:PSModulePath -split ';' | Where-Object { $_ -like [Environment]::GetFolderPath('MyDocuments')+'*'}

if (-not ($myModulePath)) {
    Write-Host "User-specific module path " -NoNewline -ForegroundColor Red
    Write-Host $myModulePath -NoNewline -ForegroundColor DarkGray
    Write-Host " not found in PSModulePath." -ForegroundColor Red
    Exit 2    
}

$repoInstalledModNames = (Get-InstalledModule).Name

function Install-LModule {
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

        if ($repoInstalledModNames -contains $moduleName) {# Local module installed from a repo check
            Write-Host "$moduleName is already installed from a repository" -ForegroundColor Red
            Write-Host "Uninstall any version installed from a repository to prevent confusion." -ForegroundColor DarkYellow
        } 
        else {
            # Uninstall previous local module if exist
            $ver0ModulePath = Join-Path $myModulePath $moduleName '0.0.0'
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

            Write-Host "Local module $moduleName successfully installed" -ForegroundColor Green
            Write-Host "Close and reopen the PowerShell console to restart the session and see the changes." -ForegroundColor DarkYellow
        }
    } 
    else {   
        Write-Host "Local Module not found at path $path" -ForegroundColor Red
    }
}


function Uninstall-LModule {
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

    # $ver0ModulePath = Join-Path -Path $myModulePath -ChildPath $Name
    $ver0ModulePath = Join-Path $myModulePath $Name '0.0.0'

    # Local module installed check
    if (Test-Path -Path $ver0ModulePath -PathType Container) {
        
        # Local module also installed from a repo check
        if ($repoInstalledModNames -contains $Name) {
            Write-Host @"

$Name is also installed from a repository, you likely forced the installation 
from there. I recommend uninstalling the repository version to avoid confusion.

"@ -ForegroundColor DarkYellow
        }

        Remove-Item -Path $ver0ModulePath -Recurse -Force
        Write-Host "Local module $Name successfully uninstalled" -ForegroundColor Green
        Write-Host "Close and reopen the PowerShell console to restart the session and see the changes." -ForegroundColor DarkYellow
        
    } else {
        Write-Host "Local module $Name not found" -ForegroundColor Red
    }    
}

function Get-LInstalledModule {
    <#
    .SYNOPSIS
        Get locally installed modules
    .DESCRIPTION
        Gets the list of modules not installed from a repository
    #>
    [CmdletBinding()]
    param ()
    # Get all directories in user modules path
    $localInstalledModNames =   Get-ChildItem -Path $myModulePath -Directory | 
                                Where-Object { Test-Path (Join-Path $_.FullName '0.0.0') -PathType Container } |
                                Select-Object -ExpandProperty Name

    if ($localInstalledModNames.Count -eq 0) {
        Write-Host "No local modules found." -ForegroundColor DarkYellow
    } else {
        Write-Host "`nName`n----" -ForegroundColor Green
        foreach ($mod in $localInstalledModNames) {
            Write-Host $mod -NoNewline
            if ($repoInstalledModNames -contains $mod) {Write-Host " (also installed from a repository)" -ForegroundColor DarkYellow}
            else {Write-Host ""}
        }

    }
}

function Set-LRepo {
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

function Remove-LRepo {
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