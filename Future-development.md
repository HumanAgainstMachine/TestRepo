
# Development Modules for Version 2.0.0

Inspired by the blog post: [Set up a local PowerShell module repository: no server needed](https://blog.devolutions.net/2021/03/local-powershell-module-repository-no-server-required), I have begun considering improvements to the `LocalModules` implementation.

The new approach leverages a local PowerShell repository and aims to minimize its impact on developers. It introduces a single cmdlet while utilizing existing cmdlets for module management.

## The New Single Function: `Install-DevMod`

This cmdlet performs the following steps:

1. Sets up a local repository named **Development** (if it is not already configured).
2. Publishes the module to the **Development** repository.
3. Installs the module from the **Development** repository.
4. Restarts the shell using `Exit 1`.

Additionally, the cmdlet:
- Deletes the previously published module before publishing the new version.
- Uninstalls the currently installed module before installing the updated version.

### Example Usage
```powershell
Install-DevMod -Path <Path/to/modulefolder>
```

### Key Considerations

- **Conflict Warning:**  
  If a module (e.g., `DumbMod`) exists in both the **PSGallery** and the **Development** repository, running the command below:
  ```powershell
  Install-Module -Name DumbMod
  ```
  will produce a warning indicating that the module is available in multiple repositories.  
  To specify the source, use:
  ```powershell
  Install-Module -Name DumbMod -Repository PSGallery
  ```

- **Behavior of `Install-Module`:**  
  If the module is already installed, no matter which repository it comes from, no additional installation occurs, and no messages are displayed.

### Managing Installed Modules

To view installed modules and their sources, use:
```powershell
Get-InstalledModule
```

To uninstall a module:
```powershell
Uninstall-Module -Name DumbMod
```

### Summary
The developer does not need to manage the **Development** repository directly, as the process is automated and integrated into existing workflows.

---

### Additional Suggestions

1. Configure the **Development** repository to a roaming folder for portability.
2. Retrieve modules published in the **Development** repository with:
   ```powershell
   Get-InstalledModule | Where-Object { $_.Repository -eq 'Development' }
   ```

---
