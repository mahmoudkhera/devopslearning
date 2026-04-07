#!/bin/bash
    #!/bin/bash
apt-get update -y
apt-get install -y nginx

# Create a simple web page
cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html>
    <head>
    <title>Frontend</title>
    <style>
        body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f4f3ef; }
        .box { text-align: center; background: white; padding: 2rem 3rem; border-radius: 12px; border: 1px solid #eee; }
        h1 { color: #1D9E75; }
        p  { color: #888; font-size: 14px; }
    </style>
    </head>
    <body>
    <div class="box">
        <h1>Hello from Frontend</h1>
        <p>Instance: $(hostname)</p>
        <p>Environment: ${env}</p>
    </div>
    </body>
</html>
HTML

# Start nginx
systemctl enable nginx
systemctl start nginx

