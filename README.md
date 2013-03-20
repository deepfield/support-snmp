 
This script will automatically collect snmp info about your network if you choose to not have it automatically collected.
Mail the results to support at deepfield.net.

This script requires snmpwalk, if you don't have snmpwalk, you can install it with apt-get on ubuntu:
```
   $ sudo apt-get install snmp
```

To download the script and run with the ips of your routers along with their community string:
```
  $ curl -o snmpwalk.bash https://raw.github.com/deepfield/support-snmp/master/snmpwalk.bash
  $ bash snmpwalk.bash <community-string> <router-ip> [<router-ips>]
```
