cdvsid_operate
========

Ansible role to manage CDV application

### Changelog 0.1.0

- Start project

Requirements
------------

Nothing beyond a remote WINDOWS server with WinRM and Powershell.

Role Variables
--------------
---

These variables MUST be set in order to operate the CDV system, they have no defaults:

    operation: "start|stop|restart"
    
Dependencies
------------

none

Example Playbook
-------------------------

Because of the larger number of variables involved, we prefer to add them to the playbook as _vars_

Before you use this role, be sure to prepare the remote. If you want to deploy from a git repo, you need
the remote user to be able to clone the project (with SSH keys for example).

    - hosts: all
      gather_facts: true
      vars:
        operate: stop
      roles:
        - cdvsid_operate

Or

    - hosts: all
      gather_facts: true
      pre_tasks:
        - include_tasks: roles/cdvsid_operate/tasks/main.yml operation=stop
