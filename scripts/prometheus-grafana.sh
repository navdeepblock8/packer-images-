 
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
sudo touch alertrules.yml
sudo tee -a alertrules.yml > /dev/null <<EOT 
groups:
  - name: default
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Instance  down"
        description: "Instance has been down for more than 5 minutes."
EOT
sudo cp alertrules.yml /etc/prometheus/
sudo touch prometheus.yml
sudo tee -a prometheus.yml > /dev/null <<EOT
global:
  scrape_interval: 10s

rule_files:
  - alertrules.yml

alerting:
  alertmanagers:
   - static_configs:
       - targets: ['localhost:9093']

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
 
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list 
sudo apt update
sudo apt install grafana -y


wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz
tar -xvzf alertmanager-0.21.0.linux-amd64.tar.gz
sudo mv alertmanager-0.21.0.linux-amd64/alertmanager /usr/local/bin/
sudo mv alertmanager-0.21.0.linux-amd64/amtool /usr/local/bin/
sudo mkdir /etc/alertmanager/
sudo touch alertmanager.yml 
sudo tee -a alertmanager.yml > /dev/null <<EOT
global:

route:
  group_by: [Alertname]
  receiver: alert-emailer

receivers:
- name: alert-emailer
  email_configs:
  - to: 'Email receiver'
    from: 'Email account for sending alert email'
    smarthost: smtp.gmail.com:587
    auth_username: 'Email account for sending alert email'
    auth_password: 'password'
    auth_identity: 'Email account for sending alert email'

EOT
sudo cp alertmanager.yml /etc/alertmanager/
sudo mkdir /var/lib/alertmanager
sudo touch alertmanager.service
sudo tee -a alertmanager.service > /dev/null <<EOT
[Unit]
Description=AlertManager Server Service
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/alertmanager \
    --config.file /etc/alertmanager/alertmanager.yml \
    --storage.path /var/lib/alertmanager

[Install]
WantedBy=multi-user.target

EOT
sudo cp alertmanager.service /etc/systemd/system 




sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl enable node_exporter
sudo systemctl enable grafana-server
sudo systemctl enable alertmanager