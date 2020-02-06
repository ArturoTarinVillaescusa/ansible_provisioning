tarsid_deploy
========

Ansible role to deploy TAR

### Changelog 0.1.0

- Start project

Requirements
------------

Nothing beyond a remote WINDOWS server with WinRM and Powershell.

Role Variables
--------------
---

These variables must be set, they have no defaults:

    tarsid_version: "1.07.000-9bb8453"
    
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
        - "roles/tarsid_deploy/defaults/{{ ansible_os_family | lower }}.yml"
      vars:
        project_templates:
          - name: "TARSID Properties"
            src: "roles/tarsid_deploy/templates/TARSID.ini.j2"
            dest: "TARSID.ini"
          - name: "PrecargasDaos Properties"
            src: "roles/tarsid_deploy/templates/PrecargasDaos.ini.j2"
            dest: "PrecargasDaos.ini"
        project_command_copy_remote_files: []
        project_pre_deploy_commands:
          - name: "{{ tools_path }}{{ path_separator }}PSTools{{ path_separator }}pskill.exe -accepteula -nobanner TARSID"
            failed_when_not: "'Process does not exist' not in pre_deploy_commands.stdout and 'Process TARSID killed' not in pre_deploy_commands.stdout"
        project_post_deploy_commands:
          - "{{ tools_path }}{{ path_separator }}PSTools{{ path_separator }}PSExec64.exe -accepteula -nobanner -h -s -w {{ project_root }}\\current\\ -i 1 cmd /c start {{ project_root }}\\current\\TARSID.exe"
      pre_tasks:
        - import_tasks: roles/tarsid_deploy/tasks/deactivate_service.yml
        - pause:
            seconds: 30
      roles:
        - tarsid_deploy
      post_tasks:
        - name: "Wait until TAR is up&running"
          win_shell: "netstat -a | findstr 0.0.0.0:9004"
          register: tar_status
          until: tar_status.stdout_lines|length == 1
          retries: 30
          delay: 10
          when: ansible_os_family | lower == "windows"
    
        - import_tasks: roles/tarsid_deploy/tasks/activate_service.yml
