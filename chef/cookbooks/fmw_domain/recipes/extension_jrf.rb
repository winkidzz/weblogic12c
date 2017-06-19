#
# Cookbook Name:: fmw_domain
# Recipe:: extension_jrf
#
# Copyright 2015 Oracle. All Rights Reserved
#
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"
fail 'databag_key parameter cannot be empty' unless node['fmw_domain'].attribute?('databag_key')

include_recipe 'fmw_domain::domain'

domain_params =  begin
                data_bag_item('fmw_domains',node['fmw_domain']['databag_key'])
              rescue Net::HTTPServerException, Chef::Exceptions::ValidationFailed, Chef::Exceptions::InvalidDataBagPath
                [] # empty array for length comparison
              end
domain_params = domain_params.to_hash if domain_params.instance_of? Chef::EncryptedDataBagItem

fail 'did not find the data_bag_item' if domain_params.length == 0

restricted = false

if ['12.2.1', '12.2.1.1', '12.2.1.2', '12.1.3', '12.1.2'].include?(node['fmw']['version'])
  if node['fmw']['version'] == '12.1.2'
    wls_em_template      = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template_12.1.2.jar"
    wls_jrf_template     = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.jrf_template_12.1.2.jar"
  elsif node['fmw']['version'] == '12.1.3'
    wls_em_template      = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template_12.1.3.jar"
    wls_jrf_template     = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.jrf_template_12.1.3.jar"
  else
    if node['fmw_domain'].attribute?('restricted') and node['fmw_domain']['restricted'] == true
      wls_em_template        = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_restricted_template.jar"
      wls_jrf_template       = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.jrf_restricted_template.jar"
      restricted             = true
    else
      wls_em_template        = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template.jar"
      wls_jrf_template       = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.jrf_template.jar"
    end
  end
elsif ['10.3.6'].include?(node['fmw']['version'])
  wls_em_template        = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar"
  wls_jrf_template       = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/applications/jrf_template_11.1.1.jar"
end

if node['os'].include?('windows')

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/jrf.py' do
    source 'domain/extensions/jrf.py'
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              java_home_dir:                 node['fmw']['java_home_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              domain_dir:                    "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}".gsub('\\\\', '/').gsub('\\', '/'),
              domain_name:                   domain_params['domain_name'],
              app_dir:                       "#{node['fmw_domain']['apps_dir']}/#{domain_params['domain_name']}".gsub('\\\\', '/').gsub('\\', '/'),
              adminserver_name:              domain_params['adminserver_name'],
              tmp_dir:                       node['fmw']['tmp_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              version:                       node['fmw']['version'],
              wls_em_template:               wls_em_template,
              wls_jrf_template:              wls_jrf_template,
              repository_database_url:       domain_params['repository_database_url'],
              repository_prefix:             domain_params['repository_prefix'],
              restricted:                    restricted
              )
  end

  # make sure the domains directory exists
  directory node['fmw_domain']['apps_dir'] do
    recursive true
    action :create
  end

  # add domain extension em
  fmw_domain_wlst "WLST add jrf domain extension" do
    version             node['fmw']['version']
    script_file         "#{node['fmw']['tmp_dir']}/jrf.py"
    middleware_home_dir node['fmw']['middleware_home_dir']
    weblogic_home_dir   node['fmw']['weblogic_home_dir']
    java_home_dir       node['fmw']['java_home_dir']
    tmp_dir             node['fmw']['tmp_dir']
    repository_password domain_params['repository_password']
    not_if { ::File.exist?("#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/config/config.xml") == true and
             ::File.readlines("#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/config/config.xml").grep(/em.ear/).size > 0 }
  end
else

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/jrf.py' do
    source 'domain/extensions/jrf.py'
    mode 0755
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'],
              java_home_dir:                 node['fmw']['java_home_dir'],
              domain_dir:                    "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}",
              domain_name:                   domain_params['domain_name'],
              app_dir:                       "#{node['fmw_domain']['apps_dir']}/#{domain_params['domain_name']}",
              adminserver_name:              domain_params['adminserver_name'],
              tmp_dir:                       node['fmw']['tmp_dir'],
              version:                       node['fmw']['version'],
              wls_em_template:               wls_em_template,
              wls_jrf_template:              wls_jrf_template,
              repository_database_url:       domain_params['repository_database_url'],
              repository_prefix:             domain_params['repository_prefix'],
              restricted:                    restricted
              )
  end

  # make sure the domains directory exists
  directory node['fmw_domain']['apps_dir'] do
    mode 0775
    recursive true
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    action :create
  end

  # add domain extension em
  fmw_domain_wlst "WLST add jrf domain extension" do
    version             node['fmw']['version']
    script_file         "#{node['fmw']['tmp_dir']}/jrf.py"
    middleware_home_dir node['fmw']['middleware_home_dir']
    weblogic_home_dir   node['fmw']['weblogic_home_dir']
    java_home_dir       node['fmw']['java_home_dir']
    tmp_dir             node['fmw']['tmp_dir']
    os_user             node['fmw']['os_user']
    repository_password domain_params['repository_password']
    not_if { ::File.exist?("#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/config/config.xml") == true and
             ::File.readlines("#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/config/config.xml").grep(/em.ear/).size > 0 }
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
