# encoding: utf-8
#
# Cookbook Name:: modcloth-hubot
# Recipe:: deploy
#
# Copyright 2013, ModCloth, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

template "/etc/default/#{node['modcloth_hubot']['service_name']}" do
  source node['modcloth_hubot']['etc_default_hubot_template_file']
  cookbook node['modcloth_hubot']['etc_default_hubot_cookbook']
  owner node['modcloth_hubot']['user']
  group node['modcloth_hubot']['group']
  mode 0400
  only_if { platform?('ubuntu') }
end

template "/etc/init/#{node['modcloth_hubot']['service_name']}.conf" do
  source node['modcloth_hubot']['upstart_conf_template_file']
  cookbook node['modcloth_hubot']['upstart_conf_cookbook']
  owner 'root'
  group 'root'
  mode 0644
  only_if { platform?('ubuntu') }
end

service node['modcloth_hubot']['service_name'] do
  provider Chef::Provider::Service::Upstart
  action :nothing
end

deploy_revision node['modcloth_hubot']['home'] do
  repo node['modcloth_hubot']['repo']
  revision node['modcloth_hubot']['revision']
  action node['modcloth_hubot']['deploy_action'].to_sym
  migrate false
  before_restart do
    execute 'echo before restart' do
      notifies :enable,
        "service[#{node['modcloth_hubot']['service_name']}]", :immediately
    end
  end
  restart do
    execute 'echo restarting' do
      notifies :start,
        "service[#{node['modcloth_hubot']['service_name']}]", :immediately
      notifies :restart,
        "service[#{node['modcloth_hubot']['service_name']}]", :immediately
    end
  end
  only_if { deployable? }
end