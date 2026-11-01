# Assignment: Create and configure the LAMP stack (solution)

```bash
multipass launch -n webserver01 --cloud-init ../../section01-setup/ansible_multipass.yaml
multipass launch -n dbserver01  --cloud-init ../../section01-setup/ansible_multipass.yaml
cp inventory/hosts.example inventory/hosts
ansible-playbook -i inventory/hosts playbook.yaml
ssh -fN -L 0.0.0.0:8080:localhost:80 ansibleadmin@<webserver_ip>   # then http://localhost:8080/phpinfo.php
multipass shell dbserver01
mysql        # Access denied (no ~/.my.cnf for this user)
sudo mysql   # works (root has ~/.my.cnf)
```

This folder is also the starting point for Section 6 (Ansible Vault).
