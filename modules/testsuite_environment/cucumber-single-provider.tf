terraform {
  required_version = ">= 1.6.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu+tcp://${var.BASE_CONFIGURATIONS.base_core["hypervisor"]}/system"
}

module "base_core" {
  source = "./modules/base"

  cc_username     = var.SCC_USER
  cc_password     = var.SCC_PASSWORD
  product_version = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix     = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi       = false
  domain          = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images = lookup(var.BASE_CONFIGURATIONS.base_core, "images", [
    "sles15sp4o", "sles15sp5o", "sles15sp6o", "sles15sp7o",
    "slmicro60o", "slmicro61o",
    "rocky8o", "rocky9o",
    "ubuntu2204o", "ubuntu2404o",
    "opensuse156o", "tumbleweedo",
  ])

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool               = var.BASE_CONFIGURATIONS.base_core["pool"]
    bridge             = var.BASE_CONFIGURATIONS.base_core["bridge"]
    additional_network = var.BASE_CONFIGURATIONS.base_core["additional_network"]
  }
}

module "testsuite_environment" {
  source = "./modules/testsuite_environment"

  providers = {
    libvirt.host_old_sle = libvirt
    libvirt.host_new_sle = libvirt
    libvirt.host_rhlike  = libvirt
    libvirt.host_deblike = libvirt
    libvirt.host_retail  = libvirt
  }

  module_base_configurations = {
    default = module.base_core.configuration
  }

  environment_configuration       = var.ENVIRONMENT_CONFIGURATION
  base_configurations             = var.BASE_CONFIGURATIONS
  platform_location_configuration = var.PLATFORM_LOCATION_CONFIGURATION
  location                        = var.LOCATION
  product_version                 = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version

  scc_user         = var.SCC_USER
  scc_password     = var.SCC_PASSWORD
  scc_ptf_user     = var.SCC_PTF_USER
  scc_ptf_password = var.SCC_PTF_PASSWORD
  zvm_admin_token  = var.ZVM_ADMIN_TOKEN

  git_user         = var.GIT_USER
  git_password     = var.GIT_PASSWORD
  cucumber_gitrepo = var.CUCUMBER_GITREPO
  cucumber_branch  = var.CUCUMBER_BRANCH

  server_container_repository = coalesce(var.SERVER_CONTAINER_REPOSITORY, var.CONTAINER_REPOSITORY)
  proxy_container_repository  = coalesce(var.PROXY_CONTAINER_REPOSITORY, var.CONTAINER_REPOSITORY)
  server_container_image      = var.SERVER_CONTAINER_IMAGE
  container_tag               = var.CONTAINER_TAG
  base_os                     = var.BASE_OS

  server_main_disk_size       = var.SERVER_MAIN_DISK_SIZE
  server_repository_disk_size = var.SERVER_REPOSITORY_DISK_SIZE
  proxy_main_disk_size        = var.PROXY_MAIN_DISK_SIZE

  cucumber_settings = var.CUCUMBER_SETTINGS
  cucumber_aliases  = var.CUCUMBER_ALIASES
}

output "configuration" {
  value = {
    controller = module.testsuite_environment.configuration.controller
    server     = module.testsuite_environment.configuration.server_configuration
  }
}

# =============================================================================
# VARIABLES
# =============================================================================

variable "ENVIRONMENT_CONFIGURATION"       { type = any }
variable "BASE_CONFIGURATIONS"             { type = any }
variable "PLATFORM_LOCATION_CONFIGURATION" { type = any }
variable "LOCATION"                        { type = string }
variable "PRODUCT_VERSION"                 { type = string; default = null }

variable "SCC_USER"         { type = string }
variable "SCC_PASSWORD"     { type = string }
variable "SCC_PTF_USER"     { type = string; default = null }
variable "SCC_PTF_PASSWORD" { type = string; default = null }
variable "ZVM_ADMIN_TOKEN"  { type = string; default = null }

variable "GIT_USER"         { type = string; default = null }
variable "GIT_PASSWORD"     { type = string; default = null }
variable "CUCUMBER_GITREPO" { type = string }
variable "CUCUMBER_BRANCH"  { type = string }

variable "CONTAINER_REPOSITORY" {
  type        = string
  description = "Shared container registry for server and proxy. Used when SERVER/PROXY overrides are not set."
  default     = null
}
variable "SERVER_CONTAINER_REPOSITORY" { type = string; default = null }
variable "PROXY_CONTAINER_REPOSITORY"  { type = string; default = null }
variable "SERVER_CONTAINER_IMAGE"      { type = string; default = "" }
variable "CONTAINER_TAG"               { type = string; default = "latest" }
variable "BASE_OS"                     { type = string; default = null }

variable "SERVER_MAIN_DISK_SIZE" {
  type        = number
  description = "Main disk size in GiB for the server. BV default: 100. Cucumber recommendation: 500."
  default     = 100
}
variable "SERVER_REPOSITORY_DISK_SIZE" {
  type        = number
  description = "Repository disk size in GiB. BV default: 3072. Cucumber default: 300."
  default     = 300
}
variable "PROXY_MAIN_DISK_SIZE" {
  type        = number
  description = "Main disk size in GiB for the proxy. BV default: 100. Cucumber recommendation: 200."
  default     = 100
}

variable "CUCUMBER_SETTINGS" {
  type = object({
    no_auth_registry         = optional(string)
    auth_registry            = optional(string)
    auth_registry_username   = optional(string)
    auth_registry_password   = optional(string)
    server_http_proxy        = optional(string)
    custom_download_endpoint = optional(string)
    git_profiles_repo        = optional(string)
    from_email               = optional(string)
  })
  description = "Testsuite controller settings (registries, proxies, git profiles)."
  default     = {}
}

variable "CUCUMBER_ALIASES" {
  type = object({
    suse_minion    = optional(string)
    suse_sshminion = optional(string)
    suse_client    = optional(string)
    rhlike_minion  = optional(string)
    deblike_minion = optional(string)
    build_host     = optional(string)
    kvm_host       = optional(string)
  })
  description = <<-EOT
    Maps generic cucumber roles to specific versioned ENVIRONMENT_CONFIGURATION
    host keys. The testsuite_environment module sets both the generic grain
    (e.g. 'minion') AND the specific versioned grain (e.g. 'sle15sp7_minion')
    from the same host, so bashrc exports both MINION and SLE15SP7_MINION.

    Example:
      CUCUMBER_ALIASES = {
        suse_minion    = "sles15sp7_minion"
        suse_sshminion = "sles15sp7_sshminion"
        suse_client    = null
        rhlike_minion  = "rocky8_minion"
        deblike_minion = "ubuntu2404_minion"
        build_host     = "sles15sp7_buildhost"
        kvm_host       = null
      }
  EOT
  default = {}
}
