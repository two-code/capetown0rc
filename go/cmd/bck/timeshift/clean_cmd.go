package timeshift

import (
	"fmt"
	"os"
	"sort"

	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
)

type (
	cleanCmdParamsT struct {
		timeshift *timeshiftParamsT

		retainCount int
	}
)

var (
	cleanCmd       *cobra.Command
	cleanCmdParams *cleanCmdParamsT
)

func SetupCleanCmd() *cobra.Command {
	cleanCmd = &cobra.Command{
		Use:  "clean",
		RunE: cleanCmdExec,
	}
	cleanCmdParams = &cleanCmdParamsT{
		timeshift: &timeshiftParamsT{},
	}

	cleanCmd.Flags().AddFlagSet(cleanCmdParams.bindFlags())

	return cleanCmd
}

func (p *cleanCmdParamsT) bindFlags() *pflag.FlagSet {
	fl := pflag.NewFlagSet("", pflag.PanicOnError)

	fl.AddFlagSet(p.timeshift.bindFlags())

	fl.IntVar(&p.retainCount, "retain-count", 7, "number of snapshots to retain")

	return fl
}

func cleanCmdExec(cmd *cobra.Command, args []string) error {
	snapshots, err := getSnapshots()
	if err != nil {
		return err
	}

	snapshotToRemoveCnt := func() int {
		val := len(snapshots) - cleanCmdParams.retainCount
		if val < 0 {
			return 0
		}
		return val
	}()
	sort.Slice(snapshots, func(i, j int) bool { return snapshots[i].DirPath < snapshots[j].DirPath })

	cyanColor.Printf("snapshots (%d from %d will be removed):\n", snapshotToRemoveCnt, len(snapshots))
	for i, snapshot := range snapshots {
		if i < snapshotToRemoveCnt {
			yellowColor.Printf("%d) %s: removing...", i+1, snapshot.DirPath)
			err = os.RemoveAll(snapshot.DirPath)
			if err != nil {
				redColor.Println(" error")
				return fmt.Errorf("error while removing snapshot '%s'; err: %w", snapshot.DirPath, err)
			}
			greenColor.Println(" done")
			continue
		}
		cyanColor.Printf("%d) %s: retained\n", i+1, snapshot.DirPath)
	}

	return nil
}
