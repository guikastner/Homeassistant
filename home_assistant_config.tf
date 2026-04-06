resource "null_resource" "home_assistant_generated_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.home_assistant_generated_dir}"
  }
}

resource "null_resource" "home_assistant_data_files" {
  provisioner "local-exec" {
    command = <<-EOT
      bash -lc 'set -eu
      mkdir -p "${local.home_assistant_data_dir}/themes"
      [ -f "${local.home_assistant_data_dir}/automations.yaml" ] || : > "${local.home_assistant_data_dir}/automations.yaml"
      [ -f "${local.home_assistant_data_dir}/scripts.yaml" ] || : > "${local.home_assistant_data_dir}/scripts.yaml"
      [ -f "${local.home_assistant_data_dir}/scenes.yaml" ] || : > "${local.home_assistant_data_dir}/scenes.yaml"'
    EOT
  }

  depends_on = [null_resource.home_assistant_data_dir]
}

resource "local_file" "home_assistant_configuration" {
  filename        = local.home_assistant_config_path
  file_permission = "0640"
  content = templatefile(
    "${path.module}/templates/home-assistant-configuration.yaml.tmpl",
    {
      trusted_proxies = var.home_assistant_trusted_proxies
    }
  )

  depends_on = [null_resource.home_assistant_generated_dir]
}
