# Ansible for DevOps automation mastery (Arabic): lab files

Companion files for the Udemy course by Ahmed Elfakharany (DevCloudLab). Rebuilt in 2026-11 from the resources attached to the lectures.

| Folder or file | Lecture |
|---|---|
| lab-01-apache | Lab: Deploy and configure the Apache web server (playbook, template, ansible.cfg) |
| docs/lab-01-apache.md | The full text of that lab |
| docs/mern-database-role.md | MERN project: the database role |
| docs/windows-winrm-setup.md | Setting up a Windows host and enabling WinRM |
| docs/windows-user-role.md | Creating a Windows user with admin privileges |
| docs/windows-aspnet-role.md | Deploying an ASP.NET application |
| docs/vault.md | Encrypting files and values with Ansible Vault |

Notes for current ansible-core (2.20): the control machine needs Python 3.12 or newer, targets Python 3.9 or newer. Use ansible_ssh_private_key_file in the inventory (see lab-01-apache/hosts.example). The labs have not been re-run on 2.20 yet.

No secrets are stored here. Passwords shown in the lab text (for example mongodb_root_password: password) are throwaway lab values; replace them, and use Ansible Vault as in the last lecture.
