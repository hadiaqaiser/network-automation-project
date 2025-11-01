variable "project_name" {
  default = "nsadmin-ca"
}

variable "aws_region" {
  default = "eu-west-1" # Ireland region
}

variable "instance_type" {
  default = "t4g.micro" # ARM free tier
}

variable "public_key_path" {
  default = "~/.ssh/aws-edu-key.pub"
}