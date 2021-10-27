#!/bin/bash
# set -x
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

echo "  Reading 01-parametersForOracle.sh ..."

# ----------------------------------------------
# --- Parameters that usually need an update ---
# ----------------------------------------------

# --- Provide those BEFORE running script 02-createCp4baDBs4Oracle.sh ---

# Password for Oracle sys user
oracleSysUserPassword=REQUIRED

# This value can be either a hostname or an IP
oracleHostName=REQUIRED

# Oracle port number (1521 standard)
oraclePortNumber=REQUIRED

# Oracle db name
oracleDb=REQUIRED

# Password to use for the users being created by this script
oracleCP4BAUsersPw=REQUIRED

# Oracle SID, to get it from connection use: SELECT sys_context('userenv','instance_name') FROM dual;
oracleSID=REQUIRED

# Oracle service name, to get it from connection use: select name from v$database;
oracleServiceName=REQUIRED

# -----------------------------------------------------
# --- Parameters that usually do NOT need an update ---
# -----------------------------------------------------

# Oracle JDBC URL (generated)
oracleJDBCUrl=jdbc:oracle:thin:@//${oracleHostName}:${oraclePortNumber}/${oracleServiceName}

# Oracle connection URL (generated)
oracleConnectionUrl=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${oracleHostName})(PORT=${oraclePortNumber}))(CONNECT_DATA=(SERVICE_NAME=${oracleServiceName}))))

# Oracle connection URL with wallet (generated)
oracleWalletConnectionUrl=(DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=${oracleHostName})(PORT=${oraclePortNumber}))(CONNECT_DATA=(SERVICE_NAME=${oracleServiceName}))(SECURITY=(SSL_SERVER_DN_MATCH=FALSE)(MY_WALLET_DIRECTORY=/shared/resources/oracle/wallet)))

# Oracle driver files
oracleDriverFile=ojdbc8.jar

# --- If changes are needed here, provide those BEFORE running script 02-createCp4baDBs4Oracle.sh ---

# Selected CP4BA template to use for deployment, for example ibm_cp4a_cr_template.101.ent.ClientOnboardingDemo.Oracle.yaml
#   Available templates:
#     ibm_cp4a_cr_template.101.ent.ClientOnboardingDemo.Oracle.yaml
cp4baTemplateToUse=ibm_cp4a_cr_template.101.ent.ClientOnboardingDemo.Oracle.yaml

# CP4BA Database Name information
oracleUmsdbName=UMSDB
oracleIcndbName=ICNDB
oracleDevos1Name=DEVOS1
oracleAeosName=AEOS
oracleBawDocsName=BAWDOCS
oracleBawTosName=BAWTOS
oracleBawDosName=BAWDOS
oracleBawDbName=BAWDB
oracleAppdbName=APPDB
oracleAedbName=AEDB
oracleBasdbName=BASDB
oracleGcddbName=GCDDB

# --- end of file ---



