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
  # 1. NOVO: Processador para detectar e adicionar recursos (hostname)
  resourcedetection:
    # O "detector" Host é responsável por ler o hostname do sistema
    detectors: [system]
    system:
      # Renomeia o atributo padrão 'host.name' para 'service.instance.id' se necessário
      # Mas para o SigNoz, o 'host.name' já é suficiente.
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
      # 2. MUDANÇA: Adicionar 'resourcedetection' ANTES do 'batch'
      processors: [resourcedetection, batch]
      exporters: [otlp]
    traces:
      receivers: [otlp]
      # Opcional: Você pode adicionar 'resourcedetection' aqui também, mas não é obrigatório para a infra
      processors: [batch] 
      exporters: [otlp]
    logs:
      receivers: [otlp]
      # Opcional: Você pode adicionar 'resourcedetection' aqui também
      processors: [batch]
      exporters: [otlp]
EOF


# Reinicia o collector com nova config
sudo systemctl restart otelcol-contrib
sudo systemctl enable otelcol-contrib
