#!/usr/bin/env python

import cherrypy

import sys

sys.path.append('/srv/salt-api')

from saltapi.netapi.rest_cherrypy import app

def bootstrap_app():
    '''
    Grab the opts dict of the master config by trying to import Salt
    '''
    import salt.client
    opts = salt.client.LocalClient().opts
    return app.get_app(opts)

def get_application(*args):
    '''
    Returns a WSGI application function. If you supply the WSGI app and config
    it will use that, otherwise it will try to obtain them from a local Salt
    installation
    '''
    opts_tuple = args

    def wsgi_app(environ, start_response):
        root, _, conf = opts_tuple or bootstrap_app()

        cherrypy.tree.mount(root, '/', conf)
        return cherrypy.tree(environ, start_response)

    return wsgi_app

application = get_application()
