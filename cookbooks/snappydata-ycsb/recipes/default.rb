#
# Cookbook Name:: snappydata-ycsb
# Recipe:: default
#
# Copyright (C) 2016 K. S. Ernest (iFire) Lee
#
# All rights reserved - Do Not Redistribute
#

user node['snappydata-ycsb']['user'] do
  supports :manage_home => true
  comment 'User ' + node['snappydata']['user']
  home node['snappydata-ycsb']['home_dir']
  shell '/bin/bash'
  system true
  action :create
end

git node['snappydata-ycsb']['dir']  do
  repository 'https://github.com/brianfrankcooper/YCSB.git'
  revision 'f25f26f5e80cc417bae4b61fa7c1a4d963ce96b4'
  action :sync
  enable_submodules true
  user node['snappydata-ycsb']['user']
  group node['snappydata-ycsb']['group']
  timeout 3600
end

cookbook_file node['snappydata-ycsb']['dir'] + "/ycsb-0.8.0-SNAPSHOT-snappystore-01.patch" do
  source "ycsb-0.8.0-SNAPSHOT-snappystore-01.patch"
  owner node['snappydata-ycsb']['user']
  group node['snappydata-ycsb']['group']
  mode 00755
  action :create
end

cookbook_file node['snappydata-ycsb']['dir'] + "/revert-to-python-2.7.patch" do
  source "revert-to-python-2.7.patch"
  owner node['snappydata-ycsb']['user']
  group node['snappydata-ycsb']['group']
  mode 00755
  action :create
end

package 'dos2unix' do
  action :upgrade
end

package 'epel-release' do
end

package 'python2.7-minimal' do
  action :upgrade
end

execute "dos2unix-snappydata-ycsb-patch" do
  command "dos2unix " + node['snappydata-ycsb']['dir'] + "/ycsb-0.8.0-SNAPSHOT-snappystore-01.patch"
  user node['snappydata-ycsb']['user']
  group node['snappydata-ycsb']['group']
  cwd node['snappydata-ycsb']['dir']
end

unless Dir.exist? node['snappydata-ycsb']['dir'] + "/snappystore"
  execute "revert-to-python-2.7-patch" do
    command "patch -p1 < revert-to-python-2.7.patch"
    user node['snappydata-ycsb']['user']
    group node['snappydata-ycsb']['group']
    cwd node['snappydata-ycsb']['dir']
  end
  execute "apply-snappydata-ycsb-patch" do
    command "git apply ycsb-0.8.0-SNAPSHOT-snappystore-01.patch"
    user node['snappydata-ycsb']['user']
    group node['snappydata-ycsb']['group']
    cwd node['snappydata-ycsb']['dir']
  end
end

package 'maven' do
  action :upgrade
end

execute "load-ycsb" do
  command "./bin/ycsb load snappystore -P workloads/workloada -s -threads 4 -p recordcount=50000"
  user node['snappydata-ycsb']['user']
  group node['snappydata-ycsb']['group']
  cwd node['snappydata-ycsb']['dir']
end

execute "run-ycsb" do
  command "./bin/ycsb run snappystore -P workloads/workloada -s -threads 4 -p operationcount=50000 -p requestdistribution=zipfian"
  user node['snappydata-ycsb']['user']
  group node['snappydata-ycsb']['group']
  cwd node['snappydata-ycsb']['dir']
end
