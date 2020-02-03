#!/bin/bash

#
# Copyright (c) 2013-2019 Nokia Deepfield.
#


function usage {
    if [ ! -z "$1" ] ; then
        echo "ERROR: $1"
        echo
    fi
    echo "Usage:"
    echo -e "\t$0 v2 <community> <router-ip>..."
    echo -e "\t$0 v3 noAuthNoPriv <username> <router-ip>..."
    echo -e "\t$0 v3 authNoPriv <username> MD5|SHA <passphrase> <router-ip>..."
    echo -e "\t$0 v3 authPriv <username> MD5|SHA <passphrase> DES|AES <priv-passphrase> <router-ip>..."
    exit 1
}


function process_oid {
    DIR=$1
    ROUTER=$2
    CMD=$3
    OID=$4
    NAME=$5

    echo "router:$ROUTER" >>"$DIR/$NAME"
    $CMD "$ROUTER" "$OID" >>"$DIR/$NAME"
}


function process_router {
    DIR=$1
    ROUTER=$2
    CMD=$3

    echo "$CMD" "$ROUTER" ...

    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.9.2.1.3 routerName
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.1.6 routerLocation
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.1.1.0 sysDescr
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.2.2.1.1 index
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.31.1.1.1.1 name
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.31.1.1.1.18 alias
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.2.2.1.2 desc
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.31.1.1.1.15 ifHighSpeed
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.31.1.1.1.6 ifHCInOctets
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.2.1.31.1.1.1.10 ifHCOutOctets
    process_oid "$DIR" "$ROUTER" "$CMD" 1.2.840.10006.300.43.1.2.1.1.13 dot3adAggPortAttachedAggID
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.2011.5.25.110.1.2.1.2 huawei_netstream_mapping
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.1.1.4 alcatel_vRtrName
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.19.1.19 alcatel_tmnxCflowdVRtrIfIndexContext
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.4.1.63 alcatel_vRtrIfGlobalIndex
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.4.1.5 alcatel_vRtrIfPortID
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.4.1.4 alcatel_vRtrIfName
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.4.1.10 alcatel_vRtrIfAlias
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.4.1.34 alcatel_vRtrIfDesc
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.4.1.3 alcatel_vRtrIfType
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.54.1.40 alcatel_vRtrIfRxPkts
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.54.1.43 alcatel_vRtrIfRxBytes
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.74.1.1 alcatel_vRtrIfTxPkts
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.74.1.4 alcatel_vRtrIfTxBytes
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.4.1.9 alcatel_vRtrIfOperState
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.4.1.62 alcatel_vRtrIfOperMtu
    process_oid "$DIR" "$ROUTER" "$CMD" 1.3.6.1.4.1.6527.3.1.2.3.54.1.103 alcatel_vRtrIfSpeed
}


function run {
    CMD=$1
    ROUTER_IPS=${@:2}
    if [ -z "$ROUTER_IPS" ] ; then
        usage "No router specified."
    fi

    DIR='/tmp/deepfield_walk'
    TAR="$DIR.tar.bz"

    rm -rf "$DIR"
    mkdir -p "$DIR"

    for ROUTER in $ROUTER_IPS ; do
        process_router "$DIR" "$ROUTER" "$CMD"
    done

    tar -cjvf "$TAR" "$DIR"
    rm -rf "$DIR"

    echo "Send $TAR to support@deepfield.net"
}


VER=$1

case $VER in
    v2)
        COMMUNITY=$2
        if [ -z "$COMMUNITY" ] ; then
            usage "Community string not specified."
        fi
        run "snmpbulkwalk -v 2c -c $COMMUNITY" ${@:3}
        ;;
    v3)
        LEVEL=$2
        USERNAME=$3
        if [ -z "$USERNAME" ] ; then
            usage "Username not specified."
        fi
        case $LEVEL in
            noAuthNoPriv)
                run "snmpbulkwalk -Cr10000 -v 3 -l noAuthNoPriv -u $USERNAME" ${@:4}
                ;;
            authNoPriv)
                PROTOCOL=$4
                if [ -z "$PROTOCOL" ] ; then
                    usage "Protocol not specified (MD5/SHA)."
                fi
                PASSPHRASE=$5
                if [ -z "$PASSPHRASE" ] ; then
                    usage "Passphrase not specified."
                fi
                run "snmpbulkwalk -Cr10000 -v 3 -l authNoPriv -u $USERNAME -a $PROTOCOL -A $PASSPHRASE" ${@:6}
                ;;
            authPriv)
                PROTOCOL=$4
                if [ -z "$PROTOCOL" ] ; then
                    usage "Protocol not specified (MD5/SHA)."
                fi
                PASSPHRASE=$5
                if [ -z "$PASSPHRASE" ] ; then
                    usage "Passphrase not specified."
                fi
                PRIV_PROTOCOL=$6
                if [ -z "$PRIV_PROTOCOL" ] ; then
                    usage "Privacy protocol not specified (DES/AES)."
                fi
                PRIV_PASSPHRASE=$7
                if [ -z "$PRIV_PASSPHRASE" ] ; then
                    usage "Privacy passphrase not specified."
                fi
                run "snmpbulkwalk -Cr10000 -v 3 -l authNoPriv -u $USERNAME -a $PROTOCOL -A $PASSPHRASE -x $PRIV_PROTOCOL -X $PRIV_PASSPHRASE" ${@:8}
                ;;
            "")
                usage "Security level not specified."
                ;;
            *)
                usage "Unexpected security level '$LEVEL'."
                ;;
        esac
        ;;
    "")
        usage
        ;;
    *)
        usage "Unexpected SNMP version '$VER'."
        ;;
esac

exit 0
