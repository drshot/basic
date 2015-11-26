#
# Cookbook Name:: basic256
# Recipe:: default
#
# Copyright 2015', 'YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


execute "group_install" do
	command "yum groupinstall -y 'Development tools'"
end

package "epel-release" do
	action :install
end

execute "qt5" do 
 	command "yum install -y qt5*"
end

node.basic256.package.each do |packages|
	package packages do
		action :install
	end
end 

path = Chef::Config[:file_cache_path]

remote_file "/#{path}/#{node.basic256.remote_version}" do
	source "http://sourceforge.net/projects/kidbasic/files/basic256/#{node.basic256.remote_version}"
	action :create_if_missing
end

bash 'configure_basic256' do
  user 'root'
  cwd '/tmp/'
  code <<-EOH
  tar xvzf #{node.basic256.remote_version} -C /opt/
  EOH
  not_if do ::Dir.exists?("/opt/#{node.basic256.local_version}/") end
end 

remote_file "/opt/#{node.basic256.local_version}/speak_lib.h" do
	source "http://espeak.sourceforge.net/speak_lib.h"
	action :create_if_missing
end

template "/opt/#{node.basic256.local_version}/Makefile" do
	source "Makefile.erb"
	action :create
end

template "/opt/#{node.basic256.local_version}/BasicMediaPlayer.cpp" do
	source "BasicMediaPlayer.cpp.erb"
	action :create
end

execute 'make_tmp' do
	cwd "/opt/#{node.basic256.local_version}"
	command "make"
	not_if do ::Dir.exists?("/opt/#{node.basic256.local_version}/tmp") end
end

execute "make_basic256" do
	command "make install"
	not_if do ::File.exists?("/opt/#{node.basic256.local_version}/basic256") end
end