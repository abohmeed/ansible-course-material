# Section 4: Real-world project, deploying the MERN stack

| Lecture | Files |
|---|---|
| Installing the common packages 01, 02 | `inventory/`, `group_vars/all.yaml`, `roles/common`, `playbook.yaml` (first play) |
| Creating the web server 01, 02 | `group_vars/webservers.yaml`, `roles/webserver` (**`files/App.css`**, `templates/App.js.j2`) |
| Creating the database role 01, 02, 03 | `roles/dbserver`, `playbook.yaml` (third play). Full text: `docs/mern-database-role.md` |

```bash
multipass launch -n webserver01 --cloud-init ../../section01-setup/ansible_multipass.yaml --cpus 4 --memory 4G --disk 10G
multipass launch -n dbserver01  --cloud-init ../../section01-setup/ansible_multipass.yaml --disk 10G
multipass list
cp inventory/hosts.example inventory/hosts     # paste both IPs
ansible-galaxy collection install -r requirements.yml   # only if you installed ansible-core without the full "ansible" package
ansible-playbook -i inventory/hosts playbook.yaml
```

React page: `ssh -fN -L 0.0.0.0:3000:localhost:3000 ansibleadmin@<webserver_ip>` then open http://localhost:3000.
Set `deploy_custom_page: true` in `group_vars/webservers.yaml` and run again to get the custom page.

Notes for 2026:
- `create-react-app` was deprecated by the React team in 2025. It still installs and runs for this lab (with a
  warning). For new projects use Vite (`npm create vite@latest`).
- The video's template starts with `{# templates/App.js.j2}`, an unclosed Jinja comment that breaks rendering. The
  file here has no comment line.
- The dbserver role checks `/root/.mongoshrc.js` (the video checks `.mongorc.js`), so a second run does not fail.
- Facts are read as `ansible_facts['distribution_release']` (injected `ansible_*` facts are deprecated in 2.20).
