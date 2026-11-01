# Section 6: Ansible Vault

Uses the LAMP assignment in `section04-mern/lampstack`. Full lecture text: `docs/vault.md`.

```bash
cd ../section04-mern/lampstack

# Encrypt a whole file, run with the password, view, decrypt
ansible-vault encrypt roles/dbserver/defaults/main.yml
ansible-playbook -i inventory/hosts playbook.yaml --ask-vault-pass
ansible-vault view roles/dbserver/defaults/main.yml
ansible-vault decrypt roles/dbserver/defaults/main.yml

# Encrypt one value and paste the output in place of the plain variable
ansible-vault encrypt_string 'secure_root_password' --name 'mysql_root_password'

# Unattended runs (CI/CD): a password file that is never committed
echo "my_vault_password" > vault_password.txt
chmod 600 vault_password.txt
ansible-playbook -i inventory/hosts playbook.yaml --vault-password-file vault_password.txt
```

Without the password Ansible stops with: `Attempting to decrypt but no vault secrets found`.
`vault_password.txt` is listed in `.gitignore`.
