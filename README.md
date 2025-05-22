# Xbox Manager - Modular Plugin System

A modular Golang CLI application for managing Xbox-related settings and applications on Windows with an extensible plugin system.

## Features

- **Plugin-based Architecture**: Each Xbox privacy operation is implemented as a separate plugin
- **Apply/Revert Operations**: Every plugin supports both applying changes and reverting them
- **Logging**: All operations are logged with timestamps for audit purposes
- **Interactive Menu**: Easy to use console interface for selecting and running operations

## Plugin Structure

Each operation consists of two paired plugin files:
- `{plugin_name}.bat` - Applies the change
- `{plugin_name}_undo.bat` - Reverts the change 

### Available Plugins

1. **Xbox App Removal** - Removes the main Xbox App
2. **Xbox Live Auth Manager** - Disables Xbox Live Authentication Manager service
3. **Xbox Live Game Save** - Disables Xbox Live Game Save service
4. **Xbox Live Networking Service** - Disables Xbox Live Networking Service
5. **Xbox Game Bar** - Removes Xbox Game Bar and Game Overlay
6. **Xbox Console Companion** - Removes outdated Xbox Console Companion
7. **Xbox Identity Provider** - Removes Xbox Identity Provider (breaks Xbox sign-in)
8. **Xbox Live In-Game Experience** - Removes Xbox Live in-game experience
9. **Xbox Speech To Text Overlay** - Removes Xbox Speech To Text Overlay
10. **Xbox Game Callable UI** - Removes Xbox Game Callable UI

## Usage

1. **Build the application:**
   ```bash
   go build
   ```

2. **Run the application:**
   ```bash
   xbox__tool.exe
   ```

3. **Select a plugin** from the numbered list
4. **Choose an operation** (Apply or Revert)
5. **Monitor the output** and check logs in the `logs/` directory

## File Structure

```
├── main.go              # Main CLI interface
├── plugin.go            # Plugin loading and management
├── executor.go          # Plugin execution logic
├── plugins/             # Plugin scripts directory
│   ├── *.bat           # Apply operation scripts
│   └── *_undo.bat      # Revert operation scripts
└── logs/               # Execution logs (created automatically)

```

## Plugin Development
To create new plugins:

1. Create two batch files in the `plugins/` directory:
   - `{plugin_name}.bat` - for applying changes
   - `{plugin_name}_undo.bat` - for reverting changes

2. Add metadata comments at the top of each file:
   ```batch
   REM PluginName: Your Plugin Name
   REM Description: What this plugin does
   ```

3. The system will automatically detect and load your plugins

## Requirements

- Windows 10/11
- PowerShell (for script execution)
- Administrator privileges (most operations require elevated access)
- Go 1.24+ (for building from source)

## Safety Features

- All operations are logged with timestamps
- Paired apply/revert operations for all changes
- Registry key backups through deprovisioning rather than deletion

## Notes

- **Administrator Rights Required**: Most plugins require administrator privileges to modify system settings
- **Backup Recommended**: While operations are designed to be reversible, creating a system backup is recommended
- **Windows Updates**: Some changes may be reverted by Windows updates; plugins handle re-provisioning where possible
