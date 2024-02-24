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

variable "entrypoint" {
  type    = list(string)
  default = null
}

variable "command" {
  type    = list(string)
  default = null
}

variable "hostname" {
  type    = string
  default = null
}

variable "networks_advanced" {
  description = "Docker networks to join."
  type = list(object({
    aliases      = optional(set(string))
    name         = string
    ipv4_address = optional(string)
  }))
}

variable "mounts" {
  type = list(object({
    target = string
    type   = string
    source = optional(string)
    bind_options = optional(object({
      propagation = string
    }))
  }))
  description = "Mounts to be added to containers created as part of the service."
  default     = []
}

variable "volumes" {
  type = list(object({
    container_path = optional(string)
    from_container = optional(string)
    host_path      = optional(string)
    read_only      = optional(bool, false)
    volume_name    = optional(string)
  }))
  description = "Spec for mounting volumes in the container."
  default     = []
}

variable "restart" {
  type        = string
  description = "The restart policy for the container."
  validation {
    condition     = contains(["no", "on-failure", "always", "unless-stopped"], var.restart)
    error_message = "Validation error."
  }
  default = "unless-stopped"
}

variable "upload_dirs" {
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

