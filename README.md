# Ansible for DevOps automation mastery (Arabic): lab files

These are the companion files for the Udemy course **Ansible for DevOps automation mastery (Arabic)** by Ahmed Elfakharany (DevCloudLab). The repo has every playbook, role, template and web asset shown in the six published sections. The files are updated for **ansible-core 2.20** (November 2026).

<div dir="rtl" markdown="1">

**بالعربي:** هنا كل ملفات الكورس (الـ playbooks والـ roles والـ templates والملفات زي `App.css`) مرتبة حسب السكاشن، ومتعدلة عشان تشتغل على ansible-core 2.20. لو حاجة في الفيديو مختلفة عن الملفات هنا، اقرا `CHANGES.md` و `docs/ansible-core-2.19-2.20-changes.md`.

</div>

## Before you start

```bash
python3 -m venv ~/ansible-env && source ~/ansible-env/bin/activate
pip install ansible            # ansible-core 2.20 needs Python 3.12+ on the control node
ansible --version
```

In each lab folder:

```bash
cp hosts.example hosts                       # or inventory/hosts.example -> inventory/hosts; put your VM IPs in it
ansible-galaxy collection install -r requirements.yml   # where the folder has one
ansible-playbook -i hosts playbook.yaml      # file name per folder, see the README there
```

What changed in Ansible since the recording: **[docs/ansible-core-2.19-2.20-changes.md](docs/ansible-core-2.19-2.20-changes.md)**. What changed in these files compared with the videos: **[CHANGES.md](CHANGES.md)**.

## Curriculum map

| Section | Lecture | Folder |
|---|---|---|
| 1 Introduction | Ansible installation, Multipass installation | `section01-setup/` (`ansible_multipass.yaml` cloud-init) |
| 2 Getting started | The hosts file | `section02-getting-started/01-hosts-file/` and [lecture notes](docs/hosts-file-lecture-notes.md) |
| | Our first Ansible playbook | `section02-getting-started/02-first-playbook/` |
| | Lab: Deploy and configure the Apache web server 01 and 02 | `section02-getting-started/03-lab-apache/` ([lab text](docs/lab-01-apache.md)) |
| | Assignment: Deploy and configure the Nginx web server | `section02-getting-started/04-assignment-nginx/` |
| 3 Ansible Galaxy | Creating your own Ansible role | `section03-roles/apache-playbook/roles/apache-deployment-role/` |
| | Publishing and downloading roles from Ansible Galaxy | `section03-roles/apache-playbook/` (`playbook-galaxy.yaml`, `requirements.yml`) |
| | Assignment: Create a role for installing and configuring Nginx | `section03-roles/nginx-assignment/` |
| 4 MERN project | Installing the common packages 01 and 02 | `section04-mern/mernstack/roles/common/` |
| | Creating the web server 01 and 02 | `section04-mern/mernstack/roles/webserver/` (includes **`files/App.css`**) |
| | Creating the database role 01 and 02 | `section04-mern/mernstack/roles/dbserver/` ([lecture text](docs/mern-database-role.md)) |
| | Assignment: LAMP stack | `section04-mern/lampstack/` |
| 5 Windows | Setting up a Windows host and WinRM | `section05-windows/winrm/setup-winrm.ps1` ([text](docs/windows-winrm-setup.md)) |
| | Creating a Windows user with admin privileges | `section05-windows/winrm/roles/windows_user_management/` ([text](docs/windows-user-role.md)) |
| | Deploying an ASP.NET application | `section05-windows/winrm/roles/aspnet/` ([text](docs/windows-aspnet-role.md)) |
| 6 Ansible Vault | Encrypting files and values | `section06-vault/` ([text](docs/vault.md)) |

`upload/` holds copies of the files attached to the Udemy lectures. Students can ignore it.

## Checked with

- ansible-core 2.20.10 (Python 3.13): `ansible-playbook --syntax-check` passes for every playbook
- ansible-lint 26.10: no findings with the repo's `.ansible-lint`, which skips only naming and style rules so that names stay as typed in the videos
- Every Jinja template rendered locally (Apache, Nginx, `App.js.j2`, `mongod.conf.j2`, `.mongoshrc.js`)

The labs were recorded on Ubuntu 24.04 Multipass VMs and Windows Server with WinRM. Run them there.

## Secrets

No real secrets are stored here. `hosts`, `inventory/hosts`, `vault_password.txt` and generated password files are git-ignored. Lab passwords such as `mongodb_root_password` are placeholders. Put real values in Ansible Vault (Section 6) or pass them with `-e`. The Windows inventory reads the password from the `ANSIBLE_WINRM_PASSWORD` environment variable.
