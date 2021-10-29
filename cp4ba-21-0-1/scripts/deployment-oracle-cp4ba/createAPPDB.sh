#!/usr/bin/env bash
###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2021. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################

dbuser=$1
dbpassword=$2
con=$3

echo "*** Creating DB user named: ${dbuser} ***"

sqlplus ${con} as sysdba <<EOF
-- create a new user
CREATE USER ${dbuser} IDENTIFIED BY ${dbpassword} ;

-- grant privileges to system and objects
grant create session to ${dbuser};
grant alter session to ${dbuser};
grant create table to ${dbuser};
grant unlimited tablespace to ${dbuser};
grant select any table to ${dbuser};
grant update any table to ${dbuser};
grant insert any table to ${dbuser};
grant drop any table to ${dbuser};
EOF