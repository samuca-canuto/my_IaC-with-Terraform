#!/bin/bash

echo "ECS_CLUSTER=ecs-cluster" >> /etc/ecs/ecs.config

# Atualiza pacotes
sudo apt-get update -y

# Instala o OpenTelemetry Collector
wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.97.0/otelcol-contrib_0.97.0_linux_amd64.deb
sudo dpkg -i otelcol-contrib_0.97.0_linux_amd64.deb

# Cria o diretório de config
mkdir -p /etc/otelcol-contrib/

# Escreve o arquivo de configuração
cat <<EOF >/etc/otelcol-contrib/config.yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:
  hostmetrics:
    collection_interval: 30s
    scrapers:
      cpu:
      load:
      memory:
      filesystem:
      network:
      disk:
      processes:

processors:
  resourcedetection:
    detectors: [env, system]
    system:
      hostname_sources: [os]
  batch:

exporters:
  otlp:
    endpoint: "https://ingest.us.signoz.cloud:443"
    headers:
      signoz-ingestion-key: "${signoz_ingestion_key}"
    tls:
      insecure: false

service:
  pipelines:
    metrics:
      receivers: [otlp, hostmetrics]
      processors: [resourcedetection, batch]
      exporters: [otlp]
    traces:
      receivers: [otlp]
      processors: [resourcedetection, batch]
      exporters: [otlp]
    logs:
      receivers: [otlp]
      processors: [resourcedetection, batch]
      exporters: [otlp]
EOF


# Reinicia o collector com nova config
sudo systemctl restart otelcol-contrib
sudo systemctl enable otelcol-contrib
