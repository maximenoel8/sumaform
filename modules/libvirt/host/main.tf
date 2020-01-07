locals {
  resource_name_prefix = "${var.base_configuration["name_prefix"]}${var.name}"
  provider_settings = merge({
    memory          = 1024
    vcpu            = 1
    running         = true
    mac             = null
    additional_disk = []
    cpu_model       = "custom"
    xslt            = null
    },
    contains(var.roles, "suse_manager_server") ? { memory = 4096, vcpu = 2 } : {},
    contains(var.roles, "suse_manager_server") && lookup(var.base_configuration, "testsuite", false) ? { memory = 8192, vcpu = 4 } : {},
    contains(var.roles, "suse_manager_proxy") && lookup(var.base_configuration, "testsuite", false) ? { memory = 2048, vcpu = 2 } : {},
    contains(var.roles, "suse_manager_server") && lookup(var.grains, "pts", false) ? { memory = 16384, vcpu = 8 } : {},
    contains(var.roles, "pts_minion") ? { memory = 4096, vcpu = 2 } : {},
    contains(var.roles, "mirror") ? { memory = 512 } : {},
    contains(var.roles, "controller") ? { memory = 2048 } : {},
    contains(var.roles, "grafana") ? { memory = 4096 } : {},
    contains(var.roles, "virthost") ? { memory = 2048, vcpu = 3 } : {},
    var.provider_settings,
    contains(var.roles, "virthost") ? { cpu_model = "host-model", xslt = file("${path.module}/sysinfos.xsl") } : {},
    contains(var.roles, "pxe_boot") ? { xslt = file("${path.module}/pxe.xsl") } : {})
}

resource "libvirt_volume" "main_disk" {
  name             = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}-main-disk"
  base_volume_name = "${var.base_configuration["use_shared_resources"] ? "" : var.base_configuration["name_prefix"]}${var.image}"
  pool             = var.base_configuration["pool"]
  count            = var.quantity
}

resource "libvirt_domain" "domain" {
  name       = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  memory     = local.provider_settings["memory"]
  vcpu       = local.provider_settings["vcpu"]
  running    = local.provider_settings["running"]
  count      = var.quantity
  qemu_agent = true

  // copy host CPU model to guest to get the vmx flag if present
  cpu = {
    mode = local.provider_settings["cpu_model"]
  }

  // base disk + additional disks if any
  dynamic "disk" {
    for_each = concat(
      length(libvirt_volume.main_disk) == var.quantity ? [{"volume_id" : libvirt_volume.main_disk[count.index].id}] : [],
      local.provider_settings["additional_disk"],
    )
    content {
      volume_id = disk.value.volume_id
    }
  }

  dynamic "network_interface" {
    for_each = slice(
      [
        {
          "wait_for_lease" = true
          "network_name"   = var.base_configuration["network_name"]
          "network_id"     = null
          "bridge"         = var.base_configuration["bridge"]
          "mac"            = local.provider_settings["mac"]
        },
        {
          "wait_for_lease" = false
          "network_name"   = null
          "network_id"     = var.base_configuration["additional_network_id"]
          "bridge"         = null
          "mac"            = null
        },
      ],
      var.connect_to_base_network ? 0 : 1,
      var.base_configuration["additional_network"] != null && var.connect_to_additional_network ? 2 : 1,
    )
    content {
      wait_for_lease = network_interface.value.wait_for_lease
      network_id     = network_interface.value.network_id
      network_name   = network_interface.value.network_name
      bridge         = network_interface.value.bridge
      mac            = network_interface.value.mac
    }
  }

  console {
    type           = "pty"
    target_port    = "0"
    target_type    = "serial"
    source_host    = null
    source_service = null
  }

  console {
    type           = "pty"
    target_port    = "1"
    target_type    = "virtio"
    source_host    = null
    source_service = null
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  xml {
    xslt = local.provider_settings["xslt"]
  }
}

resource "null_resource" "provisioning" {
  depends_on = [libvirt_domain.domain]

  triggers = {
    main_volume_id = length(libvirt_volume.main_disk) == var.quantity ? libvirt_volume.main_disk[count.index].id : null
    domain_id      = length(libvirt_domain.domain) == var.quantity ? libvirt_domain.domain[count.index].id : null
    grains_subset = yamlencode(
      {
        domain                    = var.base_configuration["domain"]
        use_avahi                 = var.base_configuration["use_avahi"]
        timezone                  = var.base_configuration["timezone"]
        testsuite                 = var.base_configuration["testsuite"]
        roles                     = var.roles
        use_os_released_updates   = var.use_os_released_updates
        use_os_unreleased_updates = var.use_os_unreleased_updates
        additional_repos          = var.additional_repos
        additional_repos_only     = var.additional_repos_only
        additional_certs          = var.additional_certs
        additional_packages       = var.additional_packages
        swap_file_size            = var.swap_file_size
        authorized_keys           = var.ssh_key_path
        gpg_keys                  = var.gpg_keys
        ipv6                      = var.ipv6
    })
  }

  count = var.provision ? var.quantity : 0

  connection {
    host     = libvirt_domain.domain[count.index].network_interface[0].addresses[0]
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "salt"
    destination = "/root"
  }

  provisioner "file" {
    content = yamlencode(merge(
      {
        hostname                  = "${local.resource_name_prefix}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
        domain                    = var.base_configuration["domain"]
        use_avahi                 = var.base_configuration["use_avahi"]
        additional_network        = var.base_configuration["additional_network"]
        timezone                  = var.base_configuration["timezone"]
        testsuite                 = var.base_configuration["testsuite"]
        roles                     = var.roles
        use_os_released_updates   = var.use_os_released_updates
        use_os_unreleased_updates = var.use_os_unreleased_updates
        additional_repos          = var.additional_repos
        additional_repos_only     = var.additional_repos_only
        additional_certs          = var.additional_certs
        additional_packages       = var.additional_packages
        swap_file_size            = var.swap_file_size
        authorized_keys = concat(
          var.base_configuration["ssh_key_path"] != null ? [trimspace(file(var.base_configuration["ssh_key_path"]))] : [],
          var.ssh_key_path != null ? [trimspace(file(var.ssh_key_path))] : [],
        )
        gpg_keys                      = var.gpg_keys
        connect_to_base_network       = var.connect_to_base_network
        connect_to_additional_network = var.connect_to_additional_network
        reset_ids                     = true
        ipv6                          = var.ipv6
        data_disk_device              = contains(var.roles, "suse_manager_server") || contains(var.roles, "suse_manager_proxy") || contains(var.roles, "mirror") ? "vdb" : null
      },
    var.grains))
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /root/salt/first_deployment_highstate.sh",
    ]
  }
}

output "configuration" {
  depends_on = [libvirt_domain.domain, null_resource.provisioning]
  value = {
    ids       = libvirt_domain.domain[*].id
    hostnames = [for value_used in libvirt_domain.domain : "${value_used.name}.${var.base_configuration["domain"]}"]
    macaddrs  = [for value_used in libvirt_domain.domain : value_used.network_interface[0].mac if length(value_used.network_interface) > 0]
  }
}
