variable "base_configuration" {
  description = "use module.base.configuration"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "mac" {
  description = "MAC address for the VM"
  type        = string
}

variable "image" {
  description = "OS image name, e.g. slemicro55o"
  type        = string
}

variable "string_registry" {
  description = "set the registry in string variable in mgradm.yaml"
  type        = bool
  default     = true
}

variable "mirror" {
  description = "hostname of a mounted mirror (for server_mounted_mirror)"
  default     = null
}

variable "container_repository" {
  description = "where to find the server container images"
  default     = ""
}

variable "container_image" {
  description = "server container image name"
  default     = ""
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}"
  default     = {}
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key for VM access"
  default     = null
}

variable "memory" {
  description = "memory for server"
  default = 16384
}

variable "vcpu" {
  description = "number of vcpus for server"
  default = 8
}

variable "repository_disk_size" {
  description = "repository disk size"
  default = 3072
}

variable "database_disk_size" {
  description = "database disk size"
  default = 150
}

variable "main_disk_size" {
  description = "Size of main disk, defined in GiB"
  default = 100
}

variable "disable_auto_bootstrap" {
  description = "disable the default bootstrap mgr-create-bootstrap-repo call after product synchronization"
  default = true
}

variable "disable_auto_channel_sync" {
  description = "disable automatic channel synchronization after product synchronization"
  default = true
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default = true
}

