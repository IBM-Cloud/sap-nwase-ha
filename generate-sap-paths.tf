# List SAP PATHS
resource "local_file" "KIT_SAP_PATHS" {
  content = <<-DOC
${var.KIT_SAPCAR_FILE}
${var.KIT_SWPM_FILE}
${var.KIT_SAPHOSTAGENT_FILE}
${var.KIT_SAPEXE_FILE}
${var.KIT_SAPEXEDB_FILE}
${var.KIT_IGSEXE_FILE}
${var.KIT_IGSHELPER_FILE}
${var.KIT_ASE_FILE}
${var.KIT_EXPORT_DIR}/*.*
    DOC
  filename = "modules/precheck-ssh-exec/sap-paths-${local.DB-HOSTNAME-1}"
}