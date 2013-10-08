require 'minitest/spec'

describe_recipe 'ganglia::source' do
  include MiniTest::Chef::Assertions
  include Minitest::Chef::Context
  include Minitest::Chef::Resources
  include Chef::Mixin::ShellOut
 
  describe 'packages' do
    it 'installs apr-devel' do
      package('apr-devel').must_be_installed
    end

    it 'installs libconfuse-devel' do
      package('libconfuse-devel').must_be_installed
    end
 
    it 'installs expat-devel' do
      package('expat-devel').must_be_installed
    end

    it 'installs rrdtool-devel' do
      package('rrdtool-devel').must_be_installed
    end
  end

  it 'downloads tarfile' do
    file("/usr/src/ganglia-#{node[:ganglia][:version]}.tar.gz").must_exist
  end 

  it 'installs ganglia' do
    file('/usr/sbin/gmond').must_exist
  end

  it 'symlinks lib and lib64' do
    link("/usr/lib/ganglia").must_exist.with(
        :link_type, :symbolic).and(:to, "/usr/lib64/ganglia")
  end
end
