# Lab: Deploy and configure the Apache web server (01 and 02)

```bash
cp hosts.example hosts     # set your VM IP
ansible-playbook -i hosts webserver.yaml
multipass shell ansiblemain
sudo systemctl status apache2
cat /etc/apache2/sites-available/000-default.conf
```

Full lab text: `docs/lab-01-apache.md`.
