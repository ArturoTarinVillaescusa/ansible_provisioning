dpp_deploy
========

Deploy a DPP with Ansible

### Changelog 2.11

- added the variables integrationTestKey = "integrationTestsId" to web.conf

Requirements
------------

Nothing beyond a remote UNIX server with ssh access and python or WinRM and Powershell. It *should* work on any
linux/unix OS although we've only tested it on Debian and Ubuntu.

Role Variables
--------------
---

These variables must be set, they have no defaults:

    pricing_version: "2.11"


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
        - "roles/dpp_deploy/defaults/{{ ansible_os_family | lower }}.yml"
      vars:
        project_unwanted_items: [ '.git', 'bin', 'conf' ]
        project_files:
          - name: "Web Certs File"
            src: "roles/dpp_deploy/files/certificados/pricing_web.cacerts"
            dest: "certificados{{ path_separator }}pricing_web.cacerts"
          - name: "Web Keystore"
            src: "roles/dpp_deploy/files/certificados/pricing_web.keystore"
            dest: "certificados{{ path_separator }}pricing_web.keystore"
    
        project_templates:
          - name: "WEB VERSION"
            src: "roles/dpp_deploy/templates/conf/VERSION.j2"
            dest: "web{{ path_separator | default('/') }}VERSION.txt"
          - name: "WEB Logback"
            src: "roles/dpp_deploy/templates/conf/logback.xml.j2"
            dest: "web{{ path_separator | default('/') }}logback.xml"
          - name: "WEB DB conf"
            src: "roles/dpp_deploy/templates/conf/db.conf.j2"
            dest: "web{{ path_separator | default('/') }}db.conf"
          - name: "WEB conf"
            src: "roles/dpp_deploy/templates/web/web.conf.j2"
            dest: "web{{ path_separator | default('/') }}web.conf"
          - name: "WEB run_web executable"
            src: "roles/dpp_deploy/templates/web/run_web.bat.j2"
            dest: "web{{ path_separator | default('/') }}run_web.bat"
          - name: "WEB check web executable"
            src: "roles/dpp_deploy/templates/web/check_web.bat.j2"
            dest: "web{{ path_separator | default('/') }}check_web.bat"
          - name: "PRI VERSION"
            src: "roles/dpp_deploy/templates/conf/VERSION.j2"
            dest: "pri{{ path_separator | default('/') }}VERSION.txt"
          - name: "PRI Logback"
            src: "roles/dpp_deploy/templates/conf/logback.xml.j2"
            dest: "pri{{ path_separator | default('/') }}logback.xml"
          - name: "PRI DB conf"
            src: "roles/dpp_deploy/templates/conf/db.conf.j2"
            dest: "pri{{ path_separator | default('/') }}db.conf"
          - name: "PRI conf"
            src: "roles/dpp_deploy/templates/pri/pri.conf.j2"
            dest: "pri{{ path_separator | default('/') }}pri.conf"
          - name: "PRI check web executable"
            src: "roles/dpp_deploy/templates/pri/check_pri.bat.j2"
            dest: "pri{{ path_separator | default('/') }}check_pri.bat"
          - name: "SYSTEM VERSION"
            src: "roles/dpp_deploy/templates/conf/VERSION.j2"
            dest: "system{{ path_separator | default('/') }}VERSION.txt"
          - name: "SYSTEM Logback"
            src: "roles/dpp_deploy/templates/conf/logback.xml.j2"
            dest: "system{{ path_separator | default('/') }}logback.xml"
          - name: "SYSTEM DB conf"
            src: "roles/dpp_deploy/templates/conf/db.conf.j2"
            dest: "system{{ path_separator | default('/') }}db.conf"
          - name: "SYSTEM conf"
            src: "roles/dpp_deploy/templates/system/system.conf.j2"
            dest: "system{{ path_separator | default('/') }}system.conf"
          - name: "SYSTEM check web executable"
            src: "roles/dpp_deploy/templates/system/check_system.bat.j2"
            dest: "system{{ path_separator | default('/') }}check_system.bat"
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
        - dpp_deploy
