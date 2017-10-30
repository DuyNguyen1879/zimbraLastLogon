#!/bin/bash

###############################################################################
# Script made by M. Rodrigo Monteiro                                          #
# Any bug or request:                                                         #
#   E-mail: falecom@rodrigomonteiro.net                                       #
#   https://github.com/mrodrigom/                                             #
# Use at your own risk                                                        #
# Tested on CentOS Linux release 7.2 64 bits                                  #
#                                                                             #
# Instructions:                                                               #
# Usage: ./zimbraLastLogon 30                                                 #
#   This show the users that the last login before than $1 days               #
#     (60 is the default) or that never login and the creation date is older  #
#     than $1 days                                                            #
###############################################################################

#edit "days" and "zmprov"
days="${1:-60}"
zmprov="/opt/zimbra/bin/zmprov"

#do not edit below here
daysAgo="$(date +%F -d "${days} days ago" | tr -d '-')"

echo "#email;displayName;zimbraIsAdminAccount;zimbraCreateTimestamp;zimbraLastLogonTimestamp"
while read email ; do
	zimbraLastLogonTimestamp="$("${zmprov}" ga "${email}" zimbraLastLogonTimestamp | sed '1d' | sed '2d' | awk '{print $NF}' | cut -c 1-8)"
	zimbraIsAdminAccount="$("${zmprov}" ga "${email}" zimbraIsAdminAccount | sed '1d' | sed '2d' | awk '{print $NF}')"
	displayName="$("${zmprov}" ga "${email}" displayName | sed '1d' | sed '2d' | sed 's/displayName: //g')"
	zimbraCreateTimestamp="$("${zmprov}" ga "${email}" zimbraCreateTimestamp | sed '1d' | sed '2d' | awk '{print $NF}' | cut -c 1-8)"
	if [ -n "${zimbraLastLogonTimestamp}" ] ; then
		if [ "${zimbraLastLogonTimestamp}" -lt "${daysAgo}" ] ; then
			echo "${email};${displayName};${zimbraIsAdminAccount};${zimbraCreateTimestamp};${zimbraLastLogonTimestamp}"
		fi
	else
		if [ "${zimbraCreateTimestamp}" -lt "${daysAgo}" ] ; then
			echo "${email};${displayName};${zimbraIsAdminAccount};${zimbraCreateTimestamp};${zimbraLastLogonTimestamp}"
		fi		
		
	fi
done < <("${zmprov}" -l gaa | sort)
