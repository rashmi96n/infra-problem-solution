#add aws access key
variable "aws_access_key" {
   type = string
   default = ""
}

#add secret  key
variable "aws_secret_key" {
   type = string
   default = ""
}


#modify the region to your config
variable "region" {
  type = string
  default = "eu-west-1"
}


variable "private_key_path" {
  description = <<DESCRIPTION
Path to the SSH private key to be used for authentication in connection block
Please add your private key path or private key = .pem file
DESCRIPTION
type = string
default = ""
}


#modify the key name to your config
variable "key_name" {
  description = "Desired name of AWS key pair"
  type = string
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

