# What is this?

This repository contains the [Ansible][ansible] code.

# How do I add a new role code

-	create a folder for my role: `mkdir roles/myrole`
-	create a `README.md` file (required)
-	create a `tasks` folder (required)
-	create a `tasks/main.yml` file (required)
-	create a `files` folder (not required)
-	create a `templates` folder (not required)
-	create a `handlers` folder (not required)

## folder `<role name>`

This is where all the files for a given [role] [ansible_role] reside, (ex: `test-deploy/`).

## `<role name>/README.md`

This file contains a brief explanation of the [role] [ansible_role] purpose and the following information:

-	Instructions to run the [role] [ansible_role] in a [playbook] [ansible_playbook]

## `<role name>/tasks`

This folder _MUST_ contain one file named **main.yml** and _MAY_ contain other **yml** files.

## `<role name>/tasks/main.yml`

This file contains a series of tasks to be performed when the [role] [ansible_role] is executed

```
- name: Run this command and ignore the result in case of error
  shell: /usr/bin/somecommand
  ignore_errors: True
  
- name: Copy ansible inventory file to client
  copy: src=/etc/ansible/hosts dest=/etc/ansible/hosts
          owner=root group=root mode=0644
```

MAY_ also [include] [ansible_include] other **yml** files with tasks.

```
- import_tasks: redis.yml
```

```
### redis.yml ###

- name: "[Redis] Check status"
  command: "{{ redis_cli }} -h {{ ansible_hostname }} -p {{ redis_port }} info"
  register: redis_status
  
- name: "[Redis] Print status" 
  debug: var=redis_status
```

## `<role name>/files`

This folder contains all the files to be copied to destination by this [role] [ansible_role], related with [COPY] [ansible_copy] module. 

## `<role name>/templates`

This folder contains [Jinja2][jinja2] template files to be copied to destination by this [role] [ansible_role], related with [TEMPLATE] [ansible_template] module.

## `<role name>/handlers`

This folder contains the definition of [Handlers][ansible_handlers] to manage them.

```
handlers:
    - name: restart redis
      service: name=redis state=restarted
    - name: restart apache
      service: name=apache state=restarted
```

to be used from tasks:

```
- name: template configuration file
  template: src=template.j2 dest=/etc/foo.conf
  notify:
     - restart redis
```

# How do I add a new playbook

-	create a file for my playbook: `touch myplaybook.yml`

## file `<playbook name>`

This file contains the following information:

- a brief explanation of the [playbook] [ansible_playbook] purpose

```
# Playbook to deploy TEST Application
```

- variables necessary for execution
```
# Variables:
#
# env: Environment where the playbook will be executed
#
```

- how to [execute] [ansible_execute] it

```
# Then run the playbook, like this:
#
# ansible-playbook -i testhosts --limit=testhost testdeploy.yml --extra-vars "env=test"
#
```

- [playbook] [ansible_playbook] code

```
- hosts: all
  gather_facts: no
  vars_files:
    - "environments/{{ env | default('test') }}/group_vars/000-common.yml"
  roles:
    - test-deploy
  tasks:
    - name: Copy file to dest path
      copy:
        src={{ test_file.path }}
        dest="{{ test_dest_file.path }}"
```

[ansible]: https://www.ansible.com/
[ansible_playbook]: http://docs.ansible.com/ansible/latest/playbooks.html
[ansible_execute]: https://docs.ansible.com/ansible/latest/ansible-playbook.html
[ansible_role]: http://docs.ansible.com/ansible/latest/playbooks_reuse_roles.html
[ansible_copy]: http://docs.ansible.com/ansible/latest/copy_module.html
[ansible_template]: http://docs.ansible.com/ansible/latest/template_module.html
[ansible_include]: http://docs.ansible.com/ansible/latest/playbooks_reuse_includes.html
[ansible_handlers]: http://docs.ansible.com/ansible/latest/playbooks_intro.html#handlers-running-operations-on-change
[jinja2]: http://jinja.pocoo.org/docs/2.10/