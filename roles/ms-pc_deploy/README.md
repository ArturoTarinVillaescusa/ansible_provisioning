ms-pc_deploy
========

Deploy Precios Competencia (MS-PC) microservice with Ansible

### Changelog 1.4

- First Deploy

Requirements
------------

Nothing beyond a remote UNIX server with ssh access and python or WinRM and Powershell. It *should* work on any
linux/unix OS although we've only tested it on Debian and Ubuntu.

Role Variables
--------------
---

These variables must be set, they have no defaults:

    ms_pc_version: "1.4"


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
      vars_files:
        - "roles/ms-pc_deploy/defaults/{{ ansible_os_family | lower }}.yml"
      vars:
        project_unwanted_items: [ '.git', 'bin', 'conf' ]
        project_files:[]
        project_templates:
          - name: "MS-PC VERSION"
            src: "roles/ms-pc_deploy/templates/conf/VERSION.j2"
            dest: "VERSION.txt"
          - name: "Logback"
            src: "roles/ms-pc_deploy/templates/conf/logback.xml.j2"
            dest: "logback.xml"
          - name: "Application conf"
            src: "roles/ms-pc_deploy/templates/conf/application.conf.j2"
            dest: "application.conf.conf"
        project_command_copy_remote_files:
          - name: "Copy PRI executable"
            cmd: "xcopy bin{{ path_separator | default('/') }}run_pri.bat {{ deploy_helper.new_release_path }}{{ path_separator | default('/') }}pri /e /s /Y"
            when: "windows"
          - name: "Copy SYSTEM executable"
            cmd: "xcopy bin{{ path_separator | default('/') }}run_system.bat {{ deploy_helper.new_release_path }}{{ path_separator | default('/') }}system /e /s /Y"
            when: "windows"
          - name: "Copy PRI executable"
            cmd: "mv bin{{ path_separator | default('/') }}run_pri.bat {{ deploy_helper.new_release_path }}{{ path_separator | default('/') }}pri"
            when: "debian"
          - name: "Copy SYSTEM executable"
            cmd: "mv bin{{ path_separator | default('/') }}run_system.bat {{ deploy_helper.new_release_path }}{{ path_separator | default('/') }}system"
            when: "debian"
        project_pre_deploy_commands: []
        project_post_deploy_commands: []
    
      roles:
        - ms-pc_deploy
