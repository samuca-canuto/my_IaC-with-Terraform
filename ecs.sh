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

exporters:
  otlp:
    endpoint: "https://ingest.us.signoz.cloud:443"
    headers:
      signoz-ingestion-key: "b4e4cb2f-5337-4c86-a952-793acc1370a3"
    tls:
      insecure: false

service:
  pipelines:
    metrics:
      receivers: [otlp]
      exporters: [otlp]
    traces:
      receivers: [otlp]
      exporters: [otlp]
    logs:
      receivers: [otlp]
      exporters: [otlp]
EOF

# Reinicia o collector com nova config
sudo systemctl restart otelcol-contrib
sudo systemctl enable otelcol-contrib
