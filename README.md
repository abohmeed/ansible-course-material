# Ansible for DevOps automation mastery (Arabic): lab files

These are the companion files for the Udemy course **Ansible for DevOps automation mastery (Arabic)** by Ahmed Elfakharany (DevCloudLab). The repo has every playbook, role, template and web asset shown in the six published sections. The files are updated for **ansible-core 2.20** (November 2026).

<div dir="rtl" markdown="1">

**بالعربي:** هنا كل ملفات الكورس (الـ playbooks والـ roles والـ templates والملفات زي `App.css`) مرتبة حسب السكاشن، ومتعدلة عشان تشتغل على ansible-core 2.20. لو حاجة في الفيديو مختلفة عن الملفات هنا، اقرا `CHANGES.md` و `docs/ansible-core-2.19-2.20-changes.md`.

</div>

## ansible-core 2.20 note

The videos were recorded on an older ansible-core. These files are updated for **ansible-core 2.20**, which needs **Python 3.12+ on the control node** (Ubuntu 24.04 has it). The change students hit most often is in the inventory: use `ansible_ssh_private_key_file=~/.ssh/id_rsa`, not `ansible_private_key` (since 2.19 that variable means the key *contents*, and a path there fails with `Cannot utilize private_key with SSH_AGENT disabled`). Details: [docs/ansible-core-2.19-2.20-changes.md](docs/ansible-core-2.19-2.20-changes.md). What differs from the videos: [CHANGES.md](CHANGES.md).

## Quick start

### 1. Install Ansible on your machine

```bash
python3 -m venv ~/ansible-env && source ~/ansible-env/bin/activate
pip install ansible
ansible --version            # should show ansible-core 2.20.x
```

### 2. Create the lab VM with Multipass

```bash
sudo snap install multipass                  # macOS: brew install --cask multipass
ssh-keygen                                   # only if you have no key yet
cat ~/.ssh/id_rsa.pub                        # paste it into section01-setup/ansible_multipass.yaml
multipass launch -n ansiblemain --cloud-init section01-setup/ansible_multipass.yaml
multipass info ansiblemain                   # note the IPv4 address
ssh -i ~/.ssh/id_rsa ansibleadmin@<vm_ip>    # check you can log in
```

Launch more VMs the same way (change `-n`) when a lab needs several hosts. Full steps: [section01-setup/README.md](section01-setup/README.md).

### 3. Run a lab

In each lab folder:

```bash
cp hosts.example hosts                       # or inventory/hosts.example -> inventory/hosts; put your VM IPs in it
ansible -i hosts all -m ansible.builtin.ping # check the connection first
ansible-galaxy collection install -r requirements.yml   # where the folder has one
ansible-playbook -i hosts playbook.yaml      # file name per folder, see the README there
```

<div dir="rtl" markdown="1">

**بالعربي:** نزّل Ansible، اعمل VM بـ Multipass باستخدام `section01-setup/ansible_multipass.yaml` بعد ما تحط فيه الـ public key بتاعك، وبعدين في كل فولدر انسخ `hosts.example` لـ `hosts` وحط IP الـ VM. استخدم `ansible_ssh_private_key_file` مش `ansible_private_key`.

</div>

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

### Where is App.css?

The stylesheet for the React app in **Creating the web server 01** is at
[`section04-mern/mernstack/roles/webserver/files/App.css`](section04-mern/mernstack/roles/webserver/files/App.css). The webserver role copies it into the app's `src/` folder. A copy is also in `upload/creating-the-web-server-01/App.css`.

`upload/` holds copies of the files attached to the Udemy lectures (for example the hosts-file notes and the ansible-core handout as PDF in `upload/the-hosts-file/`). Students can ignore it.

## Checked with

- ansible-core 2.20.10 (Python 3.13): `ansible-playbook --syntax-check` passes for every playbook
- ansible-lint 26.10: no findings with the repo's `.ansible-lint`, which skips only naming and style rules so that names stay as typed in the videos
- Every Jinja template rendered locally (Apache, Nginx, `App.js.j2`, `mongod.conf.j2`, `.mongoshrc.js`)

The labs were recorded on Ubuntu 24.04 Multipass VMs and Windows Server with WinRM. Run them there.

## Secrets

No real secrets are stored here. `hosts`, `inventory/hosts`, `vault_password.txt` and generated password files are git-ignored. Lab passwords such as `mongodb_root_password` are placeholders. Put real values in Ansible Vault (Section 6) or pass them with `-e`. The Windows inventory reads the password from the `ANSIBLE_WINRM_PASSWORD` environment variable.

## License

The files in this repo are under the [MIT License](LICENSE). The course videos and the Udemy course itself are not covered by this license.
