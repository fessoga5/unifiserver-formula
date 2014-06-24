#
# vim: sts=2 ts=2 sw=2 expandtab autoindent
#
#Add repo for unifi
mongodb:
  pkgrepo.managed:
    - name: deb http://aptcacher01.core.irknet.lan:3142/downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen 
    - dist: dist 
#    - keyid: 7F0CEB10
#    - keyserver: keyserver.ubuntu.com

ubiquiti:
  pkgrepo.managed:
    - name: deb http://aptcacher01.core.irknet.lan:3142/www.ubnt.com/downloads/unifi/distros/deb/ubuntu ubuntu ubiquiti
    - dist: ubuntu 
    #- keyid: C0A52C50
    #- keyserver: keyserver.ubuntu.com

  pkg.latest:
    - name: unifi-beta 
    - refresh: True

libmongodb-perl:
  pkg.latest:  
    - name: libmongodb-perl
    - refresh: True

libswitch-perl:
  pkg.latest:  
    - name: libswitch-perl 
    - refresh: True
#  pkg.latest:
#    - name: mongodb 
#    - refresh: True

/etc/init.d/unifi:
  file.managed:
    - mode: 775
    - source: salt://unifiserver/unifi
    - require:
      - pkg: unifi-beta

/usr/local/sbin/unifi_miner.pl:
  file.managed:
    - mode: 775
    - source: salt://unifiserver/unifi_miner.pl
    - require:
      - pkg: unifi-beta

/usr/lib/unifi/data/sites/default/config.properties:
  file.managed:
    - mode: 775
    - source: salt://unifiserver/config.properties
    - require:
      - pkg: unifi-beta

