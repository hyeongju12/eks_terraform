# Custom Network
# null resource cni path
# -> ./scripts/network.sh 스크립트를 실행하기 위한 resource

# time sleep
# -> depends on [ null_resource..] 설정을 통해 time_sleep resouce는 null_resource 다음 실행

# 작동 방식
# cusotm networking enable = true 일 경우 실행됨
# EKS Cluster가 생성된 뒤 VPC CNI가 생성되고 time sleep trigger를 이용해 EKS Nodegroup 생성을 위한 var.eks_managed_nodegroups를 전달.
# time sleep resouce는 null_resource.cni_path 다음 30초 이후(create_duration -> Default = 30s / Max = 5m )에 실행 되므로
# vpc cni의 Eniconfig 업데이트를 Nodegroup 생성 보다 먼저 진행 가능
resource "time_sleep" "this" {
  count = var.use_custom_network ? 1 : 0

  create_duration = var.nodegroups_create_duration_seconds

  triggers = {
    eks_managed_nodegroups = jsonencode(var.nodegroups_create_trigger)
  }
  depends_on = [null_resource.cni_patch]
}
resource "null_resource" "cni_patch" {
  for_each = {
    for k, v in zipmap(
      var.eni_configs[*].name,
    var.eni_configs[*].subnet_id) : k => v
    if var.use_custom_network && var.eni_configs != {}
  }
  triggers = {
    cluster_name = var.cluster_name
    cluster_sg   = var.cluster_sg
    node_sg      = var.node_sg
    name         = each.key
    subnet       = each.value
  }
  provisioner "local-exec" {
    environment = {
      CLUSTER_NAME = self.triggers.cluster_name
      CLUSTER_SG   = self.triggers.cluster_sg
      NODE_SG      = self.triggers.node_sg
      SUBNET       = self.triggers.subnet
      NAME         = self.triggers.name
    }
    command     = "${path.module}/scripts/custom_network.sh"
    interpreter = ["bash"]
  }
}
