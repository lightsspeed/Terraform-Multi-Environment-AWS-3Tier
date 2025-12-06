#!/bin/bash
set -e

# Update system
yum update -y

# Install nginx directly (no Docker)
amazon-linux-extras install -y nginx1
systemctl start nginx
systemctl enable nginx

# Create application directory
mkdir -p /usr/share/nginx/html

# Create a simple application
cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>${environment} Environment</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 3em; margin: 0; }
        p { font-size: 1.5em; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to ${environment}</h1>
        <p>3-Tier Architecture Demo</p>
        <p>Server: $(hostname)</p>
        <p>Instance ID: $(ec2-metadata --instance-id | cut -d " " -f 2)</p>
    </div>
</body>
</html>
EOF

# Create health check endpoint
cat > /usr/share/nginx/html/health <<'EOF'
OK
EOF

# Create health.html for health checks
cat > /usr/share/nginx/html/health.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Health Check</title></head>
<body>OK</body>
</html>
EOF

# Configure nginx to listen on port 80
cat > /etc/nginx/conf.d/app.conf <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Remove default nginx config
rm -f /etc/nginx/nginx.conf.default

# Restart nginx
systemctl restart nginx

# Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch Agent (basic configuration)
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'EOF'
{
  "metrics": {
    "namespace": "CustomApp/${environment}",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"}
        ],
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "rename": "DISK_USED", "unit": "Percent"}
        ],
        "resources": ["*"]
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "MEM_USED", "unit": "Percent"}
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

echo "User data script completed successfully at $(date)" >> /var/log/user-data.log