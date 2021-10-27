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

sqlplus ${con} <<EOF
-- create a new user
CREATE USER ${dbuser} IDENTIFIED BY AUTHORING_USER_PASSW0RD;

-- allow the user to connect to the database
grant connect to ${dbuser};

-- provide quota on all tablespaces with BPM tables
grant unlimited tablespace to ${dbuser};

-- grant privileges to create database objects:
grant resource to ${dbuser};
grant create view to ${dbuser};

-- grant access rights to resolve lock issues
grant execute on dbms_lock to ${dbuser};

-- grant access rights to resolve XA related issues:
grant select on pending_trans$ to ${dbuser};
grant select on dba_2pc_pending to ${dbuser};
grant select on dba_pending_transactions to ${dbuser};

-- If you're using Oracle 10.2.0.3 or lower JDBC driver, un-comment the following statement:
-- grant execute on dbms_system to ${dbuser};

-- If you're not using Oracle 10.2.0.4 or higher JDBC driver, comment the following statement:
grant execute on dbms_xa to ${dbuser};
EOF