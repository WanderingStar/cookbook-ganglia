require 'minitest/spec'

describe_recipe 'ganglia::default' do
  include MiniTest::Chef::Assertions
  include Minitest::Chef::Context
  include Minitest::Chef::Resources
  include Chef::Mixin::ShellOut

  describe 'installation' do

    it 'runs ganglia-monitor' do
      assert service('ganglia-monitor').must_be_running
    end

    it 'runs ganglia-monitor on boot' do
      assert service('ganglia-monitor').must_be_enabled
    end

    it 'creates ganglia directory' do
      assert directory('/etc/ganglia').must_exist
    end

    it 'creates conf file' do
      assert file('/etc/ganglia./gmond.conf').must_exist
    end

end
