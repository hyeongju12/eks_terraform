# VPC-CNI Custom Networking

This example shows how to provision an EKS cluster with:


-기본 네트워크 인터페이스가 있는 서브넷에서 사용할 수 있는 IPv4 주소의 수가 제한되는 경우
-보안상의 이유로 pods는 노드의 기본 네트워크 인터페이스와 다른 서브넷 또는 보안 그룹을 사용해야 하는 경우
-노드는 퍼블릭 서브넷에서 구성되며, pods를 프라이빗 서브넷에 배치할 경우

- 노드에서 사용하는 서브넷이 아닌 다른 서브넷에서 파드에 IP를 할당하기 위한 AWS VPC-CNI 커스텀 네트워킹
- 더 많은 파드 수를 허용하는 AWS VPC-CNI PREFIX-DELEGATION: 사용자 정의 네트워킹이 파드 IP 할당에 사용되는 하나의 ENI를 제거하여 노드에 할당할 수 있는 파드 수를 줄이므로 유용합니다. PREFIX-DELEGATION을 활성화하면 더 높은 파드 밀도를 통해 노드 리소스를 완전히 활용할 수 있도록 ENI에 접두사를 할당할 수 있습니다. 노드에 할당된 최대 파드를 관리하려면 아래의 사용자 데이터 섹션을 참조하세요.
- EKS 클러스터에는 컨트롤 플레인 전용 /28 서브넷이 있습니다. 컨트롤 플레인이 사용하는 서브넷을 변경하는 것은 위험한 작업이므로 클러스터를 중단하지 않고 서브넷을 추가하여 나중에 확장할 수 있도록 데이터 플레인과 분리된 컨트롤 플레인 전용 서브넷을 사용하는 것이 좋습니다.


이 예제에서 vpc-cni 애드온은 `before_compute = true` 옵션을 사용하여 구성됩니다.
prefix delegation을 비활성화 하려면 `vpc-cni` 애드온에서 환경 변수 `ENABLE_PREFIX_DELEGATION=true` 및 `WARM_PREFIX_TARGET=1` 할당을 제거합니다.


## VPC CNI Configuration

이 예제에서 `vpc-cni` 애드온은 `before_compute = true`를 사용하여 구성됩니다. 이는 EC2 인스턴스가 생성되기 *전에* `vpc-cni`가 생성되고 업데이트되어 원하는 설정이 참조되기 전에 적용되도록 하기 위해 필요합니다. 
이 구성을 사용하면 이제 생성된 노드에 `--max-pods 110`이 `vpc-cni`에서 prefix delegation이 활성화됩니다.

노드의 최대 파드의 수가 다른 경우(즉, `m5.large`의 경우 최대 파드가 110이 아닌 29인 경우), `vpc-cni`가 EC2 인스턴스보다 *먼저* 구성되지 않았을 가능성이 높습니다.


## Reference Documentation:

- [Documentation](https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html)
- [Best Practices Guide](https://aws.github.io/aws-eks-best-practices/reliability/docs/networkmanagement/#cni-custom-networking)

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. List the nodes running currently

```sh
kubectl get nodes

# Output should look similar to below
NAME                                       STATUS   ROLES    AGE   VERSION
ip-10-0-34-74.us-west-2.compute.internal   Ready    <none>   86s   v1.22.9-eks-810597c
```

3. Inspect the nodes settings and check for the max allocatable pods - should be 110 in this scenario with m5.xlarge:

```sh
kubectl describe node ip-10-0-34-74.us-west-2.compute.internal

# Output should look similar to below (truncated for brevity)
  Capacity:
    attachable-volumes-aws-ebs:  25
    cpu:                         4
    ephemeral-storage:           104845292Ki
    hugepages-1Gi:               0
    hugepages-2Mi:               0
    memory:                      15919124Ki
    pods:                        110 # <- this should be 110 and not 58
  Allocatable:
    attachable-volumes-aws-ebs:  25
    cpu:                         3920m
    ephemeral-storage:           95551679124
    hugepages-1Gi:               0
    hugepages-2Mi:               0
    memory:                      14902292Ki
    pods:                        110 # <- this should be 110 and not 58
```

4. List out the pods running currently:

```sh
kubectl get pods -A -o wide

# Output should look similar to below
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE   IP            NODE                                       NOMINATED NODE   READINESS GATES
kube-system   aws-node-ttg4h             1/1     Running   0          52s   10.0.34.74    ip-10-0-34-74.us-west-2.compute.internal   <none>           <none>
kube-system   coredns-657694c6f4-8s5k6   1/1     Running   0          2m    10.99.135.1   ip-10-0-34-74.us-west-2.compute.internal   <none>           <none>
kube-system   coredns-657694c6f4-ntzcp   1/1     Running   0          2m    10.99.135.0   ip-10-0-34-74.us-west-2.compute.internal   <none>           <none>
kube-system   kube-proxy-wnzjd           1/1     Running   0          53s   10.0.34.74    ip-10-0-34-74.us-west-2.compute.internal   <none>           <none>
```

5. Inspect one of the `aws-node-*` (AWS VPC CNI) pods to ensure prefix delegation is enabled and warm prefix target is 1:

```sh
kubectl describe pod aws-node-ttg4h -n kube-system

# Output should look similar below (truncated for brevity)
  Environment:
    ADDITIONAL_ENI_TAGS:                    {}
    AWS_VPC_CNI_NODE_PORT_SUPPORT:          true
    AWS_VPC_ENI_MTU:                        9001
    AWS_VPC_K8S_CNI_CONFIGURE_RPFILTER:     false
    AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG:     true # <- this should be set to true
    AWS_VPC_K8S_CNI_EXTERNALSNAT:           false
    AWS_VPC_K8S_CNI_LOGLEVEL:               DEBUG
    AWS_VPC_K8S_CNI_LOG_FILE:               /host/var/log/aws-routed-eni/ipamd.log
    AWS_VPC_K8S_CNI_RANDOMIZESNAT:          prng
    AWS_VPC_K8S_CNI_VETHPREFIX:             eni
    AWS_VPC_K8S_PLUGIN_LOG_FILE:            /var/log/aws-routed-eni/plugin.log
    AWS_VPC_K8S_PLUGIN_LOG_LEVEL:           DEBUG
    DISABLE_INTROSPECTION:                  false
    DISABLE_METRICS:                        false
    DISABLE_NETWORK_RESOURCE_PROVISIONING:  false
    ENABLE_IPv4:                            true
    ENABLE_IPv6:                            false
    ENABLE_POD_ENI:                         false
    ENABLE_PREFIX_DELEGATION:               true # <- this should be set to true
    MY_NODE_NAME:                            (v1:spec.nodeName)
    WARM_ENI_TARGET:                        1 # <- this should be set to 1
    WARM_PREFIX_TARGET:                     1
    ...
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target=kubectl_manifest.eni_config -target=module.eks_blueprints_kubernetes_addons -auto-approve
terraform destroy -target=module.eks -auto-approve
terraform destroy -auto-approve
```
