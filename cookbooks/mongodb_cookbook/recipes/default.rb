#
# Cookbook:: mongodb_cookbook
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
include_recipe 'apt'
apt_update 'update_sources' do
  action :update
end

# include_recipe 'sc-mongodb::default'

apt_repository 'mongodb-org' do
  uri "http://repo.mongodb.org/apt/ubuntu"
  distribution "xenial/mongodb-org/3.2"
  components ["multiverse"]
  keyserver "hkp://keyserver.ubuntu.com:80"
  key "EA312927"
end

package 'mongodb-org' do
  options '--allow-unauthenticated'
  action :upgrade
end


template '/etc/mongod.conf' do
  source 'mongod.conf.erb'
  variables port: node['mongodb']['port'], bind_ip: node['mongodb']['bind_ip']
  mode '777'
  owner 'root'
  group 'root'
  notifies :restart, 'service[mongod]'
end

template '/lib/systemd/system/mongod.service' do
  source 'mongod.service.erb'
  mode '777'
  owner 'root'
  group 'root'
  notifies :restart, 'service[mongod]'
end

service 'mongod' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
