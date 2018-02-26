#
# Cookbook:: ms-zookeeper
# Recipe:: install
#
# Copyright:: 2018, The Authors, All Rights Reserved.

include_recipe 'jdk::install'

user 'zookeeper'

group zookeeper do
  member 'zookeeper'
end

#Should validate checksum
remote_file "#{Chef::Config[:file_cache_path]}/zookeeper.tar.gz" do
  source "ftp://10.10.10.10/mirror/zookeeper/zookeeper-#{node['zookeeper']['version']}.tar.gz"
  ftp_active_mode node['ftp_active_mode']
  not_if { 	File.exists?('/srv/zookeeper') }
end


execute "install zookeeper" do
  cwd Chef::Config[:file_cache_path]
  command "tar -xf #{Chef::Config[:file_cache_path]}/zookeeper.tar.gz -C /srv/zookeeper"
  not_if { File.exists?('/srv/zookeeper') }
  only_if { File.exists?("#{Chef::Config[:file_cache_path]}/zookeeper.tar.gz") }
end

execute 'chown zookeeper' do
  execute 'chown zookeeper:zookeeper -R /srv/zookeeper'
  not_if { File.stat('/srv/zookeeper').uid == x%(id -u zookeeper) &&  File.stat('/srv/zookeeper').gid == x%(id -g zookeeper) }
end

directory '/srv/zookeeper/conf' do
  user 'zookeeper'
  group 'zookeeper'
  only_if { File.exists?('/srv/zookeeper') }
end
