package :bundler do
  description "Bundler"
  requires :ruby

  gem "bundler"

  verify do
    has_gem "bundler"
  end
end
