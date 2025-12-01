variable "testsuite-branch" {
  default = {
    "4.3-released"   = "Manager-4.3"
    "4.3-nightly"    = "Manager-4.3"
    "4.3-pr"         = "Manager-4.3"
    "4.3-VM-released"= "Manager-4.3"
    "4.3-VM-nightly" = "Manager-4.3"
    "5.0-released"   = "Manager-5.0"
    "5.0-nightly"    = "Manager-5.0"
    "5.1-released"   = "Manager-5.1"
    "5.1-nightly"    = "Manager-5.1"
    "head"           = "master"
    "uyuni-master"   = "master"
    "uyuni-released" = "master"
    "uyuni-pr"       = "master"
  }
}

locals {
  product_version = var.product_version != null ? var.product_version : var.base_configuration["product_version"]
}

module "controller" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_packages           = var.additional_packages
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = false
  roles                         = ["controller"]
  product_version               = local.product_version
  grains = {
    cc_username     = var.base_configuration["cc_username"]
    cc_password     = var.base_configuration["cc_password"]
    cc_ptf_username = var.cc_ptf_username
    cc_ptf_password = var.cc_ptf_password
    git_username    = var.git_username
    git_password    = var.git_password
    git_repo        = var.git_repo
    branch          = var.branch == "default" ? var.testsuite-branch[var.base_configuration["product_version"]] : var.branch
    mirror          = var.no_mirror == true ? null :  var.base_configuration["mirror"]

    server            = var.server_configuration["hostname"]
    proxy             = var.proxy_configuration["hostname"]
    client            = length(var.client_configuration["hostnames"]) > 0 ? var.client_configuration["hostnames"][0] : null
    minion            = length(var.minion_configuration["hostnames"]) > 0 ? var.minion_configuration["hostnames"][0] : null
    build_host        = length(var.buildhost_configuration["hostnames"]) > 0 ? var.buildhost_configuration["hostnames"][0] : null
    redhat_minion     = length(var.redhat_configuration["hostnames"]) > 0 ? var.redhat_configuration["hostnames"][0] : null
    debian_minion     = length(var.debian_configuration["hostnames"]) > 0 ? var.debian_configuration["hostnames"][0] : null
    ssh_minion        = length(var.sshminion_configuration["hostnames"]) > 0 ? var.sshminion_configuration["hostnames"][0] : null
    pxeboot_mac       = var.pxeboot_configuration["private_mac"]
    kvm_host          = length(var.kvmhost_configuration["hostnames"]) > 0 ? var.kvmhost_configuration["hostnames"][0] : null
    monitoring_server = length(var.monitoringserver_configuration["hostnames"]) > 0 ? var.monitoringserver_configuration["hostnames"][0] : null

    git_profiles_repo         = var.git_profiles_repo == "default" ? "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles" : var.git_profiles_repo
    no_auth_registry          = var.no_auth_registry
    auth_registry             = var.auth_registry
    auth_registry_username    = var.auth_registry_username
    auth_registry_password    = var.auth_registry_password
    server_http_proxy         = var.server_http_proxy
    custom_download_endpoint  = var.custom_download_endpoint
    pxeboot_image             = var.pxeboot_configuration["image"]
    is_using_paygo_server     = var.is_using_paygo_server
    is_using_build_image      = var.is_using_build_image
    is_using_scc_repositories = var.is_using_scc_repositories
    server_instance_id        = var.server_instance_id
    product_version           = local.product_version
    container_runtime         = lookup(var.server_configuration, "runtime", "")
    catch_timeout_message     = var.catch_timeout_message
    beta_enabled              = var.beta_enabled
    web_server_hostname       = var.web_server_hostname

    # UPDATED: Direct access to 'hostname' for minions
    sle12sp5_paygo_minion       = var.sle12sp5_paygo_minion_configuration["hostname"]
    sle15sp5_paygo_minion       = var.sle15sp5_paygo_minion_configuration["hostname"]
    sle15sp6_paygo_minion       = var.sle15sp6_paygo_minion_configuration["hostname"]
    sleforsap15sp5_paygo_minion = var.sleforsap15sp5_paygo_minion_configuration["hostname"]
    sle12sp5_minion             = var.sle12sp5_minion_configuration["hostname"]
    sle12sp5_sshminion          = var.sle12sp5_sshminion_configuration["hostname"]
    sle12sp5_client             = var.sle12sp5_client_configuration["hostname"]
    sle15sp3_minion             = var.sle15sp3_minion_configuration["hostname"]
    sle15sp3_sshminion          = var.sle15sp3_sshminion_configuration["hostname"]
    sle15sp3_client             = var.sle15sp3_client_configuration["hostname"]
    sle15sp4_client             = var.sle15sp4_client_configuration["hostname"]
    sle15sp4_minion             = var.sle15sp4_minion_configuration["hostname"]
    sle15sp4_sshminion          = var.sle15sp4_sshminion_configuration["hostname"]
    sle15sp4_byos_minion        = var.sle15sp4_byos_minion_configuration["hostname"]
    sle15sp5_client             = var.sle15sp5_client_configuration["hostname"]
    sle15sp5_minion             = var.sle15sp5_minion_configuration["hostname"]
    sle15sp5_sshminion          = var.sle15sp5_sshminion_configuration["hostname"]
    sle15sp6_client             = var.sle15sp6_client_configuration["hostname"]
    sle15sp6_minion             = var.sle15sp6_minion_configuration["hostname"]
    sle15sp6_sshminion          = var.sle15sp6_sshminion_configuration["hostname"]
    sle15sp7_client             = var.sle15sp7_client_configuration["hostname"]
    sle15sp7_minion             = var.sle15sp7_minion_configuration["hostname"]
    sle15sp7_sshminion          = var.sle15sp7_sshminion_configuration["hostname"]
    slemicro51_minion           = var.slemicro51_minion_configuration["hostname"]
    slemicro51_sshminion        = var.slemicro51_sshminion_configuration["hostname"]
    slemicro52_minion           = var.slemicro52_minion_configuration["hostname"]
    slemicro52_sshminion        = var.slemicro52_sshminion_configuration["hostname"]
    slemicro53_minion           = var.slemicro53_minion_configuration["hostname"]
    slemicro53_sshminion        = var.slemicro53_sshminion_configuration["hostname"]
    slemicro54_minion           = var.slemicro54_minion_configuration["hostname"]
    slemicro54_sshminion        = var.slemicro54_sshminion_configuration["hostname"]
    slemicro55_minion           = var.slemicro55_minion_configuration["hostname"]
    slemicro55_sshminion        = var.slemicro55_sshminion_configuration["hostname"]
    slmicro60_minion            = var.slmicro60_minion_configuration["hostname"]
    slmicro60_sshminion         = var.slmicro60_sshminion_configuration["hostname"]
    slmicro61_minion            = var.slmicro61_minion_configuration["hostname"]
    slmicro61_sshminion         = var.slmicro61_sshminion_configuration["hostname"]
    centos7_minion              = var.centos7_minion_configuration["hostname"]
    centos7_sshminion           = var.centos7_sshminion_configuration["hostname"]
    centos7_client              = var.centos7_client_configuration["hostname"]
    alma8_minion                = var.alma8_minion_configuration["hostname"]
    alma8_sshminion             = var.alma8_sshminion_configuration["hostname"]
    alma9_minion                = var.alma9_minion_configuration["hostname"]
    alma9_sshminion             = var.alma9_sshminion_configuration["hostname"]
    liberty9_minion             = var.liberty9_minion_configuration["hostname"]
    liberty9_sshminion          = var.liberty9_sshminion_configuration["hostname"]
    openeuler2403_minion        = var.openeuler2403_minion_configuration["hostname"]
    openeuler2403_sshminion     = var.openeuler2403_sshminion_configuration["hostname"]
    oracle9_minion              = var.oracle9_minion_configuration["hostname"]
    oracle9_sshminion           = var.oracle9_sshminion_configuration["hostname"]
    rhel9_minion                = var.rhel9_minion_configuration["hostname"]
    rhel9_sshminion             = var.rhel9_sshminion_configuration["hostname"]
    rocky8_minion               = var.rocky8_minion_configuration["hostname"]
    rocky8_sshminion            = var.rocky8_sshminion_configuration["hostname"]
    rocky9_minion               = var.rocky9_minion_configuration["hostname"]
    rocky9_sshminion            = var.rocky9_sshminion_configuration["hostname"]
    amazon2023_minion           = var.amazon2023_minion_configuration["hostname"]
    amazon2023_sshminion        = var.amazon2023_sshminion_configuration["hostname"]
    ubuntu2004_minion           = var.ubuntu2004_minion_configuration["hostname"]
    ubuntu2004_sshminion        = var.ubuntu2004_sshminion_configuration["hostname"]
    ubuntu2204_minion           = var.ubuntu2204_minion_configuration["hostname"]
    ubuntu2204_sshminion        = var.ubuntu2204_sshminion_configuration["hostname"]
    ubuntu2404_minion           = var.ubuntu2404_minion_configuration["hostname"]
    ubuntu2404_sshminion        = var.ubuntu2404_sshminion_configuration["hostname"]
    debian12_minion             = var.debian12_minion_configuration["hostname"]
    debian12_sshminion          = var.debian12_sshminion_configuration["hostname"]
    sle15sp3_buildhost          = var.sle15sp3_buildhost_configuration["hostname"]
    sle15sp3_terminal_mac       = var.sle15sp3_terminal_configuration["private_mac"]
    sle15sp4_buildhost          = var.sle15sp4_buildhost_configuration["hostname"]
    sle15sp4_terminal_mac       = var.sle15sp4_terminal_configuration["private_mac"]
    sle15sp6_buildhost          = var.sle15sp6_buildhost_configuration["hostname"]
    sle15sp6_terminal_mac       = var.sle15sp6_terminal_configuration["private_mac"]
    sle15sp7_buildhost          = var.sle15sp7_buildhost_configuration["hostname"]
    sle15sp7_terminal_mac       = var.sle15sp7_terminal_configuration["private_mac"]
    opensuse155arm_minion       = var.opensuse155arm_minion_configuration["hostname"]
    opensuse155arm_sshminion    = var.opensuse155arm_sshminion_configuration["hostname"]
    opensuse156arm_minion       = var.opensuse156arm_minion_configuration["hostname"]
    opensuse156arm_sshminion    = var.opensuse156arm_sshminion_configuration["hostname"]
    sle15sp5s390_minion         = var.sle15sp5s390_minion_configuration["hostname"]
    sle15sp5s390_sshminion      = var.sle15sp5s390_sshminion_configuration["hostname"]
    salt_migration_minion       = var.salt_migration_minion_configuration["hostname"]
  }

  image   = "opensuse156o"
  provider_settings = var.provider_settings
}

output "configuration" {
  value = {
    id       = length(module.controller.configuration["ids"]) > 0 ? module.controller.configuration["ids"][0] : null
    hostname = length(module.controller.configuration["hostnames"]) > 0 ? module.controller.configuration["hostnames"][0] : null
    branch   = var.branch == "default" ? var.testsuite-branch[var.server_configuration["product_version"]] : var.branch
  }
}