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
# CUCUMBER ALIAS IMAGES
# Override the OS image used for each generic cucumber role.
# Defaults are derived from product_version via locals in main.tf.
# ============================================================
variable "cucumber_aliases" {
  type = object({
    suse_minion_image    = optional(string)
    suse_sshminion_image = optional(string)
    suse_client_image    = optional(string)
    rhlike_minion_image  = optional(string)
    deblike_minion_image = optional(string)
    build_host_image     = optional(string)
    kvm_host_image       = optional(string)
    pxeboot_minion_image = optional(string)
    server_image         = optional(string)
    proxy_image          = optional(string)
  })
  description = <<-EOT
    Image overrides for generic cucumber host roles. When null, defaults are
    selected automatically based on product_version. Set individual fields to
    override specific roles.

    Example (in tfvars):
      CUCUMBER_ALIASES = {
        suse_minion_image    = "sles15sp7o"
        suse_sshminion_image = "sles15sp7o"
        rhlike_minion_image  = "rocky8o"
        deblike_minion_image = "ubuntu2404o"
        build_host_image     = "sles15sp7o"
        kvm_host_image       = "sles15sp7o"
        pxeboot_minion_image = "sles15sp7o"
        server_image         = "slmicro61o"
        proxy_image          = "slmicro61o"
      }
  EOT
  default = {}
}

# ============================================================
# CUCUMBER SETTINGS
# Controller and testsuite-specific settings that were
# previously hardcoded in individual cucumber main_XX.tf files.
# ============================================================
variable "cucumber_settings" {
  type = object({
    no_auth_registry          = optional(string)
    auth_registry             = optional(string)
    auth_registry_username    = optional(string)
    auth_registry_password    = optional(string)
    server_http_proxy         = optional(string)
    custom_download_endpoint  = optional(string)
    git_profiles_repo         = optional(string)
    from_email                = optional(string)
  })
  description = <<-EOT
    Testsuite controller settings previously hardcoded in cucumber main_XX.tf files.

    Example (in tfvars):
      CUCUMBER_SETTINGS = {
        no_auth_registry         = "registry.mgr.suse.de"
        auth_registry            = "registry.mgr.suse.de:5000/cucutest"
        auth_registry_username   = "cucutest"
        auth_registry_password   = "cucusecret"
        server_http_proxy        = "http-proxy.mgr.suse.de:3128"
        custom_download_endpoint = "ftp://minima-mirror-ci-bv.mgr.suse.de:445"
        git_profiles_repo        = "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles/temporary"
        from_email               = "root@suse.de"
      }
  EOT
  default = {}
}
