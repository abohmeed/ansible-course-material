# Section 3: Ansible roles and Ansible Galaxy

```bash
# Create the skeleton yourself (this folder already contains the finished role)
ansible-galaxy role init roles/apache-deployment-role

cp hosts.example hosts
ansible-playbook -i hosts playbook.yaml

# Galaxy (the instructor's role was removed from Galaxy at the end of the lecture;
# publish your own, or install it from GitHub through requirements.yml)
ansible-galaxy role install <your_github_user>.apache-example-role
ansible-galaxy install -r requirements.yml
ansible-playbook -i hosts playbook-galaxy.yaml
ansible-galaxy role remove abohmeed.apache-example-role
```

Deleting a role from Galaxy needs your own API token (Galaxy UI > API token):

```bash
ansible-galaxy role delete <github_user> <repo_name> --token <YOUR_TOKEN>
```

Never commit or share the token.
