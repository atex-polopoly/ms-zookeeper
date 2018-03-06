# # encoding: utf-8

# Inspec test for recipe ms-zookeeper::install

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe user('zookeeper') do
  it { should exist }
  its('groups') { should include('zookeeper') }
end

describe file('/srv/zookeeper') do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by 'zookeeper' }
  it { should be_grouped_into 'zookeeper' }
end

describe file('/srv/zookeeper/data') do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by 'zookeeper' }
  it { should be_grouped_into 'zookeeper' }
end


describe service('zookeeper') do
  it { should be_installed }
  it { should be_running }
  it { should be_enabled }
end
