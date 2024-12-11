variable "REGION" {
    type = string
    description = "Cloud Region"
}

variable "DOMAIN_NAME" {
	type		= string
	description	= "Private Domain Name"
}

variable "VPC" {
    type = string
    description = "VPC name"
}

variable "RESOURCE_GROUP" {
    type = string
    description = "Resource Group"
}

variable "SAP_SID" {
    type = string
    description = "SAP SID"
}

variable "ALB_ASCS_HOSTNAME" {
    type = string
    description = "ALB_ASCS_HOSTNAME"
}

variable "ALB_ERS_HOSTNAME" {
    type = string
    description = "ALB_ERS_HOSTNAME"
}

data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

variable "ASCS-VIRT-HOSTNAME" {
	type		= string
	description	= "Private SubDomain Name"
}

variable "ERS-VIRT-HOSTNAME" {
	type		= string
	description	= "Private SubDomain Name"
}
