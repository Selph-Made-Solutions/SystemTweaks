package main

import (
	"bufio"
	"errors"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

type PluginOperation struct {
	Name        string
	Description string
	FilePath    string
	IsUndo      bool
}

type Plugin struct {
	Name        string
	Description string
	Operations  []PluginOperation
}

func LoadPlugins(dir string) ([]Plugin, []string, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, nil, err
	}

	pluginMap := make(map[string]*Plugin)
	var invalid []string

	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		name := entry.Name()
		ext := strings.ToLower(filepath.Ext(name))
		if ext != ".ps1" && ext != ".bat" && ext != ".cmd" {
			continue
		}

		path := filepath.Join(dir, name)
		op, err := parsePluginOperation(path, ext)
		if err != nil {
			invalid = append(invalid, name)
			continue
		}

		baseName := name
		isUndo := false
		if strings.Contains(strings.ToLower(name), "_undo.") {
			baseName = strings.Replace(name, "_undo.", ".", 1)
			isUndo = true
		}

		baseKey := strings.TrimSuffix(baseName, filepath.Ext(baseName))

		if pluginMap[baseKey] == nil {
			pluginMap[baseKey] = &Plugin{
				Name:        op.Name,
				Description: getBaseDescription(op.Description),
				Operations:  []PluginOperation{},
			}
		}

		op.IsUndo = isUndo
		pluginMap[baseKey].Operations = append(pluginMap[baseKey].Operations, op)
	}

	var plugins []Plugin
	for _, plugin := range pluginMap {
		sort.Slice(plugin.Operations, func(i, j int) bool {
			return !plugin.Operations[i].IsUndo && plugin.Operations[j].IsUndo
		})
		plugins = append(plugins, *plugin)
	}

	sort.Slice(plugins, func(i, j int) bool {
		return strings.ToLower(plugins[i].Name) < strings.ToLower(plugins[j].Name)
	})

	return plugins, invalid, nil
}

func parsePluginOperation(path string, ext string) (PluginOperation, error) {
	file, err := os.Open(path)
	if err != nil {
		return PluginOperation{}, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var name, desc string
	for scanner.Scan() {
		line := scanner.Text()
		trimmedLeft := strings.TrimLeft(line, " \t")
		if ext == ".ps1" {
			if strings.HasPrefix(trimmedLeft, "#") {
				content := strings.TrimSpace(strings.TrimPrefix(trimmedLeft, "#"))
				if parts := strings.SplitN(content, ":", 2); len(parts) == 2 {
					key := strings.TrimSpace(parts[0])
					val := strings.TrimSpace(parts[1])
					if strings.EqualFold(key, "PluginName") {
						name = val
					} else if strings.EqualFold(key, "Description") {
						desc = val
					}
				}
				continue
			} else if trimmedLeft == "" {
				continue
			} else {
				break
			}
		} else if ext == ".bat" || ext == ".cmd" {
			upper := strings.ToUpper(trimmedLeft)
			if strings.HasPrefix(upper, "REM ") {
				content := strings.TrimSpace(trimmedLeft[4:])
				if parts := strings.SplitN(content, ":", 2); len(parts) == 2 {
					key := strings.TrimSpace(parts[0])
					val := strings.TrimSpace(parts[1])
					if strings.EqualFold(key, "PluginName") {
						name = val
					} else if strings.EqualFold(key, "Description") {
						desc = val
					}
				}
				continue
			} else if strings.HasPrefix(trimmedLeft, "::") {
				content := strings.TrimSpace(trimmedLeft[2:])
				if parts := strings.SplitN(content, ":", 2); len(parts) == 2 {
					key := strings.TrimSpace(parts[0])
					val := strings.TrimSpace(parts[1])
					if strings.EqualFold(key, "PluginName") {
						name = val
					} else if strings.EqualFold(key, "Description") {
						desc = val
					}
				}
				continue
			} else if trimmedLeft == "" {
				continue
			} else {
				break
			}
		}
	}
	if err := scanner.Err(); err != nil {
		return PluginOperation{}, err
	}
	if name == "" || desc == "" {
		return PluginOperation{}, errors.New("missing required metadata")
	}
	return PluginOperation{Name: name, Description: desc, FilePath: path}, nil
}

func getBaseDescription(description string) string {
	if strings.HasSuffix(description, "(Undo)") {
		return strings.TrimSpace(strings.TrimSuffix(description, "(Undo)"))
	}
	return description
}
