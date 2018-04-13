#!/bin/bash
#telnet alternative to ping a tcp/udp port
host=$1
port=$2
protocol="${3:-tcp}"
echo >/dev/$protocol/$host/$port
