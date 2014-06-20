#!/usr/bin/perl
#
# 21/03/2014
#
# UniFi database miner for Zabbix monitoring system. Tested with v3.1.6 controller Software
# 
# Just add some UserParameter to zabbix_agentd.conf and create proper items for Zabbix system.
# Example:
#           UserParameter = unifi.stat.ap[*],/usr/local/sbin/unifi_miner.pl $1 APCurrentState $2 $3
#           Zabbix item  =>  unifi.stat.ap[default, UAP_01, rx_bytes]
#           where 'default' is UniFi sitename, 'UAP_01' is Access Point Alias, 'rx_bytes' is counter name from UniFi database (ace > stat_current > ...)
#
#        or 
#           Zabbix item  =>  unifi.stat.ap[default, UAP_01, num_guests_clients]
#           where 'default' is UniFi sitename, 'UAP_01' is Access Point Alias, 'num_guests_clients' is alias for function that count guest numbers
#
# Some intersting counters is:	
#        rx_bytes - The number of bytes received by the UAP.
#        tx_bytes - The number of bytes transmitted by the UAP.
#        tx_dropped - The number of packets dropped during transmission.
#        ...see UniFi database for more ;)
#
# Tanx to Ubiquiti, UniFi Community and phpMoAdmin
#
#
# Mail all suggestion to sadman(a)sfi.komi.com
#
use MongoDB;
use Switch;

sub getSiteID{
   # sitename is first param of subroutine 
   return $db->get_collection('site')->find_one({'name' => "@_[0]"})->{_id};
}

sub getSiteDesc{
   # sitename is first param of subroutine 
   return $db->get_collection('site')->find_one({'name' => "@_[0]"})->{desc};
}

sub getAPID{
   # sitename is first param of subroutine 
   return $db->get_collection('device')->find_one({'name' => "@_[0]"})->{_id};
}

sub getAPMAC{
   # sitename is first param of subroutine 
   return $db->get_collection('device')->find_one({'name' => "@_[0]"})->{mac};
}

sub getAPCurrentState{
   # sitename is first param of subroutine 
   return $db->get_collection('stat_current')->find_one({'ap' => "@_[0]", 'o' => "ap"})->{@_[1]};
}

sub getAPCurrentClientsNum{
   # sitename is first param of subroutine 
   my $vaptable= $db->get_collection('cache_device')->find_one({'mac' => "@_[0]"})->{'vap_table'};
   # is guests data always at [0] and users data always at [1]?
   switch (@_[1]) {
      case "num_guests_clients" { return $vaptable->[0]{num_sta};}
      case "num_users_clients"  { return $vaptable->[1]{num_sta};}
      else          { return ($vaptable->[0]{num_sta}+$vaptable->[1]{num_sta});}
   }  
}

# Param0 = sitename
# if Param1 = APCurrentState, then Param2 = AP name, Param3 = Counter name
#
$param0=$ARGV[0];
$param1=$ARGV[1];
$param2=$ARGV[2];
$param3=$ARGV[3];

$dbhost="mongodb://127.0.0.1:27117";
$sitename=$param0;

$db = MongoDB::Connection->new(host => $dbhost)->get_database('ace');
$siteid=getSiteID($sitename);

#print "[*] Working with $siteid\n";

switch ($param1) {
   case "APCurrentState" {
      $apmac=getAPMAC($param2);
      switch ($param3) {
          case "num_guests_clients" { $res=getAPCurrentClientsNum($apmac, $param3); }
          case "num_users_clients"  { $res=getAPCurrentClientsNum($apmac, $param3); }
          case "num_all_clients"    { $res=getAPCurrentClientsNum($apmac, $param3); }
          # on default take value of counter (for example 'rx_bytes') from collection stat_current
          else                      { $res=getAPCurrentState($apmac, $param3); }
      }
   }
}
print "$res\n";
