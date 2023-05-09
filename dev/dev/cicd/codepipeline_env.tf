resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-commont-bucket-hjyoo"
}

resource "aws_iam_role" "AwsCodePipelineRole" {
    name = "AwsCodePipelineRole"
    assume_role_policy = jsonencode({
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "codepipeline.amazonaws.com"
                }
            }
        ]
    }) 
}

resource "aws_iam_policy" "CodePipelinePolicy" {
    name = "CodePipelinePolicy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
      "Effect":"Allow",
      "Action": [
        "s3:GetBucketVersioning"
      ],
      "Resource": "${aws_s3_bucket.codepipeline_bucket.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
         "kms:DescribeKey",
         "kms:GenerateDataKey*",
         "kms:Encrypt",
         "kms:ReEncrypt*",
         "kms:Decrypt"
      ],
      "Resource": "${aws_s3_bucket.codepipeline_bucket.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
         "codecommit:GitPull",
         "codecommit:GitPush",
         "codecommit:GetBranch",
         "codecommit:CreateCommit",
         "codecommit:ListRepositories",
         "codecommit:BatchGetCommits",
         "codecommit:BatchGetRepositories",
         "codecommit:GetCommit",
         "codecommit:GetRepository",
         "codecommit:GetUploadArchiveStatus",
         "codecommit:ListBranches",
         "codecommit:UploadArchive"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:BatchGetProjects"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "CodePipelineRoleAttach" {
    role = aws_iam_role.AwsCodePipelineRole.name
    policy_arn = aws_iam_policy.CodePipelinePolicy.arn
}