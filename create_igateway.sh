#!/bin/bash
# Author Brokedba https://twitter.com/BrokeDba
while true; do
 oci network vcn list -c $C --output table --query "data[*].{CIDR:\"cidr-block\", VCN_NAME:\"display-name\", DOMAIN_NAME:\"vcn-domain-name\", DNS:\"dns-label\"}"
 read -p "select the VCN you wish to add thye I-Gateway to [$vcn_name]: " vcn_name
 vcn_name=${vcn_name:-$vcn_name}
 ocid_vcn=$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].id" --raw-output)
if [ -n "$ocid_vcn" ];
    then  
     echo selected VCN name : $vcn_name
     ocid_gtw=$(oci network internet-gateway list -c $C --vcn-id $ocid_vcn --query "data[0].id" --raw-output) 
     if ! [ -n "$ocid_gtw" ];
     then echo " Creating a New Internet gateway"
     echo ...
     break
     else echo "An Internet Gateway exists already for this $vcn_name. No Action needed";
     exit 1
     fi 
else echo "The entered VCN name is not valid. Please retry"; 
 fi
done        
read -p "Enter the Internet gateway name you wish to create [CLI-IGW]: " igw_name
igw_name=${igw_name:-CLI-IGW}
oci network internet-gateway create -c $C --is-enabled true --vcn-id $ocid_vcn --display-name $igw_name 
ocid_gtw=$(oci network internet-gateway list -c $C --vcn-id $ocid_vcn --query "data[0].id" --raw-output)
oci network internet-gateway list -c $C --vcn-id $ocid_vcn --query "data[0].{GTID:\"id\", GTW_NAME:\"display-name\", ENABLED:\"is-enabled\"}" --output table
echo
echo "delete command ==>  oci network internet-gateway delete --ig-id $ocid_gtw" --force  