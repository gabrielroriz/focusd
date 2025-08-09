package main

import (
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/getlantern/systray"
)

func main() {
	systray.Run(onReady, onExit)
}

func onReady() {
	systray.SetIcon(getIcon("../assets/focusd_icon.svg"))

	// State menu item
	mState := systray.AddMenuItem("State: ...", "Current focusd state")
	systray.SetTooltip("Focus App - State: ...")

	// Other menu items
	mShow := systray.AddMenuItem("Show message", "Show a notification")
	systray.AddSeparator()
	systray.AddMenuItemCheckbox("Enable focus mode", "Enable or disable focus mode", false)
	mQuit := systray.AddMenuItem("Quit", "Close the app")

	// Watch config file and update state
	go func() {
		var lastState string
		for {
			state := readFocusdState("/etc/focusd/focusd.conf")
			if state != lastState {
				mState.SetTitle("State: " + state)
				systray.SetTooltip("Focus App - State: " + state)
				lastState = state
			}
			time.Sleep(2 * time.Second)
		}
	}()

	// Handle menu actions
	go func() {
		for {
			select {
			case <-mShow.ClickedCh:
				fmt.Println("You clicked to show the message")
				cmd := exec.Command("notify-send", "-i", "focusd", "Hello from Go", "This is a notification.")
				if err := cmd.Run(); err != nil {
					fmt.Println("Error sending notification:", err)
				}
			case <-mQuit.ClickedCh:
				systray.Quit()
				return
			}
		}
	}()

	// Handle system interrupt (Ctrl+C or kill)
	go func() {
		c := make(chan os.Signal, 1)
		signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
		<-c
		fmt.Println("Received termination signal")
		systray.Quit()
	}()
}

func onExit() {
	fmt.Println("Exiting and cleaning up...")
	// Here you could:
	// - Close files
	// - Remove locks
	// - Stop goroutines if needed
}

func getIcon(path string) []byte {
	data, err := os.ReadFile(path)
	if err != nil {
		fmt.Println("Error loading icon:", err)
		return nil
	}
	return data
}

// Reads the state from /etc/focusd/focusd.conf
func readFocusdState(path string) string {
	data, err := os.ReadFile(path)
	strData := string(data)
	fmt.Println("Reading focusd state file:", strData)
	if err != nil {
		fmt.Println("Error reading focusd state file:", err)
		return "unknown"
	}
	lines := strings.Split(strData, "\n")
	for _, line := range lines {
		if strings.HasPrefix(line, "mode=") {
			return strings.TrimSpace(strings.TrimPrefix(line, "mode="))
		}
	}
	return "unknown"
}
