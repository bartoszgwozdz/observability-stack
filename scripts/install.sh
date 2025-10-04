#!/bin/bash
set -e

kubectl create namespace observability || true

# Install kube-prometheus-stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n observability --create-namespace

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
