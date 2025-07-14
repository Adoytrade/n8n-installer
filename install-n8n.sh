#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

read -rp "👉 Entrez l'adresse IP publique du serveur : " SERVER_IP
read -rp "👉 Entrez le nom de domaine à utiliser pour n8n (ex. n8n.example.com) : " DOMAIN

echo -e "\n📋 Récapitulatif :"
echo "   • IP du serveur     : $SERVER_IP"
echo "   • Nom de domaine    : $DOMAIN"
read -rp $'\nAppuyez sur Entrée pour continuer ou Ctrl+C pour annuler…'

apt update && apt upgrade -y
apt install -y curl gnupg
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
apt install -y nodejs
npm install -g npm@latest

npm install -g n8n
npm install -g pm2
pm2 start n8n
pm2 startup systemd -u "$USER" --hp "$HOME"
pm2 save

apt install -y nginx
systemctl enable --now nginx
apt install -y certbot python3-certbot-nginx
certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "admin@$DOMAIN" --redirect

NGINX_CONF="/etc/nginx/sites-available/n8n"
cat > "$NGINX_CONF" <<EOF
server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}
EOF

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/n8n
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo -e "\n✅ Installation terminée !"
echo "   • Accès sécurisé : https://$DOMAIN"
echo "   • PM2 gère le service n8n (pm2 status)"
echo "   • Certificat Let’s Encrypt auto-renouvelé (cron Certbot)"
