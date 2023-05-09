data "terraform_remote_state" "network-config" {
    backend = "s3"

    config = {
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/vpc/terraform.tfstate"
        region = "us-east-1"
        profile = "dev"
    }
}

data "terraform_remote_state" "eks-config" {
    backend = "s3"
    config = {
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key= "dev/eks/terraform.tfstate"
        region = "us-east-1"
        profile = "dev"
    }
}
resource "aws_s3_bucket" "cicd-bucket-hjyoo2" {
    bucket = "cicd-bucket-hjyoo2"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "cicd-bucket-versioning" {
    bucket = aws_s3_bucket.cicd-bucket-hjyoo2.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cicd-bucket-encryption" {
    bucket = aws_s3_bucket.cicd-bucket-hjyoo2.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }   
    }   
}

resource "aws_security_group" "codebuild-sg" {
    name = "codebuid-sg"
    vpc_id = data.terraform_remote_state.network-config.outputs.dev-vpc-id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_codebuild_project" "web-demo-2" {
    name = "web-demo-2"
    description = "To test codebuild project"
    service_role = aws_iam_role.AdminAwsCodeBuild2.arn
    artifacts {
        type = "NO_ARTIFACTS"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/standard:3.0"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode = true

        environment_variable {
            name  = "APP_NAME"
            value = "${var.APP_NAME}"
        }

        environment_variable {
            name = "AWS_ACCOUINT_ID"
            value = "${aws_ecr_repository.hjyoo-ecr-2.registry_id}"
        }

        environment_variable {
            name = "AWS_REGION"
            value = "${var.AWS_REGION}"
        }

        environment_variable {
            name = "AWS_ECR_REPO"
            value = "${aws_ecr_repository.hjyoo-ecr-2.name}"
        }

        environment_variable {
            name = "AWS_CLUSTER_NAME"
            value = "${data.terraform_remote_state.eks-config.outputs.cluster_name}"
        }

        environment_variable {
            name = "NAMESPACE"
            value = "${var.NAMESPACE}"
        }

        environment_variable {
            name = "SERVICE_NAME"
            value = "${var.SERVICE_NAME}"
        }
    }
    
    logs_config {
        cloudwatch_logs {
        group_name  = "log-group"
        stream_name = "log-stream"
        }   
    }

    source {
        type            = "CODECOMMIT"
        location        = "${aws_codecommit_repository.web-demo-2.clone_url_http}"
        git_submodules_config {
        fetch_submodules = true
        }

        buildspec = templatefile("${path.module}/web-demo/web-demo-buildspec.yml", {
            AWS_REGION = var.AWS_REGION
            AWS_ACCESS_KEY = var.aws_access_key
            AWS_SECRET_KEY = var.aws_secret_key
            APP_NAME = var.APP_NAME
            SERVICE_NAME = var.SERVICE_NAME
            NAMESPACE = var.NAMESPACE
            EKS_CLUSTER_NAME = data.terraform_remote_state.eks-config.outputs.cluster_name
            ECR_NAME = aws_ecr_repository.hjyoo-ecr-2.name
            AWS_ACCOUNT_ID = aws_ecr_repository.hjyoo-ecr-2.registry_id
        })
#         buildspec = <<BUILDSPEC
# version: 0.2
# env:
#     git-credential-helper: yes
# phases:
#     install:
#         # runtime-versions:
#         #   runtime: correto11
#         commands:
#         - echo install kubectl
#         - curl -LO "https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl"
#         - chmod +x ./kubectl
#         - mv ./kubectl /usr/local/bin/kubectl
#     pre_build:
#         commands:
#         - aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${aws_ecr_repository.hjyoo-ecr-2.registry_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com
#         - git clone "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/web-demo-repo-2"
#     build:
#         commands:
#         - docker build -t ${aws_ecr_repository.hjyoo-ecr-2.registry_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/hjyoo-ecr-2:${var.APP_NAME}-v$CODEBUILD_BUILD_NUMBER .
#         - docker push ${aws_ecr_repository.hjyoo-ecr-2.registry_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/hjyoo-ecr-2:${var.APP_NAME}-v$CODEBUILD_BUILD_NUMBER
#     post_build:
#         commands:
#         - |
#             mkdir -p ~/.aws
#             cat <<EOF > ~/.aws/config
#             [default]
#             region = ${var.AWS_REGION}
#             [profile dev]
#             source_profile = default
#             EOF
#         - cat ~/.aws/config
#         - |
#             cat <<EOF > ~/.aws/credentials
#             [default]
#             aws_access_key_id = ${var.aws_access_key}
#             aws_secret_access_key = ${var.aws_secret_key}
#             EOF
#         - aws eks update-kubeconfig --name ${data.terraform_remote_state.eks-config.outputs.cluster_name} --region ${var.AWS_REGION}
#         - |
#             cat <<EOF > nginx-demo.yaml
#             apiVersion: apps/v1
#             kind: Deployment
#             metadata:
#               name: ${var.APP_NAME}
#               namespace: ${var.NAMESPACE}
#             spec:
#               replicas: 1
#               selector:
#                 matchLabels:
#                   app: ${var.APP_NAME}
#               template:
#                 metadata:
#                   labels:
#                     app: ${var.APP_NAME}
#                 spec:
#                   containers:
#                   - name: ${var.APP_NAME}
#                     image: ${aws_ecr_repository.hjyoo-ecr-2.registry_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/hjyoo-ecr-2:${var.APP_NAME}-v$CODEBUILD_BUILD_NUMBER
#                     ports:
#                     - containerPort: 8080
#                     resources:
#                       limits:
#                         memory: "256Mi"
#                         cpu: "1"
#                       requests:
#                         memory: "128Mi"
#                         cpu: "100m"
#             ---
#             apiVersion: v1
#             kind: Service
#             metadata:
#               name: ${var.SERVICE_NAME}
#               namespace: ${var.NAMESPACE}
#             spec:
#               selector:
#                 app: ${var.APP_NAME}
#               ports:
#               - port: 80
#                 targetPort: 80
#             ---
#             apiVersion: networking.k8s.io/v1
#             kind: Ingress
#             metadata:
#               name: ${var.APP_NAME}-ingress
#               namespace: ${var.NAMESPACE}
#               annotations:
#                 kubernetes.io/ingress.class: nginx
#               labels:
#                 app: ${var.APP_NAME}
#             spec:
#                 rules:
#                 - http:
#                     paths:
#                     - pathType: Prefix
#                       path: "/"
#                       backend:
#                         service: 
#                           name: ${var.SERVICE_NAME}
#                           port: 
#                             number: 80
#             EOF
#         - cat nginx-demo.yaml
#         - kubectl apply -f nginx-demo.yaml
#         BUILDSPEC
    }

    vpc_config {
        vpc_id = data.terraform_remote_state.network-config.outputs.dev-vpc-id

        subnets = [
        data.terraform_remote_state.network-config.outputs.dev-subnet-1d-private-id,
        data.terraform_remote_state.network-config.outputs.dev-subnet-1f-private-id,
        ]

        security_group_ids = [
            aws_security_group.codebuild-sg.id
        ]
    }

    tags = {
        Environment = "web-demo-2"
    }
}