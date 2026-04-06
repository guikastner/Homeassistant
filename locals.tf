locals {
  network_name               = var.network_name
  home_assistant_name        = "${var.name_prefix}${var.home_assistant_name}"
  node_red_name              = "${var.name_prefix}${var.node_red_name}"
  home_assistant_public_host = var.home_assistant_hostname != "" ? var.home_assistant_hostname : local.home_assistant_name
  node_red_public_host       = var.node_red_hostname != "" ? var.node_red_hostname : local.node_red_name

  home_assistant_instance = {
    name     = local.home_assistant_name
    hostname = var.base_domain != "" ? "${local.home_assistant_public_host}.${var.base_domain}" : local.home_assistant_public_host
  }

  node_red_instance = {
    name     = local.node_red_name
    hostname = var.base_domain != "" ? "${local.node_red_public_host}.${var.base_domain}" : local.node_red_public_host
  }

  data_root               = "/DATA/AppData"
  home_assistant_data_dir = abspath("${local.data_root}/${local.home_assistant_name}")
  node_red_data_dir       = abspath("${local.data_root}/${local.node_red_name}")

  home_assistant_generated_dir      = abspath("${path.module}/build/home-assistant")
  home_assistant_config_path        = abspath("${local.home_assistant_generated_dir}/configuration.yaml")
  node_red_generated_dir            = abspath("${path.module}/build/node-red")
  node_red_settings_path            = abspath("${local.node_red_generated_dir}/settings.js")
  node_red_admin_password_hash_path = abspath("${local.node_red_generated_dir}/admin-password.hash")

  cloudflare_generated_dir    = abspath("${path.module}/build/cloudflare")
  cloudflare_config_path      = abspath("${local.cloudflare_generated_dir}/config.yml")
  cloudflare_credentials_path = abspath("${local.cloudflare_generated_dir}/cloudflared-credentials.json")
}
