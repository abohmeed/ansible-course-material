# Creating a Windows user with admin privileges (Section 5)

> Lecture text as attached on Udemy. The runnable, corrected files are in `section05-windows/winrm/roles/windows_user_management/`; they are updated for ansible-core 2.20 (for example `ansible_facts['distribution']` instead of `ansible_distribution`). See `../CHANGES.md`.

### Create a directory for our projects

```
mkdir winrm
cd winrm
```

### Create the inventory file

Export the Windows login password to an environment variable in case we need it:

```
export ANSIBLE_WINRM_PASSWORD='paste_the_password'
```

```
# inventory/hosts
winhost ansible_host=paste_the_hostname ansible_user=Administrator paste_your_windows_password  ansible_winrm_server_cert_validation=ignore ansible_connection=winrm ansible_winrm_transport=ntlm
```

### Create a new Ansible Galaxy role

```
ansible-galaxy init roles/windows_user_management
```

### The variables

```
# roles/windows_user_management/defaults/main.yml
# defaults file for roles/windows_user_management
# defaults/main.yml
generated_password: "{{ lookup('password', 'group_vars/generated_password chars=ascii_letters,digits length=30') }}"
user_name: ahmed
user_groups:
  - Users
  - Administrators
```

### The tasks file

x

```
---
# tasks file for roles/windows_user_management
# tasks/main.yml
- name: Create a user with an auto-generated password
  ansible.windows.win_user:
    name: "{{ user_name }}"
    password: "{{ generated_password }}"
    password_never_expires: yes
    user_cannot_change_password: no
    groups: "{{ user_groups }}"
    state: present

- name: Display the generated password (for testing purposes)
  debug:
    msg: "The password for {{ user_name }} is {{ generated_password }}"
```

### The Playbook

```
# playbook.yaml
- name: Manage Windows user
  hosts: winhost
  roles:
    - windows_user_management
```

### Running the playbook

We need to run this playbook within a virtual environment since Ansible needs the PyWinRM module.

```
python3 -m venv ansible-env
source ansible-env/bin/activate
pip install pywinrm
export PATH=ansible-env/bin:$PATH
ansible-playbook -i inventory/hosts playbook.yaml
```

### Validation

The output should show the password that was created for the user.

We can try running the playbook again to make sure that the password does NOT change from one run to the next.

We can use RDP and try logging in with ahmed and the generated password.

Inside the Windows session, we can open the terminal "As Administrator" to confirm that the account enjoys administrative privileges.

### A more secure way for storing the generated password

Modify the tasks file so that the password is stored in a local file instead of getting displayed to the screen:

```
# tasks file for roles/windows_user_management
# tasks/main.yml
- name: Create a user with an auto-generated password
  ansible.windows.win_user:
    name: "{{ user_name }}"
    password: "{{ generated_password }}"
    password_never_expires: yes
    user_cannot_change_password: no
    groups: "{{ user_groups }}"
    state: present
# Remove the existing task and replace with the following
- name: Save the password to a secure file locally
  copy:
    content: "{{ generated_password }}"
    dest: "{{ inventory_hostname }}.txt"
    mode: '0600'
  delegate_to: localhost
```

