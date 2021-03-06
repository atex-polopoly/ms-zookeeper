#
# Cookbook:: ms-zookeeper
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.


ruby_block 'assign zookeeper domain' do
  block do
    node.normal['zookeeper']['server_id'] = assign_to_zookeeper_domain(node['customer'],
                                                                       node['environment_type'],
                                                                       node['zookeeper']['number_of_zookeepers'],
                                                                       node['ipaddress'])
    node.normal['zookeeper']['domain_name'] = get_zookeeper_domain_name(node['customer'],
                                                                        node['environment_type'],
                                                                        node['zookeeper']['server_id'])
  end
  only_if { node['zookeeper']['server_id'].nil? }
end

template '/srv/zookeeper/conf/zoo.cfg' do
  source 'zoo.cnf.erb'
  variables({
    environment: node['environment_type'],
    group: node['customer'],
    number_of_zookeepers: node['zookeeper']['number_of_zookeepers']
    })
  owner 'zookeeper'
  group 'zookeeper'
  mode '0644'
end

template '/srv/zookeeper/conf/java.env' do
  source 'java.env.erb'
  variables({
    xmx: node['zookeeper']['xmx']
    })
  owner 'zookeeper'
  group 'zookeeper'
  mode '0644'
end

directory '/mnt/data/zookeeper/data' do
  owner 'zookeeper'
  group 'zookeeper'
  mode '0755'
  recursive true
  action :create
end

link '/srv/zookeeper/data' do
  to '/mnt/data/zookeeper/data'
  owner 'zookeeper'
  group 'zookeeper'
end

file '/srv/zookeeper/data/myid' do
  content  lazy { node['zookeeper']['server_id'].to_s }
  owner 'zookeeper'
  group 'zookeeper'
  mode '0644'
end
