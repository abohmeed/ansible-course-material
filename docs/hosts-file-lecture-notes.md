# Lecture notes: The hosts file (Section 2)

Corrected notes for the lecture "The hosts file". Part A is meant to be pasted into the lecture description on Udemy. Part B is the full text, attached as a resource with the ansible-core handout.

---

## Part A: text for the lecture description (paste as is)

<div dir="rtl" markdown="1">

**تصحيح مهم (نوفمبر 2026):** لو بتستخدم ansible-core 2.19 أو أحدث، اكتب اسم المتغير بتاع مفتاح الـ SSH كده:

`ansible_ssh_private_key_file=~/.ssh/id_rsa`

ومتستخدمش `ansible_private_key`. من أول 2.19 المتغير ده بقى معناه **محتوى** المفتاح نفسه مش مسار الملف، فلو كتبت فيه المسار هيظهر لك الخطأ:
`Cannot utilize private_key with SSH_AGENT disabled`

وكمان اسم متغير الاتصال هو `ansible_connection=ssh`.
ملف hosts كامل ومصحح، وملف "إيه اللي اتغير في ansible-core 2.19 و 2.20"، موجودين في الـ Resources بتاعة المحاضرة دي.

</div>

**Correction (Nov 2026):** on ansible-core 2.19 or newer, set the key path with `ansible_ssh_private_key_file=~/.ssh/id_rsa`. Don't use `ansible_private_key`: since 2.19 that variable holds the key *contents*, not a path, so a path there fails with "Cannot utilize private_key with SSH_AGENT disabled". The connection variable is `ansible_connection=ssh`. A corrected hosts file and the "What changed in ansible-core 2.19 and 2.20" handout are in this lecture's resources.

---

## Part B: full notes

### What the hosts (inventory) file does

The inventory tells Ansible **which machines** to manage and **how to connect** to them. In the course it is a plain INI file called `hosts`, and we pass it with `-i hosts`.

### Step 1: get the VM's IP

```bash
multipass list
multipass info ansiblemain      # the IPv4 line
```

### Step 2: one host with everything on one line

```ini
ansiblemain ansible_host=10.173.4.156 ansible_user=ansibleadmin ansible_ssh_private_key_file=~/.ssh/id_rsa
```

| Variable | Meaning |
|---|---|
| `ansiblemain` | The name Ansible uses for this host (any name you like) |
| `ansible_host` | IP or DNS name to connect to |
| `ansible_user` | SSH user (created by cloud-init in `ansible_multipass.yaml`) |
| `ansible_ssh_private_key_file` | **Path** to the private key that matches the public key in cloud-init |

### Step 3: group the hosts and share the variables

```ini
ansiblemain ansible_host=10.173.4.156

[my_hosts]
ansiblemain

[my_hosts:vars]
ansible_connection=ssh
ansible_user=ansibleadmin
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Step 4: test

```bash
ansible -i hosts my_hosts -m ansible.builtin.ping
ansible -i hosts ansiblemain -m ansible.builtin.setup
```

### Corrections compared with the video

| In the video or old notes | Correct | Why |
|---|---|---|
| `ansible_private_key=...` | `ansible_ssh_private_key_file=...` | In 2.19+, `ansible_private_key` means key **contents**. Error: `Cannot utilize private_key with SSH_AGENT disabled` |
| `ansible_connect=ssh` | `ansible_connection=ssh` | Typo. Ansible ignores unknown variables, so it silently did nothing (ssh is the default anyway) |
| `host_key_checking=False` in the inventory | `host_key_checking = False` under `[defaults]` in `ansible.cfg` | It's a config setting, not an inventory variable |
| `ansible_distribution` in playbooks | `ansible_facts['distribution']` | Injected facts are deprecated in 2.20 |

### Common errors

| Error | Cause | Fix |
|---|---|---|
| `Cannot utilize private_key with SSH_AGENT disabled` | Path put in `ansible_private_key` | Rename to `ansible_ssh_private_key_file` |
| `Permission denied (publickey)` | Wrong key, or wrong `ansible_user` | Check the public key in `ansible_multipass.yaml` matches the private key path |
| `Host key verification failed` | VM recreated with the same IP | `ssh-keygen -R <ip>`, or `host_key_checking = False` in `ansible.cfg` for labs |
| `UNREACHABLE ... timed out` | Wrong IP, or the VM is stopped | `multipass list`, then `multipass start ansiblemain` |

Files: `section02-getting-started/01-hosts-file/` in the lab repo.
