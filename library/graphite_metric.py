#!/usr/bin/python
# -*- coding: utf-8 -*-

DOCUMENTATION = '''
---
module: graphite_metric
author: Alejandro Cavero
short_description: Create Metric in Graphite
description:
   - Create Metric in graphite
requirements: [ socket, time ]
'''

# ===========================================
# Module execution.
#

import socket
import time

def main():

    module = AnsibleModule(
        argument_spec=dict(
            server=dict(required=True),
            port=dict(required=True),
            path=dict(required=True),
            value=dict(required=True)
        ),
        supports_check_mode=True
    )

    timestamp = int(time.time())

    sock = socket.socket()
    sock.connect((module.params["server"], int(module.params["port"])))
    sock.sendall('%s %s %d\n' % (module.params["path"], module.params["value"], timestamp))
    sock.close()

    changed = True
    module.exit_json(changed=changed)

from ansible.module_utils.basic import *
from ansible.module_utils.urls import *

main()