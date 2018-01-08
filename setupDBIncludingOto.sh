#!/bin/bash
service mysql start
mysqladmin -u root password my_secret_password
mysql -uroot -pmy_secret_password -e "create database charaparser;"
mysql -uroot -pmy_secret_password -e "create database oto;"
mysql -uroot -pmy_secret_password charaparser < /opt/git/charaparser/setupDB.sql
mysql -uroot -pmy_secret_password oto < /opt/git/oto2/oto/setupDB.sql
mysql -uroot -pmy_secret_password -e "create user 'user'@'localhost' identified by 'password';"
mysql -uroot -pmy_secret_password -e "grant all privileges on charaparser.* to 'user'@'localhost';"
mysql -uroot -pmy_secret_password -e "grant all privileges on oto.* to 'user'@'localhost';"
service mysql stop
