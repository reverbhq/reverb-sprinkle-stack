package :mysql_client, :provides => :database do
  description 'MySQL Client'
  apt %w(mysql-client libmysqlclient-dev libmysql-ruby)

  verify do
    has_apt 'mysql-client'
  end
end

package :mysql_server do
  description 'MySQL Server'
  apt %w(mysql-server)

  requires :mysql_client

  verify do
    has_apt "mysql-server"
  end
end
