package :postgres_client, :provides => :database do
  description 'PostgreSQL Client'
  apt %w(postgresql-client libpq-dev)

  verify do
    has_apt 'postgresql-client'
  end
end

package :postgres_server do
  apt %w(postgresql)

  requires :postgres_client

  verify do
    has_apt "postgresql"
  end
end
