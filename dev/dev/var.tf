variable "key_path" {
    default = "./bastion-key.pub"
    description = "bastion key path"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "./bastion-key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "./bastion-key.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "profile_name" {
    description = "aws configure profile name"
}

variable "access_key" {
    description = "aws configure access key"
}

variable "secret_key" {
    description = "aws configure secret key"
}

variable "region" {
    description = "aws configure region"
}

variable "output" {
    description = "aws configure output type"
}
