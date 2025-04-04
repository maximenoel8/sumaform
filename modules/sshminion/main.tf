module "sshminion" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  quantity                      = var.quantity
  use_os_released_updates       = var.use_os_released_updates
  install_salt_bundle           = var.install_salt_bundle
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages           = var.additional_packages
  gpg_keys                      = var.gpg_keys
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = false
  roles                         = ["sshminion"]
  disable_firewall              = var.disable_firewall
  product_version               = var.product_version
  grains = {
    mirror                 = var.base_configuration["mirror"]
    sles_registration_code = var.sles_registration_code
  }


  image             = var.image
  provider_settings = var.provider_settings
}

output "configuration" {
  value = module.sshminion.configuration
}

