package main

import (
	"os"

	"github.com/fatih/color"
	"github.com/spf13/cobra"

	"github.com/two-code/capetown0rc.git/go/cmd/bck"
)

var (
	rootCmd = &cobra.Command{
		Use:           "",
		Short:         "",
		SilenceUsage:  true,
		SilenceErrors: true,
	}

	errColor = color.New(color.FgHiRed)
)

func main() {
	rootCmd.AddCommand(bck.SetupBckCmd())
	err := rootCmd.Execute()
	if err != nil {
		errColor.Println("──────")
		errColor.Println("ERROR:")
		errColor.Printf("%s\n", err)
		errColor.Println("──────")
		os.Exit(1)
	}
}
