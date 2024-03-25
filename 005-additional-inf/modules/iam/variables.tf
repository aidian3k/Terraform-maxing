variable "user_name" {
  type = string
  description = "The name of the created ami_user"
  default = "ami_user"
}

variable "names" {
    type = list(string)
    description = "The names of the created instances"
    default = ["ami_instance", "adrian", "daniel", "jose", "joseph", "joshua", "kevin", "michael", "robert", "william"]
}