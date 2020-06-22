#!/bin/bash
# Author Brokedba https://twitter.com/BrokeDba
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

while true; do
 oci compute instance list -c $C  --query "data[*].{name:\"display-name\",state:\"lifecycle-state\",FD:\"fault-domain\",shape:shape,region:region}" --output table 
 read -p "select theinctance you wish to check the details from [Demo-Cli-Instance]: " instance_name
 instance_name=${instance_name:-Demo-Cli-Instance}
 ocid_instance=$(oci compute instance list -c $C --query "data [?\"display-name\"==\`$instance_name\`] | [0].id" --raw-output)
    if [ -n "$ocid_instance" ];
        then  
        echo selected instance name : $instance_name
        break
        else
        echo  "Entered instance name is not valid. Please retry"
    fi
done 
echo -e "${GREEN}==============================="
echo -e "${BLUE}    INSTANCE INFO"
echo -e "${GREEN}===============================${NC}"  
     ocid_sub=$(oci compute instance list-vnics --instance-id "${ocid_instance}" --query "data[0].\"subnet-id\"" --raw-output)
     ocid_vcn=$(oci network subnet get --subnet-id $ocid_sub --query "data.\"vcn-id\"" --raw-output)
     oci network vcn get --vcn-id $ocid_vcn --query "data.{CIDR:\"cidr-block\", VCN_NAME:\"display-name\", DOMAIN_NAME:\"vcn-domain-name\", DNS:\"dns-label\"}" --output table
     oci network subnet get --subnet-id $ocid_sub --query "data.{SUBNAME:\"display-name\",SUB_CIDR:\"cidr-block\",subdomain:\"subnet-domain-name\"}" --output table
     oci compute instance list-vnics --instance-id "${ocid_instance}" --query "data[0].{private:\"private-ip\",public:\"public-ip\",Instance:\"display-name\",ocpus:\"shape-config\".ocpus,RAM:\"shape-config\".\"memory-in-gbs\"}" --output table