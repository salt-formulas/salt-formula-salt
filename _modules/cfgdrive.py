# -*- coding: utf-8 -*-

import json
import logging
import os
import shutil
import six
import tempfile
import yaml

from oslo_utils import uuidutils
from oslo_utils import fileutils
from oslo_concurrency import processutils

class ConfigDriveBuilder(object):
    """Build config drives, optionally as a context manager."""

    def __init__(self, image_file):
        self.image_file = image_file
        self.mdfiles=[]

    def __enter__(self):
        fileutils.delete_if_exists(self.image_file)
        return self

    def __exit__(self, exctype, excval, exctb):
        self.make_drive()

    def add_file(self, path, data):
        self.mdfiles.append((path, data))

    def _add_file(self, basedir, path, data):
        filepath = os.path.join(basedir, path)
        dirname = os.path.dirname(filepath)
        fileutils.ensure_tree(dirname)
        with open(filepath, 'wb') as f:
            if isinstance(data, six.text_type):
                data = data.encode('utf-8')
            f.write(data)

    def _write_md_files(self, basedir):
        for data in self.mdfiles:
            self._add_file(basedir, data[0], data[1])

    def _make_iso9660(self, path, tmpdir):

        processutils.execute('mkisofs',
            '-o', path,
            '-ldots',
            '-allow-lowercase',
            '-allow-multidot',
            '-l',
            '-V', 'config-2',
            '-r',
            '-J',
            '-quiet',
            tmpdir,
            attempts=1,
            run_as_root=False)

    def make_drive(self):
        """Make the config drive.
        :raises ProcessExecuteError if a helper process has failed.
        """
        try:
            tmpdir = tempfile.mkdtemp()
            self._write_md_files(tmpdir)
            self._make_iso9660(self.image_file, tmpdir)
        finally:
            shutil.rmtree(tmpdir)


def generate(
               dst,
               hostname,
               domainname,
               instance_id=None,
               user_data=None,
               network_data=None,
               saltconfig=None
            ):

    ''' Generate config drive

    :param dst: destination file to place config drive.
    :param hostname: hostname of Instance.
    :param domainname: instance domain.
    :param instance_id: UUID of the instance.
    :param user_data: custom user data dictionary. type: json
    :param network_data: custom network info dictionary. type: json
    :param saltconfig: salt minion configuration. type: json

    '''

    instance_md              = {}
    instance_md['uuid']      = instance_id or uuidutils.generate_uuid()
    instance_md['hostname']  = '%s.%s' % (hostname, domainname)
    instance_md['name']      = hostname

    if user_data:
      user_data = '#cloud-config\n\n' + yaml.dump(yaml.load(user_data), default_flow_style=False)
      if saltconfig:
        user_data += yaml.dump(yaml.load(str(saltconfig)), default_flow_style=False)

    data = json.dumps(instance_md)

    with ConfigDriveBuilder(dst) as cfgdrive:
      cfgdrive.add_file('openstack/latest/meta_data.json', data)
      if user_data:
        cfgdrive.add_file('openstack/latest/user_data', user_data)
      if network_data:
         cfgdrive.add_file('openstack/latest/network_data.json', network_data)
      cfgdrive.add_file('openstack/latest/vendor_data.json', '{}')
      cfgdrive.add_file('openstack/latest/vendor_data2.json', '{}')
