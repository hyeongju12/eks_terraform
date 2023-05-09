resource "aws_ecr_repository" "hjyoo-ecr-2" {
    name                 = "hjyoo-ecr-2"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
}