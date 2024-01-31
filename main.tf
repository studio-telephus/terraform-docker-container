locals {
  upload_files = flatten(tolist([for d in var.upload_dirs : [for f in fileset(d, "**") : {
    source = "${d}/${f}"
    target = "/${f}"
    }
    if !endswith(f, ".git") && !endswith(f, ".DS_Store")
  ]]))
  envmap      = merge({}, { for key, value in var.environment : key => value })
  environment = [for key, value in local.envmap : "${key}=${value}"]
}

resource "docker_container" "docker_container_instance" {
  name       = var.name
  image      = var.image
  env        = local.environment
  tty        = var.tty
  privileged = var.privileged
  restart    = var.restart
  entrypoint = var.entrypoint
  command    = var.command

  dynamic "networks_advanced" {
    for_each = var.networks_advanced
    content {
      aliases      = networks_advanced.value.aliases
      name         = networks_advanced.value.name
      ipv4_address = networks_advanced.value.ipv4_address
    }
  }
  dynamic "upload" {
    for_each = local.upload_files
    content {
      source = upload.value.source
      file   = upload.value.target
    }
  }

  dynamic "mounts" {
    for_each = var.mounts
    content {
      target = mounts.value.target
      source = mounts.value.source
      type   = mounts.value.type
      dynamic "bind_options" {
        for_each = mounts.value.bind_options == null ? [] : [1]
        content {
          propagation = mounts.value.bind_options.propagation
        }
      }
    }
  }

  dynamic "volumes" {
    for_each = var.volumes
    content {
      container_path = volumes.value.container_path
      from_container = volumes.value.from_container
      host_path      = volumes.value.host_path
      read_only      = volumes.value.read_only
      volume_name    = volumes.value.volume_name
    }
  }
}

resource "terraform_data" "local_exec_condition" {
  count = var.exec_enabled ? 1 : 0
  provisioner "local-exec" {
    when        = create
    command     = <<-EXEC
      docker exec ${var.name} /bin/bash -xe -c 'chmod +x ${var.exec} && ${var.exec}'
    EXEC
    interpreter = var.local_exec_interpreter
  }
  depends_on = [docker_container.docker_container_instance]
}
