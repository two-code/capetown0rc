package timeshift

import (
	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
)

type (
	timeshiftParamsT struct {
		snapshotDeviceID string
	}
)

var (
	timeshiftCmd       *cobra.Command
	timeshiftCmdParams *timeshiftParamsT
)

func (p *timeshiftParamsT) bindFlags() *pflag.FlagSet {
	fl := pflag.NewFlagSet("", pflag.PanicOnError)

	fl.StringVar(&p.snapshotDeviceID, "snapshot-device", "", "")

	return fl
}

func SetupTimeshiftCmd() *cobra.Command {
	timeshiftCmd = &cobra.Command{
		Use: "timeshift",
	}
	timeshiftCmdParams = &timeshiftParamsT{}

	timeshiftCmd.Flags().AddFlagSet(timeshiftCmdParams.bindFlags())

	timeshiftCmd.AddCommand(SetupCleanCmd())

	return timeshiftCmd
}
