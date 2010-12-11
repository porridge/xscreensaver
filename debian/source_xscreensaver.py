'''apport package hook for xscreensaver

(c) 2009 Canonical Ltd.
Author: Brian Murray <brian@ubuntu.com>

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.  See http://www.gnu.org/copyleft/gpl.html for
the full text of the license.
'''

from apport.hookutils import *

def add_info(report):

    attach_file_if_exists(report, '/var/log/Xorg.0.log', 'XorgLog')
    attach_file_if_exists(report, '/var/log/Xorg.0.log.old', 'XorgLogOld')
    report['DisplayDevices'] = pci_devices(PCI_DISPLAY)
    report['glxinfo'] = command_output(['glxinfo'])
    nonfree_kernel_modules()
