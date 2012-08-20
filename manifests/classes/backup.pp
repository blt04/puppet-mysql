/*
== Class: mysql::backup

Enable mysql daily backup script.

The script /usr/local/bin/mysql-backup.sh will be run every night. It runs
mysqldump --all-databases. Backups will be stored in /var/backups/mysql.

Attributes:
- $mysqldump_retention: defines if backup rotate on a weekly, monthly or yearly
  basis. Accepted values: "day", "week", "month", "year". Defaults to "day".

*/
class mysql::backup {

  if $mysqldump_retention {} else { $mysqldump_retention = "week" }

  file { "/var/backups/mysql":
    ensure  => directory,
    owner   => "root",
    group   => "adm",
    mode    => 750,
  }

  file {
    "/usr/local/bin/mysql-backup.sh":
      ensure => present,
      source => "puppet:///modules/mysql/mysql-backup.sh",
      owner => "root",
      group => "root",
      mode  => 555;
    "/usr/local/bin/mysql-backup-binlogs.sh":
      ensure => present,
      source => "puppet:///modules/mysql/mysql-backup-binlogs.sh",
      owner => "root",
      group => "root",
      mode  => 555;
    "/etc/cron.d/mysql_backup":
      ensure  => present,
      owner   => "root",
      group   => "root",
      mode    => 0644,
      content => inline_template("Managed by puppet\n\n30 2 * * *	root   /usr/local/bin/mysql-backup.sh <%= mysqldump_retention %>\n");
  }
}
