#!/bin/sh
# The folling are the two parameters to configure in this script
INSIGHTSKEY=<YOUR INSIGHTS KEY>
ACCOUNTID=<YOUR ACCOUNT ID>

# Collecting the data to build the insights query
MEMTOTAL=`grep MemTotal /proc/meminfo| awk '{print $2}'`
#echo $MEMTOTAL
MEMFREE=`grep MemFree /proc/meminfo| awk '{print $2}'`
#echo $MEMFREE
LOAD1=`awk '{print $1}' /proc/loadavg`
LOAD5=`awk '{print $2}' /proc/loadavg`
LOAD15=`awk '{print $3}' /proc/loadavg`
SWPSZ=`awk '{size=$3} END {print size}' /proc/swaps`
SWPSD=`awk '{used=$4} END {print used}' /proc/swaps`
RXB=`cat /sys/class/net/ppp0/statistics/rx_bytes`
TXB=`cat /sys/class/net/ppp0/statistics/tx_bytes`
CST=`mpstat 1 1 | awk '{usr=$3; sys=$5; iowait=$6; idle=$12} END{print usr " " sys " " iowait " " idle }'`
CUSR=$(echo $CST | cut -f1 -d" ")
CSYS=$(echo $CST | cut -f2 -d" ")
CIOW=$(echo $CST | cut -f3 -d" ") 
CIDL=$(echo $CST | cut -f4 -d" ")
UPTIME=`awk -F" " '{print $1}' /proc/uptime`

# ppp0 transfer rate
cd /tmp/mnt/rtrDisk/bricAbrac
mv rxt2 rxt1
cat /sys/class/net/ppp0/statistics/rx_bytes > rxt2
if test `cat rxt2` -gt `cat rxt1`                      
then                                                   
	rxtmp=$(expr `cat rxt2` - `cat rxt1`)
	timetmp=$(expr `stat -c"%Y" rxt2` - `stat -c"%Y" rxt1`)
	RXBPS=`expr $rxtmp / $timetmp`
fi

mv txt2 txt1
cat /sys/class/net/ppp0/statistics/tx_bytes > txt2
if test `cat txt2` -gt `cat txt1`                              
then                                                           
	txtmp=$(expr `cat txt2` - `cat txt1`)
	timetmp=$(expr `stat -c"%Y" txt2` - `stat -c"%Y" txt1`)
	TXBPS=`expr $txtmp / $timetmp`
fi
# END ppp0 transfer rate

# Insert in insights
echo "[ { \"eventType\":\"RtrPerf\", \"memtotal\":" $MEMTOTAL " , \"memfree\":" $MEMFREE " , \"uptime\":" $UPTIME " , \"load1m\":" $LOAD1 " , \"load5m\":" $LOAD5 " , \"load15m\":" $LOAD15 " , \"swapSize\":" $SWPSZ " , \"swapUsed\":" $SWPSD " , \"rxBytes\":" $RXB " , \"txBytes\":" $TXB " , \"cpuUser\":" $CUSR " , \"cpuSys\":" $CSYS " , \"cpuIowait\":" $CIOW " , \"cpuIdle\":" $CIDL " , \"txBytesPerS\":" $TXBPS " , \"rxBytePerS\":" $RXBPS " } ]" | gzip -c | curl -X POST -H "Content-Type: application/json" -H "X-Insert-Key: $INSIGHTSKEY" -H "Content-Encoding: gzip" https://insights-collector.newrelic.com/v1/accounts/$ACCOUNTID/events --data-binary @-

