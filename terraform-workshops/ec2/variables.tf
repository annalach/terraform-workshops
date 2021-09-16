variable "instance_name" {
  description = "Value of the Name tag for the EC instance"
  type        = string
  default     = "TerraformWorkshops"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 5000
}
