package bck

import (
	"github.com/spf13/cobra"
	"github.com/spf13/pflag"

	"github.com/two-code/capetown0rc.git/go/cmd/bck/timeshift"
)

type (
	bckCmdParamsT struct {
	}
)

var (
	bckCmd       *cobra.Command
	bckCmdParams *bckCmdParamsT
)

func (p *bckCmdParamsT) bindFlags() *pflag.FlagSet {
	fl := pflag.NewFlagSet("", pflag.PanicOnError)
	return fl
}

func SetupBckCmd() *cobra.Command {
	bckCmd = &cobra.Command{
		Use:           "bck",
		Short:         "",
		SilenceUsage:  true,
		SilenceErrors: false,
	}
	bckCmdParams = &bckCmdParamsT{}

	bckCmd.Flags().AddFlagSet(bckCmdParams.bindFlags())
	bckCmd.AddCommand(timeshift.SetupTimeshiftCmd())

	return bckCmd
}
