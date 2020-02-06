Deploy AWX
========

Ansible Role to deploy AWX

Requirements
------------

python3-pip

Role Variables
--------------
---

These variables SHOULD be set, they have default values but should be changed for security reasons:

    awx_secret_key: awxsecret           # Master key to encrypt/decrypt secrets
    pg_username: awx                    # Postgres username password
    pg_password: awxpass                # Postgres database password
    rabbitmq_username: guest                 # RabbitMQ username
    rabbitmq_password: guest                 # RabbitMQ password
    default_admin_user: admin           # AWX Web Portal username
    default_admin_password: password    # AWX Web Portal password

These variables SHOULD be set for non-dev environments, currently they are provided with self-signed certificates:
    
    ssl_certs_cert_data                 # SSL cert file
    ssl_certs_privkey_data              # SSL key file

This variable CAN be set in order to force or not restarting the AWX stack, by default, it will be restarted only if 
any change has been made in docker-compose file.
    
    recreate: always|smart|never  
    
Example Playbook
-------------------------

Because of the larger number of variables involved, we prefer to add them to the playbook as _vars_

    - name: Deploy role example
      hosts: all
      vars:
        - awx_secret_key: awxsecret
        - pg_password: awxpass
        - pg_database: awx
        - rabbitmq_username: guest
        - rabbitmq_password: guest
        - default_admin_user: admin
        - default_admin_password: password

      roles:
        - { name: awx_deploy }
