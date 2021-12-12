# Dolly’s Kettle, Service

This is a [blueprint](https://render.com/docs/infrastructure-as-code) for automatically setting up WordPress.

It’s used together with a content repository that has the WordPress files, uploads and a MySQL backup file.

The content repository has a file structure that looks like this:
```
html/
  ...
  wp-content/
    uploads/
  ...other wordpress files...
  ...
wordpress-database.sql
```

[A static web site](https://github.com/jimthoburn/dollyskettle.com) is generated with data from the WordPress API and published at [dollyskettle.com](https://dollyskettle.com/)
