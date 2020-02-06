Ansible NGINX Role
==================

GIT Repo forked from: https://github.com/nginxinc/ansible-role-nginx

This role installs NGINX Open Source or NGINX Plus on your target host.

Requirements
------------

This role was developed using Ansible 2.4.0.0. Backwards compatibility is not guaranteed.

It supports all platforms supported by [NGINX Open Source](https://nginx.org/en/linux_packages.html#mainline) and [NGINX Plus](https://www.nginx.com/products/technical-specs/):

**NGINX Open Source:**

    CentOS:
      versions:
        - 6
        - 7
    RedHat:
      versions:
        - 6
        - 7
    Debian:
      versions:
        - jessie
        - stretch
    Ubuntu:
      versions:
        - trusty
        - xenial
        - zesty
    SUSE/SLES:
      versions:
        - 12

**NGINX Plus:**

    CentOS:
      versions:
        - 6
        - 7
    RedHat:
      versions:
        - 6
        - 7
    Debian:
      versions:
        - wheezy
        - jessie
        - stretch
    Ubuntu:
      versions:
        - trusty
        - xenial
        - zesty
    SUSE/SLES:
      versions:
        - 12
    FreeBSD:
      versions:
        - 10.3
        - 11
    Oracle Linux:
      versions:
        - 6.5
        - 7
    Amazon Linux:
      versions:
        - 2016.09

Role Variables
--------------

This role has multiple variables. The defaults for all these variables are the following:

    ---
    # Specify which version of NGINX you want to install.
    # Options are 'opensource' or 'plus'.
    # Default is 'opensource'.
    type: opensource

    # Specify which branch of NGINX Open Source you want to install.
    # Options are 'mainline' or 'stable'.
    # Default is mainline.
    branch: mainline

    # Install nginscript, perl, waf (NGINX Plus only), geoip, image-filter, rtmp and/or xslt modules.
    # Default is false.
    modules:
      njs: false
      perl: false
      waf: false
      geoip: false
      image_filter: false
      rtmp: false
      xslt: false

    # Install NGINX Amplify.
    # Use your NGINX Amplify API key.
    # Default is null.
    amplify_enable: false
    amplify_key: null

    # Enable NGINX status data.
    # Will enable 'stub_status' in NGINX Open Source and 'status' in NGINX Plus.
    # Default is false.
    status_enable: false

    # Enable NGINX Plus REST API, write access to the REST API, and NGINX Plus dashboard.
    # Default is false.
    rest_api_enable: false
    rest_api_write: false
    rest_api_dashboard: false

    # Location of your NGINX Plus license in your local machine.
    # Default is the files folder within the NGINX Ansible role.
    license:
      certificate: license/nginx-repo.crt
      key: license/nginx-repo.key

    # Enable uploading NGINX configuration files to your system.
    # Default for uploading files is false.
    # Default location of files is the files folder within the NGINX Ansible role.
    main_push_enable: false
    main_push_location: conf/nginx.conf
    http_push_enable: false
    http_push_location: conf/http/*.conf
    stream_push_enable: false
    stream_push_location: conf/stream/*.conf

    # Configuration variables to create a templated NGINX configuration.
    # Defaults are the values found in a fresh NGINX installation.
    main_template_enable: false
    main_template_user: nginx
    main_template_worker_processes: auto
    main_template_error_level: warn
    main_template_worker_connections: 1024
    http_template_enable: false
    http_template_keepalive_timeout: 65
    http_template_listen: 80
    http_template_server_name: localhost
    stream_template_enable: false
    stream_template_listen: 12345

Dependencies
------------

None

Example Playbook
----------------

This is a sample playbook file for deploying the Ansible Galaxy NGINX role in a localhost and installing the open source version of NGINX.

    ---
    - hosts: localhost
      become: true
      roles:
        - role: nginx

This is a sample playbook file for deploying the Ansible Galaxy NGINX role in a localhost and installing NGINX Plus.

    ---
    - hosts: localhost
      become: true
      roles:
        - role: nginx
      vars:
        - type: plus

This is a sample playbook file for deploying the Ansible Galaxy NGINX role to a dynamic inventory containing the `nginx` tag.

    ---
    - hosts: tag_nginx
      remote_user: root
      roles:
        - role: nginx

To run any of the above sample playbooks create a `setup-nginx.yml` file and paste the contents. Executing the Ansible Playbook is then as simple as executing `ansible-playbook setup-nginx.yml`.