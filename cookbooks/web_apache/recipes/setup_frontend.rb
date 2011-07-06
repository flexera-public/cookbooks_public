# Cookbook Name:: web_apache
# Recipe:: setup_frontend

if node[:web_apache][:ssl_enable]
  Chef::Log.info "Enabling SSL"
  include_recipe "web_apache::setup_frontend_ssl_vhost"
else
  Chef::Log.info "Using regular HTTP"
  include_recipe "web_apache::setup_frontend_http_vhost"
end
