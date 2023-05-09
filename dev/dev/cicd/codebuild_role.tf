data "terraform_remote_state" "subnet_info" {
    backend = "s3"

    config = {
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/vpc/terraform.tfstate"
        region = "us-east-1"
        profile = "dev"
    }
}

data "aws_iam_user" "cloud_user" {
    user_name = "cloud_user"
}

resource "aws_iam_role" "AdminAwsCodeBuild2" {
    name = "AdminAwsCodeBuild2"
    assume_role_policy = jsonencode({
        Statement = [
        {
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Principal = {
                Service = "codebuild.amazonaws.com"
                AWS = "${data.aws_iam_user.cloud_user.arn}"
            }
        },
        {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "codepipeline.amazonaws.com"
                    AWS = "${data.aws_iam_user.cloud_user.arn}"
                }
        }
        ]
    }) 
}


resource "aws_iam_role_policy_attachment" "CodebuildNetworkInterfaceAttach2" {
    role = aws_iam_role.AdminAwsCodeBuild2.name
    policy_arn = aws_iam_policy.CodebuildControlNetworkInterface2.arn
}

resource "aws_iam_role_policy_attachment" "CodebuildECRAttach2" {
    role = aws_iam_role.AdminAwsCodeBuild2.name
    policy_arn = aws_iam_policy.CodebuildECR2.arn
}

resource "aws_iam_role_policy_attachment" "CodebuildEKSAttach2" {
    role = aws_iam_role.AdminAwsCodeBuild2.name
    policy_arn = aws_iam_policy.CodeBuildDeployEKS2.arn
}

resource "aws_iam_role_policy_attachment" "CodebuildReportAttach2" {
    role = aws_iam_role.AdminAwsCodeBuild2.name
    policy_arn = aws_iam_policy.CodeBuildCreateReport2.arn
}

resource "aws_iam_role_policy_attachment" "CodeBuildCloudWatchAttach2" {
    role = aws_iam_role.AdminAwsCodeBuild2.name
    policy_arn = aws_iam_policy.CodeBuildCloudWatch2.arn
}

resource "aws_iam_role_policy_attachment" "CodeBuildCodeCommitAttach2" {
    role = aws_iam_role.AdminAwsCodeBuild2.name
    policy_arn = aws_iam_policy.CodebuildCodeCommit2.arn
}

resource "aws_iam_policy" "CodebuildControlNetworkInterface2" {
    name = "CodebuildControlNetworkInterface2"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterface",
                    "ec2:DescribeDhcpOptions",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DeleteNetworkInterface",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeVpcs"
                ],
                "Resource": "*"
                },
                {
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterfacePermission"
                ],
                "Resource": "arn:aws:ec2:us-east-1:${aws_ecr_repository.hjyoo-ecr-2.registry_id}:network-interface/*",
                "Condition": {
                    "StringEquals": {
                    "ec2:AuthorizedService": "codebuild.amazonaws.com"
                    },
                    "ArnEquals": {
                    "ec2:Subnet": [
                        data.terraform_remote_state.subnet_info.outputs.dev-subnet-1d-private-arn,
                        data.terraform_remote_state.subnet_info.outputs.dev-subnet-1f-private-arn
                    ]
                    }
                }
            },
        ]
    })
}

resource "aws_iam_policy" "CodebuildCodeCommit2" {
    name = "CodebuildCodeCommit2"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            "Action": [
                "codebuild:*",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GitPull",
                "codecommit:GitPush",
                "codecommit:ListBranches",
                "codecommit:ListRepositories",
                "codecommit:UploadArchive",
                "codecommit:DownloadArchive",
                "codecommit:GetUploadArchiveStatus",
                "cloudwatch:GetMetricStatistics",
                "ec2:DescribeVpcs",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "elasticfilesystem:DescribeFileSystems",
                "events:DeleteRule",
                "events:DescribeRule",
                "events:DisableRule",
                "events:EnableRule",
                "events:ListTargetsByRule",
                "events:ListRuleNamesByTarget",
                "events:PutRule",
                "events:PutTargets",
                "events:RemoveTargets",
                "logs:GetLogEvents",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Effect": "Allow",
            "Resource": "*"
            },
            {
            "Action": [
                "logs:DeleteLogGroup"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:log-group:/aws/codebuild/*:log-stream:*"
            },
            {
            "Effect":"Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:PutObjectAcl",
                "s3:PutObject"
            ],
            "Resource": "${aws_s3_bucket.codepipeline_bucket.arn}/*"
            },            
            {
            "Effect": "Allow",
            "Action": [
                "ssm:PutParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/CodeBuild/*"
            },
            {
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession"
            ],
            "Resource": "arn:aws:ecs:*:*:task/*/*"
            }
        ]
    })
}

resource "aws_iam_policy" "CodebuildECR2" {
    name = "CodebuildECR2"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:GetAuthorizationToken"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "ecr:PutImage",
                    "ecr:InitiateLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:CompleteLayerUpload"
                ],
                "Resource": "${aws_ecr_repository.hjyoo-ecr-2.arn}"
            }
        ]
    })
}

resource "aws_iam_policy" "CodeBuildDeployEKS2" {
    name = "CodeBuildDeployEKS2"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": "eks:DescribeCluster",
                "Resource": "*"
            }
        ]
    })
}

resource "aws_iam_policy" "CodeBuildCreateReport2" {
    name = "CodeBuildCreateReport2"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            "Effect": "Allow",
            "Action": "codebuild:CreateReportGroup",
            "Resource": "${aws_codebuild_project.web-demo-2.arn}"
            }
        ]
    })
}

resource "aws_iam_policy" "CodeBuildCloudWatch2" {
    name = "CodeBuildCloudWatch2"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
                {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "logs:DescribeLogStreams"
                ],
                "Resource": [
                    "arn:aws:logs:*:*:*"
                ]
            }
        ]
    })
}