# Changes compared with the videos

The course was recorded in late 2024. These are the differences between what you see on screen and the files in this repo. Every change is either a bug fix or an update for ansible-core 2.19 and 2.20. The lessons themselves are unchanged.

## Bugs fixed

| Where | In the video or lecture resource | Fixed | Effect of the bug |
|---|---|---|---|
| Inventory (all labs) | `ansible_private_key=...` (or `ansible_private_key_file`) | `ansible_ssh_private_key_file=...` | On 2.19+ `ansible_private_key` means key contents: "Cannot utilize private_key with SSH_AGENT disabled" |
| Inventory | `ansible_connect=ssh` | `ansible_connection=ssh` | Typo, silently ignored |
| Inventory | `host_key_checking=False` as a host variable | `ansible.cfg` → `[defaults] host_key_checking = False` | Had no effect in the inventory |
| Lab Apache, Apache role (lecture resources) | Copied HTML text contained non-breaking spaces | Plain spaces | `YAML parsing failed ... did not find expected '-' indicator` when pasted |
| MERN `App.js.j2` | `{# templates/App.js.j2}` (comment never closed) | Removed | `Syntax error in template: Missing end of comment tag` |
| MERN web server | `App.css` not attached to "Creating the web server 01" | `roles/webserver/files/App.css` | The copy task failed: file not found |
| MERN web server | `when: deploy_custom_page` with a string value | `when: deploy_custom_page | bool`, default `false` in `group_vars/webservers.yaml` | 2.19+: "Conditionals must have a boolean result" |
| MERN web server | `pm2 start` ran again on every play | Named pm2 process; a re-run isn't reported as a change | Duplicate processes or failures on the second run |
| MERN database | `stat` checked `/root/.mongorc.js` and the template wrote `.mongoshrc.js` | Both use `/root/.mongoshrc.js` | The root user was re-created on every run |
| MERN common | Key pair generated per host | `run_once: true` | Different keys per host |
| LAMP database | `stat` on `~/.my.cnf.j2` | `stat` on `~/.my.cnf` | The root password step re-ran and failed on the second run |
| LAMP database | Password visible in the output | `no_log: true` on password tasks | Leaked into logs |
| Galaxy lecture | `abohmeed.apache-example-role` from Galaxy | Installed from GitHub in `requirements.yml` | The role was deleted from Galaxy at the end of the lecture |
| Galaxy lecture notes | A real Galaxy API token was in the notes | Placeholder `<your_galaxy_api_token>` | Never commit tokens |
| Windows inventory | `ansible_password=paste_your_windows_password` in the file | Read from `ANSIBLE_WINRM_PASSWORD` | Avoids passwords in git |
| Windows ASP.NET | `Default.aspx` and `Web.config` in one document | Two files in `roles/aspnet/files/SampleAspNetFrameworkApp/` | Couldn't be copied as is |
| Setup notes | `~/.ssh/.id_rsa`, `known_keys` | `~/.ssh/id_rsa`, `authorized_keys` | Typos |

## Updates for ansible-core 2.20

- Facts are written as `ansible_facts['distribution']` and so on. Injected `ansible_distribution` is deprecated in 2.20.
- Modules use fully qualified names (`ansible.builtin.apt`, `community.general.npm`, `community.mongodb.mongodb_user`, `ansible.windows.win_user`).
- Each project has a `requirements.yml` for its collections.
- The MongoDB repository uses `ansible.builtin.deb822_repository` (8.0, Ubuntu 24.04).
- `apt` tasks are run with `become: true` at play level, as in the videos.

## Left as in the video on purpose

- Role and variable names (`apache-deployment-role`, `nginx-role`, `db_password`, ...) so you can follow along. ansible-lint naming rules are skipped in `.ansible-lint`.
- `create-react-app` for the React app. It's deprecated upstream but still works. Vite is the modern choice.
- Section 7 (cloud) is not published on Udemy and isn't included.
