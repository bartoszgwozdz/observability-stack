# Observability Stack dla Kubernetes

To repozytorium dostarcza kompletny zestaw do obserwowalności (observability) dla klastra Kubernetes, w którym działają:
- aplikacja Java
- aplikacja Node.js
- frontend HTML
- Mongo Express
- MongoDB

W paczce znajdują się komponenty: **Prometheus, Grafana, Loki, Fluent Bit, OpenTelemetry Collector i MongoDB Exporter**.
Dzięki nim masz monitoring metryk, logi, trace’y, dashboardy i alerty.

---

## 📦 Co wchodzi w skład paczki

- **kube-prometheus-stack**
  - Prometheus (metryki)
  - Alertmanager (alerty)
  - Grafana (dashboardy)
  - node-exporter, kube-state-metrics (metryki węzłów i obiektów K8s)

- **OpenTelemetry Collector**
  - Odbiera trace’y i metryki od aplikacji (OTLP)
  - Udostępnia metryki Prometheusowi
  - Może wysyłać trace’y do Jaegera/Tempo

- **Loki + Fluent Bit**
  - Fluent Bit zbiera logi z podów (stdout/stderr)
  - Loki przechowuje logi i udostępnia je w Grafanie

- **MongoDB Exporter**
  - Eksportuje metryki z MongoDB (połączenia, opóźnienia, cache, operacje)

- **Dashboardy**
  - K8s overview
  - JVM metryki
  - Node.js service
  - MongoDB

- **Alerty**
  - np. wysoki % błędów 5xx

---

## 🚀 Instalacja

1. Rozpakuj archiwum:

   ```bash
   unzip observability-stack.zip
   cd observability
   ```

2. Uruchom instalator:

   ```bash
   chmod +x scripts/install.sh
   ./scripts/install.sh
   ```

   To spowoduje:
   - utworzenie namespace `observability`
   - instalację kube-prometheus-stack przez Helm
   - instalację Loki + Fluent Bit
   - zastosowanie manifestów (otel-collector, MongoDB exporter, ServiceMonitor, alerty)

---

## 🖥 Dostęp do Grafany

Grafana jest częścią kube-prometheus-stack.

Pobierz hasło admina:

```bash
kubectl get secret -n observability kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Zrób port-forward:

```bash
kubectl -n observability port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Wejdź na [http://localhost:3000](http://localhost:3000)  
Login: `admin`  
Hasło: <z komendy powyżej>

---

## 📊 Dashboardy

W `manifests/grafana/dashboards/` znajdziesz przykładowe JSON-y:
- `overview.json` — metryki klastra i węzłów
- `java.json` — JVM (heap, GC)
- `mongo.json` — MongoDB (połączenia, zapytania)

Importuj je w Grafanie.

---

## 📡 Instrumentacja aplikacji

- **Java (Spring Boot)**
  - włącz `/actuator/prometheus`
  - dodaj OTEL Java Agent, np.:
    ```bash
    java -javaagent:/opt/otel/opentelemetry-javaagent.jar          -Dotel.exporter.otlp.endpoint=http://otel-collector.observability:4317          -Dotel.service.name=my-java-service          -jar app.jar
    ```

- **Node.js**
  - użyj `@opentelemetry/sdk-node`
  - wystaw `/metrics` dla Prometheus

- **Frontend**
  - użyj OpenTelemetry JS SDK dla RUM (metryki przeglądarki + trace’y)

---

## 🔔 Alerty

W `manifests/alerts/app-error-rules.yaml` jest przykładowa reguła:
- **HighErrorRate**: wyzwala gdy >5% żądań to 5xx przez 5 minut

Alertmanager (wraz z kube-prometheus-stack) może wysyłać powiadomienia do Slacka, email, PagerDuty itd.

---

## 🛠 Jak działa każdy komponent (krok po kroku)

1. **Prometheus Operator** – zarządza Prometheusem, Alertmanagerem, Grafaną i ServiceMonitorami.
2. **ServiceMonitor** – mówi Prometheusowi, które serwisy i endpointy `/metrics` ma zbierać.
3. **Grafana** – UI do dashboardów, korelacja logów, metryk i trace’ów.
4. **OTel Collector** – centralny odbiornik OTLP, eksportuje metryki i trace’y.
5. **Fluent Bit + Loki** – zbierają i przechowują logi, które widzisz w Grafanie.
6. **MongoDB Exporter** – specjalny exporter dla MongoDB, Prometheus go skrobie.
7. **Alerty** – PrometheusRule wykrywa anomalie, Alertmanager wysyła notyfikacje.

---

## ✅ Co zrobić po instalacji

- Sprawdź pody w `observability`:  
  ```bash
  kubectl -n observability get pods
  ```
- Wejdź do Grafany (port-forward) i importuj dashboardy.
- Sprawdź Prometheus → /targets → czy są scrape’y aplikacji.
- Instrumentuj aplikację (Java/Node) i zobacz metryki + trace’y.
- Upewnij się, że logi są widoczne w Grafana Explore (źródło: Loki).

---

## 📚 Dobre praktyki

- Logi w JSON z polami `trace_id`, `span_id`, `request_id` – łatwa korelacja z trace’ami.
- Nie dodawaj etykiet o dużej kardynalności (np. user_id) do metryk Prometheusa.
- Definiuj SLO (np. p95 < 300ms) i twórz alerty zgodne z budżetem błędów.
- Rozważ Thanos/Cortex jeśli potrzebujesz długiego retention metryk.
- Zacznij od kilku kluczowych dashboardów i 5–10 alertów, resztę rozwijaj stopniowo.
