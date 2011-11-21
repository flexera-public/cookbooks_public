# Cookbook Name::
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'cgi'
require 'logger'

module RightScale
  module DnsTools
    class DNS
      def initialize(logger = nil)
        @logger = logger || Logger.new(STDOUT)
      end

      def action_set(id, user, password, address)
        raise 'Not implemented!'
      end
    end

    class AWS < DNS
      def action_set(id, user, password, address)
        zone_id, hostname = id.split(':')

        current_ip= `dig +short #{hostname}`.chomp

        aws_cred=<<EOF
%awsSecretAccessKeys = (
    "my-aws-account" => {
        id => "#{user}",
        key => "#{password}",
    },
);
EOF
        secrets_filename="/root/.aws-secrets"
        File.open(secrets_filename, "w") { |f| f.write aws_cred }
        File.chmod(0600, secrets_filename)

        endpoint = "https://route53.amazonaws.com/2010-10-01/"
        xml_doc = "https://route53.amazonaws.com/doc/2010-10-01/"
        ttl = 60
        record_type = 'A'

        modify_cmd=<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ChangeResourceRecordSetsRequest xmlns="#{xml_doc}">
  <ChangeBatch>
    <Comment>
    Modified by RightScale
    </Comment>
    <Changes>
      <Change>
        <Action>DELETE</Action>
        <ResourceRecordSet>
          <Name>#{hostname}.</Name>
          <Type>#{record_type}</Type>
          <TTL>#{ttl}</TTL>
          <ResourceRecords>
            <ResourceRecord>
              <Value>#{current_ip}</Value>
            </ResourceRecord>
          </ResourceRecords>
        </ResourceRecordSet>
      </Change>
      <Change>
        <Action>CREATE</Action>
        <ResourceRecordSet>
          <Name>#{hostname}.</Name>
          <Type>#{record_type}</Type>
          <TTL>#{ttl}</TTL>
          <ResourceRecords>
            <ResourceRecord>
              <Value>#{address}</Value>
            </ResourceRecord>
          </ResourceRecords>
        </ResourceRecordSet>
      </Change>
    </Changes>
  </ChangeBatch>
</ChangeResourceRecordSetsRequest>
EOF
        cmd_filename="/tmp/modify.xml"

        @logger.info("Changing IP for '#{hostname}' from '#{current_ip}' to '#{address}'")

        File.open(cmd_filename, "w") { |f| f.write modify_cmd }

        result = ""
        # Simple retry loop, sometimes the DNS call will flake out..
        5.times do |attempt|
          result = `/opt/rightscale/dns/dnscurl.pl --keyfile #{secrets_filename} --keyname my-aws-account -- -X POST -H "Content-Type: text/xml; charset=UTF-8" --upload-file #{cmd_filename} #{endpoint}hostedzone/#{zone_id}/rrset`
          break if result =~ /ChangeResourceRecordSetsResponse/
          @logger.info("DNS change not successful - waiting then retrying - attempt number #{attempt}")
          sleep 5
        end

        if(result =~ /ChangeResourceRecordSetsResponse/ ) then
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, output: #{result}"
        end
      end
    end

    class DME < DNS
      def action_set(id, user, password, address)
        query="username=#{CGI::escape(user)}&password=#{CGI::escape(password)}&id=#{id}&ip=#{CGI::escape(address)}"
        result = `curl -S -s -o - -f -g 'https://www.dnsmadeeasy.com/servlet/updateip?#{query}'`

        if( result =~ /success/ || result =~ /error-record-ip-same/   ) then
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, id=#{id}, address:#{address}, output:#{result}"
        end

        result
      end
    end

    class DynDNS < DNS
      def action_set(id, user, password, address)
        query="hostname=#{CGI::escape(id)}&myip=#{CGI::escape(address)}"
        result = `curl -u #{user}:#{password} -S -s -o - -f -g 'https://members.dyndns.org/nic/update?#{query}'`

        if(result =~ /nochg #{address}/ || result =~ /good #{address}/) then
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, output: #{result}"
        end

        result
      end
    end
  end
end
