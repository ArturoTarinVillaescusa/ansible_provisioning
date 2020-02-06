sarsisd_deploy
========

Ansible role to deploy SARSIS

### Changelog 0.1.0

- Start project

Requirements
------------

Nothing beyond a remote WINDOWS server with WinRM and Powershell.

Role Variables
--------------
---

These variables MUST be set, they have no defaults:

    sarsisd_version: "1.27.001-221d03a"
    openssl_pass: # Password to decrypt SSL Keys
    sarsisd_ca_cert # SARSISD CA Cert
    sarsisd_cert_privatekey # SARSISD Private Key
    sarsisd_cert # SARSISD Certificate
    
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
        - "roles/sarsisd_deploy/defaults/{{ ansible_os_family | lower }}.yml"
      vars:
        project_files:
          - name: "CA cert file"
            src: "roles/sarsisd_deploy/files/certificados/CA_cert.pem"
            dest: "certificados{{ path_separator }}CA_cert.pem"
          - name: "PEM file"
            src: "roles/sarsisd_deploy/files/certificados/Cert_privatekey.pem"
            dest: "certificados{{ path_separator }}Cert_privatekey.pem"
          - name: "CERT file"
            src: "roles/sarsisd_deploy/files/certificados/rentalcar-sarsis.cert"
            dest: "certificados{{ path_separator }}rentalcar-sarsis.cert"
        project_templates:
          - name: "SARSISD WebServer Properties"
            src: "roles/sarsisd_deploy/templates/SARSISDWebServer.ini.j2"
            dest: "SARSISDWebServer.ini"
          - name: "PrecargasDaos Properties"
            src: "roles/sarsisd_deploy/templates/PrecargasDaos.ini.j2"
            dest: "PrecargasDaos.ini"
        project_command_copy_remote_files: []
        project_pre_deploy_commands:
          - name: "{{ tools_path }}{{ path_separator }}PSTools{{ path_separator }}pskill.exe -accepteula -nobanner SARSISDWebServer"
            failed_when_not: "'Process does not exist' not in pre_deploy_commands.stdout and 'Process SARSISDWebServer killed' not in pre_deploy_commands.stdout"
        project_post_deploy_commands:
          - "{{ tools_path }}{{ path_separator }}PSTools{{ path_separator }}PSExec64.exe -accepteula -nobanner -h -s -w {{ project_root }}\\current\\ -i {{ current_session_id.stdout | int }} cmd /c start {{ project_root }}\\current\\SARSISDWebServer.exe"
      roles:
        - sarsisd_deploy