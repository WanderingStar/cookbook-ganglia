require 'minitest/spec'

describe_recipe 'ganglia::source' do
  include MiniTest::Chef::Assertions
  include Minitest::Chef::Context
  include Minitest::Chef::Resources
  include Chef::Mixin::ShellOut
 
  it 'creates init script' do
   file('/etc/init.d/gmetad').must_exist
  end

  it 'creates rrds directory' do
    directory('/var/lib/ganglia/rrds').must_exist.with(:owner, "nobody")
  end

  it 'creates the conf file' do
    file('/etc/ganglia/gmetad.conf').must_exist
  end

  it 'starts the gmetad service' do
    service("gmetad").must_be_running
  end

  it 'enables the gmetad service' do
    service("gmetad").must_be_enabled
  end
end
