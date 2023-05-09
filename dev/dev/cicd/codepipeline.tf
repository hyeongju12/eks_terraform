resource "aws_codepipeline" "codepipeline" {
    name     = "web-demo-codepipeline"
    role_arn = aws_iam_role.AdminAwsCodeBuild2.arn

    artifact_store {
        location = aws_s3_bucket.codepipeline_bucket.bucket
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeCommit"
        version          = "1"
        output_artifacts = ["source_output"]
        run_order        = 1


        configuration = {
            RepositoryName    = "${aws_codecommit_repository.web-demo-2.repository_name}"
            BranchName       = "main"
            PollForSourceChanges = "true"
        }
        }
    }

    stage {
        name = "Build"

        action {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output"]
        version          = "1"

        configuration = {
            ProjectName = "${aws_codebuild_project.web-demo-2.name}"
        }
        }
    }

    depends_on = [ aws_codebuild_project.web-demo-2 ]
}