#!/bin/bash
# Author Brokedba https://twitter.com/BrokeDba

echo "******* Oci Image Selecta ! ************"
echo "Choose your Destiny ||{**}||" 
echo
PS3='Select an option and press Enter: '
options=("Oracle-Linux" "CentOS" "Oracle Autonomus Linux" "Ubuntu" "Windows" "Exit?" "All")
select opt in "${options[@]}"
do
  case $opt in
        "Oracle-Linux")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'Oracle-Linux')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ;;
        "CentOS")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'CentOS')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          break
          ;;
          
        "Oracle Autonomus Linux")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'Oracle-Autonomous-Linux')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ;;
        "Ubuntu")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'Canonical-Ubuntu')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ;;
        "Windows")
          oci compute image list --cid $C --query "reverse(sort_by(data[?contains(\"display-name\",'Windows')],&\"time-created\")) |[0:1].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\",time:\"time-created\"}" --output table
          ;;
        "All")
          oci compute image list --cid $C --query "reverse(sort_by(data[*],&\"display-name\")) |[*].{ImageName:\"display-name\", OCID:id, OS:\"operating-system\", Size:\"size-in-mbs\"}" --output table
          ;;          
        "Exit?")
          exit 
          ;;                              
        *) echo "invalid option";;
  esac
done
echo "*********************"
#ocid_img=$(oci compute image list -c $C --operating-system "Oracle Linux" --operating-system-version "7.8" --shape "VM.Standard2.1"   --query 'data[0].id'  --raw-output)
