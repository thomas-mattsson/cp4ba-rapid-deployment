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
CREATE USER ${dbuser} IDENTIFIED BY ${dbpassword};

GRANT CREATE TABLE TO ${dbuser};
GRANT CREATE SESSION TO ${dbuser};
GRANT CREATE SEQUENCE TO ${dbuser};
GRANT UNLIMITED TABLESPACE TO ${dbuser};