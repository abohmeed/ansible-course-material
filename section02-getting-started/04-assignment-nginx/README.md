# Assignment: Nginx with IP restrictions (solution)

```bash
multipass delete --purge ansiblemain
multipass launch -n ansiblemain --cloud-init ../../section01-setup/ansible_multipass.yaml
multipass info ansiblemain
cp hosts.example hosts     # set the new IP
ansible-playbook -i hosts nginx.yaml
multipass shell ansiblemain
sudo systemctl status nginx
cat /etc/nginx/sites-available/default
```

Note: the solution in the video writes `ansible_connect=ssh` and `host_key_checking=false` in the inventory. The
variable is `ansible_connection` (ssh is the default anyway), and host key checking belongs in `ansible.cfg`.
