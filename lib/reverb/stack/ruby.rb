package :ruby do
  description 'Ruby'
  version '1.9.3'
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz"

  requires :ruby_dependencies

  verify do
    has_executable "/usr/local/bin/ruby"
  end
end

package :ruby_dependencies do
  apt %{zlib1g-dev libssl-dev libreadline-dev libyaml-dev libcurl4-openssl-dev curl}

  requires :build_essential
end
