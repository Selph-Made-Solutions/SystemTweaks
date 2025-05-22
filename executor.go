package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

func ExecutePluginOperation(op PluginOperation, logsDir string) error {
	base := filepath.Base(op.FilePath)
	nameBase := strings.TrimSuffix(base, filepath.Ext(base))
	timestamp := time.Now().Format("20060102_150405")
	logFileName := fmt.Sprintf("%s_%s.log", nameBase, timestamp)
	logPath := filepath.Join(logsDir, logFileName)

	f, err := os.Create(logPath)
	if err != nil {
		return fmt.Errorf("failed to create log file: %w", err)
	}
	defer func(f *os.File) {
		err := f.Close()
		if err != nil {
			fmt.Printf("Failed to close log file: %v\n", err)
		}
	}(f)

	action := "Applying"
	if op.IsUndo {
		action = "Reverting"
	}
	header := fmt.Sprintf("[%s] %s operation: %s\n", time.Now().Format(time.RFC3339), action, op.Name)
	f.WriteString(header)
	fmt.Printf("Logging output to: %s\n", logPath)

	var cmd *exec.Cmd
	ext := strings.ToLower(filepath.Ext(op.FilePath))
	if ext == ".ps1" {
		cmd = exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", op.FilePath)
	} else if ext == ".bat" || ext == ".cmd" {
		cmd = exec.Command("cmd", "/C", op.FilePath)
	} else {
		return fmt.Errorf("unsupported file extension: %s", ext)
	}
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
	cmd.Dir = filepath.Dir(op.FilePath)

	multi := io.MultiWriter(os.Stdout, f)
	cmd.Stdout = multi
	cmd.Stderr = multi

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(f, "Plugin operation failed: %v\n", err)
		fmt.Printf("Plugin operation failed: %v\n", err)
	}
	return nil
}

func ExecutePlugin(pl Plugin, logsDir string) error {
	if len(pl.Operations) == 0 {
		return fmt.Errorf("no operations available for plugin: %s", pl.Name)
	}
	return ExecutePluginOperation(pl.Operations[0], logsDir)
}
