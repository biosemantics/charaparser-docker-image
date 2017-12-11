#!/bin/bash
service mysql start
mysqladmin -u root password my_secret_password
mysql -uroot -pmy_secret_password -e "create database charaparser;"
mysql -uroot -pmy_secret_password charaparser < /root/git/charaparser/setupDB.sql
mysql -uroot -pmy_secret_password -e "create user 'user'@'localhost' identified by 'password';"
mysql -uroot -pmy_secret_password -e "grant all privileges on charaparser.* to 'user'@'localhost';"
service mysql stop
