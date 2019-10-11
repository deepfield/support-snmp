#!/bin/bash

USAGE="Usage: $0 <community-string> <router-ip> [<router-ips>]"
COMM_STR=${1?$USAGE}
ROUTER_IP=${2?$USAGE}
ROUTER_IPS=${@:3}

DIR=/tmp/deepfield_walk;
TAR=$DIR.tar.bz;

rm -fr $DIR; # remove old run
mkdir -p $DIR;

function run {
  CMD="snmpwalk -v 2c -c $COMM_STR $1"
  echo $CMD

  echo "router:$1" >> $DIR/routerName
  $CMD 1.3.6.1.4.1.9.2.1.3 >> $DIR/routerName

  echo "router:$1" >> $DIR/routerLocation
  $CMD 1.3.6.1.2.1.1.6 >> $DIR/routerLocation

  echo "router:$1" >> $DIR/sysDescr
  $CMD 1.3.6.1.2.1.1.1.0 >> $DIR/sysDescr

  echo "router:$1" >> $DIR/index
  $CMD 1.3.6.1.2.1.2.2.1.1 >> $DIR/index

  echo "router:$1" >> $DIR/name
  $CMD 1.3.6.1.2.1.31.1.1.1.1 >> $DIR/name

  echo "router:$1" >> $DIR/alias
  $CMD 1.3.6.1.2.1.31.1.1.1.18 >> $DIR/alias

  echo "router:$1" >> $DIR/desc
  $CMD 1.3.6.1.2.1.2.2.1.2 >> $DIR/desc

  echo "router:$1" >> $DIR/ifHighSpeed
  $CMD 1.3.6.1.2.1.31.1.1.1.15 >> $DIR/ifHighSpeed

  echo "router:$1" >> $DIR/ifHCInOctets
  $CMD 1.3.6.1.2.1.31.1.1.1.6 >> $DIR/ifHCInOctets

  echo "router:$1" >> $DIR/ifHCOutOctets
  $CMD 1.3.6.1.2.1.31.1.1.1.10 >> $DIR/ifHCOutOctets

  echo "router:$1" >> $DIR/dot3adAggPortAttachedAggID
  $CMD 1.2.840.10006.300.43.1.2.1.1.13 >> $DIR/dot3adAggPortAttachedAggID
  
  echo "router:$1" >> $DIR/huawei_netstream_mapping
  $CMD 1.3.6.1.4.1.2011.5.25.110.1.2.1.2 >> $DIR/huawei_netstream_mapping

  echo "router:$1" >> $DIR/alcatel_vRtrName
  $CMD 1.3.6.1.4.1.6527.3.1.2.3.1.1.4 >> $DIR/alcatel_vRtrName

  echo "router:$1" >> $DIR/alcatel_tmnxCflowdVRtrIfIndexContext
  $CMD 1.3.6.1.4.1.6527.3.1.2.19.1.19 >> $DIR/alcatel_tmnxCflowdVRtrIfIndexContext

  echo "router:$1" >> $DIR/alcatel_vRtrIfGlobalIndex
  $CMD 1.3.6.1.4.1.6527.3.1.2.3.4.1.63 >> $DIR/alcatel_vRtrIfGlobalIndex

  echo "router:$1" >> $DIR/alcatel_vRtrIfPortID
  $CMD 1.3.6.1.4.1.6527.3.1.2.3.4.1.5 >> $DIR/alcatel_vRtrIfPortID

  echo "router:$1" >> $DIR/alcatel_vRtrIfName
  $CMD 1.3.6.1.4.1.6527.3.1.2.3.4.1.4 >> $DIR/alcatel_vRtrIfName

  echo "router:$1" >> $DIR/alcatel_vRtrIfAlias
  $CMD 1.3.6.1.4.1.6527.3.1.2.3.4.1.10 >> $DIR/alcatel_vRtrIfAlias

  echo "router:$1" >> $DIR/alcatel_vRtrIfDesc
  $CMD 1.3.6.1.4.1.6527.3.1.2.3.4.1.34 >> $DIR/alcatel_vRtrIfDesc

  echo "router:$1" >> $DIR/alcatel_vRtrIfType
  $CMD 1.3.6.1.4.1.6527.3.1.2.3.4.1.3 >> $DIR/alcatel_vRtrIfType
}

run $ROUTER_IP;
for ri in $ROUTER_IPS;
do
  run $ri;
done

tar cfj $TAR $DIR;

echo "Send $TAR to support@deepfield.net"
