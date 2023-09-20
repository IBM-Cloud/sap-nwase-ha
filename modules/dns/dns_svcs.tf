resource "ibm_resource_instance" "dns_inst" {
  name           =  lower ("${var.VPC}-${var.SAP_SID}-${var.REGION}-dns")
  resource_group_id  =  data.ibm_resource_group.group.id
  location           =  "global"
  service        =  "dns-svcs"
  plan           =  "standard-dns"
}

resource "ibm_dns_zone" "ha_zone" {
  name = var.DOMAIN_NAME
  instance_id = ibm_resource_instance.dns_inst.guid
  description = "The zone is created to address the ALBs for SYBASE HA Deployment"
  label = "sap_ha_zone"
}

resource "ibm_dns_resource_record" "cname-ascs" {
  instance_id = ibm_resource_instance.dns_inst.guid
  zone_id     = ibm_dns_zone.ha_zone.zone_id
  type        = "CNAME"
  name        = var.ASCS-VIRT-HOSTNAME
  rdata       = "${var.ALB_ASCS_HOSTNAME}"
  ttl         = 43200
}

resource "ibm_dns_resource_record" "cname-ers" {
  instance_id = ibm_resource_instance.dns_inst.guid
  zone_id     = ibm_dns_zone.ha_zone.zone_id
  type        = "CNAME"
  name        = var.ERS-VIRT-HOSTNAME
  rdata       = "${var.ALB_ERS_HOSTNAME}"
  ttl         = 43200
}

resource "ibm_dns_permitted_network" "test-pdns-permitted-network-nw" {
    instance_id = ibm_resource_instance.dns_inst.guid
    zone_id = ibm_dns_zone.ha_zone.zone_id
    vpc_crn = data.ibm_is_vpc.vpc.crn
    type = "vpc"
}



