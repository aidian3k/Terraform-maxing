variable "name" {
  description = "Default name used by all resources"
  type        = string
  default     = "this"
}

variable "port" {
  description = "The port the server will listen on"
  type        = number
  default     = 8080
}

variable "replicas" {
  description = "The number of replicas to run"
  type        = number
  default     = 1
}

variable "image_name" {
  description = "The name of the image to run"
  type        = string
  default     = "nginx"
}

variable "environment_variables" {
  type = map(string)
  description = "Environment variables used in application"
  default = {}
}