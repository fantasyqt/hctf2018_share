service mysql start
mysql -uroot -e "SET GLOBAL INNODB_LARGE_PREFIX = ON;SET GLOBAL innodb_file_format = BARRACUDA;"

su rails <<EOF 
RAILS_ENV=production bundle exec rake db:migrate;
nohup bin/rails s -e production &
ls;
exit;
EOF
mysql -uroot -e "insert into hctf.users(id,email,encrypted_password,created_at,updated_at,role) values(1,'admin@admin.com','\$2a\$11\$1q/KBj1gGUYAQVndWuPPb.zm6QzYr9P2SjdWdarUFFX7WyqNn19/a','2018-12-05 14:10:10.055691','2018-12-05 14:10:10.055691','admin');"

