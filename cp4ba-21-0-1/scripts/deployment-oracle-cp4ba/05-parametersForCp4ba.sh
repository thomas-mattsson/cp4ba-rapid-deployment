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

echo "  Reading 05-parametersForCp4ba.sh ..."

# ----------------------------------------------
# --- Parameters that usually need an update ---
# ----------------------------------------------

# --- Provide those BEFORE running script 06-prepareCp4baDeployment.sh ---

# OCP project name for CP4BA, for example ibm-cp4ba - make sure to use the same value as used before when running script cp4a-clusteradmin-setup.sh
cp4baProjectName=REQUIRED

# OCP hostname, see output of script cp4a-clusteradmin-setup.sh
cp4baOcpHostname=REQUIRED

# TLS secret name - see also secret name in project ibm-cert-store
#   If this secret is not available, leave empty (but remove the value 'REQUIRED') - then self-signed certificates will be used at the routes
cp4baTlsSecretName=REQUIRED

# Password for CP4BA Admin User (cp4baAdminName name see below)
# This is the password for the admin LDAP user
cp4baAdminPassword=REQUIRED

# Password for UMS Admin User (cp4baUmsAdminName name see below), for example passw0rd.
# Note that this user should NOT exist in ldap
cp4baUmsAdminPassword=REQUIRED

# Password for LDAP Admin User (ldapAdminName name see below), for example passw0rd - use the password that you specified when setting up LDAP
ldapAdminPassword=REQUIRED

# LDAP instance access information - hostname or IP
ldapServer=REQUIRED


# --- If changes are needed here, provide those BEFORE running script 06-prepareCp4baDeployment.sh ---

# --- CP4BA settings ---
# This user should not be in ldap
cp4baUmsAdminName=umsadmin

# --- LDAP settings ---

cp4baAdminName=cp4badmin
cp4baAdminGroup=cp4badmins
cp4baUsersGroup=cp4bausers
cp4baUmsAdminGroup=cn=cp4badmins,dc=example,dc=com

# LDAP name - don't use dashes (-), only use underscores
ldapName=ldap_custom

ldapAdminName=cn=root

ldapType="IBM Security Directory Server"
ldapPort="389"
ldapBaseDn="dc=example,dc=com"
ldapUserNameAttribute="*:cn"
ldapUserDisplayNameAttr="cn"
ldapGroupBaseDn="dc=example,dc=com"
ldapGroupNameAttribute="*:cn"
ldapGroupDisplayNameAttr="cn"
ldapGroupMembershipSearchFilter="(\|(\&(objectclass=groupOfNames)(member={0}))(\&(objectclass=groupOfUniqueNames)(uniqueMember={0})))"
ldapGroupMemberIdMap="groupofnames:member"
ldapAdGcHost=
ldapAdGcPort=
ldapAdUserFilter="(\&(samAccountName=%v)(objectClass=user))"
ldapAdGroupFilter="(\&(samAccountName=%v)(objectclass=group))"
ldapTdsUserFilter="(\&(cn=%v)(objectclass=person))"
ldapTdsGroupFilter="(\&(cn=%v)(\|(objectclass=groupofnames)(objectclass=groupofuniquenames)(objectclass=groupofurls)))"

# --- Storage Class Settings ---
cp4baScSlow=cp4a-file-delete-bronze-gid
cp4baScMedium=cp4a-file-delete-silver-gid
cp4baScFast=cp4a-file-delete-gold-gid

# --- HA Settings ---
cp4baReplicaCount=1
cp4baBaiJobParallelism=1



# --- end of file ---



