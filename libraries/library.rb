require 'resolv'

def dig(hash, *path)
  path.inject hash do |location, key|
    location.respond_to?(:keys) ? location[key] : nil
  end
end

def assign_to_zookeeper_domain(group, environment, number_of_zookeepers, ip)

  # Sleep a random amount of time to reduce risk of collisions when
  # multiple zookeeper start at the same time.
  srand
  sleep(rand(10))

  hosted_zone = `aws route53 list-hosted-zones --query 'HostedZones[0].Id'`.strip[1..-2]
  index = get_free_server_id("#{group}-#{environment}",number_of_zookeepers)
  domain = get_zookeeper_domain_name(group, environment, index)

  create_record_set(domain, ip, hosted_zone)
  index
end

def get_free_server_id(chef_environment, number_of_zookeepers)
  used_ids = []
  search(:node, "chef_environment:#{chef_environment} AND roles:zoo").each do |matching_node|
    unless dig(matching_node, 'zookeeper', 'server_id').nil?
      used_ids << matching_node['zookeeper']['server_id']
    end
  end
  for i in 1..number_of_zookeepers
    if !used_ids.include? i
      return i
    end
  end
  abort "All zookeeper domains are occupied: #{chef_environment} | #{number_of_zookeepers} | #{used_ids}"
end

def create_record_set(record, ip, hosted_zone)
  puts `aws route53 change-resource-record-sets --hosted-zone-id '#{hosted_zone}' --change-batch '{"Changes":[{"Action": "UPSERT", "ResourceRecordSet": {"Name": "#{record}", "Type": "A", "TTL": 10, "ResourceRecords": [ {"Value": "#{ip}"}]}}]}'`

  print "Waiting for DNS record for #{record} to become available..."
  loops = 0
  resolver = Resolv::DNS.new()
  loop do
    loops += 1
    if resolver.getaddresses(record).length > 0
      print 'Done!'
      break
    end
    if loops > 30
      print 'Aborting due to timeout.'
      break
    end
    print '.'
    sleep 1
  end
end

def get_zookeeper_domain_name(group, environment, index)
  "zoo#{index}.#{environment}.#{group}.cloud.atex.com"
end
