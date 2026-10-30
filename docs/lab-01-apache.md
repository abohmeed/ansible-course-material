Talk

## Deploying the Apache web server

In this lecture, we are going to deploy and configure the Apache web server. We need to install the package itself and also configure it to accept connections from specific IP addresses.

### 1. Create a new playbook

Let's create a new playbook and call it webserver.yaml. The file contents should go as follows:

```
---
- name: Deploy Apache web server with IP restrictions
  hosts: my_hosts
  become: yes
  vars:
    apache_document_root: /var/www/html
    apache_server_name: mywebsite.local
    allowed_ips:
      - 192.168.1.10
      - 192.168.1.20
      - 192.168.1.30

  tasks:
    - name: Install Apache
      ansible.builtin.apt:
        name: apache2
        state: present # do not update the package if it is already there. 'latest' will update the package even if it is there.
        update_cache: yes

    - name: Deploy Apache config template
      ansible.builtin.template:
        src: apache.conf.j2
        dest: /etc/apache2/sites-available/000-default.conf
        mode: '0644'
        owner: root
        group: root
      notify: Restart Apache

    - name: Enable Apache site configuration
      ansible.builtin.command:
        cmd: a2ensite 000-default.conf
      notify: Restart Apache

    - name: Start and enable Apache
      ansible.builtin.service:
        name: apache2
        state: started
        enabled: true

  handlers:
    - name: Restart Apache
      ansible.builtin.service:
        name: apache2
        state: restarted
```

Before we can run this playbook, we need to create the template that Ansible would use. Create a file called apache.conf.j2 and add the following:

```
ServerName {{ apache_server_name }}
DocumentRoot {{ apache_document_root }}

<Directory {{ apache_document_root }}>
    AllowOverride None
    Options Indexes FollowSymLinks
    Require all denied

    # Allow access from specified IPs
    {% for ip in allowed_ips %}
    Require ip {{ ip }}
    {% endfor %}
</Directory>
```

We can optionally avoid being asked to accept the server's SSH key. Create a new file called ansible.cfg and add the following:

```
[defaults]
host_key_checking = False
```

Run the playbook against the server:

```
ansible-playbook -i hosts webserver.yaml
```

After the playbook runs successfully, let's see what happened in the target host. We log in and see if the Apache service is running:

```
multipass shell ansiblemain
sudo systemctl status apache2
```

Let's see if the tempalte was correctly rendered:

```
cat /etc/apache2/sites-available/000-default.conf
```

The output should be as follows:

```
ServerName mywebsite.local
DocumentRoot /var/www/html

<Directory /var/www/html>
    AllowOverride None
    Options Indexes FollowSymLinks
    Require all denied

    # Allow access from specified IPs
        Require ip 192.168.1.10
        Require ip 192.168.1.20
        Require ip 192.168.1.30
    </Directory>
```

