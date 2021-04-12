variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
copy from the create_keygen.sh
DESCRIPTION
type = "string"
default = "/tmp/ssh_util//keypair.key.pub"
}


#modify the key name to your config
variable "key_name" {
  description = "Desired name of AWS key pair"
  type = "string"
  default = "rashmi"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

# Ubuntu Xenial 20.04 LTS (x64). Modify the ami fields to match your config
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-08bac620dc84221eb"
    eu-west-2 = "ami-096cb92bb3580c759"
  }
  description = "I have added four regions: Ireland, London. You can use as many regions as you want."
}


variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}

