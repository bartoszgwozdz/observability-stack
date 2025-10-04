# Kubernetes Observability Stack

This package provides a complete observability setup for a Kubernetes cluster running:
- Java application
- Node.js application
- HTML frontend
- Mongo Express
- MongoDB

The stack integrates **Prometheus, Grafana, Loki, Fluent Bit, OpenTelemetry Collector, and MongoDB Exporter**.

---

## 📦 What’s Included

- **kube-prometheus-stack**
  - Prometheus (metrics)
  - Alertmanager (alerts)
  - Grafana (dashboards)
  - node-exporter, kube-state-metrics

- **OpenTelemetry Collector**
  - Receives traces and metrics from applications (OTLP)
  - Exposes metrics for Prometheus
  - Can export traces to Jaeger/Tempo

- **Loki + Fluent Bit**
  - Fluent Bit collects logs from pods
  - Loki stores logs for Grafana

- **MongoDB Exporter**
  - Exports MongoDB metrics

- **Dashboards**
  - K8s overview
  - JVM metrics
  - Node.js service
  - MongoDB

- **Alerts**
  - e.g. High 5xx error rate

---

## 🚀 Installation

1. Unpack the archive:

   ```bash
   unzip observability-stack.zip
   cd observability
   ```

2. Run the installer:

   ```bash
   chmod +x scripts/install.sh
   ./scripts/install.sh
   ```

This will:
- create the `observability` namespace
- install kube-prometheus-stack via Helm
- install Loki + Fluent Bit
- apply manifests (otel-collector, MongoDB exporter, ServiceMonitors, alerts)

---

## 🖥 Access Grafana

Retrieve the admin password:

```bash
kubectl get secret -n observability kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Port-forward Grafana:

```bash
kubectl -n observability port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Open [http://localhost:3000](http://localhost:3000)  
Login: `admin`  
Password: <from the command above>

---

## 📊 Dashboards

Example dashboards in `manifests/grafana/dashboards/`:
- `overview.json` — cluster and node metrics
- `java.json` — JVM heap, GC
- `mongo.json` — MongoDB metrics

Import them into Grafana.

---

## 📡 Application Instrumentation

- **Java (Spring Boot)**  
  - expose `/actuator/prometheus`  
  - use OTEL Java Agent:
    ```bash
    java -javaagent:/opt/otel/opentelemetry-javaagent.jar          -Dotel.exporter.otlp.endpoint=http://otel-collector.observability:4317          -Dotel.service.name=my-java-service          -jar app.jar
    ```

- **Node.js**  
  - use `@opentelemetry/sdk-node`
  - expose `/metrics` for Prometheus

- **Frontend**  
  - use OpenTelemetry JS SDK for RUM

---

## 🔔 Alerts

`manifests/alerts/app-error-rules.yaml` includes a sample alert:
- **HighErrorRate**: triggers if >5% requests are 5xx for 5m

Alertmanager can notify via Slack, email, PagerDuty, etc.

---

## 🛠 Component Overview

1. **Prometheus Operator** – manages Prometheus, Alertmanager, Grafana, and ServiceMonitors  
2. **ServiceMonitor** – defines scrape targets for Prometheus  
3. **Grafana** – UI for dashboards, logs, metrics, traces  
4. **OTel Collector** – receives OTLP, exports metrics and traces  
5. **Fluent Bit + Loki** – collect and store logs, available in Grafana  
6. **MongoDB Exporter** – exposes MongoDB metrics  
7. **Alerts** – PrometheusRule + Alertmanager

---

## ✅ After Installation

- Check pods in observability:
  ```bash
  kubectl -n observability get pods
  ```
- Access Grafana (port-forward) and import dashboards
- Check Prometheus → /targets → scrape endpoints
- Instrument app and confirm metrics + traces
- Verify logs in Grafana Explore (source: Loki)

---

## 📚 Best Practices

- Log in JSON with `trace_id`, `span_id`, `request_id` for correlation  
- Avoid high-cardinality labels (e.g. `user_id`) in Prometheus  
- Define SLOs (e.g. p95 < 300ms) and alerts tied to error budget  
- Use Thanos/Cortex for long-term metric storage  
- Start small (key dashboards + 5–10 alerts), then expand
