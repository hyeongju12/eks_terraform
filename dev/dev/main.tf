# resource 생성 순서
# 1) VPC 구성(public 2, private 2)
#    - public 2a 10.1.0.0/16 / 2c 10.2.0.0/16
#    - private 2a 10.3.0.0/16 / 2c 10.4.0.0/16
# 2) igw 생성 
#    - vpc attach
# 2) route table 생성
#    - 각 public subnet에 ngw 생성
#    - private route table에 ngw 추가 ----- 완료
# EKS Manage EC2 Instance 생성
#    - kubectl 설치
#    - helm 설치
#    - kubeconfig update
#    - ssh key-pair 생성 > 업로드
# EKS 생성
# 요구사항에 맞춰 EKS NodeGroup 2 / t3.medium

terraform {
    backend "s3" {
        profile = "dev"
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "hjyoo-tf-project-locks"
        encrypt = true
    }
}
