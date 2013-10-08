require 'minitest/spec'

describe_recipe 'ganglia::graphite' do
  include MiniTest::Chef::Assertions
  include Minitest::Chef::Context
  include Minitest::Chef::Resources
  include Chef::Mixin::ShellOut

  it 'creates graphite file' do
    file('/usr/local/sbin/ganglia_graphite.rb').must_exist
  end

  it 'crons graphite' do
    cron("ganglia_graphite").must_exist
  end

end
