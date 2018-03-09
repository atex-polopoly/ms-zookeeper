# # encoding: utf-8

# Inspec test for recipe ms-zookeeper::configure

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('/srv/zookeeper/data/myid') do
  it { should exist }
  it { should be_file }
  it { should be_owned_by 'zookeeper' }
  it { should be_grouped_into 'zookeeper' }
  its('mode') { should cmp '00644' }
  its('content') { should include('3')}
end

describe file('/srv/zookeeper/conf/zoo.cnf') do
  it { should exist }
  it { should be_file }
  it { should be_owned_by 'zookeeper' }
  it { should be_grouped_into 'zookeeper' }
  its('mode') { should cmp '00644' }
  its('content') { should include('server.1=zookeeper.1.prod.atx.cloud.atex.com:2888:3888')}
  its('content') { should include('server.2=zookeeper.2.prod.atx.cloud.atex.com:2888:3888')}
  its('content') { should include('server.3=zookeeper.3.prod.atx.cloud.atex.com:2888:3888')}
  its('content') { should include('dataDir=/srv/zookeeper/data')}
end

describe file('/srv/zookeeper/data') do
  it { should exist }
  it { should be_owned_by 'zookeeper' }
  it { should be_grouped_into 'zookeeper' }
  its('link_path') { should eq '/mnt/data/zookeeper/data' }
  its('mode') { should cmp '00755' }
  its('type') { should cmp 'link' }
end
