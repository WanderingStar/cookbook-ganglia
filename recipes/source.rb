include_recipe 'build-essential'

if node[:platform_family] == 'rhel'
  include_recipe 'yum-epel'
  package 'apr-devel'
  package 'libconfuse-devel'
  package 'expat-devel'
  package 'rrdtool-devel'
  package 'python-devel'
end

remote_file "/usr/src/ganglia-#{node[:ganglia][:version]}.tar.gz" do
  source node[:ganglia][:uri]
  checksum node[:ganglia][:checksum]
end

src_path = "/usr/src/ganglia-#{node[:ganglia][:version]}"

execute "untar ganglia" do
  command "tar xzf ganglia-#{node[:ganglia][:version]}.tar.gz"
  creates src_path
  cwd "/usr/src"
end

execute "configure ganglia build" do
  command "./configure --with-gmetad --with-libpcre=no --sysconfdir=/etc/ganglia"
  creates "#{src_path}/config.log"
  cwd src_path
end

execute "build ganglia" do
  command "make"
  creates "#{src_path}/gmond/gmond"
  cwd src_path
end

execute "install ganglia" do
  command "make install"
  creates "/usr/sbin/gmond"
  cwd src_path
end

link "/usr/sbin/gmond" do
  to "/usr/local/sbin/gmond"
end

link "/usr/lib/ganglia" do
  to "/usr/local/lib64/ganglia"
  only_if do
    node[:kernel][:machine] == "x86_64" and
      platform_family?( "rhel", "fedora" )
  end
end
