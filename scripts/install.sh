#!/bin/bash
set -e

kubectl create namespace observability || true

# Install kube-prometheus-stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n observability --create-namespace \
  --values manifests/grafana/values.yaml

# Install Grafana (via kube-prometheus-stack, Grafana already included)
# Install Loki
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki-stack -n observability --set grafana.enabled=false

# Apply manifests
kubectl apply -f manifests/otel-collector/ -n observability
kubectl apply -f manifests/mongodb-exporter/ -n observability
kubectl apply -f manifests/servicemonitors/ -n observability
kubectl apply -f manifests/alerts/ -n observability

# Fluent Bit — zbieranie logów i przesyłanie do Loki
# Kolejność ma znaczenie: najpierw RBAC, potem ConfigMap, na końcu DaemonSet
kubectl apply -f manifests/loki/fluentbit-rbac.yaml
kubectl apply -f manifests/loki/fluentbit-configmap.yaml -n observability
kubectl apply -f manifests/loki/fluentbit-daemonset.yaml

# Sprawdź, czy DaemonSet uruchomił się poprawnie
echo "Czekam na Fluent Bit DaemonSet..."
kubectl rollout status daemonset/fluentbit -n observability --timeout=120s
