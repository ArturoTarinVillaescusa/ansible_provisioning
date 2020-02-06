#!/usr/bin/python
# -*- coding: utf-8 -*-

DOCUMENTATION = '''
---
module: graphite_event
author: Facundo Guerrero
short_description: Create Event in Graphite
description:
   - Create Event in graphite
requirements: [ urllib2, json ]
'''

# ===========================================
# Module execution.
#

import urllib2
import json

def main():

    module = AnsibleModule(
        argument_spec=dict(
            tags=dict(required=True),
            url=dict(required=True),
            data=dict(required=True),
            what=dict(required=True)
        ),
        supports_check_mode=True
    )

    tags = module.params["tags"]
    url = module.params["url"]
    what = module.params["what"]
    data = module.params["data"]

    event = {}
    event['what'] = what
    event['tags'] = tags
    event['data'] = data
    payload = json.dumps(event)

    request = urllib2.Request(url, payload, {'Content-Type': 'application/json'})
    response = urllib2.urlopen(request)

    changed = True
    module.exit_json(changed=changed)

from ansible.module_utils.basic import *
from ansible.module_utils.urls import *

main()
