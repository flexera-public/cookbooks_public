maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "All rights reserved"
description      "Installs/Configures block_device"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

recipe  "block_device::do_attach", "creates, format and mount block_device."

attribute "block_device/storage_type",
  :display_name => "Block Device Storage Type",
  :description => "Sets storage type to Volume (i.e.EBS) or Remote Object Store (i.e. s3, cloudfiles)",
  :choice => ["volume", "ros"],
  :type => "string",
  :required => true,
  :recipes => [ "block_device::do_attach" ]

