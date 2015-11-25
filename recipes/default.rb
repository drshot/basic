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
	package "#{packages}" do
		action :install
	end
end 

remote_file "/opt/#{node.basic256.remote_version}" do
	source "http://sourceforge.net/projects/kidbasic/files/basic256/#{node.basic256.remote_version}"
end

bash 'configure_basic256' do
  user 'root'
  cwd '/opt/'
  code <<-EOH
  tar xvzf #{node.basic256.remote_version}
  EOH
end 

remote_file "/opt/#{node.basic256.local_version}/speak_lib.h" do
	source "http://espeak.sourceforge.net/speak_lib.h"
end

template "/opt/#{node.basic256.local_version}/Makefile" do
	source "Makefile.erb"
	action :create
end

template "/opt/#{node.basic256.local_version}/BasicMediaPlayer.cpp" do
	source "BasicMediaPlayer.cpp.erb"
	action :create
end

bash 'install_basic256' do
	cwd "/opt/#{node.basic256.local_version}"
	code <<-EOH
	make
	make install
	EOH
end