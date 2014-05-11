#
# Cookbook Name:: nginx
# Recipe:: ngx_pagespeed_module
#
# Author:: Joseph Passavanti (<gottaloveit@gmail.com>)
#
# Copyright 2014, Joseph Passavanti
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Verify dependencies
packages = value_for_platform_family(
  %w(rhel fedora) => %w(gcc-c++ pcre-dev pcre-devel zlib-devel make),
  %w(gentoo)      => [],
  %w(ubuntu debian)     => %w(build-essential zlib1g-dev libpcre3 libpcre3-dev)
)

packages.each do |name|
  package name
end

ngx_pagespeed_source = "https://github.com/pagespeed/ngx_pagespeed/archive/v#{node['nginx']['ngx_pagespeed']['version']}.tar.gz"
tar_location = "#{Chef::Config['file_cache_path']}/ngx_pagespeed_#{node['nginx']['ngx_pagespeed']['version']}.tar.gz"
module_location = "#{Chef::Config['file_cache_path']}/ngx_pagespeed-#{node['nginx']['ngx_pagespeed']['version']}"

remote_file tar_location do
  source   ngx_pagespeed_source
  owner    'root'
  group    'root'
  mode     '0644'
end

bash 'extract_ngx_pagespeed' do
  cwd  ::File.dirname(tar_location)
  user 'root'
  code <<-EOH
    tar -zxf #{tar_location}
	cd #{module_location}
	wget https://dl.google.com/dl/page-speed/psol/#{node['nginx']['ngx_pagespeed']['psol_version']}.tar.gz
	tar -zxf #{node['nginx']['ngx_pagespeed']['psol_version']}.tar.gz
  EOH
  not_if { ::File.exists?("#{module_location}/psol") }
end

directory node['nginx']['ngx_pagespeed']['conf_filecachepath'] do
  owner node['nginx']['user']
  group node['nginx']['group']
  mode 0755
  action :create
  not_if { node['nginx']['ngx_pagespeed']['conf_tmpfs_filecachepath'] }
end

mount node['nginx']['ngx_pagespeed']['conf_filecachepath'] do
  pass     0
  fstype   "tmpfs"
  device   "/dev/null"
  options  "nr_inodes=999k,mode=755,size=#{node['nginx']['ngx_pagespeed']['conf_tmpfs_filecachepath_size']}"
  action   [:mount, :enable]
  only_if { node['nginx']['ngx_pagespeed']['conf_tmpfs_filecachepath'] }
end

template 'ngx_pagespeed.conf' do
  path   "#{node['nginx']['dir']}/conf.d/ngx_pagespeed.conf"
  source 'modules/ngx_pagespeed_conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  notifies :reload, 'service[nginx]', :delayed
end

template 'ngx_pagespeed.siteconfig' do
  path   "#{node['nginx']['dir']}/conf.d/ngx_pagespeed.siteconfig"
  source 'modules/ngx_pagespeed.siteconfig.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  notifies :reload, 'service[nginx]', :delayed
end

node.run_state['nginx_configure_flags'] =
    node.run_state['nginx_configure_flags'] | ["--add-module=#{module_location}"]
