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
oracleDatafileBase=$4

echo "*** Creating DB user named: ${dbuser} ***"

sqlplus ${con} as sysdba <<EOF
-- https://www.ibm.com/docs/en/filenet-p8-platform/5.5.x?topic=accounts-creating-content-platform-engine-database-user-oracle
CREATE USER ${dbuser} IDENTIFIED BY ${dbpassword};

grant create session to ${dbuser};
grant create TABLE to ${dbuser};
grant create VIEW to ${dbuser};
grant create SEQUENCE to ${dbuser};
grant select on pending_trans$ to ${dbuser};
grant select on dba_2pc_pending to ${dbuser};
grant select on dba_pending_transactions to ${dbuser};
grant select on DUAL to ${dbuser};
grant select on product_component_version to ${dbuser};
grant select on USER_INDEXES to ${dbuser};
grant execute on dbms_xa to ${dbuser};

-- https://www.ibm.com/docs/en/filenet-p8-platform/5.5.x?topic=vtosiifp-creating-oracle-table-space-content-platform-engine-gcd

CREATE TABLESPACE gcd DATAFILE '${oracleDatafileBase}gcd.dbf' SIZE 100M;
CREATE TEMPORARY TABLESPACE tempgcd TEMPFILE '${oracleDatafileBase}tempgcd.dbf' SIZE 2G;

alter user ${dbuser} quota unlimited on gcd;
EOF

echo "*** Done creating DB user named: ${dbuser} ***"
