---
title: "Installation automatique de n8n"
layout: default
---

# 🚀 Guide d'installation automatisée de n8n sur Ubuntu 24.04

Ce guide vous montre comment installer **n8n** sur un VPS Ubuntu 24.04, sans Docker, avec HTTPS, NGINX, PM2 et sécurité.

## Prérequis
- Un nom de domaine pointant vers l’IP du serveur
- Ubuntu 24.04 avec accès root
- Les ports `80`, `443`, `5678` doivent être libres

## 📥 Installation

```bash
git clone https://github.com/Adoytrade/n8n-installer.git
cd n8n-installer
chmod +x install-n8n.sh
sudo ./install-n8n.sh
```

## 🔗 Accès final

Votre n8n sera accessible à :  
`https://votre-domaine.com`
