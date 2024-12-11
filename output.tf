output "SYBASE_DB_PRIVATE_IP_VSI1" {
  value		= "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
}

output "SYBASE_DB_PRIVATE_IP_VSI2" {
  value		= "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
}

output "SAP_APP_PRIVATE_IP_VSI1" {
  value		= "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
}

output "SAP_APP_PRIVATE_IP_VSI2" {
  value		= "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
}

output "DOMAIN_NAME" {
  value = var.DOMAIN_NAME
}

output FQDN_ALB_ASCS {
 value		= "${data.ibm_is_lb.alb-ascs.hostname}" 
}

output FQDN_ALB_ERS {
 value		= "${data.ibm_is_lb.alb-ers.hostname}"
}

output "HADR_USERS_ON_BOTH_NODES" {
  description = "Users for Sybase HADR on both nodes"
  value = {
    hadr_maintenance_user = "${var.SAP_SID}_maint"
    rma_admin_user        = "DR_admin"
  }
}

output "HADR_USED_PORTS_ON_BOTH_NODES" {
  description = "Ports used by Sybase HADR on both nodes"
  value = {
    ase_server_port       = 4901
    backup_server_port    = 4902
    rma_tds_port          = 4909
    rma_rmi_port          = 7000
    srs_port              = 4905
  }
}

output "APP_VSI_STORAGE_LAYOUT" {
  value = distinct([
    for stg in module.app-vsi : stg.STORAGE-LAYOUT
  ])[0]
}

output "SYBASE_VSI_STORAGE_LAYOUT" {
  value = distinct([
    for stg in module.db-vsi : stg.STORAGE-LAYOUT
  ])[0]
}
