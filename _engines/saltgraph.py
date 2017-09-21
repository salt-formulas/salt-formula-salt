# -*- coding: utf-8 -*-
'''
Saltgraph engine for catching returns of state runs, parsing them 
and passing them to flat database of latest Salt resource runs.
'''

# Import python libs
from __future__ import absolute_import
import datetime
import json
import logging

# Import salt libs
import salt.utils.event

# Import third party libs
try:
    import psycopg2
    import psycopg2.extras
    HAS_POSTGRES = True
except ImportError:
    HAS_POSTGRES = False

__virtualname__ = 'saltgraph'
log = logging.getLogger(__name__)


def __virtual__():
    if not HAS_POSTGRES:
        return False, 'Could not import saltgraph engine. python-psycopg2 is not installed.'
    return __virtualname__


def _get_conn(options={}):
    '''
    Return a postgres connection.
    '''
    host = options.get('host', '127.0.0.1')
    user = options.get('user', 'salt')
    passwd = options.get('passwd', 'salt')
    datab = options.get('db', 'salt')
    port = options.get('port', 5432)

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


def _get_lowstate_data(options={}):
    '''
    TODO: document this method
    '''
    conn = _get_conn(options)
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


def _up_to_date(options={}):
    '''
    TODO: document this method
    '''
    conn = _get_conn(options)
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


def _update_resources(event, options):
    '''
    TODO: document this method
    '''
    conn = _get_conn(options)
    cur = conn.cursor()

    cur.execute('SELECT id FROM salt_resources')
    resources_db = [res[0] for res in cur.fetchall()]
    resources = event.get('return', {}).values()

    for resource in resources:
        rid = '%s|%s' % (event.get('id'), resource.get('__id__'))
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


def start(host='salt', user='salt', password='salt', database='salt', port=5432, **kwargs):
    '''
    Listen to events and parse Salt state returns
    '''
    if __opts__['__role'] == 'master':
        event_bus = salt.utils.event.get_master_event(
                __opts__,
                __opts__['sock_dir'],
                listen=True)
    else:
        event_bus = salt.utils.event.get_event(
            'minion',
            transport=__opts__['transport'],
            opts=__opts__,
            sock_dir=__opts__['sock_dir'],
            listen=True)
        log.debug('Saltgraph engine started')

    while True:
        event = event_bus.get_event()
        supported_funcs = ['state.sls', 'state.apply', 'state.highstate']
        if event and event.get('fun', None) in supported_funcs:
            test = 'test=true' in [arg.lower() for arg in event.get('fun_args', [])]
            if not test:
                options = {
                    'host': host,
                    'user': user,
                    'passwd': password,
                    'db': database,
                    'port': port
                }
                is_reclass = [arg for arg in event.get('fun_args', []) if arg.startswith('reclass')]
                if is_reclass or not _up_to_date(options):
                    _get_lowstate_data(options)

                _update_resources(event, options)

