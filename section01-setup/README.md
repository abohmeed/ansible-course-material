# Section 1: Ansible installation and the lab VM

## Install Ansible (pick one)

```bash
# macOS / Linux / WSL2 with Homebrew
brew install ansible

# Ubuntu packages (older ansible-core, fine for Sections 1-3)
sudo apt update && sudo apt install -y ansible

# pip in a virtual environment (recommended; gives the newest ansible-core)
sudo apt install -y python3-pip python3-venv
python3 -m venv ansible-env
source ansible-env/bin/activate
pip install --upgrade pip
pip install ansible
ansible --version
```

Current ansible-core (2.20) needs **Python 3.12 or newer on the control machine** and Python 3.9 or newer on the
targets. Ubuntu 24.04 ships Python 3.12, so it works out of the box. See `docs/ansible-core-2.19-2.20-changes.md`.

## Create the lab VM with Multipass

```bash
sudo snap install multipass          # or: brew install --cask multipass
ssh-keygen                           # accept the defaults if you have no key yet
cat ~/.ssh/id_rsa.pub                # paste it into ansible_multipass.yaml
multipass launch -n ansiblemain --cloud-init ansible_multipass.yaml
multipass info ansiblemain           # note the IPv4 address
ssh -i ~/.ssh/id_rsa ansibleadmin@<vm_ip>
```

Note: the video types `~/.ssh/.id_rsa` in the last command; the file is `~/.ssh/id_rsa` (no dot before `id_rsa`).
The manual method in the video writes the key to `~/.ssh/known_keys`; the correct file is `~/.ssh/authorized_keys`.
