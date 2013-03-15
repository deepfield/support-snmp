#!/bin/bash
 
USAGE="Usage: $0 <community-string> <router-ip> [<router-ips>]"
COMM_STR=${1?$USAGE}
ROUTER_IP=${2?$USAGE}
ROUTER_IPS=${@:3}
 
DIR=/tmp/deepfield_walk;
TAR=$DIR.tar.bz;
mkdir -p $DIR;
 
function run {
  CMD="snmpbulkwalk -Cr10000 -v 2c -c $COMM_STR $1"
  echo $CMD
 
  echo "router:$1" >> $DIR/alias
  $CMD 1.3.6.1.2.1.31.1.1.1.18 >> $DIR/alias
 
  echo "router:$1" >> $DIR/name
  $CMD 1.3.6.1.2.1.31.1.1.1.1 >> $DIR/name
 
  echo "router:$1" >> $DIR/index
  $CMD 1.3.6.1.2.1.2.2.1.1 >> $DIR/index
 
  echo "router:$1" >> $DIR/desc
  $CMD 1.3.6.1.2.1.2.2.1.2 >> $DIR/desc
}
 
run $ROUTER_IP;
for ri in $ROUTER_IPS;
do
  run $ri;
done
 
tar cfj $TAR $DIR;
 
echo "Send $TAR to support@deepfield.net"
