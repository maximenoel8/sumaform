variable "environment_configuration" {
  type = any
  description = "Collection of values containing: mac addresses, hypervisor and additional network"
}

variable "platform_location_configuration" {
  type = any
  description = "Collection of values containing location specific information"
}

variable location {
  type = string
  description = "Platform location, nue or slc1"
}

variable "cucumber_gitrepo" {
  type = string
  description = "Testsuite git repository"
}

variable "cucumber_branch" {
  type = string
  description = "Testsuite git branch"
}

variable "git_user" {
  type = string
  description = "Git user to access git repository"
  default = null // Not needed for master, as it is public
}

variable "git_password" {
  type = string
  description = "Git user password to access git repository"
  default = null // Not needed for master, as it is public
}

variable "scc_user" {
  type = string
  description = "SCC user used as product organization"
}

variable "scc_password" {
  type = string
  description = "SCC password used as product organization"
}

variable "scc_ptf_user" {
  type = string
  description = "SCC user used for PTF Feature testing, only available for 5.1"
  default = null
}

variable "scc_ptf_password" {
  type = string
  description = "SCC user used for PTF Feature testing, only available for 5.1"
  default = null
}

variable "server_container_repository" {
  type = string
  description = "Server container registry path, not needed for 4.3"
  default = ""
}

variable "proxy_container_repository" {
  type = string
  description = "Proxy container registry path, not needed for 4.3"
  default = ""
}

variable "server_container_image" {
  type = string
  description = "Server container image, not needed for 4.3"
  default = ""
}

variable "container_tag" {
  type = string
  description = "Container tag to use for server and proxy"
  default = "latest"
}

variable "zvm_admin_token" {
  type = string
  description = "Admin token for Feilong provider"
}

variable "base_os" {
  type        = string
  description = "Optional override for the server base OS image"
  default     = null
}

variable "product_version" {
  type        = string
}

variable "base_configurations" {
  type        = map(any)
  description = "Map of base configurations. Mandatory keys: default. Optional: old_sle, new_sle, deblike, rhlike, retail, arm, s390."
}

variable "module_base_configurations" {
  type        = map(any)
  description = "Module base configurations"
}

# ============================================================
# CUCUMBER ALIASES
# Maps generic cucumber role names to the specific versioned
# module that backs them. The testsuite_environment module will
# set both the generic grain (e.g. 'minion') AND the specific
# versioned grain (e.g. 'sle15sp7_minion') from the same host,
# so that both MINION and SLE15SP7_MINION are exported in the
# controller's .bashrc — without any testsuite changes.
#
# Each field is the key of an existing ENVIRONMENT_CONFIGURATION
# entry, e.g. "sles15sp7_minion". When null, no alias is set.
#
# Example (in tfvars):
#   CUCUMBER_ALIASES = {
#     suse_minion    = "sles15sp7_minion"
#     suse_sshminion = "sles15sp7_sshminion"
#     suse_client    = null
#     rhlike_minion  = "rocky8_minion"
#     deblike_minion = "ubuntu2404_minion"
#     build_host     = "sles15sp7_buildhost"
#     kvm_host       = null
#   }
# ============================================================
variable "cucumber_aliases" {
  type = object({
    suse_minion    = optional(string)
    suse_sshminion = optional(string)
    suse_client    = optional(string)
    rhlike_minion  = optional(string)
    deblike_minion = optional(string)
    build_host     = optional(string)
    kvm_host       = optional(string)
  })
  description = "Maps generic cucumber roles to specific versioned ENVIRONMENT_CONFIGURATION host keys."
  default     = {}
}

