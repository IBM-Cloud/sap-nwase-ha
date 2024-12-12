#  Deployment Automation for SAP Netweaver 7.x (ABAP) and SAP ASE High Availability Multi-Zone or Single-Zone

## Description

This automation solution is designed for the deployment of **SAP Netweaver 7.x (ABAP) and SAP ASE High Availability solution** on top of **Red Hat Enterprise Linux 8.x**, in IBM CLoud Multi-Zone or Single-Zone, using IBM Cloud Schematics or Terraform CLI. The SAP solution will be deployed in an existing IBM Cloud Gen2 VPC, using a deployed [BASTION server (Deployment server) host with secure remote SSH access](https://github.com/IBM-Cloud/sap-bastion-setup), with secure remote SSH access.

The solution is based on Terraform and Ansible playbooks executed using IBM Cloud Schematics or Terraform CLI and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.

It contains:

- Terraform scripts to provision:
  - one Power Placement group for all four VMs created by this solution
  - four VSIs, in an EXISTING VPC, with Subnet and Security Group configs. The VSIs scope: two for the ASE database instances and two for the SAP NW application cluster.
- Terraform scripts to provision and configure:
  - two Application Load Balancers for SAP ASCS/ERS
  - one VPC DNS service used to map the ALB FQDN to the SAP ASCS/ERS Virtual hostnames
  - seven File shares for VPC
- Bash scripts:
  - to check the prerequisites required by SAP VSIs deployment 
  - to integrate into a single step the VPC virtual resources provisioning and the **SAP ASE HADR solution** installation and configuration.
- Ansible scripts for:
  - OS requirements installation and configuration for SAP applications
  - cluster components installation
  - SAP application cluster configuration
  - ASE DB installationn
  - ASE DB system replica configuration
  - ASCS and ERS instances installation
  - Fault Manager installation
  - primary and additional application servers installation

The following resources are created during the deployment:

- two SAP VSIs for ASCS/ERS HA running in a pacemaker cluster; SAP PAS is running on one of the cluster node and SAP AAS on the second node  
- two ASE VSIs, with Sybase HADR configuration and HSR Sync replication; the primary node is active and the secondary node runs in standby mode
- two ALBs used for Virtual IP/hostname for ASCS and ERS.
- one DNS service to map the virtual names for ASCS/ERS to ALB hostname
- seven File shares to be used by SAP: `sapmnt/<SAP_SID>`, `/usr/sap/trans`, `/usr/sap/<SAP_SID>/SYS`, `/usr/sap/SYB/ASCSxx`,  `/usr/sap/SYB/ERSxx`, `/usr/sap/<SAP_SID>/Dxx`,  `/usr/sap/<SAP_SID>/Dxx`

Notes:
- For Network latency between VPC Zones and Regions please check the"VPC Network latency dashboards" using the link bellow and run your own measurement according with SAP note "500235 - Network Diagnosis with NIPING" to perform a latency check using SAP tool niping: https://cloud.ibm.com/docs/vpc?topic=vpc-network-latency-dashboard
   - The results reported are as measured. There are no performance guarantees implied by these measurement. 
   - These statistics provide visibility into latency between all regions and zones to help you plan the optimal selection for your cloud deployment and plan for scenarios, such as data residency and performance

- ZONE_1 is the availability zone for DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs.
- SUBNET_1  is an EXISTING Subnet, where DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs will be created. 
- ZONE_2 is the availability zone for DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs.
- SUBNET_2  is an EXISTING Subnet, where DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs will be created. 
- If the values of the variables ZONE_1 and ZONE_2 are equal and the values of the variables SUBNET_1 and SUBNET_2 are also equal, an **SAP Single-Zone Deployment** will be executed in ZONE_1, SUBNET_1.
- If the variable values from ZONE_1, SUBNET_1 are different than ZONE_2, SUBNET_2, an **SAP Multi-Zone Deployment** will be executed.
- Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc.
- The list of EXISTING Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets.
- Each Subnet must have Internet access throught a  Public Gateway.


## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 Prerequisites](#12-prerequisites)
- [1.3 VSI Configuration](#13-vsi-configuration)
- [1.4 VPC Configuration](#14-vpc-configuration)
- [1.5 Files description and structure](#15-files-description-and-structure)
- [1.6 General input variabiles](#16-general-input-variables)
- [2.1 Executing the deployment of **HA SAP Netweaver and ASE DB installation** in GUI (Schematics)](#21-executing-the-deployment-of-ha-sap-netweaver-and-ase-db-installation-in-gui-schematics)
- [2.2 Executing the deployment of **HA SAP Netweaver and ASE DB installation** in CLI](#22-executing-the-deployment-of-ha-sap-netweaver-and-ase-db-installation-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5 and SAP ASE 16.0.04.04** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 Prerequisites

- A Deployment Server (BASTION Server) in the same VPC must exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- On the Deployment Server, download the SAP kits from the SAP Portal. Make note of the download locations. Ansible decompresses all of the archive kits.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform and to determine your permissions for IBM Cloud services.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.

## 1.3 VSI Configuration

Red Hat Enterprise Linux 8 for SAP HANA (amd64) is installed on the VSIs and SSH keys are configured to allow the access as root user vis SSH. The following storage volumes created for DB and SAP APP VSI:

ASE DB VSI Disks:
- 3 disks ["256" , "32" , "64"] GB, with 10 IOPS / GB - DATA
- 1 disk with 10 IOPS / GB - SWAP (the size depends on the OS profile used, for `bx2-4x16` the size will be 48 GB)

SAP APPs VSI Disks:
- 1 disk with 10 IOPS / GB - SWAP (the size depends on the OS profile used, for `bx2-4x16` the size will be 48 GB)

File Shares:
- 6 x 20 GB file shares - DATA
- 1 x 80 GB file shares - DATA

In order to perform the deployment, you can use either the CLI component or the GUI component (Schematics) of the automation solution.

## 1.4 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

## 1.5 Files description and structure

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

## 1.6 General Input variables

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys)
SSH_KEYS | List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. The SSH Keys must be created for the same region as the Cloud resources for SAP. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input:<br /> ["r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a", "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e"]
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are available [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
VPC | The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
ZONE_1| Availability zone for DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. 
SUBNET_1 | The name of an EXISTING Subnet, in the same VPC, ZONE_1, where DB_HOSTNAME_1 and APP_HOSTNAME_1 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets
ZONE_2| Availability zone for DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. OBS.: If the same value as for ZONE_1 is used, and the value for SUBNET_1 is the same with the value for SUBNET_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then an SAP Multizone deployment will be done.
SUBNET_2 | The name of an EXISTING Subnet, in the same VPC, ZONE_2, where DB_HOSTNAME_2 and APP_HOSTNAME_2 VSIs will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets. OBS.: If the same value as for SUBNET_1 is used, and the value for ZONE_1 is the same with the value for ZONE_2, the deployment will be done in a single zone. If the values for ZONE_1, SUBNET_1 are different than the ones for ZONE_2, SUBNET_2 then it an SAP Multizone deployment will be done.
SECURITY_GROUP | The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
DOMAIN_NAME | The DOMAIN_NAME variable should contain at least one "." as a separator. It is a private domain and it is not reachable from the outside world. The DOMAIN_NAME value could be like a subdomain name. Ex.: staging.example.com. You can't use a domain name that is already in use. The list with DNS resources can be searched [here](https://cloud.ibm.com/resources). <br />  Sample value:  "example.com". <br /> _(See Obs.*)_
SHARE PROFILE | The Storage Profile for the File Share. More details on https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#dp2-profile." <br/> Default value:  SHARE_PROFILE = "dp2".
SHARE SIZES | Custom File Shares Sizes for SAP mounts. Sample values:  USRSAP_SAPMNT = "20" , USRSAP_TRANS = "80".
[ASCS/ERS]_VIRT_HOSTNAME | ASCS/ERS virtual hostnames.  <br /> Default values:  "sap[ascs/ers]". When the default value is used, the virtual hostname will automatically be changed based on <SAP_SID> to "sap<sap_sid>[ascs/ers]"
[DB/APP]_HOSTNAME | Hostname of SAP ASE DB/APP VSIs. Each hostname should be up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361). <br> Default values: "sapapp-1/2" for APP_HOSTNAME_1/2 and "sybdb-1/2" for DB_HOSTNAME_1/2. When the default value is used, the virtual hostname will automatically be changed, based on <SAP_SID>, to "sybdb-<sap_sid>-1/2" for DB_HOSTNAME_1/2 and "sapapp-<sap_sid>-1/2" for APP_HOSTNAME_1/2.
[DB/APP]_PROFILE | The profile used for the ASE DB/APP VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)<br/> Default values: DB_PROFILE = "bx2-4x16" , APP_PROFILE = "bx2-4x16".
[DB/APP]_IMAGE | The OS image used for the ASE DB/APP VSI. Red Hat Enterprise Linux 8 for SAP HANA (amd64) image must be used for all VMs, as this image type contains the required SAP and HA subscriptions. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)  <br/> Default value: ibm-redhat-8-6-amd64-sap-hana-4"

**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
SAP_SID | The SAP system ID. Identifies the entire SAP system. It will be used also as identification string across different HA name resources <br /> _(See Obs.*)_| <ul><li>Consists of exactly three alphanumeric characters</li><li>The first character must be a letter</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li><li>Duplicates are not allowed</li></ul>
SAP_ASCS_INSTANCE_NUMBER | The central ABAP service instance number. Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
SAP_ERS_INSTANCE_NUMBER | The enqueue replication server instance number. Technical identifier for internal processes of ERS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
SAP_CI_INSTANCE_NUMBER | The SAP central instance number. Technical identifier for internal processes of PAS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
SAP_AAS_INSTANCE_NUMBER | The SAP additional application server instance number. Technical identifier for internal processes of AAS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal.
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal.
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal.
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal.
KIT_IGSEXE_FILE | Path to IGS archive (SAR) | As downloaded from SAP Support Portal.
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal.
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal.
KIT_ASE_FILE | Path to ASE DB installation archive (ZIP) | As downloaded from SAP Support Portal.
KIT_NWABAP_EXPORT_FILE | Path to Netweaver Installation Export ZIP file | The archives downloaded from SAP Support Portal should be present in this path.
 
 **Obs***: <br />

- The configured instance number must be different for each components (ASCS, ERS, CI, AAS).<br />
- **Sensitive** - The variable value is not displayed in Schematics logs and it is hidden in the input field.<br />
- **SAP Passwords** 
  - The passwords for the SAP system will be asked interactively during `terraform plan` step and will not be available after the deployment. (Sensitive* values).

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 15 to 30 characters long<li>It must contain at least one digit (0-9)</li><li>It must contain at least one lowercase letter (a-z)</li><li>It must contain at least one uppercase letter (A-Z)</li><li>It may contain one of the following special characters: !, #, $, &, , +, ,, -, ., /, :, =>, @, ^, _, |, ~.</li><li>It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z).</li></ul>
HA_PASSWORD | HA cluster password | <ul><li>It must be 15 to 30 characters long<li>It must contain at least one digit (0-9)</li><li>It must contain at least one lowercase letter (a-z)</li><li>It must contain at least one uppercase letter (A-Z)</li><li>It must contain at least one of the following special characters: !, #, $, %, &, (, ), *, +, ,, -, ., /, :, =, >, @, [, ], ^, _, {, |, }, ~.</li><li>It must start with a lowercase letter (a-z) or with an uppercase letter (A-Z).</li></ul>

- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONES, VPC, SUBNET, SECURITYGROUP.
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

The following ASE DB specific parameters are configured by default:

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
SOFTWARE PROVISIONING MGR | 1.0 SP42 PL 1 | SWPM10SP42_1-20009701.SAR
SAPCAR | 7.53 PL 1300 | SAPCAR_1300-70007716.EXE
SAP KERNEL | 7.54 64-BIT UNICODE PL 400 | SAPEXE_400-80007612.SAR SAPEXEDB_400-80007655.SAR
SAP IGS | 7.54 PL 4  | igsexe_4-80007786.sar
SAP IGS HELPER | PL 17 | igshelper_17-10010245.sar
SAP HOST AGENT | 7.22 SP65 | SAPHOSTAGENT65_65-80004822.SAR
SAP ASE | 16.0.04.06 | 51057961_1.ZIP

**OS images validated for this solution:**

OS version | Image | Role
-----------|-----------|-----------
Red Hat Enterprise Linux 8.6 for SAP HANA (amd64) | ibm-redhat-8-6-amd64-sap-hana-6 | APP/DB
Red Hat Enterprise Linux 8.4 for SAP HANA (amd64) | ibm-redhat-8-4-amd64-sap-hana-10 | APP/DB

**Terraform version used to validate this solution:**

The deployment was validated for Terraform 1.5.7 and Terraform 1.9.2

## 2.1 Executing the deployment of **HA SAP Netweaver and ASE DB installation** in GUI (Schematics)

### Input parameters

In IBM Schematics, besides [General input variables Section](#15-general-input-variables), there are additional parameters:

**VSI input parameters:**

Parameter | Description
----------|------------
PRIVATE_SSH_KEY | id_rsa private key content (Sensitive* value) in OpenSSH format. This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | File path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. <br /> Default value: "ansible/id_rsa".
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.

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
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the VSI host, the hostname and the VPC.

 ## 2.2 Executing the deployment of **HA SAP Netweaver and ASE DB installation** in CLI

 ### IBM Cloud API Key
During Terraform planning phase (command `terraform plan --out plan1`), your IBM Cloud API Key will be required.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).
 
### Input parameter file
The `input.auto.tfvars` file must be used to make the desired configuration, as in the example bellow:

**VSI input parameters**

```shell
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

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-4"
# The OS image for the DB VSI. 
# Red Hat Enterprise Linux 8 for SAP HANA (amd64) image must be used for all VMs, as this image type contains the required SAP and HA subscriptions.
# Supported OS images: ibm-redhat-8-6-amd64-sap-hana-4, ibm-redhat-8-4-amd64-sap-hana-7. 
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211
# A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images.
# Example: DB_IMAGE = "ibm-redhat-8-4-amd64-sap-hana-4" 

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

KIT_SAPCAR_FILE = "/storage/NW75SYB/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE =  "/storage/NW75SYB/SWPM10SP38_0-20009701.SAR"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75SYB/SAPHOSTAGENT61_61-80004822.SAR"
KIT_SAPEXE_FILE = "/storage/NW75SYB/KERNEL/754UC/SAPEXE_200-80007612.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75SYB/KERNEL/754UC/SAPEXEDB_200-80007655.SAR"
KIT_IGSEXE_FILE = "/storage/NW75SYB/KERNEL/754UC/igsexe_2-80007786.sar"
KIT_IGSHELPER_FILE = "/storage/NW75SYB/igshelper_17-10010245.sar"
KIT_ASE_FILE = "/storage/NW75SYB/51056521_1_16_0_04_04.ZIP"
KIT_NWABAP_EXPORT_FILE = "/storage/NW75SYB/ABAPEXP/51050829_3.ZIP"
```

## Steps to reproduce:

To initialize Terraform:

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
