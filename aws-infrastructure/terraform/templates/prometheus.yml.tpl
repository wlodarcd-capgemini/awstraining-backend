global:
  scrape_interval: 1m
  scrape_timeout: 10s
  evaluation_interval: 1m
  external_labels:
    ENV: ${env}
    HUB: ${hub}
    %{ if env == "prod"}
    priorityHigh: "HIGH"
    priorityMed: "MEDIUM"
    priorityLow: "LOW"
    %{ else}
    priorityHigh: "MEDIUM"
    priorityMed: "LOW"
    priorityLow: "LOW"
    %{ endif}
scrape_configs:
  - job_name: backend
    scrape_interval: 1m
    scrape_timeout: 10s
    metrics_path: /backend/status/v1/prometheus
    honor_labels: true
    scheme: http
    tls_config:
      insecure_skip_verify: true
    file_sd_configs:
      - files:
        - /prometheus/discovered.yml
        refresh_interval: 2m
    relabel_configs:
      - source_labels: [container_arn]
        regex: '(.+)'
        replacement: '$1'
        target_label: arn
        action: replace
rule_files:
  - /prometheus/rules/spring-rules.yaml
  - /prometheus/rules/backend-rules.yaml

alerting:
  alertmanagers:
    - timeout: 10s
      api_version: v1
      scheme: https
      static_configs:
        - targets:
          - ${alert_target_endpoint}
