service mysql start

mysql -uroot -e"create database hctf;GRANT USAGE ON *.* TO 'hctf'@'localhost' IDENTIFIED BY '92e53104c0d3d9e597065abc779d118c';GRANT ALL ON hctf.* TO 'hctf'@'localhost';FLUSH PRIVILEGES;"


