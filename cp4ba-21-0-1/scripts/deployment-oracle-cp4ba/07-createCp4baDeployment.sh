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
   
   if [ $oracleHostName == "REQUIRED" ] || [ $oraclePortNumber == "REQUIRED" ]; then
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

CP4BA_INPUT_PROPS_FILENAME="05-parametersForCp4ba.sh"
CP4BA_INPUT_PROPS_FILENAME_FULL="${CUR_DIR}/${CP4BA_INPUT_PROPS_FILENAME}"

if [[ -f $CP4BA_INPUT_PROPS_FILENAME_FULL ]]; then
   echo
   echo "Found ${CP4BA_INPUT_PROPS_FILENAME}.  Reading in variables from that script."
   . $CP4BA_INPUT_PROPS_FILENAME_FULL
   
   if [ $cp4baProjectName == "REQUIRED" ] || [ $cp4baOcpHostname == "REQUIRED" ] || [ "$cp4baTlsSecretName" == "REQUIRED" ] || [ $cp4baAdminPassword == "REQUIRED" ] || [ $cp4baUmsAdminPassword == "REQUIRED" ] || [ $ldapAdminPassword == "REQUIRED" ] || [ $ldapServer == "REQUIRED" ]; then
      echo "File ${CP4BA_INPUT_PROPS_FILENAME} not fully updated. Pls. update all REQUIRED parameters."
      echo
      exit 0
   fi

   echo "Done!"
else
   echo
   echo "File ${CP4BA_INPUT_PROPS_FILENAME_FULL} not found. Pls. check."
   echo
   exit 0
fi

echo
echo -e "\x1B[1mThis script PREPARES and optionaly CREATES the CP4BA deployment using template ${cp4baTemplateToUse} in project ${cp4baProjectName}. \n \x1B[0m"

printf "Are ${ORACLE_INPUT_PROPS_FILENAME} and ${CP4BA_INPUT_PROPS_FILENAME} up to date, and do you want to continue? (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Preparing the CP4BA deployment..."
    ;;
*)
    echo
    echo -e "Exiting..."
    echo
    exit 0
    ;;
esac

echo
echo "Switching to project ${cp4baProjectName}..."
oc project $cp4baProjectName

echo
echo "Collecting information for secret ibm-entitlement-key. For this, your Entitlement Registry key is needed."
echo
echo "You can get the Entitlement Registry key from here: https://myibm.ibm.com/products-services/containerlibrary"
echo
ENTITLEMENTKEY=""
EMAIL="me@here.com"
DOCKER_REG_SERVER="cp.icr.io"
DOCKER_REG_USER="cp"
printf "\x1B[1mEnter your Entitlement Registry key: \x1B[0m"
while [[ $ENTITLEMENTKEY == '' ]]
do
  read -rsp "" ENTITLEMENTKEY
  if [ -z "$ENTITLEMENTKEY" ]; then
    printf "\n"
    printf "\x1B[1;31mEnter a valid Entitlement Registry key: \x1B[0m"
  else
    DOCKER_REG_KEY=$ENTITLEMENTKEY
    entitlement_verify_passed=""
    while [[ $entitlement_verify_passed == '' ]]
    do
      printf "\n"
      printf "Verifying the Entitlement Registry key...\n"
      if podman login -u "$DOCKER_REG_USER" -p "$DOCKER_REG_KEY" "$DOCKER_REG_SERVER" --tls-verify=false; then
        printf 'Entitlement Registry key is valid.\n'
        entitlement_verify_passed="passed"
      else
        printf '\x1B[1;31mThe Entitlement Registry key verification failed. Enter a valid Entitlement Registry key: \x1B[0m'
        ENTITLEMENTKEY=''
        entitlement_verify_passed="failed"
      fi
    done
  fi
done


echo
echo "Preparing the CP4BA secrets..."
cp secrets.template.yaml secrets.yaml
sed -i.bak "s|db2AdminUserName|$db2AdminUserName|g" secrets.yaml
sed -i.bak "s|db2AdminUserPassword|$db2AdminUserPassword|g" secrets.yaml
sed -i.bak "s|cp4baAdminName|$cp4baAdminName|g" secrets.yaml
sed -i.bak "s|cp4baAdminPassword|$cp4baAdminPassword|g" secrets.yaml
sed -i.bak "s|cp4baUmsAdminName|$cp4baUmsAdminName|g" secrets.yaml
sed -i.bak "s|cp4baUmsAdminPassword|$cp4baUmsAdminPassword|g" secrets.yaml
sed -i.bak "s|ldapAdminName|$ldapAdminName|g" secrets.yaml
sed -i.bak "s|ldapAdminPassword|$ldapAdminPassword|g" secrets.yaml

tlsSecretName=
if [ $cp4baDeploymentPlatform == "ROKS" ] && [ "$cp4baTlsSecretName" != "" ]; then
  echo
  echo "Preparing the tls secret..."
  oc project ibm-cert-store
  
  tlsCert=$(oc get secret/$cp4baTlsSecretName -o "jsonpath={.data.tls\.crt}")
  tlsKey=$(oc get secret/$cp4baTlsSecretName -o "jsonpath={.data.tls\.key}")
  
  oc project $cp4baProjectName
  
  cp tlsSecrets.template.yaml tlsSecrets.yaml
  sed -i.bak "s|tlsCert|$tlsCert|g" tlsSecrets.yaml
  sed -i.bak "s|tlsKey|$tlsKey|g" tlsSecrets.yaml
  tlsSecretName=icp4a-tls-secret
fi

echo
echo "Preparing the CR YAML for deployment..."

cp $cp4baTemplateToUse ibm_cp4a_cr_final.yaml

sed -i.bak "s|oracleHostName|$oracleHostName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oraclePortNumber|$oraclePortNumber|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleSID|$oracleSID|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleServiceName|$oracleServiceName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleJDBCUrl|$oracleJDBCUrl|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleConnectionUrl|$oracleConnectionUrl|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleWalletConnectionUrl|$oracleWalletConnectionUrl|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleDriverFile|$oracleDriverFile|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleUmsdbName|$oracleUmsdbName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleIcndbName|$oracleIcndbName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleDevos1Name|$oracleDevos1Name|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleAeosName|$oracleAeosName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleBawDocsName|$oracleBawDocsName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleBawDosName|$oracleBawDosName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleBawTosName|$oracleBawTosName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleBawDbName|$oracleBawDbName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleAppdbName|$oracleAppdbName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleAedbName|$oracleAedbName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleBasdbName|$oracleBasdbName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleGcddbName|$oracleGcddbName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleCaBasedbName|$oracleCaBasedbName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|oracleCaTendbName|$oracleCaTendbName|g" ibm_cp4a_cr_final.yaml

sed -i.bak "s|ldapName|$ldapName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapType|$ldapType|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapServer|$ldapServer|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapPort|$ldapPort|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapBaseDn|$ldapBaseDn|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapUserNameAttribute|$ldapUserNameAttribute|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapUserDisplayNameAttr|$ldapUserDisplayNameAttr|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapGroupBaseDn|$ldapGroupBaseDn|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapGroupNameAttribute|$ldapGroupNameAttribute|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapGroupDisplayNameAttr|$ldapGroupDisplayNameAttr|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapGroupMembershipSearchFilter|$ldapGroupMembershipSearchFilter|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapGroupMemberIdMap|$ldapGroupMemberIdMap|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapAdGcHost|$ldapAdGcHost|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapAdGcPort|$ldapAdGcPort|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapAdUserFilter|$ldapAdUserFilter|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapAdGroupFilter|$ldapAdGroupFilter|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapTdsUserFilter|$ldapTdsUserFilter|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|ldapTdsGroupFilter|$ldapTdsGroupFilter|g" ibm_cp4a_cr_final.yaml

sed -i.bak "s|cp4baUmsAdminGroup|$cp4baUmsAdminGroup|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baDeploymentPlatform|$cp4baDeploymentPlatform|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baOcpHostname|$cp4baOcpHostname|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baScSlow|$cp4baScSlow|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baScMedium|$cp4baScMedium|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baScFast|$cp4baScFast|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baReplicaCount|$cp4baReplicaCount|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baBaiJobParallelism|$cp4baBaiJobParallelism|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baAdminName|$cp4baAdminName|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baAdminPassword|$cp4baAdminPassword|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baAdminGroup|$cp4baAdminGroup|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|cp4baUsersGroup|$cp4baUsersGroup|g" ibm_cp4a_cr_final.yaml

sed -i.bak "s|bawLibertyCustomXml|$bawLibertyCustomXml|g" ibm_cp4a_cr_final.yaml
sed -i.bak "s|tlsSecretName|$tlsSecretName|g" ibm_cp4a_cr_final.yaml

if [ $cp4baDeploymentPlatform == "ROKS" ] && [ "$cp4baTlsSecretName" != "" ]; then
  sed -i.bak "s|trustedCertificateList|- $tlsSecretName|g" ibm_cp4a_cr_final.yaml
else
  sed -i.bak "s|trustedCertificateList||g" ibm_cp4a_cr_final.yaml
fi

# TODO: if db ssl certificate needed also has to be in trusted certificate list 

# finally, create all the prepared artifacts on OCP if user decides to do that
echo
echo -e "\x1B[1mAll artefacts for deployment are prepared. \n \x1B[0m"

printf "Do you want to CREATE the CP4BA deployment in project ${cp4baProjectName} now? (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Creating the CP4BA deployment..."
    ;;
*)
    echo
    echo -e "Exiting without creating the deployment..."
    echo
    exit 0
    ;;
esac

echo
echo "Creating secret ibm-entitlement-key..."
oc create secret docker-registry ibm-entitlement-key --docker-server=${DOCKER_REG_SERVER} --docker-username=${DOCKER_REG_USER} --docker-password=${ENTITLEMENTKEY} --docker-email=${EMAIL} --namespace=${cp4baProjectName}
echo "Done."

echo
echo "Copying the jdbc driver to ibm-cp4a-operator..."
oc get pods | grep ibm-cp4a-operator- | awk '$1 {print$1}' | while read vol; do oc cp jdbc ${vol}:/opt/ansible/share/; done
echo "Done."

echo
echo "Creating CP4BA secrets..."
oc apply -f secrets.yaml
echo "Done."

if [ $cp4baDeploymentPlatform == "ROKS" ] && [ "$cp4baTlsSecretName" != "" ]; then
  echo
  echo "Creating the tls secret..."
  oc apply -f tlsSecrets.yaml
  echo "Done."
fi

echo
echo "Creating the CP4BA deployment..."
oc apply -f ibm_cp4a_cr_final.yaml
echo "Done."

echo
echo "All changes got applied. Exiting..."
echo
