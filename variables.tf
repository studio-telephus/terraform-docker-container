variable "name" {
  type = string
}

variable "image" {
  type = string
}

variable "tty" {
  type    = bool
  default = true
}

variable "privileged" {
  type    = bool
  default = false
}

variable "networks" {
  description = "Docker networks to join."
  type = list(object({
    name         = string
    ipv4_address = string
  }))
}

variable "volumes" {
  type = list(object({
    container_path = string
    from_container = string
    host_path      = string
    read_only      = bool
    volume_name    = string
  }))
  description = "Spec for mounting volumes in the container."
  default     = []
}

variable "restart" {
  type        = string
  description = "The restart policy for the container."
  validation {
    condition = contains(["no", "on-failure", "always", "unless-stopped"], var.restart)
  }
  default = "unless-stopped"
}

variable "mount_dirs" {
  type    = list(string)
  default = []
}

variable "exec_enabled" {
  type    = bool
  default = false
}

variable "exec" {
  type    = string
  default = null
}

variable "environment" {
  type    = map(any)
  default = {}
}

variable "local_exec_interpreter" {
  type    = list(string)
  default = ["/bin/bash", "-c"]
}

