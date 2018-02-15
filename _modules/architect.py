# -*- coding: utf-8 -*-
'''
Salt modules to work with the Architect service.
'''

# Import python libs
from __future__ import absolute_import
import logging

__virtualname__ = 'architect'

logger = logging.getLogger(__name__)


def __virtual__():
    return __virtualname__


def node_info():
    '''
    Get Salt minion metadata and forward it to the Architect master.

    CLI Examples:

    .. code-block:: bash

        salt-call architect.minion_info
    '''
    data = {
        'pillar': __salt__['pillar.data'](),
        'grain': __salt__['grains.items'](),
        'lowstate': __salt__['state.show_lowstate'](),
    }
    return data
