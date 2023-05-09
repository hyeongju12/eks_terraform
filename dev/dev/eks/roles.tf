data "terraform_remote_state" "cicd_info" {
    backend = "s3"

    config = {
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/cicd2/terraform.tfstate"
        region = "us-east-1"
        profile = "dev"
    }
}

resource "aws_iam_role" "EKSAccessCICD" {
    name = "EKSAccessCICD"
    assume_role_policy = jsonencode({
        Statement = [
        {
            Effect = "Allow"
            Action = "sts:AssumeRole"
            Principal = {
                Service = "eks.amazonaws.com"
            }
        }
        ]
    }) 
}

resource "aws_iam_policy" "EKSAccessCodeCommitPolicy" {
    name = "EKSAccessCodeCommitPolicy"
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
            },
        ]
    })
}

resource "aws_iam_policy" "EKSAccessECR" {
    name = "EKSAccessECR"
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
                "Resource": "${data.terraform_remote_state.cicd_info.outputs.hjyoo-ecr-arn2}"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "EKSAccessCodeCommitAttach" {
    role = aws_iam_role.EKSAccessCICD.name
    policy_arn = aws_iam_policy.EKSAccessCodeCommitPolicy.arn
}

resource "aws_iam_role_policy_attachment" "EKSAccessECRAttach" {
    role = aws_iam_role.EKSAccessCICD.name
    policy_arn = aws_iam_policy.EKSAccessECR.arn
}