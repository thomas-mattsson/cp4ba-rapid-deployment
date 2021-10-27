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

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ORACLE_INPUT_PROPS_FILENAME="01-parametersForOracle.sh"
ORACLE_INPUT_PROPS_FILENAME_FULL="${CUR_DIR}/${ORACLE_INPUT_PROPS_FILENAME}"

if [[ -f $ORACLE_INPUT_PROPS_FILENAME_FULL ]]; then
   echo
   echo "Found ${ORACLE_INPUT_PROPS_FILENAME}.  Reading in variables from that script."
   . $ORACLE_INPUT_PROPS_FILENAME_FULL
   
   if [ $oracleSysUserPassword == "REQUIRED" ]; then
      echo "File ${ORACLE_INPUT_PROPS_FILENAME} not fully updated. Pls. update all REQUIRED parameters."
      echo
      exit 0
   fi
   
   echo "Done!"
else
   echo
   echo "File ${ORACLE_INPUT_PROPS_FILENAME_FULL} not found. Pls. check."
   echo
   exit 0
fi

echo
echo -e "\x1B[1mThis script CREATES all needed CP4BA databases (assumes Db2u is running in project ${oracleOnOcpProjectName}). \n \x1B[0m"

printf "Do you want to continue (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Creating all needed CP4BA databases..."
    ;;
*)
    echo
    echo -e "Exiting..."
    echo
    exit 0
    ;;
esac

oracleCon="sys/${oracleSysUserPassword}@//${oracleHostName}:${oraclePortNumber}/${oracleDb} as sysdba"

echo
echo "Creating database ${oracleUmsdbName}..."
. createUMSDB.sh ${oracleUmsdbName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleIcndbName}..."
. createICNDB.sh ${oracleIcndbName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleDevos1Name}..."
. createOSDB.sh ${oracleDevos1Name} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleAeosName}..."
. createOSDB.sh ${oracleAeosName} ${oracleCP4BAUsersPw} ${oracleCon}
  
echo
echo "Creating database ${oracleBawDocsName}..."
. createOSDB.sh ${oracleBawDocsName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleBawDosName}..."
. createOSDB.sh ${oracleBawDosName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleBawTosName}..."
. createOSDB.sh ${oracleBawTosName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleBawDbName}..."
. createBAWDB.sh ${oracleBawDbName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleAppdbName}..."
. createAPPDB.sh ${oracleAppdbName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleAedbName}..."
. createAPPDB.sh ${oracleAedbName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleBasdbName}..."
. createBASDB.sh ${oracleBasdbName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Creating database ${oracleGcddbName}..."
. createGCDDB.sh ${oracleGcddbName} ${oracleCP4BAUsersPw} ${oracleCon}

echo
echo "Done. Exiting..."
echo
