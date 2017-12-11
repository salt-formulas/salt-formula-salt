
from __future__ import absolute_import

import glob
import json
import logging
import os.path
import yaml

# Import third party libs
try:
    from jsonschema import validate as _validate
    from jsonschema.validators import validator_for as _validator_for
    from jsonschema.exceptions import SchemaError, ValidationError
    HAS_JSONSCHEMA = True
except ImportError:
    HAS_JSONSCHEMA = False

__virtualname__ = 'modelschema'

LOG = logging.getLogger(__name__)


def __virtual__():
    """
    Only load if jsonschema library exist.
    """
    if not HAS_JSONSCHEMA:
        return (
            False,
            'Can not load module jsonschema: jsonschema library not found')
    return __virtualname__


def _get_base_dir():
    return __salt__['config.get']('pilllar_schema_path',
                                  '/usr/share/salt-formulas/env')


def _dict_deep_merge(a, b, path=None):
    """
    Merges dict(b) into dict(a)
    """
    if path is None:
        path = []
    for key in b:
        if key in a:
            if isinstance(a[key], dict) and isinstance(b[key], dict):
                _dict_deep_merge(a[key], b[key], path + [str(key)])
            elif a[key] == b[key]:
                pass  # same leaf value
            else:
                raise Exception(
                    'Conflict at {}'.format('.'.join(path + [str(key)])))
        else:
            a[key] = b[key]
    return a


def schema_list():
    """
    Returns list of all defined schema files.

    CLI Examples:

    .. code-block:: bash

        salt-call modelutils.schema_list


    """
    output = {}
    schemas = glob.glob('{}/*/schemas/*.yaml'.format(_get_base_dir()))
    for schema in schemas:
        if os.path.exists(schema):
            role_name = schema.split('/')[-1].replace('.yaml', '')
            service_name = schema.split('/')[-3]
            print role_name, service_name
            name = '{}-{}'.format(service_name, role_name)
            output[name] = {
                'service': service_name,
                'role': role_name,
                'path': schema,
                'valid': schema_validate(service_name, role_name)[name]
            }
    return output


def schema_get(service, role):
    """
    Returns pillar schema for given service and role. If no service and role
    is specified, method will return all known schemas.

    CLI Examples:

    .. code-block:: bash

        salt-call modelutils.schema_get ntp server

    """
    schema_path = 'salt://{}/schemas/{}.yaml'.format(service, role)
    schema = __salt__['cp.get_file_str'](schema_path)
    if schema:
        try:
            data = yaml.safe_load(schema)
        except yaml.YAMLError as exc:
            raise Exception("Failed to parse schema:{}\n"
                            "{}".format(schema_path, exc))
    else:
        raise Exception("Schema not found:{}".format(schema_path))
    return {'{}-{}'.format(service, role): data}


def schema_validate(service, role):
    """
    Validates pillar schema itself of given service and role.

    CLI Examples:

    .. code-block:: bash

        salt-call modelutils.schema_validate ntp server

    """

    schema = schema_get(service, role)['{}-{}'.format(service, role)]
    cls = _validator_for(schema)
    LOG.debug("Validating schema..")
    try:
        cls.check_schema(schema)
        LOG.debug("Schema is valid")
        data = 'Schema is valid'
    except SchemaError as exc:
        LOG.error("SchemaError:{}".format(exc))
        data = repr(exc)
    return {'{}-{}'.format(service, role): data}


def model_validate(service=None, role=None):
    """
    Validates pillar metadata by schema for given service and role. If
    no service and role is specified, method will validate all defined
    services.

    CLI Example:
    .. code-block:: bash
        salt-run modelschema.model_validate keystone server

    """
    schema = schema_get(service, role)['{}-{}'.format(service, role)]
    model = __salt__['pillar.get']('{}:{}'.format(service, role))
    try:
        _validate(model, schema)
        data = 'Model is valid'
    except SchemaError as exc:
        LOG.error("SchemaError:{}".format(exc))
        data = repr(exc)
    except ValidationError as exc:
        LOG.error("ValidationError:{}\nInstance:{}\n"
                  "SchemaPath:{}".format(exc.message, exc.instance,
                                         exc.schema_path))
        raise Exception("ValidationError")
    return {'{}-{}'.format(service, role): data}


def data_validate(model, schema):
    """
    Validates model by given schema.

    CLI Example:
    .. code-block:: bash
        salt-run modelschema.data_validate {'a': 'b'} {'a': 'b'}
    """
    try:
        _validate(model, schema)
        data = 'Model is valid'
    except SchemaError as exc:
        LOG.error("SchemaError:{}".format(exc))
        data = str(exc)
    except ValidationError as exc:
        LOG.error("ValidationError:{}\nInstance:{}\n"
                  "SchemaPath:{}".format(exc.message, exc.instance,
                                         exc.schema_path))
        raise Exception("ValidationError")
    return data


def schema_from_tests(service):
    """
    Generate pillar schema skeleton for given service. Method iterates throught
    test pillars and generates schema scaffold structure in JSON format that
    can be passed to service like http://jsonschema.net/ to get the basic
    schema for the individual roles of the service.

    CLI Examples:

    .. code-block:: bash

        salt-call modelutils.schema_from_tests keystone
    """
    pillars = glob.glob(
        '{}/{}/tests/pillar/*.sls'.format(_get_base_dir(), service))
    raw_data = {}
    for pillar in pillars:
        if os.path.exists(pillar):
            with open(pillar, 'r') as stream:
                try:
                    data = yaml.load(stream)
                except yaml.YAMLError as exc:
                    data = {}
                    LOG.error('{}: {}'.format(pillar, repr(exc)))
            try:
                _dict_deep_merge(raw_data, data)
            except Exception as exc:
                LOG.error('{}: {}'.format(pillar, repr(exc)))
    if service not in raw_data.keys():
        raise Exception(
            "Could not find applicable  data "
            "for:{}\n at:{}".format(service, _get_base_dir()))
    data = raw_data[service]
    output = {}
    for role_name, role in data.items():
        output[role_name] = json.dumps(role)
    return output
