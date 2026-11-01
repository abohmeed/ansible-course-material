# What changed in ansible-core 2.19 and 2.20 for this course

- **Course:** Ansible for DevOps automation mastery (Arabic), DevCloudLab
- **Applies to:** every lecture. Attach to "The hosts file" (Section 2).
- **Updated:** November 2026, checked against ansible-core 2.20.

<div dir="rtl" markdown="1">

**ملخص سريع بالعربي:** الكورس اتسجل على إصدار أقدم من ansible-core. الفيديوهات لسه صحيحة في الفكرة، بس فيه شوية تفاصيل اتغيرت في 2.19 و 2.20:

1. في ملف الـ hosts استخدم `ansible_ssh_private_key_file` (مش `ansible_private_key`).
2. اكتب الـ facts بالشكل ده: `ansible_facts['distribution']` بدل `ansible_distribution`.
3. جهاز التحكم (control node) محتاج Python 3.12 أو أحدث، والسيرفرات محتاجة Python 3.9 أو أحدث.
4. الشروط في `when` لازم ترجع true أو false بشكل صريح.

كل ملفات الكورس بعد التعديل موجودة في مستودع الـ lab.

</div>

## 1. Check your version

```bash
ansible --version        # look at "ansible [core 2.xx]" and "python version"
python3 --version        # control node: 3.12 or newer for ansible-core 2.20
```

If you installed with `pip install ansible` in 2026 you have ansible-core 2.20. Ubuntu 24.04's `apt install ansible` gives an older 2.16, where the videos work exactly as recorded. A virtual environment is the cleanest way to get 2.20:

```bash
sudo apt install -y python3-venv
python3 -m venv ~/ansible-env && source ~/ansible-env/bin/activate
pip install ansible
```

## 2. Python versions

| | ansible-core 2.19 | ansible-core 2.20 |
|---|---|---|
| Control node (where you run `ansible-playbook`) | Python 3.11+ | **Python 3.12+** |
| Managed hosts (the Multipass VMs) | Python 3.8+ | **Python 3.9+** |

Ubuntu 24.04 ships Python 3.12, so the course VMs are fine both as control node and as targets. On macOS, use Homebrew Python 3.12+ or `pipx install ansible`.

## 3. Inventory: the SSH key variable (lecture "The hosts file")

This is the change that affects students most.

| Variable | What it means | Use it? |
|---|---|---|
| `ansible_ssh_private_key_file` | **Path** to the private key file | **Yes, recommended** |
| `ansible_private_key_file` | Same thing, generic name | Yes |
| `ansible_private_key` / `ansible_ssh_private_key` | **New in 2.19:** the key **contents** (the text of the key), loaded into ssh-agent | No, not for this course |

If you write a **path** into `ansible_private_key`, ansible-core 2.19+ treats it as key contents and fails with:

```
Failed to authenticate: Failed to add configured private key into ssh-agent: Cannot utilize private_key with SSH_AGENT disabled
```

Fix: rename the variable to `ansible_ssh_private_key_file`.

```ini
[my_hosts:vars]
ansible_connection=ssh
ansible_user=ansibleadmin
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

Two related clean-ups used in the lab repo:

- The connection variable is `ansible_connection=ssh` (not `ansible_connect`). Ansible silently ignores unknown variables, so a typo here doesn't raise an error, but it does nothing.
- `host_key_checking` is an `ansible.cfg` setting (`[defaults] host_key_checking = False`). It isn't an inventory variable.

## 4. Facts: use `ansible_facts['...']`

The videos use injected fact variables such as `ansible_distribution`, `ansible_nodename` and `ansible_distribution_release`. In 2.20 this style is **deprecated** (setting `INJECT_FACTS_AS_VARS`), and its default is scheduled to switch off in ansible-core 2.24. It still works today but prints a deprecation warning. The future-proof form is:

| Video | Write this instead |
|---|---|
| `{{ ansible_nodename }}` | `{{ ansible_facts['nodename'] }}` |
| `{{ ansible_distribution }}` | `{{ ansible_facts['distribution'] }}` |
| `{{ ansible_distribution_version }}` | `{{ ansible_facts['distribution_version'] }}` |
| `{{ ansible_distribution_release }}` | `{{ ansible_facts['distribution_release'] }}` |
| `{{ ansible_os_family }}` | `{{ ansible_facts['os_family'] }}` |

Connection variables such as `ansible_host`, `ansible_user` and `inventory_hostname` aren't facts and don't change.

## 5. Templating and conditionals (2.19 overhaul)

ansible-core 2.19 rewrote the templating engine. The changes you may notice in the labs:

- **Conditionals must be real booleans.** If `deploy_custom_page: "false"` is a *string* (quoted, or passed with `-e deploy_custom_page=false`), `when: deploy_custom_page` now fails with:
  `Conditional result (True) was derived from value of type 'str' ... Conditionals must have a boolean result.`
  The "(True)" is the trap: a non-empty string is truthy, so older versions silently ran the task. Write `when: deploy_custom_page | bool`, or use a real YAML `true`/`false`. (A temporary escape hatch is `ALLOW_BROKEN_CONDITIONALS=True`.)
- **Template syntax errors are caught.** An unclosed comment such as `{# templates/App.js.j2}` (no closing `#}`) now fails with "Missing end of comment tag". The lab repo's `App.js.j2` is fixed.
- **No more "double templating".** A variable whose value contains `{{ ... }}` from an untrusted source isn't rendered a second time. None of the course labs depend on this.
- **Better error messages** show the file, line and column. Read them, because they usually point straight at the problem.

## 6. Other changes you may hit

| Area | Change | What to do |
|---|---|---|
| Module names | Short names (`apt`, `copy`) still work | The lab repo uses FQCNs (`ansible.builtin.apt`, `community.mongodb.mongodb_user`) so ansible-lint is happy |
| Collections | `pip install ansible-core` alone has no `community.*` collections | `ansible-galaxy collection install -r requirements.yml` in each lab folder |
| Galaxy | The v2 Galaxy API was removed in 2.20. The instructor's demo role was deleted from Galaxy after the lecture | Publish your own role, or install from GitHub (see `section03-roles/apache-playbook/requirements.yml`) |
| `include_vars` | `extensions` and `ignore_files` must be lists | Not used in the labs |
| Transport | `DEFAULT_TRANSPORT=smart` was removed | Use `ssh` (the default) |
| Windows | PowerShell no longer strips quotes from module arguments | Quote `win_shell` and `win_command` arguments the way PowerShell expects |
| `become` | A become timeout now reports the host as **unreachable** instead of failed | Nothing to change |
| `bool` filter | Passing values that aren't real booleans or yes/no strings is deprecated | Keep values to `true`/`false`/`yes`/`no` |

## 7. Changes outside Ansible that affect the MERN and LAMP projects

- **create-react-app** was deprecated by the React team in 2025. `npx create-react-app` still works but prints warnings. The lab keeps it so it matches the video. For new projects, use Vite (`npm create vite@latest`).
- **MongoDB 8.0** on Ubuntu 24.04: the repo uses `ansible.builtin.deb822_repository` and the `mongosh` shell (`~/.mongoshrc.js`, not the old `~/.mongorc.js`).
- **MySQL** (LAMP assignment): Ubuntu 24.04 ships MySQL 8.0, where the lab's `IDENTIFIED WITH mysql_native_password` still works. MySQL 8.4 and later disable that plugin by default. There, drop `WITH mysql_native_password` and keep the default `caching_sha2_password`.

## 8. Where are the corrected files?

The lab repo has every playbook, role, template and web asset from Sections 1 to 6, updated for ansible-core 2.20. It also includes `App.css` for "Creating the web server 01". The `README.md` maps each folder to its lecture and lists every fix made compared with the videos.
