## To connect to MySQL from a terminal in the running service.

```
mysql \
  -u root \
  --password=$MYSQL_ROOT_PASSWORD
```


## To make free up space taken by binary logs

1. Connect to MySQL

2. Get a list of logs:
```
SHOW BINARY LOGS;
```

3. Purge logs before some date:
```
PURGE BINARY LOGS BEFORE '2022-05-08 22:46:26';
```

https://dev.mysql.com/doc/refman/8.0/en/purge-binary-logs.html


## Configuration can be added to this file:

```
/etc/mysql/conf.d/
```

https://github.com/docker-library/mysql/blob/master/8.0/config/my.cnf
