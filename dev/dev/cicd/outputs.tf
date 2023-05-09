output "web-demo-clone-http-url2" {
    value = aws_codecommit_repository.web-demo-2.clone_url_http
    description = "web-demo http clone url"
}

output "web-demo-clone-ssh-url2" {
    value = aws_codecommit_repository.web-demo-2.clone_url_ssh
    description = "web-demo ssh clone url"
}

output "web-demo-repo-id2" {
    value = aws_codecommit_repository.web-demo-2.repository_id
    description = "web-demo repo id"
}

output "web-demo-repo-arn2" {
    value = aws_codecommit_repository.web-demo-2.arn
    description = "web-demo repo arn"
}

output "hjyoo-ecr-arn2" {
    value = aws_ecr_repository.hjyoo-ecr-2.arn
}

output "hjyoo-ecr-repo-id2" {
    value = aws_ecr_repository.hjyoo-ecr-2.registry_id
}

output "hjyoo-ecr-repo-url2" {
    value = aws_ecr_repository.hjyoo-ecr-2.repository_url
}

output "hjyoo-repo-key-id" {
    value = aws_iam_service_specific_credential.http-repo-key.service_specific_credential_id
}

output "hjyoo-repo-username" {
    value = aws_iam_service_specific_credential.http-repo-key.service_user_name
}

output "hjyoo-repo-key-password" {
    value = nonsensitive(aws_iam_service_specific_credential.http-repo-key.service_password)
}

output "code-s3" {
    value = aws_s3_bucket.codepipeline_bucket.arn
}