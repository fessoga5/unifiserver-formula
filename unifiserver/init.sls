#
# vim: sts=2 ts=2 sw=2 expandtab autoindent
#
#Add repo for unifi
vlan:
  pkg.installed

mongodb:
  pkgrepo.managed:
    - name: deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen 
    - dist: dist 
    - keyid: 7F0CEB10
    - keyserver: keyserver.ubuntu.com

ubiquiti:
  pkgrepo.managed:
    - name: deb http://www.ubnt.com/downloads/unifi/distros/deb/ubuntu ubuntu ubiquiti
    - dist: ubuntu 
    - keyid: C0A52C50
    - keyserver: keyserver.ubuntu.com

  pkg.latest:
    - name: unifi-beta 
    - refresh: True

#  pkg.latest:
#    - name: mongodb 
#    - refresh: True

/etc/init.d/unifi:
  file.managed:
    - mode: 775
    - source: salt://unify/unifi
    - require:
      - pkg: unifi
