# Option B audit: labs vs current ansible-core

Read-only check of this repo (student lab files for Udemy course **6262369**, Ansible for DevOps automation mastery, Arabic). No playbook or role was edited. Section 7 (cloud) is not in the repo and is not on the published course (6 sections). Out of scope.

**Recommendation:** do not retake the course for ansible-core compatibility. Every playbook `--syntax-check`s on current ansible-core once its collections (and, for the Galaxy play, its roles) are installed. ansible-lint is clean with the repo's `.ansible-lint`. The hard failures are in what the videos and some lecture attachments still show. One of those, the hosts-file SSH variable, already has a correction on the live lecture description. The two web-server lectures do not, and they hard-fail if a student types what the recording shows.

## Versions (2026-11-05)

| Install | What you get | Python | Used for |
|---|---|---|---|
| `pip install ansible` (what the course tells students to run) | **ansible 14.6.0**, which depends on **ansible-core 2.21.6** | `>=3.12` (this VM: 3.12.3) | Comparison pass |
| Current stable **ansible-core** | **2.22.0** (released 2026-11-02) | **`>=3.13`** (installed 3.13.18 for this audit) | Primary pass |
| ansible-lint | **26.11.0** (with ansible-core 2.22.0, no `--fix`) | same venv as 2.22 | Lint |

`ansible-core==2.22.0` does not install on Ubuntu 24.04's Python 3.12:

```text
Because the current Python version (3.12.3) does not satisfy Python>=3.13
and ansible-core==2.22.0 depends on Python>=3.13
```

ansible 15 (the package that will track 2.22) was still a beta (`15.0.0b1`) on this date. The README and the course page still say `pip install ansible` yields ansible-core 2.20 and that the control node needs Python 3.12. The command still works. It now yields **2.21.6**, not 2.20. Bare `pip install ansible-core` on Ubuntu 24.04 does not.

`INJECT_FACTS_AS_VARS` still defaults to `True` on both 2.21.6 and 2.22.0. The deprecation warning says the default flips in **2.24**. `SSH_AGENT` still defaults to `none`.

## How to read the table

| Status | Meaning |
|---|---|
| OK | Runnable files pass, and typing the lecture does not hit a 2.19+ hard error. |
| notes-only | The video or the attached text is wrong, and a short note (or the file already in this repo) is enough. |
| retake recommended | Typing the recording hard-fails on 2.21/2.22, and that lecture's public description has no correction. |
| cannot verify | Needs a Windows host or a live WinRM login. Syntax was still checked. |

Durations are from the public curriculum (course last updated 10/2026): **24 lectures, 6h 36m**. Three assignments have no duration. Quizzes are not counted.

## Lecture / lab table

| Lecture / lab | Status | Reason | Suggested fix |
|---|---|---|---|
| What is Ansible? (16:44) | OK | Conceptual. No playbook. | None. |
| How Ansible differs from other tools (15:56) | OK | Conceptual. | None. |
| Ansible installation (6:35). `section01-setup/README.md` | notes-only | `pip install ansible` still works and gives core **2.21.6** on Python 3.12. The spoken/README version "2.20" is stale. Latest ansible-core **2.22.0 needs Python 3.13**, which Ubuntu 24.04 does not have. | Keep teaching `pip install ansible` in a venv. Say 2.21.x, not 2.20. Do not tell students to pip-install latest ansible-core on Ubuntu 24.04. |
| Multipass installation (11:14). `section01-setup/ansible_multipass.yaml` | notes-only | Cloud-init is valid. The video's `~/.ssh/.id_rsa` and `known_keys` are typos (`id_rsa`, `authorized_keys`). The placeholder public key will not SSH until the student pastes their own. Not launched here (no Multipass). | Keep the path correction already in `section01-setup/README.md`. |
| The hosts file (16:00). `section02-getting-started/01-hosts-file/` | notes-only | Video variable hard-fails. Reproduced on 2.22.0 and 2.21.6 with a path in `ansible_private_key`: `Failed to authenticate: Failed to add configured private key into ssh-agent: Cannot utilize private_key with SSH_AGENT disabled`. The same key in `ansible_ssh_private_key_file` gets past that check (this VM then failed with `Connection refused` on port 22, which is the SSH client, not the variable). `ansible-doc` ssh: `ansible_private_key` / `ansible_ssh_private_key` are key **contents** and require `SSH_AGENT`; `ansible_ssh_private_key_file` is the path. `ansible_connect` is not a real variable. The Nov 2026 correction is already on this lecture's Udemy description, and `hosts.example` is correct. | Do not retake unless you want the recording itself to match. The pinned description is the right fix. |
| Our first Ansible playbook (18:27). `section02-getting-started/02-first-playbook/playbook.yaml` | notes-only | Syntax-check passed (with `-i ../01-hosts-file/hosts.example`). Injected facts still work. A localhost run of `{{ ansible_distribution }}` printed `Ubuntu cursor` and this warning: `INJECT_FACTS_AS_VARS default to True is deprecated, top-level facts will not be auto injected after the change. This feature will be removed from ansible-core version 2.24.` Same warning on 2.21.6. The repo file already uses `ansible_facts['nodename']`. Unreachable if the student copied the video's hosts file (row above). | Leave the playbook. Mention the warning in the hosts-file handout, which already does. Revisit before 2.24, not now. |
| Lab: Apache 01 (21:12) and 02 (11:30). `section02-getting-started/03-lab-apache/webserver.yaml` | OK | Syntax-check passed. Lecture text in `docs/lab-01-apache.md` matches the play (FQCN, no injected facts). `become: yes` and `update_cache: yes` are accepted by 2.22. Inherits the hosts-file key variable if the student skips that note. | None for ansible-core. Optional: the play adds `changed_when` on `a2ensite` so a second run does not restart Apache. The lecture text omits that. It still works. |
| Assignment: Nginx. `section02-getting-started/04-assignment-nginx/nginx.yaml` | notes-only | Syntax-check passed. Video inventory uses `ansible_connect=ssh` and `host_key_checking=false`. Unknown inventory vars are ignored, and ssh is the default, so this does not fail by itself. Host key checking only works in `ansible.cfg`, which this folder has. | Keep the note already in that folder's README. |
| What is an Ansible role? (17:16) | OK | Conceptual. | None. |
| Creating your own Ansible role (9:29). `section03-roles/apache-playbook/roles/apache-deployment-role/`, `playbook.yaml` | OK | Syntax-check passed. Tasks are FQCN. Short names in a video would still resolve for `ansible.builtin` modules. | None. |
| Publishing and downloading roles (14:27). `playbook-galaxy.yaml`, `requirements.yml` | notes-only | `ansible-galaxy role install abohmeed.apache-example-role` exits 1: `sorry, abohmeed.apache-example-role was not found on https://galaxy.ansible.com/api/.` Without the role, syntax-check exits 1: `The role 'abohmeed.apache-example-role' was not found`. Installing from `requirements.yml` (GitHub `abohmeed/apache-example-role` plus `geerlingguy.ntp` 4.0.1) succeeded, and syntax-check then passed. `ansible-galaxy role delete` still exists in 2.22 (help only; nothing was deleted). | Keep the GitHub `requirements.yml`. Say on screen that the Galaxy name from the video 404s. No need to re-record the publish half. |
| Assignment: Nginx role. `section03-roles/nginx-assignment/` | OK | Syntax-check passed. | None. |
| What are we going to build? (1:30) | OK | Conceptual. | None. |
| Installing the common packages 01 (15:02) and 02 (23:56). `section04-mern/mernstack/roles/common/` | notes-only | Syntax-check passed **after** collections were installed. On ansible-core alone it stops at the first missing module, exit 4: `couldn't resolve module/action 'community.crypto.openssh_keypair'`. `pip install ansible` (14.6.0) already ships `community.crypto` 3.5.1, `ansible.posix` 2.2.2, `community.general` 13.5.1, `community.mongodb` 1.8.1. Video key generation per host is a logic bug; the repo has `run_once: true`. The play still converges either way. `ansible.posix.authorized_key` exists in posix 2.2.2 (not only `ansible.builtin.authorized_key`). | Tell ansible-core-only students to run `ansible-galaxy collection install -r requirements.yml`. The `pip install ansible` path can skip that. |
| Creating the web server 01 (18:11). `roles/webserver/` | retake recommended | Two hard failures if the student follows the recording, per `CHANGES.md`, both reproduced: an opening `{# templates/App.js.j2}` with no closing `#}` fails with `Syntax error in template: Missing end of comment tag`. The copy task fails if `App.css` is not there (`file not found`). The repo template renders (custom delimiters `{[% %]}` produced `Custom React app`). `App.css` is in the role and in `upload/creating-the-web-server-01/`. This lecture's public description does not carry a correction (unlike The hosts file). `create-react-app` is deprecated upstream and still runs; that part is a note, not a retake. | Retake, or pin a description note and attach `App.css` plus the fixed `App.js.j2`. A note would downgrade this row to notes-only. |
| Creating the web server 02 (23:00). same role, `group_vars/webservers.yaml` | retake recommended | A string conditional hard-fails on 2.21.6 and 2.22.0. Reproduced with `deploy_custom_page: "false"` and with `-e deploy_custom_page=false`: `Conditional result (True) was derived from value of type 'str' ... Conditionals must have a boolean result.` The `(True)` is the trap: a non-empty string is truthy. The repo uses `when: deploy_custom_page \| bool` and a real YAML `false`, and syntax-check passed. No correction is on this lecture's public description. | Retake the `when` step, or pin `when: deploy_custom_page \| bool` the way the hosts lecture is already pinned. |
| Creating the database role 01 (10:50), 02 (23:17), 03 (9:59). `roles/dbserver/` | notes-only | The **role in the repo** syntax-checks and uses `ansible_facts['distribution_release']`, FQCN, and `/root/.mongoshrc.js` for both the `stat` and the template. The **attached lecture text** `docs/mern-database-role.md` is still the old sample: `{{ ansible_distribution }}` (deprecation warning until 2.24, not a hard failure), short names (`apt`, `pip`, `stat`, `mongodb_user`, `include_tasks`), and `stat` on `/root/.mongorc.js` while the template writes `~/.mongoshrc.js` (second run creates the user again and fails). The header says the text was updated for `ansible_facts`; the code blocks were not. `roles: "root"` is a valid `mongodb_user` type (string or list). The pip shortcut deletes `/usr/lib/python3.12/EXTERNALLY-MANAGED`, which matches Ubuntu 24.04 targets only. | Do not retake (~44 min). Replace the Udemy attachment with the repo role. Point lecture 03's verify step at `.mongoshrc.js`. |
| Assignment: LAMP. `section04-mern/lampstack/` | OK | Syntax-check passed. `community.mysql` is commented as optional; the play uses `ansible.builtin.shell`, so the collection is not required. `stat` checks `~/.my.cnf`, which is the file the template writes. `mysql_native_password` is fine on MySQL 8.0 (Ubuntu 24.04). MySQL 8.4 disables that plugin. Runtime not executed (no Multipass VMs). | None until a lab image moves to MySQL 8.4. Then drop `WITH mysql_native_password`. |
| Setting up a Windows host and WinRM (18:22). `section05-windows/winrm/setup-winrm.ps1` | cannot verify | PowerShell on Windows. No `win_shell` in this script, so the 2.20 "PowerShell no longer strips quotes" change does not apply to it. Not run. | None from this audit. |
| Creating a Windows user (18:29). `roles/windows_user_management/` | cannot verify | Playbook syntax-check passed. Live WinRM was not possible. Controller-side checks: the lecture inventory line in `docs/windows-user-role.md` does not parse: `Expected key=value host variable assignment, got: paste_your_windows_password` (the password is a bare word, not `ansible_password=`). The repo `inventory/hosts.example` does parse. With `ANSIBLE_WINRM_PASSWORD` set, `delegate_to: localhost` wrote the env value, so the lookup works. A task that actually connects fails first with `winrm or requests is not installed: No module named 'winrm'` on both venvs (`pywinrm` is not part of ansible or ansible-core). On **2.22 only**, `debug` of that password prints `$REDACTED$` (password lookup and WinRM `password` are registered secrets). The file the repo writes still contains the real password. 2.21.6 still prints the password. Same host and group name `winhost` warns: `Found both group and host with same name: winhost`. | Keep the repo inventory and the file-copy task. Add one line to the lecture: the video's inventory line is invalid, and on 2.22 the on-screen `debug` password is `$REDACTED$`. Install `pywinrm` in the same venv. No retake until you have a Windows host to re-record against. |
| Deploying an ASP.NET application (12:50). `roles/aspnet/` | cannot verify | Syntax-check passed on 2.21.6 and 2.22.0 with this deprecation (module still present): `community.windows.win_iis_webapplication has been deprecated. Use microsoft.iis.web_application instead. This feature will be removed from collection 'community.windows' version 4.0.0.` Installed collection is 3.3.0, so this is a warning, not a failure. The lecture text pastes `Default.aspx` and `Web.config` as one document; the repo has two files under `files/SampleAspNetFrameworkApp/`. Not run against IIS. | Keep the two files. Switch to `microsoft.iis.web_application` before community.windows 4.0.0, not as an emergency retake. |
| What is Ansible Vault? (4:52) | OK | Comparison with HashiCorp Vault. No command that 2.22 breaks. | None. |
| LAB: Encrypting sensitive data (14:50). `section06-vault/`, uses the LAMP play | OK | On 2.22, `ansible-vault encrypt` of a real file and `ansible-vault view` returned the plaintext. A playbook that used the decrypted value wrote `secure_root_password` to a file. Task **output** masks it (`$REDACTED$`) on 2.22; 2.21.6 does not. The lecture uses `view` and a playbook run, not `debug` of the secret, so the demo still works. `encrypted-value-example.yml` is a placeholder, not a vault blob: `ansible-vault view` says `Input is not vault encrypted data.` | Leave the lecture. Do not ask students to view the placeholder file. Optional later note: 2.22 masks vault values in play output. |

## Prioritized retake shortlist

Only if you want the recording to match what students must type. The repo already runs.

| Priority | Lecture | Minutes | Why this and not a note |
|---|---|---|---|
| 1 | Creating the web server 01 | 18:11 | Template comment is a hard syntax error on 2.19+. `App.css` was missing from the lecture resources. No correction on the public lecture description. |
| 2 | Creating the web server 02 | 23:00 | `when: deploy_custom_page` with a string is a hard error, and the message says the result was `True`. Easy to mistrust. No public correction. |
| — | The hosts file | 16:00 | Same kind of hard failure, but the correction is **already on the Udemy lecture**. Retake only if you do not want students to see the old variable on screen. |
| — | Database role 01–03 | 44:06 | Do not retake. Replace the downloadable text with `roles/dbserver/`. Facts still work until 2.24. |
| — | Galaxy download | 14:27 | Do not retake. One sentence plus the GitHub `requirements.yml`. |
| — | Windows user | 18:29 | Do not retake for 2.22 masking. Students on `pip install ansible` are still on 2.21.6, where `debug` shows the password. |

**If you retake 1 and 2: 2 lectures, about 41 minutes, out of 24 lectures / 6h 36m.** Adding the hosts file makes 3 lectures, about 57 minutes. A pinned description note on the two web-server lectures (same pattern as the hosts file) brings the retake count to **zero**.

Nothing else needs a retake for ansible-core 2.21 or 2.22. Schedule a fact-syntax pass before **2.24**, when injected `ansible_distribution` stops working by default. That hits the first-playbook video and the database attachment, not the repo files.

## Syntax-check and lint

Playbooks, run from their own directory so `ansible.cfg` was picked up. Inventory was `hosts.example` or `inventory/hosts.example`. The first playbook used `../01-hosts-file/hosts.example`. ansible-core **2.22.0** unless noted.

| Playbook | Without collections / Galaxy roles | With them |
|---|---|---|
| `section02-getting-started/02-first-playbook/playbook.yaml` | pass | pass |
| `section02-getting-started/03-lab-apache/webserver.yaml` | pass | pass |
| `section02-getting-started/04-assignment-nginx/nginx.yaml` | pass | pass |
| `section03-roles/apache-playbook/playbook.yaml` | pass | pass |
| `section03-roles/apache-playbook/playbook-galaxy.yaml` | exit 1, role `abohmeed.apache-example-role` not found | pass after `requirements.yml` |
| `section03-roles/nginx-assignment/playbook.yaml` | pass | pass |
| `section04-mern/lampstack/playbook.yaml` | pass | pass |
| `section04-mern/mernstack/playbook.yaml` | exit 4, `community.crypto.openssh_keypair` unresolved | pass |
| `section05-windows/winrm/playbook.yaml` | exit 4, `ansible.windows.win_user` unresolved | pass, plus the `win_iis_webapplication` deprecation |

The same nine passed on ansible-core **2.21.6** (ansible 14.6.0) with that package's bundled collections. Windows showed the same deprecation.

`ansible-lint` 26.11.0 `--offline`, no `--fix`, repo `.ansible-lint`: **0 failures, 0 warnings, 68 files, profile production.** The only deprecations it printed are from ansible itself (`oneline` and `tree` callbacks, removed in 2.23), not from these plays.

With the skip list removed, lint reported style only: `var-naming[no-role-prefix]` (24), `package-latest` (3: first playbook, common role, pymongo), `yaml[truthy]` (2, both in `webserver.yaml`: `become: yes`, `update_cache: yes`), `role-name` (2: `apache-deployment-role`, `nginx-role`). No correctness rules. The skip list is doing what `CHANGES.md` says it does.

## Static scan

Confirmed against 2.22.0 source and docs, not only against the existing handout.

| Check | Repo files | Video / attachment |
|---|---|---|
| `ansible_private_key` vs `ansible_ssh_private_key_file` | Every `hosts.example` uses `ansible_ssh_private_key_file`. No play sets `ansible_private_key`. | Video uses `ansible_private_key` for a path. Hard-fail, reproduced. `ansible_private_key_file` is also a path (same setting as `ansible_ssh_private_key_file`). |
| Injected facts / `INJECT_FACTS_AS_VARS` | Plays and the db role use `ansible_facts[...]`. | First playbook and `docs/mern-database-role.md` use `ansible_distribution`. Warning until 2.24. Still returns the fact. |
| FQCN vs short names | Tasks use FQCN (`ansible.builtin.*`, `community.general.npm`, `community.mongodb.mongodb_user`, `ansible.windows.win_user`, `community.windows.win_iis_webapplication`). | Short names still resolve. Builtin ones need no collection. `mongodb_user`, `npm`, `win_user`, `win_iis_webapplication` need the collection on the path (`pip install ansible` has them; ansible-core alone does not). |
| Collections | `requirements.yml` in MERN, LAMP (optional mysql), Windows, and the Galaxy roles file. | Easy to miss on an ansible-core-only install. Syntax-check then exits 4. |
| WinRM / Python | Windows README says `pip install ansible pywinrm`. Not installed here, and the connect error names `winrm`. Control node for 2.22 is Python 3.13; course VMs on 24.04 are 3.12, which is enough for 2.21.6. Managed-host floor in the handout (3.9+) was not re-tested. | Lecture installs `pywinrm` only. That is required. |
| `ansible.cfg` | Nine labs, all only `[defaults] host_key_checking = False`. No `inventory=`, no `collections_path`, no interpreter. Ansible loads `ansible.cfg` from the **current directory**, so the plays must be run from the lab folder, which the READMEs say. | `host_key_checking=False` inside the inventory is not a config setting. |
| Inventory quirks | Example IPs and `paste_the_hostname` are placeholders. Windows lookup form works (tested). Group and host share the name `winhost` (warning only). | Lecture Windows line is not valid INI. MERN/LAMP examples use real-looking lab IPs (`10.223.9.220`, `10.223.9.127`); students must replace them. |
| Templates | `App.js.j2` rendered with the role's custom delimiters. Other `.j2` files were not applied to a VM. Syntax-check does not render them. | Unclosed `{#` fails, reproduced. |
| Galaxy v2 | Role install-by-name 404s. GitHub install works. Delete subcommand still present; not executed. | Video's `ansible-galaxy install abohmeed.apache-example-role` cannot succeed. |

`docs/lab-01-apache.md`, `docs/vault.md`, `docs/windows-*.md` share a header that says they were updated to `ansible_facts`. Apache and Vault never used that fact. The Windows and database attachments still show the old samples. The header overclaims.

## Blockers

- **Multipass / lab VMs.** `multipass` is not installed. `/dev/kvm` exists; `virsh` does not. No play was applied to Ubuntu. Syntax-check, lint, local `connection: local` repros, and a refused SSH to 127.0.0.1 are the execution evidence. Idempotence bugs (mongorc vs mongoshrc, `a2ensite` changed status, pm2, MySQL password on second run) were read from the files and `CHANGES.md`, not watched on a second live run.
- **Windows.** No Windows host, no WinRM listener, `pywinrm` not installed. IIS, `win_user`, and the setup script were not run. The inventory parse error, the password lookup, the missing-`winrm` error, and the module deprecation were checked from the controller.
- **Galaxy delete and a real Galaxy publish** were not executed. No token was used.

## What this audit did not change

No playbook, role, inventory, `ansible.cfg`, or lecture text was modified. This file is the only addition.
