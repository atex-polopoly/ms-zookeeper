#
# Cookbook:: ms-zookeeper
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.




file '/srv/zookeeper/data/myid' do
  content '1'#server id, needs some fancy schmancy logic to determine
end

template 'zoo.cnf' do
  source 'zoo.cnf.erb'
end
