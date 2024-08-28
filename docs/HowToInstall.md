# How to install

Terraform을 통해 `EKS cluster`를 설치하는 방법을 설명한다.

Terraform 코드는 다음 기능을 지원한다.

- EKS 생명주기 관리
  - 생성/삭제 관리
  - 버전 업그레이드
- 노드 그룹 생명주기 관리
  - 생성/삭제 관리
  - Launch template를 통한 UserData 설정
  - 버전 업그레이드
- s3 백엔드 지원
- Custom network 설정
- AWS 교차 계정 설치
- 복수 Workspace 설정

## Install

Cluster를 설치하는 다양한 방법에 대해 설명한다.

### 1. Basic installation: Local

Terraform을 사용하여 Local 환경에서 cluster를 설치하는 방법에 대해 설명한다.

<details>

<summary>설치 방법</summary>

- tfvars 설정

각 항목의 자세한 설명은 [README](./../README.md) 참조

```yaml
# cluster 및 tag 구성 필수 정보
project     = "demo"
region      = "ap-northeast-2"
abbr_region = "ane2"
env         = "dev"
org         = "example"

# 네트워크 구성 정보
vpc_id             = "vpc-0d2502934730afebd"
private_subnet_ids = ["subnet-0e0586fa9048f932a", "subnet-0c7ea9aa38102c6d4"]
public_subnet_ids  = ["subnet-0ab6dc3405d2c171c", "subnet-09eef3c587f0f5f7d"]

# 노드 그룹 구성 정보
eks_node_groups = [
  {
    name            = "apps"
    instance_type   = "t3.small"
    instance_volume = "10"
    desired_size    = 2
    min_size        = 1
    max_size        = 4
    description     = "Dev EKS Cluster"
  }
]
```

- 배포

```sh
# Terraform 환경 구성
terraform init

# Create Workspace (option)
terraform workspace new dev

# Change Workspace (option)
terraform workspace select dev

# Check installation plan (option)
terraform plan -var-file=examples/1.basic_install.tfvars

# Install
terraform apply -var-file=examples/1.basic_install.tfvars --auto-approve
```

- 배포 결과 확인

```sh
# 'terraform.tfstate'가 생성 된 것을 확인 할 수 있다.
ls -al

...
-rw-r--r-- 1 mzc mzc 19575 Mar 24 14:34 terraform.tfstate
...
```

- 삭제

```sh
# Destroy
terraform destroy -var-file=examples/1.basic_install.tfvars --auto-approve
```

</details>

### 2. Remote backend type: s3

Terraform을 사용하여 cluster를 설치하고 terraform metadata를 `s3`에 저장하는 방법에 대해 설명한다.
또한 Terraform으로 생성 한 네트워크를 Cluster를 생성 할 때 `s3`에서 참조 할 수 있다.

<details>

<summary>설치 방법</summary>

- s3 backend 설정

  - backend.hcl 생성

  ```yaml
  bucket         = "demo-common-terraform-state"              # s3 버킷 이름
  key            = "demo/ap-northeast-2/eks.tfstat"           # key 이름. project/az/component 형식을 권장. env는 workspace 설정을 통해 지원 가능
  region         = "ap-northeast-2"                           # s3 버킷 리전
  encrypt        = true                                       # 데이터 송수신시, 암호화 적용 여부. default: false
  dynamodb_table = "EKS"                                      # dynamodb 테이블 이름. terraform 중복 실행 방지를 위해 lock 용도로 사용하는 table
  ```

  - version.tf 설정

  version.tf 파일에서 `backend "s3" {}` 를 주석 해제한다.

  ```yaml
  # Uncomment if you are using s3 as backend.
  backend "s3" {}
  ```

- 적용

```sh
# Terraform 환경 구성
terraform init -backend-config=/path/backend.hcl

# Create Workspace (option)
terraform workspace new dev

# Change Workspace (option)
terraform workspace select dev

# Install
terraform apply --auto-approve
```

- 삭제

```sh
# Destroy
terraform destroy --auto-approve
```

</details>

### 3. Cross account installation

교차 계정 환경에서 Cluster를 구성하는 방법을 설명한다.

<details>

<summary>설치 방법</summary>

#### Local 환경일 경우 사전 작업

- source account

```sh
# source account
aws configure

# target account
aws configure --profile <TARGET>
```

- tfvars 수정

```yaml
... 중략 ...
# source account
shared_account = {
  region  = <REGION>
}

# target account
target_account = {
  region  = <REGION>
  profile = <TARGET PROFILE>
}
... 중략 ...
```

#### Instance profile or IAM Role 을 사용 하는 환경일 경우 사전 작업

- Source account에서 적절한 권한을 부여한 instance profile 또는 IAM role을 생성

- Target account에서 적절한 권한을 부여한 IAM role을 생성

- 생성한 target Role에 source profile or role에 대한 신뢰관계 설정

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<SOURCE ACCOUNT>:role/<SOURCE ROLE - Instance profile>"
        ]
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
```

- tfvars 수정

```yaml
... 중략 ...
# source account
shared_account = {
  region  = <REGION>
}

# target account
target_account = {
  region          = <REGION>
  assume_role_arn = "arn:aws:iam::<ACCOUNT>:role/<ROLE_NAME>"
}
```

#### 배포 및 삭제

- 적용

```sh
# Terraform 환경 구성
terraform init

# Create Workspace (option)
terraform workspace new dev

# Change Workspace (option)
terraform workspace select dev

# Check installation plan (option)
terraform plan -var-file=examples/4.cross_account_install.tfvars

# Install
terraform apply -var-file=examples/4.cross_account_install.tfvars --auto-approve
```

- 삭제

```sh
# Destroy
terraform destroy -var-file=examples/4.cross_account_install.tfvars --auto-approve
```

</details>

### 4. Use spot instance

노드를 스팟으로 사용 할 경우 적용 방법을 설명한다.

<details>

<summary>설치 방법</summary>

- tfvars 수정

```yaml
... 중략 ...
eks_node_groups = [
  {
    name                = "apps"
    use_spot            = true                        # spot 사용
    spot_instance_types = ["t3.small"]                # cpu, memory 용량이 유사한 인스턴스 유형을 나열한다.
    instance_volume     = "10"
    desired_size        = 2
    min_size            = 1
    max_size            = 4
    description         = "Dev EKS Cluster"
  }
]
... 중략 ...
```

```sh
# Terraform 환경 구성
terraform init

# Create Workspace (option)
terraform workspace new dev

# Change Workspace (option)
terraform workspace select dev

# Check installation plan (option)
terraform plan -var-file=examples/5.spot_instance.tfvars

# Install
terraform apply -var-file=examples/5.spot_instance.tfvars --auto-approve
```

- 삭제

```sh
# Destroy
terraform destroy -var-file=examples/5.spot_instance.tfvars --auto-approve
```

</details>

### 5. Addon installation

EKS Add-Ons는 Kubernetes 애플리케이션에 대한 지원 운영 기능을 제공하는 소프트웨어로써 AWS 리소스인 네트워킹, 컴퓨팅 및 스토리지에 대한 관리를 지원한다.

Add-Ons은 일반적으로 Kubernetes 커뮤니티, AWS 클라우드 공급자 또는 3rd party 공급업체에 의해 유지 관리 된다. AWS EKS는 모든 클러스터에 `Amazon VPC CNI`, `kube-proxy`, `CoreDNS`를 자동으로 설치하나 관리의 목적을 위해 기본 구성을 변경 또는 업데이트할 수 있다. 이를 위해 Add-Ons은 이를 관리하는 역할을 담당한다. AWS Add-Ons에서 제공하는 기능에는 최신 보안 패치, 버그 수정 사항이 포함되어 있으며, Amazon EKS와 작동하도록 AWS에서 검증되었다.

Amazon EKS Add-Ons는 1.18이상에서 사용할 수 있다.

#### 지원되는 Add-Ons

- Amazon VPC CNI
- CoreDNS
- kube-proxy
- Amazon EBS CSI (제한적)

Add On은 계속 추가 될 예정이며 현재 EKS에서 지원되는 Add-Ons 및 버전은 다음 명령어를 실행하여 확인한다.

```sh
aws eks describe-addon-versions --kubernetes-version <value>
```

<details>

<summary>설치 방법</summary>

- tfvars 수정

```yaml
... 중략 ...
eks_addons = [
  {
    name    = "aws-ebs-csi-driver"
    install = true
    policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    ]
    policy_file = "kms-key-for-encryption-on-ebs.tpl"
  },
  {
    name    = "vpc-cni"
    install = true
    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ]
  },
  {
    name    = "coredns"
    install = true
  },
  {
    name    = "kube-proxy"
    install = true
  }
]
... 중략 ...
```

---

**_Note!_**

노드를 생성하지 않는 경우, `aws-ebs-csi-driver`와 `coredns` 등 `DaemonSet`이 아닌 addon은 `install = true`을 설정해도 설치하지 않는다.

---

- 적용

```sh
# Terraform 환경 구성
terraform init

# Create Workspace (option)
terraform workspace new dev

# Change Workspace (option)
terraform workspace select dev

# Check installation plan (option)
terraform plan -var-file=examples/6.install_addons.tfvars

# Install
terraform apply -var-file=examples/6.install_addons.tfvars --auto-approve
```

- 삭제

```sh
# Destroy
terraform destroy -var-file=examples/6.install_addons.tfvars --auto-approve
```

</details>

