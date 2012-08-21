%w(build_essential bundler deploy_user git libxml passenger postgresql ruby).each do |lib|
  require "reverb/stack/#{lib}"
end
