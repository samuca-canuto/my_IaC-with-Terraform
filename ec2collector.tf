# ============================================================
# Instância EC2 dedicada ao OpenTelemetry Collector
# ============================================================

resource "aws_instance" "otel_collector" {
  ami                    = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sub-pub1.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  key_name               = "sua-chave-ssh" # substitua pela sua chave existente

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
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

processors:
  batch:
    timeout: 10s

exporters:
  otlp:
    endpoint: "ingest.us.signoz.cloud:443"
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
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
EOT

    # Habilita e inicia o serviço
    systemctl enable otelcol-contrib
    systemctl restart otelcol-contrib
  EOF

  tags = {
    Name = "otel-collector"
  }
}

# ============================================================
# Saída útil: IPs da instância
# ============================================================

output "otel_collector_private_ip" {
  value = aws_instance.otel_collector.private_ip
}

output "otel_collector_public_ip" {
  value = aws_instance.otel_collector.public_ip
}
