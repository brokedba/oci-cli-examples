#!/bin/bash
# Author Brokedba https://twitter.com/BrokeDba
while true; do
 oci network vcn list -c $C --output table --query "data[*].{CIDR:\"cidr-block\", VCN_NAME:\"display-name\", DOMAIN_NAME:\"vcn-domain-name\", DNS:\"dns-label\"}"
 read -p "select the VCN you wish to set the route table for [$vcn_name]: " vcn_name
 vcn_name=${vcn_name:-$vcn_name}
 ocid_vcn=$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].id" --raw-output)
if [ -n "$ocid_vcn" ];
    then  
     echo selected VCN name : $vcn_name
     ocid_gtw=$(oci network internet-gateway list -c $C --vcn-id $ocid_vcn --query "data[0].id" --raw-output) 
     if  [ -n "$ocid_gtw" ];
     then echo " Internet gateway exists => Seting up the default Route table"
     echo ...
     break
     else echo " Internet Gateway doesn't exist for $vcn_name. Please run create_igateway.sh script first";
     exit 1
     fi 
else echo "The entered VCN name is not valid. Please retry"; 
 fi
done        
ocid_rt=$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].\"default-route-table-id\"" --raw-output)
oci network route-table update  --rt-id $ocid_rt  --route-rules '[{"cidrBlock":"0.0.0.0/0","networkEntityId":"'"${ocid_gtw}"'"}]' --force
echo "==== Default Route table entries for $vcn_name ===="
oci network route-table list -c $C --vcn-id $ocid_vcn --query "data[0].{Route:\"display-name\",dest:\"route-rules\"[0].destination,CIDR:\"route-rules\"[0].\"cidr-block\",RT_OCID:id}"  --output table