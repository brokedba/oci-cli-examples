#!/bin/bash
# Author Brokedba https://twitter.com/BrokeDba
read -p "Enter the VCN name you wish to create [CLI-VCN]: " vcn_name
vcn_name=${vcn_name:-CLI-VCN}
echo selected VCN name : $vcn_name
vcn_dns=`echo "${vcn_name//[_-]/}"`
if [ -z "$vcn_name" ];
    then  echo "The entered name is not valid ";
else
    while true; do
        read -p "Enter the VCN network CIDR to assign [192.168.0.0/16]: " vcn_cidr
        vcn_cidr=${vcn_cidr:-"192.168.0.0/16"};
        if [ "$vcn_cidr" = "" ] 
            then echo "Entered CIDR is not valid. Please retry"
            else
             REGEX='^(((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))(\/([1][6-9]|[2][0-9]|3[0]))([^0-9.]|$)'
                 if [[ $vcn_cidr =~ $REGEX ]]
            then
            echo == VCN information === 
            echo VCN name = $vcn_name 
            echo CIDR = $vcn_cidr
            echo VCN Dns-Label = $vcn_dns
            break
            else
                        echo  "Entered CIDR is not valid. Please retry"
            fi
        fi    
    done                
fi
oci network vcn create --cidr-block $vcn_cidr -c $C --display-name $vcn_name --dns-label $vcn_dns
ocid_vcn=$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].id" --raw-output)
echo "==== Created VCN details ===="
 oci network vcn list -c $C --output table --query "data [?contains(\"display-name\",\`$vcn_name\`)].{CIDR:\"cidr-block\", VCN_NAME:\"display-name\", DOMAIN_NAME:\"vcn-domain-name\", DNS:\"dns-label\"}"
echo
echo "delete command ==>  oci network vcn delete --vcn-id $ocid_vcn" --force
