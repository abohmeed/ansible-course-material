work

### Create the database role

```
ansible-galaxy role init roles/dbserver
```

### Create the default variables

We can add some overridable default variables in the defaults/main.yml:

```
---
# defaults file for roles/dbserver
mongodb_version: "8.0"
mongodb_repo_key: "https://www.mongodb.org/static/pgp/server-{{ mongodb_version }}.asc"
mongodb_repo_url: "https://repo.mongodb.org/apt/{{ ansible_distribution | lower }}/{{ ansible_distribution_release | lower }}/mongodb-org/{{ mongodb_version }}"
mongodb_port: 27017
mongodb_bind_ip: "0.0.0.0"
mongodb_config_path: "/etc/mongod.conf"
mongodb_data_path: "/var/lib/mongodb"
mongodb_root_user: root
mongodb_root_password: password
```

### Create the handlers

Let's add any handlers that this role may need.

```
# handlers/main.yml
- name: Restart MongoDB
  ansible.builtin.service:
    name: mongod
    state: restarted
  become: true
```

### The configuration template

We need a mongod.conf file for customizing MongoDB. We can create a template for this as follows:

```
# MongoDB Configuration File
storage:
  dbPath: {{ mongodb_data_path }}
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
net:
  port: {{ mongodb_port }}
  bindIp: {{ mongodb_bind_ip }}
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
```

### The auto-auth template

MongoDB allows us to create a file that contains the DB login credentials if we are using Mongosh. We can create this file and populate it with the credentials so that we can login to the database by using mongosh without the the need to provide a username and a password:

```
// templates/mongoshsrc.js.j2
const uri = "mongodb://{{ mongodb_root_user }}:{{ mongodb_root_password }}@localhost:{{ mongodb_port }}";
const dbName = "admin";

const connection = new Mongo(uri);
const db = connection.getDB(dbName);
```

### The tasks

In the tasks part, we will follow a different approach than before since we have several tasks for this role. So, we will create a separate file for each type of tasks we want then call them from the tasks/main.yml file. By doing this we keep our tasks modular and we can comment out any group of tasks as we need.

#### The installation task

In this file, we add our installation instructions. They are taken from https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/#install-mongodb-community-edition

```
- name: Install pip
  apt:
    name: python3-pip
    state: present
- name: Allow PIP to install packages globally
  ansible.builtin.file:
    path: /usr/lib/python3.12/EXTERNALLY-MANAGED
    state: absent
- name: Install pymongo
  pip:
    name: "{{ item }}"
    state: latest
    executable: pip3
  loop:
    - pymongo
    - configparser

- name: Add MongoDB repository using deb822_repository
  ansible.builtin.deb822_repository:
    name: mongodb
    types: deb
    uris: "https://repo.mongodb.org/apt/ubuntu"
    components: [multiverse]
    architectures: [amd64, arm64]
    suites: "{{ ansible_distribution_release }}/mongodb-org/{{ mongodb_version }}"
    signed_by: "https://www.mongodb.org/static/pgp/server-{{ mongodb_version }}.asc"

- name: Update apt package cache
  ansible.builtin.apt:
    update_cache: true

- name: Install MongoDB packages
  ansible.builtin.apt:
    name: mongodb-org
    state: present

- name: Ensure MongoDB is enabled and started
  ansible.builtin.service:
    name: mongod
    state: started
    enabled: true
```

#### Configuring MongoDB

```
- name: Create MongoDB data directory
  ansible.builtin.file:
    path: "{{ mongodb_data_path }}"
    state: directory
    owner: mongodb
    group: mongodb
    mode: '0755'

- name: Template MongoDB configuration file
  ansible.builtin.template:
    src: mongod.conf.j2
    dest: "{{ mongodb_config_path }}"
    owner: root
    group: root
    mode: '0644'
  notify: Restart MongoDB

- name: Check if .mongorc.js file exists
  stat:
    path: /root/.mongorc.js
  register: mongorc_file

- name: Create MongoDB root user
  mongodb_user:
    database: "admin"
    name: "{{ mongodb_root_user }}"
    password: "{{ mongodb_root_password }}"
    roles: "root"
  when: not mongorc_file.stat.exists

- name: Deploy MongoDB .mongorc.js file for root user
  template:
    src: mongoshsrc.js.j2
    dest: ~/.mongoshrc.js
    mode: '0600'
  notify:
    - Restart MongoDB

- name: Enable authentication in MongoDB
  lineinfile:
    path: /etc/mongod.conf
    line: "security:\n  authorization: enabled"
    insertafter: "^#security:"
    state: present
    backup: yes
  notify:
    - Restart MongoDB
```

#### Calling the tasks

```
# tasks/main.yml
---
# tasks file for roles/dbserver
- name: Include installation tasks
  include_tasks: install.yaml

- name: Include configuration tasks
  include_tasks: configure.yaml
```

### The playbook

We must configure the playbook.yaml file to include the new database role. The file should look like this:

```
# playbook.yaml
---
- name: Install common packages
  become: yes
  hosts: all
  gather_facts: no
  roles:
    - common
- name: Install the web server
  become: yes
  hosts: webservers
  gather_facts: no
  roles:
    - webserver
- name: Install and configure the database
  gather_facts: yes
  become: true
  hosts: dbservers
  roles:
    - dbserver
```

### Run the playbook and verify the results

##### We need an updated version of Ansible

For this role, we need the latest Ansible version. So, we will use a virtual environment and use pip to install Ansible:

```
python3 -m venv ansible-env
source ansible-env/bin/activate
pip install ansible
export PATH=ansible-env/bin:$PATH
ansible --version
```

Now, we can run the playbook:

```
ansible-playbook -i inventory/hosts playbook.yaml
```

Login to the databse server and ensure that the service is running:

```
multipass shell db01
sudo systemctl status mongod
```

Try to login to MongoDB using any user other than root:

```
multipass shell db01
mongosh
use admin
db.getUsers()
```

It should return MongoServerError[Unauthorized]: Command usersInfo requires authentication because this user did not authenticate when connecting to the database and the .mongoshrc file does not exist in the user's home directory.

Now, try the same command using root:

```
sudo mongosh
# it should already by on the 'admin' database since it used the ~/.mongoshrc file
db.getUsers()
```

It should return:

```
{
  users: [
    {
      _id: 'admin.root',
      userId: UUID('16455d9a-2c49-4471-a3e2-75faba559316'),
      user: 'root',
      db: 'admin',
      roles: [ { role: 'root', db: 'admin' } ],
      mechanisms: [ 'SCRAM-SHA-1', 'SCRAM-SHA-256' ]
    }
  ],
  ok: 1
}
```

