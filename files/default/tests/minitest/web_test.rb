require 'minitest/spec'

describe_recipe 'ganglia::web' do
  include MiniTest::Chef::Assertions
  include Minitest::Chef::Context
  include Minitest::Chef::Resources
  include Chef::Mixin::ShellOut
  
  describe 'packages' do
    it 'installs apache' do
      package("httpd").must_exist
    end

    it 'installs php' do
      package("php").must_exist
    end
  end

  describe 'installation' do
  
    it 'copies the web directory' do
      directory('/var/www/html/ganglia').must_exist
    end

    it 'creates the conf file' do
      file('/etc/ganglia-webfrontend/apache.conf').must_exist
    end

    it 'runs apache' do
      service('httpd').must_be_running
    end

    it 'runs apache on boot' do
      service('httpd').must_be_enabled
    end

    it 'downloads ganglia-web tarfile' do
      file("/usr/src/ganglia-#{node[:ganglia][:web_version]}.tar.gz").must_exist
    end
  end
end
