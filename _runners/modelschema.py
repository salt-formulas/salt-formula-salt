
# Import python libs
import logging
import glob
import os
import yaml

# Import salt modules
import salt.client

# Import third party libs
from jsonschema import validate
from jsonschema.validators import validator_for
from jsonschema.exceptions import SchemaError


__virtualname__ = 'modelschema'

LOG = logging.getLogger(__name__)

BASE_DIR = '/usr/share/salt-formulas/env/_formulas'


def _get_schemas():
    '''
    Method will return all known schemas.
    '''
    output = {}
    schemas = glob.glob('{}/*/schemas/*.yaml'.format(BASE_DIR))
    for schema in schemas:
        if os.path.exists(schema):
            filename = schema.split('/')[-1].replace('.yaml', '')
            service_name, role_name = filename.split('-')
            if service_name not in output:
                output[service_name] = {}
            with open(schema, 'r') as stream:
                try:
                    data = yaml.load(stream)
                except yaml.YAMLError as exc:
                    data = None
                    LOG.error(exc)
            output[service_name][role_name] = data
    return output


def validate_node_model(target, service, role):
    '''
    Validates pillar by schema for given given minion, service and role.
    If no service and role is specified, method will validate all
    defined services on minion.

    CLI Example:
    .. code-block:: bash
        salt-run modelschema.validate_node_model
    '''
    client = salt.client.LocalClient(__opts__['conf_file'])
    schema = _get_schemas()[service][role]
    result = {}

    validator = validator_for(schema)
    try:
        validator.check_schema(schema)
    except SchemaError as exception:
        LOG.error(exception)
        return result

    minions = client.cmd(target, 'pillar.data', timeout=1)
    for minion, pillar in minions.items():
        model = pillar[service][role]
        validation_result = validator(schema).validate(model)
        result[minion] = validation_result
    return result
