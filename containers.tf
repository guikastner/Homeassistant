resource "docker_container" "home_assistant" {
  name         = local.home_assistant_instance.name
  image        = docker_image.home_assistant.image_id
  restart      = "unless-stopped"
  hostname     = local.home_assistant_instance.name
  network_mode = "host"

  env = [
    "TZ=${var.timezone}"
  ]

  mounts {
    target = "/config"
    source = local.home_assistant_data_dir
    type   = "bind"
  }

  mounts {
    target    = "/config/configuration.yaml"
    source    = local.home_assistant_config_path
    type      = "bind"
    read_only = true
  }

  capabilities {
    add = var.home_assistant_capabilities_add
  }

  depends_on = [
    local_file.home_assistant_configuration,
    null_resource.home_assistant_data_dir,
    null_resource.home_assistant_data_files,
  ]
}

resource "docker_container" "node_red" {
  name     = local.node_red_instance.name
  image    = docker_image.node_red.image_id
  restart  = "unless-stopped"
  hostname = local.node_red_instance.name

  env = [
    "TZ=${var.timezone}"
  ]

  mounts {
    target = "/data"
    source = local.node_red_data_dir
    type   = "bind"
  }

  mounts {
    target    = "/data/settings.js"
    source    = local.node_red_settings_path
    type      = "bind"
    read_only = true
  }

  networks_advanced {
    name    = local.network_name
    aliases = [local.node_red_instance.name]
  }

  # Keep internal service communication on main network and allow outbound internet via default bridge.
  networks_advanced {
    name = "bridge"
  }

  depends_on = [
    null_resource.main_network,
    local_file.node_red_settings,
    null_resource.node_red_data_dirs,
    null_resource.node_red_modules,
  ]
}
