require 'net/http'

OPEN_TIMEOUT = 2


def assign_to_zookeeper_domain(group, environment, number_of_zookeepers, ip)

  srand
  sleep(OPEN_TIMEOUT + rand(10))

  hosted_zone = `aws route53 list-hosted-zones --query 'HostedZones[0].Id'`

  for i in 1..number_of_zookeepers
    domain = get_zookeeper_domain_name(group, environment, i)
    if is_domain_free(domain, 2888)
      create_record_set(domain, ip, hosted_zone)
      return i
    end
  end
  abort 'no free zookeeper domain'
end

def is_domain_free(domain, port)
  begin
    Net::HTTP.get(domain, port, open_timeout => OPEN_TIMEOUT)
  rescue Net::OpenTimeout
    return true
  end
  false
end

def create_record_set(record, ip, hosted_zone)
  `aws route53 change-resource-record-sets --hosted-zone-id '#{hosted_zone}' --change-batch '{"Changes":[{"Action": "UPSERT", "ResourceRecordSet": {"Name": "#{record}", "Type": "A", "TTL": 10, "ResourceRecords": [ {"Value": "#{ip}"}]}}]}'`
end

def get_zookeeper_domain_name(group, environment, index)
  "zookeeper.#{index}.#{environment}.#{group}.cloud.atex.com"
end
