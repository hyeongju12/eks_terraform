resource "aws_codecommit_repository" "web-demo-2" {
    repository_name = "web-demo-repo-2"
    description = "web-demo-repo-2"
    default_branch = "main"
    tags = {
        "Name" = "web-demo-repo-2"
    }
}

resource "aws_iam_service_specific_credential" "http-repo-key" {
    service_name = "codecommit.amazonaws.com"
    user_name = "cloud_user"
}