#!/bin/bash
# Author Brokedba https://twitter.com/BrokeDba
while true; do
 oci network vcn list -c $C --output table --query "data[*].{CIDR:\"cidr-block\", VCN_NAME:\"display-name\", DOMAIN_NAME:\"vcn-domain-name\", DNS:\"dns-label\"}"
 read -p "select the VCN you wish to attach your subnet to [$vcn_name]: " vcn_name
 vcn_name=${vcn_name:-$vcn_name}
 ocid_vcn=$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].id" --raw-output)
 if [ -n "$ocid_vcn" ];
    then  
   echo selected VCN name : $vcn_name
   read -p "Enter the subnet name you wish to create [CLI-SUB]: " sub_name
   sub_name=${sub_name:-CLI-SUB}
   echo selected Subnet name : $sub_name
   sub_dns=`echo "${sub_name//[_-]/}"`
   while true; do
   echo ============ SUBNET CIDR ========================== 
   echo Subnet CIDR must be contained in its VCN CIDR block "$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].\"cidr-block\"" --raw-output)"
   echo ===================================================
   read -p "Enter the VCN network CIDR to assign [192.168.10.0/24]: " sub_cidr
            sub_cidr=${sub_cidr:-"192.168.10.0/24"};
            if [ "$sub_cidr" = "" ] 
                then echo "Entered CIDR is not valid. Please retry"
                else
                REGEX='(((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))(\/([1][6-9]|[2][0-9]|3[0]))([^0-9.]|$)'
                vcn_pref=$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].\"cidr-block\"" --raw-output| awk -F/ '{print $2}')
                sub_pref=`echo $sub_cidr | awk -F/ '{print $2}'`
                if [[ $sub_cidr =~ $REGEX ]]  && (( $sub_pref >= $vcn_pref && $sub_pref <= 30 ))
                then
                echo == Subnet information === 
                echo VCN name = $vcn_name 
                echo VCN CIDR = $(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].\"cidr-block\"" --raw-output)
                echo SUBNET name = $sub_name
                echo SUBNET CIDR = $sub_cidr
                break
                else
                            echo  "Entered CIDR is not valid. Please retry"
                fi
            fi
    done
    break
 else echo "The entered VCN name is not valid.please retry"; 
 fi
done          
ocid_vcn=$(oci network vcn list -c $C --query "data [?\"display-name\"==\`$vcn_name\`] | [0].id" --raw-output)
oci network subnet create --cidr-block $sub_cidr -c $C --vcn-id $ocid_vcn --display-name $sub_name --dns-label $sub_dns --prohibit-public-ip-on-vnic false 
ocid_sub=$(oci network subnet list -c $C --vcn-id $ocid_vcn --query "data[?contains(\"display-name\",\`$sub_name\`)]|[0].id" --raw-output)
echo "==== Created SUBNET details ===="
oci network subnet list -c $C --vcn-id $ocid_vcn --query "data[*].{SUBNAME:\"display-name\",SUB_CIDR:\"cidr-block\",subdomain:\"subnet-domain-name\",SUB_OCID:id}" --output table
echo
echo "delete command ==>  oci network subnet delete --subnet-id $ocid_sub" --force