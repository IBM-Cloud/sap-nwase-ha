# Automation scripts for SAP Netweaver 7.x (ABAP) and ASE DB High Availability Deployment using Terraform and Ansible integration

## Description

This automation solution is designed for the deployment of **SAP Netweaver 7.x (ABAP) and ASE DB High Availability solution** using IBM Cloud Schematics. The SAP solution will be deployed  in an existing IBM Cloud Gen2 VPC, using a deployed [bastion host with secure remote SSH access](https://github.com/IBM-Cloud/sap-bastion-setup).

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

It contains:

- Terraform scripts for deploying one Power Placement group to include all the 4 VMs involved in this solution.
- Terraform scripts for deploying four VSIs in an EXISTING VPC with Subnet and Security Group configs. The VSIs scope: two for the ASE database instances and two for the SAP NW application cluster.
- Terraform scripts for deploying and configuring two Application Load Balancers like: SAP ASCS/ERS.
- Terraform scripts for deploying and configuring one VPC DNS service used to map the ALB FQDN to the SAP ASCS/ERS Virtual hostnames.
- Terraform scripts for deploying and configuring seven File shares for VPC.
- Bash scripts used for checking the prerequisites required by SAP VSIs deployment and for the integration into a single step in IBM Schematics GUI of the VPC virtual resources provisioning and the SAP SAP HA cluster solution installation.
- Ansible scripts for OS requirements installation and configuration for SAP applications.
- Ansible scripts for cluster components installation.
- Ansible scripts for SAP application cluster configuration.
- Ansible scripts for ASE DB installation.
- Ansible scripts for ASE DB replica installation.
- Ansible scripts for ASE DB system replica configuration.
- Ansible scripts for ASCS and ERS instances installation.
- Ansible scripts for Fault Manager installation.
- Ansible scripts for primary and additional application servers installation.

The SAP with Sybase HA configuration consists of the following resources:

- 2x SAP VMs running in pacemaker cluser for ASCS/ERS HA and PAS on one node and AAS on second node
- 2x Sybase VM running with Sybase HADR configuration; Sync replication; Primary node active and Secondary node standby
- 1x Fault manager integrated with SAP ASCS running on the SAP Cluster to monitor Sybase DB availability and control failover
- 2x ALB used for Virtual IP/hosntame for ASCS and ERS
- 1x DNS service to map the virtual names for ASCS/ERS to ALB hostname
- 7x File shares to used by SAP:   /sapmnt/<SAPSID>, /usr/sap/trans, /usr/sap/<SAPSID>/SYS, /usr/sap/SYB/ASCSxx,  /usr/sap/SYB/ERSxx, /usr/sap/<SAPSID>/Dxx,  /usr/sap/<SAPSID>/Dxx 

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 VSI Configuration](#12-vsi-configuration)
- [1.3 VPC Configuration](#13-vpc-configuration)
- [1.4 Files description and structure](#14-files-description-and-structure)
- [1.5 General input variabiles](#15-general-input-variables)
- [2.1 Executing the deployment of **HA SAP Netweaver and ASE DB installation** in GUI (Schematics)](#21-executing-the-deployment-of-sap-netweaver-and-ase-db-installation-in-gui-schematics)
- [2.2 Executing the deployment of **HA SAP Netweaver and ASE DB installation** in CLI](#22-executing-the-deployment-of-sap-netweaver-and-ase-db-installation-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5 and SAP ASE 16.0.04.04** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 VSI Configuration
The VSIs are configured with Red Hat Enterprise Linux 8 for SAP ASE DB (amd64)  and they have: at least two SSH keys configured to access as root user and the following storage volumes created for DB and SAP APP VSI:

ASE DB VSI Disks:
- 3 volume disks ["256" , "32" , "64"] GB, with 10 IOPS / GB - DATA
- 1 x 40 GB disk - SWAP

SAP APPs VSI Disks:
- 1x 40 GB disk with 10 IOPS / GB - SWAP

File Shares:
- 6 x 20GB file shares - DATA
- 1 x 80GB file shares - DATA

In order to perform the deployment you can use either the CLI component or the GUI component (Schematics) of the automation solution.

## 1.3 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

## 1.4 Files description and structure

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

 - `modules` - directory containing the terraform modules.
 - `ansible`  - directory containing the SAP ansible playbooks.
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (VPC, Hostname, Private IP).
 - `integration*.tf & generate*.tf` files - contain the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI.
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.
 - `sch.auto.tfvars` - contains programatic variables.

## 1.5 General Input variables

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
PRIVATE_SSH_KEY | id_rsa private key content (Sensitive* value). This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server.
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets).
SECURITY_GROUP | The name of an EXISTING Security group, previously created by the user in the same VPC. It can be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
DOMAIN_NAME | The Domain Name used for DNS and ALB. Duplicates are not allowed. The list with DNS resources can be searched [here](https://cloud.ibm.com/resources). <br />  Sample value:  "example.com". <br /> _(See Obs.*)_
SHARE PROFILE | Enter the profile for File Share storage. More details on https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile." <br/> Default value:  SHARE_PROFILE = "dp2".
SHARE SIZES | Custom File Shares Sizes for SAP mounts. Sample values:  USRSAP_SAPMNT   = "20" , USRSAP_TRANS    = "80".
[DB/APP]- <br />VIRT-HOSTNAMES | ASCS/ERS virtual hostnames.  <br /> Default values:  "sap($your_sap_sid)ascs/ers".
[DB/APP]-HOSTNAMES | SAP ASEDB/APP Cluster VSI Hostnames. Each hostname should be up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361). <br> Default values: APP_HOSTNAME_1/2 = "sapapp-$your_sap_sid-1/2" ,  DB_HOSTNAME_1/2 = "sybdb-$your_sap_sid-1/2".
[DB/APP]-PROFILES | The profile used for the ASEDB/APP VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)<br/> Default values: DB_PROFILE = "bx2-4x16" , APP_PROFILE = "bx2-4x16".
[DB/APP]-IMAGE | The OS image used for the ASEDB/APP VSI. You must use the Red Hat Enterprise Linux 8 for SAP ASEDB (amd64) image for all VMs as this image contains  the required SAP and HA subscriptions.  A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)  <br/> Default value: "	ibm-redhat-8-6-amd64-sap-hana-4"

**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
SAP_SID | The SAP system ID <SAPSID> identifies the entire SAP system. <br /> _(See Obs.*)_| <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
SAP_ASCS_INSTANCE_NUMBER | Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_ERS_INSTANCE_NUMBER | Technical identifier for internal processes of ERS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_CI_INSTANCE_NUMBER | Technical identifier for internal processes of PAS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_AAS_INSTANCE_NUMBER | Technical identifier for internal processes of AAS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal.
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal.
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal.
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal.
KIT_IGSEXE_FILE | Path to IGS archive (SAR) | As downloaded from SAP Support Portal.
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal.
KIT_SAPHOTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal.
KIT_ASE_FILE | Path to ASE DB installation archive (ZIP) | As downloaded from SAP Support Portal.
KIT_EXPORT_DIR | Path to Netweaver Installation Export dir | The archives downloaded from SAP Support Portal should be present in this path.
 
 **Obs***: <br />

- The configured instance number must be different for each components (ASCS, ERS, CI, AAS).<br />
- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- **SAP Passwords** 
  - The passwords for the SAP system will be asked interactively during terraform plan step and will not be available after the deployment. (Sensitive* values).

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9) and one uppercase letter</li><li> It must not contain \ (backslash) and " (double quote)</li></ul>
HA_PASSWORD | HA cluster password | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>

- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- **DOMAIN_NAME** variable rules:
  -  it should contain at least one "." as a separator. It is a private domain and it is not reacheable to and from the outside world.
  -  it could be like a subdomain name. Ex.: staging.example.com
  -  it can only use letters, numbers, and hyphens.
  -  hyphens cannot be used at the beginning or end of the domain name.
  -  it can't be used a domain name that is already in use.
  -  domain names are not case sensitive.
- The following SAP **"_SID_"** values are _reserved_ and are _not allowed_ to be used: ADD, ALL, AMD, AND, ANY, ARE, ASC, AUX, AVG, BIT, CDC, COM, CON, DBA, END, EPS, FOR, GET, GID, IBM, INT, KEY, LOG, LPT, MAP, MAX, MIN, MON, NIX, NOT, NUL, OFF, OLD, OMS, OUT, PAD, PRN, RAW, REF, ROW, SAP, SET, SGA, SHG, SID, SQL, SUM, SYS, TMP, TOP, UID, USE, USR, VAR".
 - For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.

 **ASE DB specific parameters:**

 The following ASE DB specific parameters have been configured by default:

Parameter | Value
----------|-------------
ase_server_port | 4901
backup_server_port | 4902
hadr_maintenance_user | **SID**_maint
rma_admin_user | DR_admin
rma_rmi_port | 7000
rma_tds_port | 4909
srs_port | 4905

**Installation media validated for this solution:**

Component | Version | Filename
----------|-------------|-------------
SOFTWARE PROVISIONING MGR | 1.0 SP31 PL 7 | SWPM10SP31_7-20009701.SAR
SOFTWARE PROVISIONING MGR | 1.0 SP38 PL 0 | SWPM10SP38_0-20009701.SAR
SAP KERNEL | 7.53 64-BIT UNICODE PL 1200| SAPEXE_1200-80002573.SAR SAPEXEDB_1200-80002616.SAR
SAP KERNEL | 7.54 64-BIT UNICODE PL 200 | SAPEXE_200-80007612.SAR SAPEXEDB_200-80007655.SAR
SAP IGS | 7.53 PL 15 | igsexe_15-80003187.sar
SAP IGS | 7.54 PL 2  | igsexe_2-80007786.sar
SAP IGS HELPER | PL 17 | igshelper_17-10010245.sar
SAP HOST AGENT | 7.22 SP61 | SAPHOSTAGENT61_61-80004822.SAR
SAP ASE | 16.0.04.04 | RDBMS 51056521_1

**OS images validated for this solution:**

OS version | Image | Role
-----------|-----------|-----------
Red Hat Enterprise Linux 8.6 for SAP HANA (amd64) | ibm-redhat-8-6-amd64-sap-hana-2 | APP/DB
Red Hat Enterprise Linux 8.6 for SAP HANA (amd64) | ibm-redhat-8-6-amd64-sap-hana-4 | APP/DB

## 2.1 Executing the deployment of **SAP Netweaver and ASE DB installation** in GUI (Schematics)

### IBM Cloud API Key
The IBM Cloud API Key should be provided as input value of type sensitive for "ibmcloud_api_key" variable, in `IBM Schematics -> Workspaces -> <Workspace name> -> Settings` menu.
The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).

### Input parameters

The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables. These are described in [General input variables Section](#15-general-input-variables) section.

Beside [General input variables Section](#15-general-input-variables), the below ones, in IBM Schematics have specific description and GUI input options:

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
PRIVATE_SSH_KEY | Input your id_rsa private key pair content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | The file path for private_ssh_key will be automatically generated by default. If it is changed, it must contain the relative path from git repo folders.<br /> Default value: "ansible/id_rsa".
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server.

**SAP input parameters:**

### Steps to follow:

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
       - Click Create a workspace.
       - Enter a name for your workspace.
       - Click Create to create your workspace.
    2.  On the workspace **Settings** page, enter the URL of this solution in the Schematics examples Github repository.
     - Select the latest Terraform version.
     - Click **Save template information**.
     - In the **Input variables** section, review the default input variables and provide alternatives if desired.
    - Click **Save changes**.

4.  From the workspace **Settings** page, click **Generate plan** 
5.  Click **View log** to review the log files of your Terraform
    execution plan.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the VSI host, the hostname and the VPC.

 ## 2.2 Executing the deployment of **SAP Netweaver and ASE DB installation** in CLI

 ### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).
 
### Input parameter file
The solution is configured by editing your variables in the file `input.auto.tfvars`
Edit your VPC, Subnet, Security group, Hostnames, Profile, Image, SSH Keys and starting with minimal recommended disk sizes like so:

**VSI input parameters**

```shell
##########################################################
# General VPC variables:
##########################################################

REGION = "eu-de"
# Region for the VSI. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-2"
# Availability zone for VSI. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-2"

DOMAIN_NAME = "production.example.com"
# The DOMAIN_NAME variable should contain at least one "." as a separator. It is a private domain and it is not reachable to and from the outside world.
# The DOMAIN_NAME variable could be like a subdomain name. Example: staging.example.com
# Domain names can only use letters, numbers, and hyphens.
# Hyphens cannot be used at the beginning or end of the domain name.
# You can't use a domain name that is already in use.
# Domain names are not case sensitive.

ASCS_VIRT_HOSTNAME = "sapascs"
# ASCS Virtual hostname​
# Default =  "sap($your_sap_sid)ascs"

ERS_VIRT_HOSTNAME =  "sapers"
# ERS Virtual Hostname​  
# Default =  "sap($your_sap_sid)ascs"

VPC = "ic4sap"
# EXISTING VPC, previously created by the user in the same region as the VSI. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# EXISTING Security group, previously created by the user in the same VPC. It can be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message.
# The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet"
# EXISTING Subnet in the same region and zone as the VSI, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = [""]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# Input your existing id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_ase-syb_ha" , "~/.ssh/id_rsa_ase-syb_ha" , "/root/.ssh/id_rsa".

##########################################################
# File Shares variables:
##########################################################

SHARE_PROFILE = "dp2"
# Enter the profile for File Share storage.
# More details on https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile."

# Enter Custom File Shares sizes for SAP mounts.
# File shares sizes:
USRSAP_AS1      = "20"
USRSAP_AS2      = "20"
USRSAP_SAPASCS  = "20"
USRSAP_SAPERS   = "20"
USRSAP_SAPMNT   = "20"
USRSAP_SAPSYS   = "20"
USRSAP_TRANS    = "80"

##########################################################
# DB VSI variables:
##########################################################
DB_HOSTNAME_1 = "sybdb-1"
# SYBASE Cluster VSI1 Hostname.
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Default: DB_HOSTNAME_1 = "sybdb-$your_sap_sid-1"

DB_HOSTNAME_2 = "sybdb-2"
# SYBASE Cluster VSI2 Hostname.
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Default: DB_HOSTNAME_2 = "sybdb-$your_sap_sid-2"

DB_PROFILE = "bx2-4x16"
# The DB VSI profile. Supported profiles for DB VSI: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4"
# OS image for DB VSI. Supported OS images for DB VSIs: ibm-redhat-8-6-amd64-sap-hana-2, ibm-redhat-8-6-amd64-sap-hana-4
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB-IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4" 

##########################################################
# SAP APP VSI variables:
##########################################################
APP_HOSTNAME_1 = "sapapp-1"
# SAP Cluster VSI1 Hostname.
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Default: APP_HOSTNAME_1 = "sapapp-$your_sap_sid-1"

APP_HOSTNAME_2 = "sapapp-2"
# SAP Cluster VSI2 Hostname.
# The Hostname for the SAP APP VSI. The hostname should be up to 13 characters, as required by SAP
# Default: APP-HOSTNAME-2 = "sapapp-$your_sap_sid-2"

APP_PROFILE = "bx2-4x16"
# The APP VSI profile. Supported profiles: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

APP_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4"
# OS image for SAP APP VSI. Supported OS images for APP VSIs: ibm-redhat-8-6-amd64-sap-hana-2, ibm-redhat-8-6-amd64-sap-hana-4
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: APP-IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4" 

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWD"
# SAP System ID
# Obs. This will be used  also as identification number across different HA name resources. Duplicates are not allowed.

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

KIT_SAPCAR_FILE = "/storage/NW75SYB/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE =  "/storage/NW75SYB/SWPM10SP38_0-20009701.SAR"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75SYB/SAPHOSTAGENT61_61-80004822.SAR"
KIT_SAPEXE_FILE = "/storage/NW75SYB/KERNEL/754UC/SAPEXE_200-80007612.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75SYB/KERNEL/754UC/SAPEXEDB_200-80007655.SAR"
KIT_IGSEXE_FILE = "/storage/NW75SYB/KERNEL/754UC/igsexe_2-80007786.sar"
KIT_IGSHELPER_FILE = "/storage/NW75SYB/igshelper_17-10010245.sar"
KIT_ASE_FILE = "/storage/NW75SYB/51056521_1_16_0_04_04.ZIP"
KIT_EXPORT_DIR = "/storage/NW75SYB/EXP"
```

## Steps to reproduce:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables:
'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD' and 'HA_PASSWORD'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY', 'SAP_MAIN_PASSWORD' and 'HA_PASSWORD'.
```

### 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
