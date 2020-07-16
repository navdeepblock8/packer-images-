 
 sudo useradd --no-create-home --shell /bin/false prometheus
 sudo useradd --no-create-home --shell /bin/false node_exporter
 sudo mkdir /etc/prometheus
 sudo mkdir /var/lib/prometheus
 sudo chown prometheus:prometheus /etc/prometheus
 sudo chown prometheus:prometheus /var/lib/prometheus
 sudo apt update
 sudo apt -y install wget curl ex
 wget https://github.com/prometheus/prometheus/releases/download/v2.19.2/prometheus-2.19.2.linux-amd64.tar.gz
 tar xvf prometheus*.tar.gz
 sudo cp prometheus-2.19.2.linux-amd64/prometheus /usr/local/bin/
 sudo cp prometheus-2.19.2.linux-amd64/promtool /usr/local/bin/
 sudo chown prometheus:prometheus /usr/local/bin/prometheus
 sudo chown prometheus:prometheus /usr/local/bin/promtool
 sudo cp -r prometheus-2.19.2.linux-amd64/consoles /etc/prometheus
 sudo cp -r prometheus-2.19.2.linux-amd64/console_libraries /etc/prometheus
 sudo chown -R prometheus:prometheus /etc/prometheus/consoles
 sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
 sudo touch prometheus.yml
 sudo tee -a prometheus.yml > /dev/null <<EOT
  
 global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
EOT

 sudo cp prometheus.yml /etc/prometheus/
 sudo touch prometheus.service
 sudo tee -a prometheus.service > /dev/null <<EOT
  
  [Unit]
   Description=Prometheus Time Series Collection and Processing Server
   Wants=network-online.target
    After=network-online.target

   [Service]
   User=prometheus
   Group=prometheus
   Type=simple
    ExecStart=/usr/local/bin/prometheus \
     --config.file /etc/prometheus/prometheus.yml \
     --storage.tsdb.path /var/lib/prometheus/ \
     --web.console.templates=/etc/prometheus/consoles \
     --web.console.libraries=/etc/prometheus/console_libraries

   [Install]
   WantedBy=multi-user.target
EOT
 sudo cp prometheus.service /etc/systemd/system 
 sudo systemctl daemon-reload
 sudo systemctl start prometheus



 wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
 tar xvfz node_exporter-1.0.1.linux-amd64.tar.gz
 sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin
 sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

 sudo touch node_exporter.service

 sudo tee -a node_exporter.service > /dev/null <<EOT
  
  [Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

EOT

 sudo cp node_exporter.service /etc/systemd/system 
 sudo systemctl daemon-reload
 sudo systemctl restart prometheus
 sudo systemctl start node_exporter
