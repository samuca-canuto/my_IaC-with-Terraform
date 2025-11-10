resource "aws_instance" "otel_collector" {
  ami                    = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sub-pub1.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  key_name               = "vockey"
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
set -e

apt update -y
apt install -y wget unzip

# Baixa e instala o OpenTelemetry Collector
wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.108.0/otelcol-contrib_0.108.0_linux_amd64.deb
dpkg -i otelcol-contrib_0.108.0_linux_amd64.deb

# Cria o arquivo de configuração
cat <<EOT > /etc/otelcol-contrib/config.yaml
extensions:
  health_check:
    endpoint: 0.0.0.0:13133

receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

  hostmetrics:
    collection_interval: 30s
    scrapers:
      cpu:
      memory:
      disk:
      network:

processors:
  batch:
    timeout: 10s

exporters:
  otlp:
    endpoint: "ingest.us.signoz.cloud:443"
    headers:
      signoz-ingestion-key: "b4e4cb2f-5337-4c86-a952-793acc1370a3"
    tls:
      insecure: false

service:
  extensions: [health_check]
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
    metrics:
      receivers: [otlp, hostmetrics]
      processors: [batch]
      exporters: [otlp]
EOT

# Recarrega daemons e inicia o serviço
systemctl daemon-reload
systemctl enable otelcol-contrib
systemctl start otelcol-contrib
EOF

  tags = {
    Name = "otel-collector"
  }
}

output "otel_collector_private_ip" {
  value = aws_instance.otel_collector.private_ip
}

output "otel_collector_public_ip" {
  value = aws_instance.otel_collector.public_ip
}
