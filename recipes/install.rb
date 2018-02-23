#
# Cookbook:: ms-zookeeper
# Recipe:: install
#
# Copyright:: 2018, The Authors, All Rights Reserved.

include_recipe 'jdk::install'

#Should validate checksum
remote_file "#{Chef::Config[:file_cache_path]}/zookeeper-#{node['zookeeper']['version']}.tar.gz" do
  source "ftp://10.10.10.10/mirror/zookeeper/zookeeper-#{node['zookeeper']['version']}.tar.gz"
  ftp_active_mode node['ftp_active_mode']
  not_if { 	File.exists?('/srv/zookeeper') }
end


execute "untar-zookeeper" do
  cwd Chef::Config[:file_cache_path]
  command "tar -xf #{Chef::Config[:file_cache_path]}/zookeeper-#{node['zookeeper']['version']}.tar.gz"
  not_if { File.exists?('/srv/zookeeper') }
  only_if { File.exists?("#{Chef::Config[:file_cache_path]}/zookeeper-#{node['zookeeper']['version']}.tar.gz") }
end
