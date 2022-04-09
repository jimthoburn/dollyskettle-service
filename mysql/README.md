To connect to MySQL from a terminal in the running service.

```
mysql \
  -u root \
  --password=$MYSQL_ROOT_PASSWORD
```


Configuration can be added to this file:

```
/etc/mysql/conf.d/
```

https://github.com/docker-library/mysql/blob/master/8.0/config/my.cnf
