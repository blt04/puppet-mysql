/*
== Class: mysql::rsnapshot-backup

Enable mysql rsnapshot backup script.
*/
class mysql::rsnapshot-backup {

  file {
    "/var/backups/mysql":
      ensure  => directory,
      owner   => "root",
      group   => "adm",
      mode    => 750;
    "/usr/local/bin/mysql-rsnapshot.sh":
      ensure => present,
      source => "puppet:///modules/mysql/mysql-rsnapshot.sh",
      owner => "root",
      group => "root",
      mode  => 555;
  }
}
