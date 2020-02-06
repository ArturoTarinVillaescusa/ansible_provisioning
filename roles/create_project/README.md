create_project
========

This Ansible Role prepares GIT repository and Jenkins jobs for a new project

Requirements
------------

The below requirements are needed on the host that executes this module.

* python-jenkins

Role Variables
--------------
---

These variables must be set, they have no defaults:

    repo_name: My Test
    repo_project_key: IC
    nexus_repo_name: MavenRentalcar
    
This variable creates Build Jobs in Jenkins.

    build_job: false
    
This variable creates Deliver Jobs in Jenkins to upload artifact to Nexus.

    build_deliver: false
    
This variable creates Build View in Jenkins.

    build_view: false

This list provide information about the Build Jobs to create in Jenkins.

    build_branch:
     - develop
     - release
     - hotfix
    
These variables configure the job with Delphi and assign proper Agents to execute the Build Jobs.

    build_builders_delphi: false
    
These variables configure the job with Gradle and assign proper Agents to execute the Build Jobs.

    build_builders_gradle: false
    build_builders_gradle_plugin: "gradle@1.28"
    build_builders_gradle_tasks: "test zip"
    
These variables configure the job to work with a custom command to execute the Build Jobs.

    build_builders_batchfile: false
    build_builders_batchfile_command: "activator.bat clean packageAll"
    
This variable enable/disable Sonar for the Build Jobs.

    build_builders_sonar: false
    
These variables configure the artifact output of the Job.

    build_publishers_archiver: false
    build_publishers_archiver_artifact_path: "build/distributions/*.zip"
    
This variable enable/disable JUnit for the Build Jobs.

    build_publishers_junit: false
    
This variable configure the output path with the results of JUnit tests.

    build_publishers_junit_results_path: "build/test-results/test/*.xml"
    
This variable enable/disable Jacoco for the Build Jobs.

    build_publishers_jacoco: false

Example Playbook
-------------------------

Because of the larger number of variables involved, we prefer to add them to the playbook as _vars_

    - name: Deploy role example
      hosts: all
      vars:
        - repo_name: My Test
        - repo_project_key: IC
        - nexus_repo_name: MavenRentalcar
        - build_job: true
        - build_deliver: true
        - build_builders_gradle: true
        - build_builders_sonar: true
        - build_publishers_jacoco: true
        - build_publishers_junit: true
        - build_builders_delphi: true
        - repo_project_key: DOS

      roles:
        - { name: create_project }
