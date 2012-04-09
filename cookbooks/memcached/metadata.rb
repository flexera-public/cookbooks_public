maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Cookbook for a memcached server setup."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))

version          "0.0.1"

depends "rs_utils"

recipe  "memcached::default", "Default recipe for memcached setup"


