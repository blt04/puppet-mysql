class mysql::master inherits mysql::server {

  if $mysql_serverid {} else { $mysql_serverid = 1 }
  if $mysql_binlog {} else { $mysql_binlog = "mysqld-bin" }

  Augeas["my.cnf/replication"] {
    changes => [
      "set log-bin ${mysql_binlog}",
      "set server-id ${mysql_serverid}",
      "set expire_logs_days 7",
      "set max_binlog_size 100M"
    ],
  }

  if $mysql_binlog_format {
    augeas { "my.cnf/binlog-format":
      context => "$mycnfctx/mysqld/",
      changes => [
        "set binlog-format ${mysql_binlog_format}"
      ],
    }
  }
}
