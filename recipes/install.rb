#
# Cookbook:: ms-zookeeper
# Recipe:: install
#
# Copyright:: 2018, The Authors, All Rights Reserved.

include_recipe 'jdk::install'

user 'zookeeper'

group 'zookeeper' do
  members 'zookeeper'
end

#Should validate checksum
remote_file "#{Chef::Config[:file_cache_path]}/zookeeper.tar.gz" do
  source "ftp://10.10.10.10/mirror/zookeeper/zookeeper-#{node['zookeeper']['version']}.tar.gz"
  ftp_active_mode node['ftp_active_mode']
  not_if { 	File.exists?('/srv/zookeeper') && Dir.entries('/srv/zookeeper').select {|f| !File.directory? f}.length > 0}
end

directory '/srv/zookeeper' do
  user 'zookeeper'
  group 'zookeeper'
end

execute "install zookeeper" do
  cwd Chef::Config[:file_cache_path]
  command "tar -xf #{Chef::Config[:file_cache_path]}/zookeeper.tar.gz -C /srv/zookeeper --strip-components 1"
  not_if { Dir.entries('/srv/zookeeper').select {|f| !File.directory? f}.length > 0 }
  only_if { File.exists?("#{Chef::Config[:file_cache_path]}/zookeeper.tar.gz") }
  notifies :run, 'execute[chown zookeeper]', :immediately
end

execute 'chown zookeeper' do
  command 'chown zookeeper:zookeeper -R /srv/zookeeper'
  action :nothing
end

directory '/srv/zookeeper/conf' do
  user 'zookeeper'
  group 'zookeeper'
  only_if { File.exists?('/srv/zookeeper') }
end

unit = template '/etc/systemd/system/zookeeper.service' do
  source 'zookeeper.service.erb'
end

execute 'systemd-reload' do
  command 'systemctl daemon-reload'
  user 'root'
  only_if { unit.updated_by_last_action? }
end
