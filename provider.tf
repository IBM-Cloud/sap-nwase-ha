variable "IBMCLOUD_API_KEY" {
	description	= "The IBM Cloud API Key should be provided as input value of type sensitive for \"IBMCLOUD_API_KEY\" variable.The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys)."
	sensitive	= true
		validation {
			condition     = length(var.IBMCLOUD_API_KEY) > 43 #&& substr(var.IBMCLOUD_API_KEY, 14, 15) == "-"
			error_message = "The IBMCLOUD_API_KEY value must be a valid IBM Cloud API key."
		}
}

provider "ibm" {
    ibmcloud_api_key	= var.IBMCLOUD_API_KEY
    region				= var.REGION
}
