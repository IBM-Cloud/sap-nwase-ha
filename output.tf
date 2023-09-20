output "SYBASE-DB-PRIVATE-IP-VSI1" {
  value		= "${data.ibm_is_instance.db-vsi-1.primary_network_interface[0].primary_ip[0].address}"
}

output "SYBASE-DB-PRIVATE-IP-VSI2" {
  value		= "${data.ibm_is_instance.db-vsi-2.primary_network_interface[0].primary_ip[0].address}"
}

output "SAP-APP-PRIVATE-IP-VSI1" {
  value		= "${data.ibm_is_instance.app-vsi-1.primary_network_interface[0].primary_ip[0].address}"
}

output "SAP-APP-PRIVATE-IP-VSI2" {
  value		= "${data.ibm_is_instance.app-vsi-2.primary_network_interface[0].primary_ip[0].address}"
}

output "DOMAIN-NAME" {
  value = var.DOMAIN_NAME
}

output FQDN-ALB-ASCS {
 value		= "${data.ibm_is_lb.alb-ascs.hostname}" 
}

output FQDN-ALB-ERS {
 value		= "${data.ibm_is_lb.alb-ers.hostname}"
}

output "HADR_users_ports_used_on_both_nodes" {
  description = "Users and ports used by Sybase HADR on both nodes"
  value = {
    hadr_maintenance_user = "${var.SAP_SID}_maint"
    rma_admin_user        = "DR_admin"
    ase_server_port       = 4901
    backup_server_port    = 4902
    rma_tds_port          = 4909
    rma_rmi_port          = 7000
    srs_port              = 4905
  }
}