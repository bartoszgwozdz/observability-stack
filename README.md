# Observability Stack for Kubernetes

This repository bootstraps a complete observability environment for a Kubernetes cluster running:
- Java application
- Node.js application
- HTML frontend
- Mongo Express
- MongoDB

It uses **Prometheus, Grafana, Loki, Fluent Bit, OpenTelemetry Collector, and MongoDB Exporter** to provide full observability: metrics, logs, traces, dashboards, and alerts.

---

## 📦 Components

- **[kube-prometheus-stack](https://github.com/prometheus-operator/kube-prometheus)**
  - Prometheus for metrics
  - Alertmanager for alerting
  - Grafana for dashboards
  - Node exporter, kube-state-metrics

- **[OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)**
  - Receives traces/metrics from Java, Node.js, and frontend
  - Exposes metrics to Prometheus
  - Sends traces to logging/tracing backends (example config included)

- **[Loki](https://grafana.com/oss/loki/) + [Fluent Bit](https://fluentbit.io/)**
  - Centralized log collection from all pods
  - Query logs in Grafana (with trace correlation)

- **[MongoDB Exporter](https://github.com/percona/mongodb_exporter)**
  - Exposes MongoDB metrics to Prometheus

- **Dashboards**
  - Kubernetes / cluster overview
  - JVM metrics
  - Node.js service metrics
  - MongoDB metrics

- **Alert rules**
  - High error rate (>5% 5xx responses)
  - Basic infrastructure alerts

---

## 🚀 Installation

1. Unpack the archive:

   ```bash
   unzip observability-stack.zip
   cd observability
