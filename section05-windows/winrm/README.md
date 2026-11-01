# Section 5: Running Ansible against Windows machines

| Lecture | Files |
|---|---|
| Setting up a Windows host and enabling WinRM | `setup-winrm.ps1`, `test-winrm.ps1`, text: `docs/windows-winrm-setup.md` |
| Creating a Windows user with admin privileges | `inventory/`, `roles/windows_user_management`, text: `docs/windows-user-role.md` |
| Deploying an ASP.NET application | `roles/aspnet`, text: `docs/windows-aspnet-role.md` |

```bash
python3 -m venv ansible-env && source ansible-env/bin/activate
pip install ansible pywinrm
export ANSIBLE_WINRM_PASSWORD='paste_the_password'
cp inventory/hosts.example inventory/hosts       # set the hostname
ansible -i inventory/hosts winhost -m ansible.windows.win_ping
ansible-playbook -i inventory/hosts playbook.yaml
```

Open TCP 5986 (and 80 for the web app) in the security group. Browse to `http://<hostname>/sample`.
