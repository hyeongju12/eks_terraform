# eks_terraform
# 
export AWS_ACCESS_KEY_ID="AKIAVIH3DRLNOL3NW7UG" 
export AWS_SECRET_ACCESS_KEY="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"
export AWS_REGION="us-east-1"


mysql_endpoint = "terraform-and-running-hjyoo20230324042527484600000001.c3wxrxrpl7cy.us-east-1.rds.amazonaws.com"
port = 3306


cat >load-balancer-role-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::431095615907:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/440FFEC00D5D808C4968CF671B4491A9"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.region-code.amazonaws.com/id/440FFEC00D5D808C4968CF671B4491A9:aud": "sts.amazonaws.com",
                    "oidc.eks.region-code.amazonaws.com/id/440FFEC00D5D808C4968CF671B4491A9:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF


aws iam attach-role-policy \
  --policy-arn arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json \
    --profile dev

eksctl create iamserviceaccount \
  --cluster=eks_cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::727503995468:policy/AWSLoadBalancerControllerIAMPolicy \
  --profile=dev \
  --approve 


eksctl utils associate-iam-oidc-provider --cluster eks_cluster --approve
oidc_id=$(aws eks describe-cluster --name eks_cluster --query "cluster.identity.oidc.issuer --profile dev" --output text | cut -d '/' -f 5)


aws iam create-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --assume-role-policy-document file://"load-balancer-role-trust-policy.json" \
  --profile dev

  aws iam attach-role-policy \
  --policy-arn arn:aws:iam::727503995468:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --profile dev


cat >aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::727503995468:role/AmazonEKSLoadBalancerControllerRole
EOF

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks_cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

  #helm 버전 에러 발생... ㅋ.. 
  다운그레이드.. 3.8.2 으로 
  https://peterica.tistory.com/205


  # 로드밸런서 컨트롤러 설치
  https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html

  # OICD 제공업체 ID생성
  https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/enable-iam-roles-for-service-accounts.html

  # eksctl 설치 
  https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/eksctl.html


  # ingress-nginx 설치 
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/aws/deploy.yaml

  # repo 추가
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

  # values 다운로드
  helm show values ingress-nginx/ingress-nginx > values.yaml

  # 설치
  helm install ingress-nginx ingress-nginx/ingress-nginx -f values.yaml -n ingress-nginx

  # argocd 설치
  sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
  sudo chmod +x /usr/local/bin/argocd
  helm repo add argo https://argoproj.github.io/argo-helm
  helm show values argo/argo > values.yaml



service.beta.kubernetes.io/aws-load-balancer-internal: "true"

  An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls


ad3b31d72c691406da249739c39b3912-1677466696.us-east-1.elb.amazonaws.com 

eksctl create iamserviceaccount \
  --cluster=eks_cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::880344156207:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve \
  --profile dev


cat >load-balancer-role-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::880344156207:oidc-provider/oidc.eks.region-code.amazonaws.com/id/A5F6A0D0A0398371D4220BEDD36D4FD3"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.region-code.amazonaws.com/id/A5F6A0D0A0398371D4220BEDD36D4FD3:aud": "sts.amazonaws.com",
                    "oidc.eks.region-code.amazonaws.com/id/A5F6A0D0A0398371D4220BEDD36D4FD3:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

  A6976D51883DEC3349A331F1EBE5E16B

  aws iam create-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --assume-role-policy-document file://"load-balancer-role-trust-policy.json" \
  --profile dev

  aws iam attach-role-policy \
  --policy-arn arn:aws:iam::092258095084:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --profile dev


cat >aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::092258095084:role/AmazonEKSLoadBalancerControllerRole
EOF


5817817537:AAHgNV5iW-63xWCWe4SA2dNkURHM1mG_qRY

https://api.telegram.org/bot5817817537:AAHgNV5iW-63xWCWe4SA2dNkURHM1mG_qRY/getUpdates
https://api.telegram.org/bot5817817537:AAHgNV5iW-63xWCWe4SA2dNkURHM1mG_qRY/getUpdates?offset=0
