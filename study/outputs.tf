output "iam_all_user_arn" {
    value = values(aws_iam_user.name)[*].arn
    description = "All IAM user arn"
}

output "Upper_all_user_name" {
    value = [for name in var.user_name: upper(name)]
}

output "Map_hjyoo" {
    value = [for inform, value in var.hjyoo: "hjyoo inform ${inform} : ${value}"]
}

output "for_directive" {
    value = <<EOF
        %{~ for user_name in var.user_name}
            ${user_name}
        %{~ endfor}
    EOF
}