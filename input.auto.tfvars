##########################################################
# General VPC variables:
##########################################################

REGION = ""
# The cloud region where to deploy the solution. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

DOMAIN_NAME = ""
# The Domain Name for DNS and ALB. 
# The DOMAIN_NAME value should contain at least one "." as a separator. It is a private domain and is not reachable from the outside world.
# The DOMAIN_NAME value could be like a subdomain name. Example: staging.example.com
# Domain names can only contain letters, numbers and hyphens. Hyphens cannot be used at the beginning or end of the domain name.
# Using a domain name that is already in use is not supported.
# Domain names are not case sensitive.

ASCS_VIRT_HOSTNAME = "sapascs"
# ASCS Virtual Hostname
# Default value: "sapascs"
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sap<sap_sid>ascs"

ERS_VIRT_HOSTNAME = "sapers"
# ERS Virtual Hostname 
# Default value: "sapers"
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sap<sap_sid>ers"

VPC = ""
# The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs.
# Example: VPC = "ic4sap"

ZONE_1 = ""
# Availability zone for DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-1"

SUBNET_1 = ""
# The name of an EXISTING Subnet, in the same VPC, ZONE_1, where DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet_1"

ZONE_2 = ""
# Availability zone for DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. 
# If the same value as for ZONE_1 is used, and the value for SUBNET_1 is the same with the value for SUBNET_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then an SAP Multizone deployment will be done.
# Example: ZONE = "eu-de-2"

SUBNET_2 = ""
# The name of an EXISTING Subnet, in the same VPC, ZONE_2, where DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets. 
# If the same value as for SUBNET_1 is used, and the value for ZONE_1 is the same with the value for ZONE_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then it an SAP Multizone deployment will be done.
# Example: SUBNET = "ic4sap-subnet_2"

SECURITY_GROUP = ""
# The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.
# The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = ""
# The name of an EXISTING Resource Group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SSH_KEYS = [""]
# List of SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSIs. Can contain one or more IDs. The SSH Keys should be created for the same region as the VSIs. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# The path to an existing id_rsa private key file, with 0600 permissions. The private key must be in OpenSSH format.
# This private key is used only during the provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_ase-syb_ha" , "~/.ssh/id_rsa_ase-syb_ha" , "/root/.ssh/id_rsa".

##########################################################
# File Shares variables:
##########################################################

SHARE_PROFILE = "dp2"
# The Storage Profile for the File Share
# More details on https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile."

USRSAP_AS1      = "20"
USRSAP_AS2      = "20"
USRSAP_SAPASCS  = "20"
USRSAP_SAPERS   = "20"
USRSAP_SAPMNT   = "20"
USRSAP_SAPSYS   = "20"
USRSAP_TRANS    = "80"
# File share sizes for SAP, in GB

##########################################################
# DB VSI variables:
##########################################################

DB_HOSTNAME_1 = "sybdb-1"
# The hostname for the primary SYBASE DB VSI server. The hostname should be up to 13 characters, as required by SAP.
# Default value: "sybdb-1"
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sybdb-<sap_sid>-1"

DB_HOSTNAME_2 = "sybdb-2"
# The hostname for the standby (companion) SYBASE DB VSI server. The hostname should be up to 13 characters, as required by SAP.
# Default value: "sybdb-2"
# When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sybdb-<sap_sid>-2"

DB_PROFILE = "bx2-4x16"
# The profile for the DB VSI. A list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui. 
# For more information, check SAP Note 2927211: "SAP Applications on IBM Virtual Private Cloud".

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6"
# The OS image for the DB VSI. 
# Red Hat Enterprise Linux 8 for SAP HANA (amd64) image must be used for all VMs, as this image type contains the required SAP and HA subscriptions.
# Validated OS images: ibm-redhat-8-6-amd64-sap-hana-6, ibm-redhat-8-4-amd64-sap-hana-10. 
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211
# A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images.
# Example: DB_IMAGE = "ibm-redhat-8-4-amd64-sap-hana-10" 

##########################################################
# SAP APP VSI variables:
##########################################################

APP_HOSTNAME_1 = "sapapp-1"
# The hostname for APP VSI 1, in SAP APP Cluster. The hostname should be up to 13 characters. 
# Default value: "sapapp-1"
# When the default value is used, the virtual hostname will automatically be changed, based on <SAP_SID>, to "sapapp-<sap_sid>-1"

APP_HOSTNAME_2 = "sapapp-2"
# The hostname for APP VSI 2, in SAP APP Cluster. The hostname should be up to 13 characters. 
# Default value: "sapapp-2"
# When the default value is used, the virtual hostname will automatically be changed, based on <SAP_SID>, to "sapapp-<sap_sid>-2"

APP_PROFILE = "bx2-4x16"
# The profile for the SAP APP VSIs. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. 
# For more information, check SAP Note 2927211: "SAP Applications on IBM Virtual Private Cloud"

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6"
# The OS image for SAP APP VSI. Red Hat Enterprise Linux 8 for SAP HANA (amd64) image must be used for all VMs, as this image type contains the required SAP and HA subscriptions. 
# Supported OS images for APP VSIs: ibm-redhat-8-6-amd64-sap-hana-6, ibm-redhat-8-4-amd64-sap-hana-10. 
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211-SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images"
# Example: APP_IMAGE = "ibm-redhat-8-4-amd64-sap-hana-10" 

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWD"
# The SAP system ID identifies the entire SAP system. 
# Consists of three alphanumeric characters and the first character must be a letter. 
# Does not include any of the reserved IDs listed in SAP Note 1979280
# Obs. It will be used also as identification string across different HA name resources. Duplicates are not allowed.

SAP_ASCS_INSTANCE_NUMBER = "00"
# The central ABAP service instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "00"

SAP_ERS_INSTANCE_NUMBER = "01"
# The enqueue replication server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_ERS_INSTANCE_NUMBER = "01"

SAP_CI_INSTANCE_NUMBER = "10"
# The primary application server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_CI_INSTANCE_NUMBER = "10"

SAP_AAS_INSTANCE_NUMBER = "20"
# The additional application server instance number. Should follow the SAP rules for instance number naming.
# Example: SAP_AAS_INSTANCE_NUMBER = "20"

##########################################################
# SAP Kit Paths
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75SYB/SAPCAR/7.53/SAPCAR_1300-70007716.EXE"
KIT_SWPM_FILE =  "/storage/NW75SYB/SWPM10SP42_1-20009701.SAR"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75SYB/SAPHOSTAGENT65_65-80004822.SAR"
KIT_SAPEXE_FILE = "/storage/NW75SYB/KERNEL/7.54UC/SAPEXE_400-80007612.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75SYB/KERNEL/7.54UC/SAPEXEDB_400-80007655.SAR"
KIT_IGSEXE_FILE = "/storage/NW75SYB/KERNEL/7.54UC/igsexe_4-80007786.sar"
KIT_IGSHELPER_FILE = "/storage/NW75SYB/igshelper_17-10010245.sar"
KIT_ASE_FILE = "/storage/NW75SYB/ASEBU/51057961_1.ZIP"
KIT_NWABAP_EXPORT_FILE = "/storage/NW75SYB/ABAPEXP/51050829_3.ZIP"
