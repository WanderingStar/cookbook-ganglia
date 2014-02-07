directory "/etc/ganglia-webfrontend"

include_recipe "apache2"

if node[:ganglia][:server_auth_method] == "openid"
then
  include_recipe "apache2::mod_auth_openid"
end

case node[:platform_family]
when "debian"
  package "ganglia-webfrontend"
  conf_file = "/etc/apache2/sites-enabled/ganglia"
  content_location = "/usr/share/ganglia-webfrontend"

when "rhel", "fedora"
  package "httpd"
  package "php"
  include_recipe "ganglia::source"
  include_recipe "ganglia::gmetad"
 
  remote_file "/usr/src/ganglia-#{node[:ganglia][:web_version]}.tar.gz" do
    source node[:ganglia][:web_uri]
    checksum node[:ganglia][:web_checksum]
  end

  src_path = "/usr/src/ganglia-#{node[:ganglia][:web_version]}"

  execute "untar ganglia" do
    command "tar xzf ganglia-#{node[:ganglia][:web_version]}.tar.gz"
    creates src_path
    cwd "/usr/src"
  end


  execute "copy web directory" do
    command "make install"
    creates "/var/www/html/ganglia"
    cwd "/usr/src/ganglia-web-#{node[:ganglia][:web_version]}"
  end
  conf_file = "/etc/httpd/sites-enabled/ganglia"
  content_location = "/var/www/html/ganglia"
end

template "/etc/ganglia-webfrontend/apache.conf" do
  source "apache.conf.erb"
  mode 00644
  variables(
    :content_location => content_location
  )
  notifies :reload, "service[apache2]"
end

link conf_file do
  to "/etc/ganglia-webfrontend/apache.conf"
  notifies :restart, "service[apache2]"
end

service "apache2" do
  service_name "httpd" if platform_family?( "rhel", "fedora" )
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
