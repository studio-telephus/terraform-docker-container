locals {
  files = flatten(tolist([for d in var.mount_dirs : [for f in fileset(d, "**") : {
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

  dynamic "networks_advanced" {
    for_each = var.networks
    content {
      name         = networks_advanced.name
      ipv4_address = networks_advanced.ipv4_address
    }
  }
  dynamic "upload" {
    for_each = local.files
    content {
      source = upload.source
      file   = upload.target
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
