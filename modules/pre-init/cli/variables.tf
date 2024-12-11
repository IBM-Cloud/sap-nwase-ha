variable "kit_sapcar_file" {
	type		= string
	description = "kit_sapcar_file"
    validation {
    condition = fileexists("${var.kit_sapcar_file}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "kit_swpm_file" {
	type		= string
	description = "kit_swpm_file"
    validation {
    condition = fileexists("${var.kit_swpm_file}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "kit_saphostagent_file" {
	type		= string
	description = "kit_saphostagent_file"
    validation {
    condition = fileexists("${var.kit_saphostagent_file}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "kit_sapexe_file" {
	type		= string
	description = "kit_sapexe_file"
    validation {
    condition = fileexists("${var.kit_sapexe_file}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "kit_sapexedb_file" {
	type		= string
	description = "kit_sapexedb_file"
    validation {
    condition = fileexists("${var.kit_sapexedb_file}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "kit_igsexe_file" {
	type		= string
	description = "kit_igsexe_file"
    validation {
    condition = fileexists("${var.kit_igsexe_file}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "kit_igshelper_file" {
	type		= string
	description = "kit_igshelper_file"
    validation {
    condition = fileexists("${var.kit_igshelper_file}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "kit_ase_file" {
	type		= string
	description = "kit_ase_file"
    validation {
    condition = fileexists("${var.kit_ase_file}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "kit_nwabap_export_file" {
	type		= string
	description = "kit_nwabap_export_file"
    validation {
    condition = fileexists("${var.kit_nwabap_export_file}") == true
    error_message = "The PATH  does not exist."
    }
}
