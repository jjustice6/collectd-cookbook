require 'spec_helper'

describe_recipe 'collectd::server' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  it { expect(chef_run).to include_recipe('collectd::default') }

  it do
    expect(chef_run).to create_collectd_plugin('network')
    .with(options: {'listen' => '0.0.0.0'})
  end

  context 'with default attributes' do
    it 'converges successfully' do
      chef_run
    end
  end
end
