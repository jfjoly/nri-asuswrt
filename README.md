# nri-asuswrt
Monitoring script for AsusWRT Merlin router OS

## Install
1. Edit the varaibles `INSIGHTSKEY` and `ACCOUNTID` in the script
1. Copy the script to `/jffs/scripts/` on your router
1. Edit the file `/jffs/scripts/services-start` on your router
1. Add the following line so that the script is added to the crontab everytime the router starts
```
cru a New_Relic_exporter '* * * * * sh /jffs/scripts/export_perf.sh'
```
1. Add the script to the crontab by executung the same command in a shell
1. In New Relic's chart builder , execute the following query:
```
FROM RtrPerf  SELECT * since 10 minutes ago 
```
1. Start building your own dashboard
