data "terraform_remote_state" "subnet_ids" {
    backend = "s3"

    config = {
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/vpc/terraform.tfstate"
        region = "us-east-1"
        profile = "dev"
    }
}

locals {
  subnet_ids = [data.terraform_remote_state.network-config.outputs.dev-subnet-1a-public-id, data.terraform_remote_state.network-config.outputs.dev-subnet-1c-public-id]
}

output "subnet_ids" {
  value = join(",", local.subnet_ids)
}

resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks update-kubeconfig --profile dev --name ${aws_eks_cluster.aws_eks.name}"
    }

    depends_on = [ aws_eks_node_group.node ]
}

provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
    }
}

resource "helm_release" "ingress-nginx" {
    chart = "ingress-nginx"
    name = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx"

    values = [
        "${file("ingress-nginx.yaml")}"
    ]

    create_namespace = true
    namespace = "ingress-nginx"

    depends_on = [ aws_eks_node_group.node ]
}

resource "helm_release" "argocd" {
    chart = "argo-cd"
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"

    values = [ 
        templatefile("${path.module}/argo_values.yaml", {
            subnet_ids = "${join(",", local.subnet_ids)}",
            role_arn = "${aws_iam_role.EKSAccessCICD.arn}"
        })
    ]

    # values = [
    #     "${file("argo_values.yaml")}"
    #     ]
    
    create_namespace = true
    namespace = "argocd"

    depends_on = [ aws_eks_node_group.node ]

    # set {
    #     name = "server.ingress.annotations\\.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    #     value = "{${join(",", local.subnet_ids)}}"
    # }
}

# resource "helm_release" "prometheus" {
#     chart = "prometheus"
#     name = "prometheus"
#     repository = "https://prometheus-community.github.io/helm-charts"

#     values = [
#         "${file("promethus_values.yaml")}"
#     ]

#     create_namespace = true
#     namespace = "prometheus"
#     depends_on = [ aws_eks_node_group.node ]
# }

# resource "helm_release" "grafana" {
#     chart = "grafana"
#     name = "grafana"
#     repository = "https://grafana.github.io/helm-charts"

#     values = [
#         "${file("grafana_values.yaml")}"
#     ]

#     create_namespace = true
#     namespace = "grafana"
#     depends_on = [ aws_eks_node_group.node ]

# }

# resource "helm_release" "autoscaler" {
#     chart = "cluster-autoscaler"
#     name = "autoscaler"
#     repository = "https://kubernetes.github.io/autoscaler"

#     values = [
#         "${file("auto_scaler_values.yaml")}"
#     ]

#     namespace = "kube-system"

#     set {
#         name = "autoDiscovery.clusterName"
#         value = aws_eks_cluster.aws_eks.name
#     }

#     set {
#         name = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#         value = aws_iam_role.cluster_autoscaler_role.arn
#     }

#     set {
#         name  = "awsRegion"
#         value = "us-east-1"
#     }
#     depends_on = [ aws_eks_node_group.node ]
# }

# resource "helm_release" "metrics-server" {
#     chart = "metrics-server"
#     name = "metrics-server"
#     repository = "https://kubernetes-sigs.github.io/metrics-server/"

#     values = [
#         "${file("metrics-server.yaml")}"
#     ]

#     namespace = "kube-system"
#     depends_on = [ aws_eks_node_group.node ]
# }
