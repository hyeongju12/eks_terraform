provider "kubernetes" {
    config_path = "~/.kube/config"
}


resource "kubernetes_config_map" "aws_auth" {
    metadata {
        name = "aws-auth"
        namespace = "kube-system"
    }

    data = {
        "mapRoles" = <<YAML
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: "${aws_iam_role.AdminAwsCodeBuild2.arn}"
  username: "system:node:{{EC2PrivateDNSName}}"
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: "arn:aws:iam::${aws_ecr_repository.hjyoo-ecr-2.registry_id}:role/eks-node-group"
  username: "system:node:{{EC2PrivateDNSName}}"
        YAML
    }
}