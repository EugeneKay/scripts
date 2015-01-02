#
# salt/states/services/nrpe/init.sls
# EugeneKay/scripts

# State to install & configure nrpe
#

nrpe:
  pkg.installed:
    - pkgs:
      - nrpe
      - nagios-common
      - nagios-plugins
      - nagios-plugins-load
      - nagios-plugins-ping
      - nagios-plugins-users
      - nagios-plugins-check-updates
  service:
    - running
    - enable: True
    - watch:
      - file: nrpe
  file.managed:
    - name: /etc/nagios/nrpe.cfg
    - source:
      - salt://services/nrpe/files/nrpe.cfg
    - mode: 644
    - user: root
    - group: root
    - requires: nrpe.pkg

nagios-check-bandwidth:
  file.managed:
    - name: /usr/lib64/nagios/plugins/check_bandwidth
    - source:
      - salt://services/nrpe/files/check_bandwidth.sh
    - mode: 755
    - user: root
    - group: root

nagios-check-mem:
  file.managed:
    - name: /usr/lib64/nagios/plugins/check_mem
    - source:
      - salt://services/nrpe/files/check_mem.pl
    - mode: 755
    - user: root
    - group: root
