from __future__ import absolute_import
# Let's not allow PyLint complain about string substitution
# pylint: disable=W1321,E1321

# Import python libs
import logging

# Import Salt libs
import salt.returners

# Import third party libs
try:
    import psycopg2
    import psycopg2.extras
    HAS_POSTGRES = True
except ImportError:
    HAS_POSTGRES = False

__virtualname__ = 'saltresource'
LOG = logging.getLogger(__name__)


def __virtual__():
    if not HAS_POSTGRES:
        return False, 'Could not import saltresource module; psycopg2 is not installed.'
    return __virtualname__


def _get_options(ret=None):
    '''
    Get the postgres options from salt.
    '''
    defaults = {'host': '127.0.0.1',
                'user': 'salt',
                'passwd': 'salt',
                'db': 'salt',
                'port': '5432'}

    _options = {}
    for key, default in defaults.items():
        _options[key] = __salt__['config.get']('%s.%s' % (__virtualname__, key), default)

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


def graph_data(*args, **kwargs):
    '''
    Returns graph data for visualization app

    CLI Examples:

    .. code-block:: bash

        salt '*' saltresource.graph_data
 
    '''
    conn = _get_conn()
    cur_dict = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    cur_dict.execute('SELECT host, service, status FROM salt_resources')
    resources_db = [dict(res) for res in cur_dict]
    db_dict = {}

    for resource in resources_db:
        host = resource.get('host')
        service = '.'.join(resource.get('service').split('.')[:2])
        status = resource.get('status')

        if db_dict.get(host, None):
            if db_dict[host].get(service, None):
                service_data = db_dict[host][service]
                service_data.append(status)
            else:
                db_dict[host][service] = [status]
        else:
            db_dict[host] = {service: []}

    graph = []
    for host, services in db_dict.items():
        for service, statuses in services.items():
            status = 'unknown'
            if 'failed' in statuses:
                status = 'failed'
            elif 'success' in statuses and not ('failed' in statuses or 'unknown' in statuses):
                status = 'success'
            datum = {'host': host, 'service': service, 'status': status}
            graph.append(datum)

    _close_conn(conn)

    return {'graph': graph}


def host_data(host, **kwargs):
    '''
    Returns data describing single host

    CLI Examples:

    .. code-block:: bash

        salt-call saltresource.host_data '<minion_id>'
 
    '''
    conn = _get_conn()
    cur_dict = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    sql = 'SELECT host, service, resource_id, last_ret, status FROM salt_resources WHERE host=%s'
    cur_dict.execute(sql, (host,))
    resources_db = [dict(res) for res in cur_dict]
    db_dict = {}

    for resource in resources_db:
        host = resource.get('host')
        service = '.'.join(resource.get('service').split('.')[:2])
        status = resource.get('status')

        if db_dict.get(host, None):
            if db_dict[host].get(service, None):
                service_data = db_dict[host][service]
                service_data.append(status)
            else:
                db_dict[host][service] = [status]
        else:
            db_dict[host] = {service: []}

    graph = []

    for host, services in db_dict.items():
        for service, statuses in services.items():
            status = 'unknown'
            if 'failed' in statuses:
                status = 'failed'
            elif 'success' in statuses and not ('failed' in statuses or 'unknown' in statuses):
                status = 'success'
            resources = [{'service': r.get('service', ''), 'resource_id': r.get('resource_id', ''), 'last_ret': r.get('last_ret', None), 'status': r.get('status', '')}
                         for r
                         in resources_db
                         if r.get('service', '').startswith(service)]
            datum = {'host': host, 'service': service, 'status': status, 'resources': resources}
            graph.append(datum)

    _close_conn(conn)

    return {'graph': graph}


def sync_db(*args, **kwargs):
    conn = _get_conn()
    cur = conn.cursor()

    resources_sql = '''
      CREATE TABLE IF NOT EXISTS salt_resources (
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
    '''
    cur.execute(resources_sql)
    conn.commit()

    resources_meta_sql = '''
      CREATE TABLE IF NOT EXISTS salt_resources_meta (
        id           varchar(255) NOT NULL UNIQUE,
        options      json NULL,
        alter_time   TIMESTAMP WITH TIME ZONE DEFAULT now()
      );
    '''
    cur.execute(resources_meta_sql)
    _close_conn(conn)

    return True


def flush_db(*args, **kwargs):
    conn = _get_conn()
    cur = conn.cursor()
    result = True

    resources_sql = 'DELETE FROM salt_resources'
    try:
        cur.execute(resources_sql)
        conn.commit()
    except Exception as e:
        LOG.warning(repr(e))
        result = False

    resources_meta_sql = 'DELETE FROM salt_resources_meta'
    try:
        cur.execute(resources_meta_sql)
        _close_conn(conn)
    except Exception as e:
        LOG.warning(repr(e))
        result = False

    return result


def destroy_db(*args, **kwargs):
    conn = _get_conn()
    cur = conn.cursor()

    resources_sql = 'DROP TABLE IF EXISTS salt_resources;'
    cur.execute(resources_sql)
    conn.commit()

    resources_meta_sql = 'DROP TABLE IF EXISTS salt_resources_meta;'
    cur.execute(resources_meta_sql)
    _close_conn(conn)

    return True

