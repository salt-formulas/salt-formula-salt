
from collections import OrderedDict


def __virtual__():
    return True


def _set_subtree(node, relationships):
    return {
        v: _set_subtree(v, relationships)
        for v in [x['id'] for x in relationships if node in x['require']]
    }


def _traverse_subtree(output, data):
    for key, value in data.items():
        output.append(key)
        _traverse_subtree(output, value)
    return output


def order_by_requisites(data):
    '''
    Returns dictionary ordered by require and require_by

    CLI Examples:

    .. code-block:: bash

        salt-call modelutils.order_by_requisites "{'dict':'value'}""

    Sample data

    passed_data:
      syslog2:
        pattern: 'syslog.*'
      syslog_tele1:
        type: parser
        require:
        - syslog1
      syslog1:
        pattern: 'syslog.*'
        require_in:
        - syslog2
      syslog_tele2:
        require:
        - syslog_tele1

    '''
    raw_key_list = []
    ordered_key_list = []
    output_dict = OrderedDict()

    for datum_id, datum in data.items():
        if 'require_in' in datum:
            for req in datum['require_in']:
                if 'require' not in data[req]:
                    data[req]['require'] = []
                data[req]['require'].append(datum_id)
            datum.pop('require_in')

    for datum_id, datum in data.items():
        if 'require' not in datum:
            datum['require'] = ['top']
        datum['id'] = datum_id
        raw_key_list.append(datum)

    tree_data = _set_subtree('top', raw_key_list)
    _traverse_subtree(ordered_key_list, tree_data)
    for key in ordered_key_list:
        output_dict[key] = data[key]

    return output_dict

