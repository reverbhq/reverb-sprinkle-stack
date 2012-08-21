package :passenger do
  description "Phusion Passenger with nginx"

  gem "passenger" do
    post :install, "sudo passenger-install-nginx-module --auto --auto-download --prefix=/usr/local/nginx"
  end

  verify do
    has_gem "passenger"
  end
end

package :nginx_passenger do
  description "Configure nginx installed through passenger"
  requires :passenger

  push_text File.read(File.join(File.dirname(__FILE__), 'nginx', 'init.d')), "/etc/init.d/nginx", :sudo => true do
    post :install, "sudo chmod +x /etc/init.d/nginx"
    post :install, "sudo /usr/sbin/update-rc.d -f nginx defaults"
    post :install, "sudo /etc/init.d/nginx start"
  end

  verify do
    has_executable "/usr/local/nginx/sbin/nginx"
    has_file "/etc/init.d/nginx"
  end
end
