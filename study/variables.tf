variable "user_name" {
    description = "Create IAM users with these name"
    type = list(string)
    default = ["james", "joe", "mark"]
}

variable "custom_tags" {
    description = "for_each test"
    type = map(string)
    default = {
        Owner = "hjyoo"
        DeployedBy = "terraform"
    }
}

variable "hjyoo" {
    description = "map"
    type = map(string)
    default = {
        name = "hyjoo"
        age = "32"
        height = "172"
    }
}