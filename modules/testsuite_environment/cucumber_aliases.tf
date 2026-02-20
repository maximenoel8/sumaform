# Copyright (c) 2026 SUSE LLC
# Licensed under the terms of the MIT license.
#
# cucumber_aliases.tf
#
# This file is intentionally separate from main.tf so it can be cleanly
# deleted when the testsuite is refactored to no longer need generic role
# aliases (MINION, SSH_MINION, etc.) alongside versioned ones.
#
# It contains:
#   1. Alias locals that resolve generic role hostnames from versioned modules
#
# The corresponding controller grain wiring lives at the bottom of this file
# as inline comments showing what was added to module "controller" in main.tf.

# =============================================================================
# ALIAS LOCALS
# Resolves a hostname from whatever versioned module the alias points to.
# Returns null when no alias is declared — BV deployments are unaffected.
# =============================================================================

locals {
  _alias_suse_minion_hostname = (
    var.cucumber_aliases.suse_minion != null &&
    length(module[var.cucumber_aliases.suse_minion]) > 0
  ) ? module[var.cucumber_aliases.suse_minion][0].configuration.hostnames[0] : null

  _alias_suse_sshminion_hostname = (
    var.cucumber_aliases.suse_sshminion != null &&
    length(module[var.cucumber_aliases.suse_sshminion]) > 0
  ) ? module[var.cucumber_aliases.suse_sshminion][0].configuration.hostnames[0] : null

  _alias_suse_client_hostname = (
    var.cucumber_aliases.suse_client != null &&
    length(module[var.cucumber_aliases.suse_client]) > 0
  ) ? module[var.cucumber_aliases.suse_client][0].configuration.hostnames[0] : null

  _alias_rhlike_minion_hostname = (
    var.cucumber_aliases.rhlike_minion != null &&
    length(module[var.cucumber_aliases.rhlike_minion]) > 0
  ) ? module[var.cucumber_aliases.rhlike_minion][0].configuration.hostnames[0] : null

  _alias_deblike_minion_hostname = (
    var.cucumber_aliases.deblike_minion != null &&
    length(module[var.cucumber_aliases.deblike_minion]) > 0
  ) ? module[var.cucumber_aliases.deblike_minion][0].configuration.hostnames[0] : null

  _alias_build_host_hostname = (
    var.cucumber_aliases.build_host != null &&
    length(module[var.cucumber_aliases.build_host]) > 0
  ) ? module[var.cucumber_aliases.build_host][0].configuration.hostnames[0] : null

  _alias_kvm_host_hostname = (
    var.cucumber_aliases.kvm_host != null &&
    length(module[var.cucumber_aliases.kvm_host]) > 0
  ) ? module[var.cucumber_aliases.kvm_host][0].configuration.hostnames[0] : null

  # Maps cucumber_aliases values (versioned module key) to the corresponding
  # grain name used in bashrc. null means the image has no versioned BV grain.
  _alias_grain_map = {
    "sles15sp4_minion"     = "sle15sp4_minion"
    "sles15sp5_minion"     = "sle15sp5_minion"
    "sles15sp6_minion"     = "sle15sp6_minion"
    "sles15sp7_minion"     = "sle15sp7_minion"
    "tumbleweed_minion"    = null
    "rocky8_minion"        = "rocky8_minion"
    "rocky9_minion"        = "rocky9_minion"
    "sles15sp4_sshminion"  = "sle15sp4_sshminion"
    "sles15sp5_sshminion"  = "sle15sp5_sshminion"
    "sles15sp6_sshminion"  = "sle15sp6_sshminion"
    "sles15sp7_sshminion"  = "sle15sp7_sshminion"
    "tumbleweed_sshminion" = null
    "rocky8_sshminion"     = "rocky8_sshminion"
    "rocky9_sshminion"     = "rocky9_sshminion"
    "sles15sp4_client"     = "sle15sp4_client"
    "sles15sp6_client"     = "sle15sp6_client"
    "sles15sp7_client"     = "sle15sp7_client"
    "ubuntu2204_minion"    = "ubuntu2204_minion"
    "ubuntu2404_minion"    = "ubuntu2404_minion"
    "sles15sp6_buildhost"  = "sle15sp6_buildhost"
    "sles15sp7_buildhost"  = "sle15sp7_buildhost"
    "sles15sp6_kvmhost"    = null
    "sles15sp7_kvmhost"    = null
  }
}
