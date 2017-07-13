# -*- coding: utf-8 -*-
'''
Return data to a postgresql graph server

.. note::
    Creates database of all Salt resources which are to be run on
    all minions and then updates their last known state during state
    file runs. It can't function as master nor minion external cache.

:maintainer:    None
:maturity:      New
:depends:       psycopg2
:platform:      all

To enable this returner the minion will need the psycopg2 installed and
the following values configured in the minion or master config:

.. code-block:: yaml

    returner.postgres_graph_db.host: 'salt'
    returner.postgres_graph_db.user: 'salt'
    returner.postgres_graph_db.passwd: 'salt'
    returner.postgres_graph_db.db: 'salt'
    returner.postgres_graph_db.port: 5432

Alternative configuration values can be used by prefacing the configuration.
Any values not found in the alternative configuration will be pulled from
the default location:

.. code-block:: yaml

    alternative.returner.postgres_graph_db.host: 'salt'
    alternative.returner.postgres_graph_db.user: 'salt'
    alternative.returner.postgres_graph_db.passwd: 'salt'
    alternative.returner.postgres_graph_db.db: 'salt'
    alternative.returner.postgres_graph_db.port: 5432

Running the following commands as the postgres user should create the database
correctly:

.. code-block:: sql
    psql << EOF
    CREATE ROLE salt WITH LOGIN;
    ALTER ROLE salt WITH PASSWORD 'salt';
    CREATE DATABASE salt WITH OWNER salt;
    EOF
    
    psql -h localhost -U salt << EOF
    --
    -- Table structure for table 'salt_resources'
    --
    
    DROP TABLE IF EXISTS salt_resources;
    CREATE TABLE salt_resources (
      id            varchar(255) NOT NULL UNIQUE,
      resource_id   varchar(255) NOT NULL,
      host          varchar(255) NOT NULL,
      service       varchar(255) NOT NULL,
      module        varchar(50) NOT NULL,
      fun           varchar(50) NOT NULL,
      status        varchar(50) NOT NULL,
      options       json NULL,
      last_ret      text NULL,
      alter_time    TIMESTAMP WITH TIME ZONE DEFAULT now()
    );
    
    --
    -- Table structure for table 'salt_resources_meta'
    --
    
    DROP TABLE IF EXISTS salt_resources_meta;
    CREATE TABLE salt_resources_meta (
      id           varchar(255) NOT NULL UNIQUE,
      options      json NULL,
      alter_time   TIMESTAMP WITH TIME ZONE DEFAULT now()
    );
    EOF

Required python modules: psycopg2

To use the postgres_graph_db returner, append '--return postgres_graph_db' to the salt command.

.. code-block:: bash

    salt '*' test.ping --return postgres_graph_db

To use the alternative configuration, append '--return_config alternative' to the salt command.

.. versionadded:: 2015.5.0

.. code-block:: bash

    salt '*' test.ping --return postgres_graph_db --return_config alternative

To override individual configuration items, append --return_kwargs '{"key:": "value"}' to the salt command.

.. versionadded:: 2016.3.0

.. code-block:: bash

    salt '*' test.ping --return postgres_graph_db --return_kwargs '{"db": "another-salt"}'

'''
from __future__ import absolute_import
# Let's not allow PyLint complain about string substitution
# pylint: disable=W1321,E1321

# Import python libs
import datetime
import json
import logging

# Import Salt libs
import salt.utils.jid
import salt.returners

# Import third party libs
try:
    import psycopg2
    import psycopg2.extras
    HAS_POSTGRES = True
except ImportError:
    HAS_POSTGRES = False

__virtualname__ = 'postgres_graph_db'
LOG = logging.getLogger(__name__)


def __virtual__():
    if not HAS_POSTGRES:
        return False, 'Could not import postgres returner; psycopg2 is not installed.'
    return __virtualname__


def _get_options(ret=None):
    '''
    Get the postgres options from salt.
    '''
    attrs = {'host': 'host',
             'user': 'user',
             'passwd': 'passwd',
             'db': 'db',
             'port': 'port'}

    _options = salt.returners.get_returner_options('returner.{0}'.format(__virtualname__),
                                                   ret,
                                                   attrs,
                                                   __salt__=__salt__,
                                                   __opts__=__opts__)
    return _options


def _get_conn(ret=None):
    '''
    Return a postgres connection.
    '''
    _options = _get_options(ret)

    host = _options.get('host')
    user = _options.get('user')
    passwd = _options.get('passwd')
    datab = _options.get('db')
    port = _options.get('port')

    return psycopg2.connect(
            host=host,
            user=user,
            password=passwd,
            database=datab,
            port=port)


def _close_conn(conn):
    '''
    Close the Postgres connection
    '''
    conn.commit()
    conn.close()


def _get_lowstate_data():
    '''
    TODO: document this method
    '''
    conn = _get_conn()
    cur = conn.cursor()

    try:
        # you can only do this on Salt Masters minion
        lowstate_req = __salt__['saltutil.cmd']('*', 'state.show_lowstate', **{'timeout': 15, 'concurrent': True, 'queue': True})
    except:
        lowstate_req = {}
    
    for minion, lowstate_ret in lowstate_req.items():
        if lowstate_ret.get('retcode') != 0:
            continue
        for resource in lowstate_ret.get('ret', []):
            low_sql = '''INSERT INTO salt_resources
                         (id, resource_id, host, service, module, fun, status)
                         VALUES (%s, %s, %s, %s, %s, %s, %s)
                         ON CONFLICT (id) DO UPDATE
                           SET resource_id = excluded.resource_id,
                               host = excluded.host,
                               service = excluded.service,
                               module = excluded.module,
                               fun = excluded.fun,
                               alter_time = current_timestamp'''

            rid = "%s|%s" % (minion, resource.get('__id__'))

            cur.execute(
                low_sql, (
                    rid,
                    resource.get('__id__'),
                    minion,
                    resource.get('__sls__'),
                    resource.get('state') if 'state' in resource else resource.get('module'),
                    resource.get('fun'),
                    'unknown'
                )
            )

            conn.commit()

    if lowstate_req:
        meta_sql = '''INSERT INTO salt_resources_meta
                      (id, options)
                      VALUES (%s, %s)
                      ON CONFLICT (id) DO UPDATE
                        SET options = excluded.options,
                            alter_time = current_timestamp'''

        cur.execute(
            meta_sql, (
                'lowstate_data',
                '{}'
            )
        )

    _close_conn(conn)


def _up_to_date():
    '''
    TODO: document this method
    '''
    conn = _get_conn()
    cur = conn.cursor()
    #cur_dict = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    ret = False

    # if lowstate data are older than 1 day, refresh them
    cur.execute('SELECT alter_time FROM salt_resources_meta WHERE id = %s', ('lowstate_data',))
    alter_time = cur.fetchone()

    if alter_time:
        now = datetime.datetime.utcnow()
        day = datetime.timedelta(days=1)
        time_diff = now - alter_time[0].replace(tzinfo=None)
        if time_diff < day:
            ret = True
    else:
        skip = False

    _close_conn(conn)

    return ret


def _update_resources(ret):
    '''
    TODO: document this method
    '''
    conn = _get_conn(ret)
    cur = conn.cursor()

    cur.execute('SELECT id FROM salt_resources')
    resources_db = [res[0] for res in cur.fetchall()]
    resources = ret.get('return', {}).values()

    for resource in resources:
        rid = '%s|%s' % (ret.get('id'), resource.get('__id__'))
        if rid in resources_db:
            status = 'unknown'
            if resource.get('result', None) is not None:
                status = 'success' if resource.get('result') else 'failed'

            resource_sql = '''UPDATE salt_resources SET (status, last_ret, alter_time) = (%s, %s, current_timestamp)
                                WHERE id = %s'''

            cur.execute(
                resource_sql, (
                    status,
                    repr(resource),
                    rid
                )
            )

            conn.commit()

    _close_conn(conn)


def returner(ret):
    '''
    Return data to a postgres server
    '''
    #LOG.warning('RET: %s' % repr(ret))
    supported_funcs = ['state.sls', 'state.apply', 'state.highstate']
    test = 'test=true' in [arg.lower() for arg in ret.get('fun_args', [])]

    if ret.get('fun') in supported_funcs and not test:
        is_reclass = [arg for arg in ret.get('fun_args', []) if arg.startswith('reclass')]
        if is_reclass or not _up_to_date():
            _get_lowstate_data()

        _update_resources(ret)

