#
# Cookbook: collectd
# License: Apache 2.0
#
# Copyright 2010, Atari, Inc.
# Copyright 2015, Bloomberg Finance L.P.
#
require_relative 'helpers'
require 'poise'

module CollectdCookbook
  module Resource
    # A resource for managing collectd plugins.
    # @since 2.0.0
    class CollectdPlugin < Chef::Resource
      include Poise
      provides(:collectd_plugin)
      actions(:create, :delete)

      # @!attribute plugin_name
      # Name of the collectd plugin to install and configure.
      # @return [String]
      attribute(:plugin_name, kind_of: String, name_attribute: true)

      # @!attribute directory
      # Name of directory where plugin configuration resides. Defaults to
      # '/etc/collectd.d'.
      # @return [String]
      attribute(:directory, kind_of: String, default: '/etc/collectd.d')

      # @!attribute user
      # User which the configuration for {#plugin_name} is owned by.
      # Defaults to 'collectd.'
      # @return [String]
      attribute(:user, kind_of: String, default: 'collectd')

      # @!attribute group
      # Group which the configuration for {#plugin_name} is owned by.
      # Defaults to 'collectd.'
      # @return [String]
      attribute(:group, kind_of: String, default: 'collectd')

      # @!attribute options
      # Set of key-value options to configure the plugin.
      # @return [Hash, Mash]
      attribute(:options, option_collector: true)
    end
  end

  module Provider
    # @since 2.0.0
    class CollectdPlugin < Chef::Provider
      include Poise
      provides(:collectd_plugin)
      include CollectdCookbook::Helpers

      def action_create
        notifying_block do
          directory new_resource.directory do
            recursive true
            mode '0644'
          end

          directives = [
            '# This file is autogenerated by Chef.',
            '# Do not edit; All changes will be overwritten!',
            %(LoadPlugin "#{new_resource.plugin_name}"),
            %(<Plugin "#{new_resource.plugin_name}">),
            build_configuration(new_resource.options, 1),
            "</Plugin>\n"
          ]

          file ::File.join(new_resource.directory, "#{new_resource.plugin_name}.conf") do
            content directives.flatten.join("\n")
            mode '0644'
          end
        end
      end

      def action_delete
        notifying_block do
          file ::File.join(new_resource.directory, "#{new_resource.plugin_name}.conf") do
            action :delete
          end
        end
      end
    end
  end
end
