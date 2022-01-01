package timeshift

import (
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"

	"github.com/fatih/color"
)

var (
	cyanColor   = color.New(color.FgCyan)
	yellowColor = color.New(color.FgYellow)
	redColor    = color.New(color.FgRed)
	greenColor  = color.New(color.FgGreen)
)

func getSnapshots() ([]snapshot, error) {
	dirs, err := os.ReadDir(snapshotsDir)
	if err != nil {
		return nil, fmt.Errorf("error while reading the directory '%s'; err: %w", snapshotsDir, err)
	}

	res := []snapshot{}
	for _, dir := range dirs {
		if !dir.IsDir() {
			continue
		}

		dirPath := filepath.Join(snapshotsDir, dir.Name())
		if isSnashot, err := isSnapshotDir(dirPath); !isSnashot {
			if err != nil {
				return nil, fmt.Errorf("error while verifying snapshot directory '%s'; err: %w", dirPath, err)
			}
			yellowColor.Printf("directory '%s' is not a snapshot directory\n", dirPath)
			continue
		}

		res = append(res,
			snapshot{
				DirPath: dirPath,
			})
	}

	return res, nil
}

func isSnapshotDir(name string) (bool, error) {
	check := func(n string, err *error) bool {
		_, locErr := os.Stat(n)
		if errors.Is(locErr, fs.ErrNotExist) {
			return false
		}
		*err = locErr
		return locErr == nil
	}
	var err error
	errP := &err
	return check(filepath.Join(name, "info.json"), errP) &&
		check(filepath.Join(name, "rsync-log"), errP) &&
		check(filepath.Join(name, "rsync-log-changes"), errP), err
}
