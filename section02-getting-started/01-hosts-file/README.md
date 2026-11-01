# The hosts file

```bash
cp hosts.example hosts         # then put your VM IP in it
ansible --version
ansible -i hosts ansiblemain -m ansible.builtin.setup
ansible -i hosts my_hosts -m ansible.builtin.setup
ansible -i hosts my_hosts -m ansible.builtin.ping
```

Corrected lecture notes: `docs/hosts-file-lecture-notes.md`.
