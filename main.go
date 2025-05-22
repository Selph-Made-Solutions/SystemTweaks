package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

func main() {
	cwd, err := os.Getwd()
	if err != nil {
		fmt.Printf("Error getting current directory: %v\n", err)
		return
	}
	pluginsDir := filepath.Join(cwd, "plugins")
	logsDir := filepath.Join(cwd, "logs")

	if _, err := os.Stat(pluginsDir); os.IsNotExist(err) {
		fmt.Printf("Plugins directory not found, creating: %s\n", pluginsDir)
		if err = os.MkdirAll(pluginsDir, os.ModePerm); err != nil {
			fmt.Printf("Failed to create plugins directory: %v\n", err)
			return
		}
	}

	if _, err := os.Stat(logsDir); os.IsNotExist(err) {
		if err = os.MkdirAll(logsDir, os.ModePerm); err != nil {
			fmt.Printf("Failed to create logs directory: %v\n", err)
			return
		}
	}

	reader := bufio.NewReader(os.Stdin)
	for {
		plugins, invalidFiles, err := LoadPlugins(pluginsDir)
		if err != nil {
			fmt.Printf("Error loading plugins: %v\n", err)
			return
		}

        fmt.Println("\n=== Xbox Manager - Plugin System ===")
		fmt.Println("Available Plugins:")
		if len(plugins) == 0 {
			fmt.Println("  [No valid plugins found]")
		}
		for i, pl := range plugins {
			fmt.Printf("  %d) %s - %s\n", i+1, pl.Name, pl.Description)
			for j, op := range pl.Operations {
				action := "Apply"
				if op.IsUndo {
					action = "Revert"
				}
				fmt.Printf("     %c) %s\n", 'a'+j, action)
			}
		}

		if len(invalidFiles) > 0 {
			fmt.Printf("\n%d script(s) skipped (missing metadata): %v\n", len(invalidFiles), invalidFiles)
		}

		fmt.Println("\nR) Refresh plugins list")
		fmt.Println("Q) Quit")
		fmt.Print("Select a plugin number: ")

		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)
		inputUpper := strings.ToUpper(input)

		if inputUpper == "Q" {
			fmt.Println("Exiting.")
			break
		}
		if inputUpper == "R" {
			continue
		}

		choice, err := strconv.Atoi(input)
		if err != nil {
			fmt.Println("Invalid selection. Please enter a number, 'R', or 'Q'.")
			continue
		}
		if choice < 1 || choice > len(plugins) {
			fmt.Println("Invalid plugin number. Please try again.")
			continue
		}

		selected := plugins[choice-1]

		var selectedOp PluginOperation
		if len(selected.Operations) > 1 {
			fmt.Printf("\nSelected plugin: %s\n", selected.Name)
			for i, op := range selected.Operations {
				action := "Apply"
				if op.IsUndo {
					action = "Revert"
				}
				fmt.Printf("  %c) %s - %s\n", 'a'+i, action, op.Description)
			}
			fmt.Print("Select operation (a, b, etc.): ")

			opInput, _ := reader.ReadString('\n')
			opInput = strings.TrimSpace(strings.ToLower(opInput))

			if len(opInput) != 1 || opInput[0] < 'a' || opInput[0] >= 'a'+byte(len(selected.Operations)) {
				fmt.Println("Invalid operation selection.")
				continue
			}

			selectedOp = selected.Operations[opInput[0]-'a']
		} else if len(selected.Operations) == 1 {
			selectedOp = selected.Operations[0]
		} else {
			fmt.Println("No operations available for this plugin.")
			continue
		}

		action := "Applying"
		if selectedOp.IsUndo {
			action = "Reverting"
		}
		fmt.Printf("\n%s '%s'...\n", action, selected.Name)

		err = ExecutePluginOperation(selectedOp, logsDir)
		if err != nil {
			fmt.Printf("Error executing plugin: %v\n", err)
		}

		fmt.Println("\nPlugin execution completed. Press Enter to return to menu.")
		reader.ReadString('\n')
	}
}
