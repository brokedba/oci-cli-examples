#!/bin/bash
# Author Brokedba https://twitter.com/BrokeDba
echo "******* Oci instance launch ! ************"
echo "Choose your Shape ||{**}||" 
echo
oci compute shape list --cid $C --output table --query "sort_by(data[?contains("shape",'VM.Standard.E2.1.Micro')],&\"shape\") [*].{ShapeName:shape,Memory:\"memory-in-gbs\",CPUcores:ocpus}"
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
echo -e "Note: If ${RED} VM.Standard2.1${GREEN} is not listed that means that your FreeTier trial is over ${BLUE}[Default option =Micro compute]"
read -p "Enter the Shape name you wish to create [VM.Standard.E2.1.Micro]: " shape
shape=${shape:-"VM.Standard.E2.1.Micro"}

read -p "Enter the Path of your ssh key [/c/Users/brokedba/oci/.ssh/id_rsa.pub]: " public_key
public_key=${public_key:-/c/oracle/oci/.ssh/id_rsa.pub}  # this is a GITbash path
read -p "Enter the name of your new Instance ["Demo-Cli-Instance"]: " instance_name
instance_name=${instance_name:-"Demo-Cli-Instance"}
 echo selected Instance name : $sub_name
 echo selected shape: $shape
 echo selected public key: $public_key
echo
echo "Choose your Image ||{**}||" 
echo
PS3='Select an option and press Enter: '
options=("Oracle-Linux" "CentOS" "Oracle Autonomus Linux" "Ubuntu" "Windows" "Abort?" )
select opt in "${options[@]}"
do
  case $opt in
        "Oracle-Linux")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'Oracle-Linux')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ocid_img=$(oci compute image list -c $C --query "reverse(sort_by(data[?contains(\"display-name\",'Oracle-Linux')],&\"time-created\")) |[0].id" --raw-output) 
          break
          ;;
        "CentOS")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'CentOS')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ocid_img=$(oci compute image list -c $C --query "reverse(sort_by(data[?contains(\"display-name\",'CentOS')],&\"time-created\")) |[0].id" --raw-output)
          break
          ;;
        "Oracle Autonomus Linux")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'Oracle-Autonomous-Linux')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ocid_img=$(oci compute image list -c $C --query "reverse(sort_by(data[?contains(\"display-name\",'Oracle-Autonomous-Linux')],&\"time-created\")) |[0].id" --raw-output)
          break
          ;;
        "Ubuntu")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'Canonical-Ubuntu')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ocid_img=$(oci compute image list -c $C --query "reverse(sort_by(data[?contains(\"display-name\",'Canonical-Ubuntu')],&\"time-created\")) |[0].id" --raw-output)
          break
          ;;
        "Windows")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'Windows')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ocid_img=$(oci compute image list -c $C --query "reverse(sort_by(data[?contains(\"display-name\",'Windows')],&\"time-created\")) |[0].id" --raw-output)
          break
          ;;         
        "Abort?")
          exit 
          ;;                              
        *) echo "invalid option";;
  esac
done
echo "*********************"
# ocid_img=$(oci compute image list -c $C --operating-system "Oracle Linux" --operating-system-version "7.8" --shape $shape --query 'data[0].id' --raw-output) 
while true; do
 oci network vcn list -c $C --output table --query "data[*].{CIDR:\"cidr-block\", VCN_NAME:\"display-name\", DOMAIN_NAME:\"vcn-domain-name\", DNS:\"dns-label\"}"
 read -p "select the VCN for your new instance [$vcn_name]: " vcn_name
 vcn_name=${vcn_name:-$vcn_name}
 ocid_vcn=$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].id" --raw-output)
 if [ -n "$ocid_vcn" ];
   then  
   echo selected VCN name : $vcn_name
   while true; do
   oci network subnet list -c $C --vcn-id $ocid_vcn --query "data[*].{SUBNAME:\"display-name\",SUB_CIDR:\"cidr-block\",SUB_OCID:id}" --output table
   read -p "Select The Subnet for your new instance [CLI-SUB]: " sub_name
   sub_name=${sub_name:-CLI-SUB}
   ocid_sub=$(oci network subnet list -c $C --vcn-id $ocid_vcn --query "data[?\"display-name\"==\`$sub_name\`]|[0].id" --raw-output)
     if [ -n "$ocid_sub" ];
        then  
         break
        else echo "$sub_name is not valid subnet name. Please retry";   
     fi 
   done
   break
   else echo "The entered VCN name is not valid.please retry"; 
 fi
done  
 ocid_ad=$(oci iam availability-domain list -c $C --query "data[0].name" --raw-output)
 echo ===== Instance Deployment Detail ========
       echo selected Subnet name : $sub_name
       echo selected Instance name : $sub_name
       echo selected shape: $shape
       echo selected public key: $public_key
# run the below which will launch the instance and store the ocid in a variable 
ocid_instance=$(oci compute instance launch --display-name ${instance_name} --availability-domain "${ocid_ad}" -c $C --subnet-id "${ocid_sub}" --image-id "${ocid_img}" \
--shape "${shape}" \
--ssh-authorized-keys-file "${public_key}" \
--assign-public-ip true \
--wait-for-state RUNNING \
--query 'data.id' \
--hostname-label Hostcli-demo \
--raw-output)
echo
echo ====================================
echo Check the status of the new Instance
echo ====================================
oci compute instance list -c $C --display-name ${instance_name} --query "data[*].{name:\"display-name\",state:\"lifecycle-state\",id:id}" --output table
oci compute instance list -c $C --display-name ${instance_name} \
--query "data[*].{name:\"display-name\",state:\"lifecycle-state\",id:id,FD:\"fault-domain\",ocpu:\"shape-config\"[0].ocpus, RAM:\"shape-config\"[0].\"memory-in-gbs\",shape:shape,region:region}" --output table 
oci compute instance list-vnics --instance-id "${ocid_instance}" --query "data[0].{private:\"private-ip\",public:\"public-ip\",Instance:\"display-name\"}" --output table
echo
echo "termination command ==> oci compute instance terminate --instance-id $ocid_instance" --force
 