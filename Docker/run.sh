service mysql start
mysql -uroot -e "SET GLOBAL INNODB_LARGE_PREFIX = ON;SET GLOBAL innodb_file_format = BARRACUDA;"

su rails <<EOF 
RAILS_ENV=production bundle exec rake db:migrate;
nohup bin/rails s -e production &
exit
EOF
