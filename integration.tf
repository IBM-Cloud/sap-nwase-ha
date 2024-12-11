#############################################################
# Export Terraform variable values to an Ansible var_file.
#############################################################

#### HA Infra variables.

resource "local_file" "ha_ansible_infra-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.

# INFRA variables
api_key: "${var.IBMCLOUD_API_KEY}"
region: "${var.REGION}"
ha_password: ${base64encode(var.HA_PASSWORD)}

sybdb_iphost1: "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
sybdb_iphost2: "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
sybdb_hostname1: "${data.ibm_is_instance.db-vsi-1.name}"
sybdb_hostname2: "${data.ibm_is_instance.db-vsi-2.name}"

app_iphost1: "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
app_iphost2: "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
app_hostname1: "${data.ibm_is_instance.app-vsi-1.name}"
app_hostname2: "${data.ibm_is_instance.app-vsi-2.name}"

app_instanceid1: "${data.ibm_is_instance.app-vsi-1.id}"
app_instanceid2: "${data.ibm_is_instance.app-vsi-2.id}"
sybdb_instanceid1: "${data.ibm_is_instance.db-vsi-1.id}"
sybdb_instanceid2: "${data.ibm_is_instance.db-vsi-2.id}"

alb_ascs_hostname: "${data.ibm_is_lb.alb-ascs.hostname}"
alb_ers_hostname: "${data.ibm_is_lb.alb-ers.hostname}"
...
    DOC
  filename = "ansible/hainfra-vars.yml"
}

#### Ansible inventory.

resource "local_file" "ansible_inventory" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
all:
  hosts:
    sybdb_iphost1:
      ansible_host: "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
    sybdb_iphost2:
      ansible_host: "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
    app_iphost1:
      ansible_host: "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
    app_iphost2:
      ansible_host: "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
    DOC
  filename = "ansible/inventory.yml"
}

#### SAP-APP variables.

resource "local_file" "app_ansible_sap-vars" {
  depends_on = [ module.db-vsi ]
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.

# SAP system configuration
app_swap_disk_size: "${distinct([ for stg in module.app-vsi : stg.SWAP_DISK_SIZE ])[0]}"
ase_swap_disk_size: "${distinct([ for stg in module.db-vsi : stg.SWAP_DISK_SIZE ])[0]}"
sap_sid: "${var.SAP_SID}"
sap_ascs_instance_number: "${var.SAP_ASCS_INSTANCE_NUMBER}"
sap_ers_instance_number: "${var.SAP_ERS_INSTANCE_NUMBER}"
sap_ci_instance_number: "${var.SAP_CI_INSTANCE_NUMBER}"
sap_aas_instance_number: "${var.SAP_AAS_INSTANCE_NUMBER}"
sap_main_password: ${base64encode(var.SAP_MAIN_PASSWORD)}

# SAP Installation kit paths
kit_sapcar_file: "${var.KIT_SAPCAR_FILE}"
kit_swpm_file: "${var.KIT_SWPM_FILE}"
kit_sapexe_file: "${var.KIT_SAPEXE_FILE}"
kit_sapexedb_file: "${var.KIT_SAPEXEDB_FILE}"
kit_igsexe_file: "${var.KIT_IGSEXE_FILE}"
kit_igshelper_file: "${var.KIT_IGSHELPER_FILE}"
kit_saphostagent_file: "${var.KIT_SAPHOSTAGENT_FILE}"
kit_ase_file: "${var.KIT_ASE_FILE}"
kit_nwabap_export_file: "${var.KIT_NWABAP_EXPORT_FILE}"
...
    DOC
  filename = "ansible/sap-vars.yml"
}

#### Integrate all variables for sap file shares in one.

resource "null_resource" "file_shares_ansible_vars" {
  depends_on = [module.file-shares]

  provisioner "local-exec" {
    working_dir = "ansible"
    command = <<EOF
    echo -e "---\n`cat fileshare_*`\n...\n" > fileshares-vars.yml; rm -rf fileshare_*; echo done
      EOF
      }
}

# Export Terraform variable values to an Ansible var_file for Sybase server
resource "local_file" "tf_ansible_hana_storage_generated_file" {
  depends_on = [ module.db-vsi ]
  source = "${path.root}/modules/db-vsi/files/sybase_vm_volume_layout.json"
  filename = "ansible/sybase_vm_volume_layout.json"
}

# Export Terraform variable values to an Ansible var_file for APP Server
resource "local_file" "tf_ansible_vars_generated_file_app" {
  depends_on = [ module.app-vsi ]
  source = "${path.root}/modules/app-vsi/files/sapapp_vm_volume_layout.json"
  filename = "ansible/sapapp_vm_volume_layout.json"
}
