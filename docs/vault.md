work

We have two ways by which we can encrypt values using Ansible Vault:

Entire files

Specific values

### Encrypting entire files

Let's revisit the LAMP stack that we've used in a previous assignment. If you notice, we have the DB credentials stored in roles/dbserver/defaults/main.yml

We can encrypt this file using Ansible Vault as follows:

```
ansible-vault encrypt roles/dbserver/defaults/main.yml
```

It will ask you for a password, enter it twice for confirmation.

Now, if we view the file contents, we'd see that they are no longer in plain text:

```
cat roles/dbserver/defaults/main.yml
```

The more interesting part is that you don't need to decrypt the file before using it with Ansible. Let's repeat the operation:

```
# Ensure that we have the DB server for the LAMP stack available
multipass list
# Run the Ansible playbook as is
ansible-playbook  -i inventory/hosts playbook.yaml
ERROR! Attempting to decrypt but no vault secrets found
```

We need to give the password to Ansible so that it can decrypt the Secret:

```
ansible-playbook  -i inventory/hosts playbook.yaml --ask-vault-pass
```

Now, if we give the password, the playbook would run as expected.

#### Viewing the file

We can view the file contents by running:

```
ansible-vault view roles/dbserver/defaults/main.yml
# Enter the password
```

#### Decrypting the file

If you want to restore the file to the original state, you can run:

```
ansible-vault decrypt roles/dbserver/defaults/main.yml
# Enter the password
```

### Encrypting specific values

Sometimes, you want to encrypt only a single value rather than an entire file. In this case, we can use Ansible Vault as follows:

Get the value that you want to encrypt, for example, cat roles/dbserver/defaults/main.yml. Let's say we want to encrypt only the mysql_root_password.

We run the following command:

```
ansible-vault encrypt_string 'secure_root_password' --name 'mysql_root_password'
```

We copy the output of the command and replace the line that contains the variable.

This way, we can run Ansible with the --ask-vault-pass without having to encrypt the entire file.

### Saving the password to a file

In many cases, we want to run Ansible in an unattended mode like in CI/CD pipelines. There will be no human operator to enter the password when the playbook runs. We can use a file to save the Vault password. Obviously, we must ensure that the file is secured:

```
echo "my_vault_password" > vault_password.txt
chmod 600 vault_password.txt
# We can use this file in all the operations that require a password (encryption, decryption, viewing, and running the playbook)
ansible-vault encrypt secrets.yml --vault-password-file vault_password.txt
ansible-playbook playbook.yml --vault-password-file vault_password.txt
```

In a CI/CD pipeline, you can store the password in an environment variable and save it to a temporary file then use this file while running the playbook.

