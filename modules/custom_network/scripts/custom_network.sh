#! /bin/bash
aws eks update-kubeconfig --name "${CLUSTER_NAME}"

cat <<EOF | kubectl apply -f -
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: ${NAME}
spec:
  subnet: ${SUBNET}
  securityGroups:
  - ${NODE_SG}
  - ${CLUSTER_SG}
EOF