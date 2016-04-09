###
### Make the plugin toggle and provide a subscriber list
### No automatic actions are taken, it just offers some helper functions
###
### To work with subscribers, use:
###
### announce_targets{|target| ... }
###
module Ricer4::Extend::IsAnnounceTrigger
  DEFAULT_OPTIONS ||= {
    user: :public,
    user_default: false,
    channel: :operator,
    channel_default: false,
  }
  def is_announce_trigger(trigger_name, options={})
    class_eval do |klass|
      
      ActiveRecord::Magic::Options.merge(options, DEFAULT_OPTIONS)
  
      trigger_is trigger_name
      
      has_setting name: :announce, type: :boolean, scope: :user,    permission: options[:user],    default: options[:user_default]    if options[:user]
      has_setting name: :announce, type: :boolean, scope: :channel, permission: options[:channel], default: options[:channel_default] if options[:channel]
  
      if options[:user]
        has_usage '<boolean>', :scope => :user, :permission => options[:user], :function => :execute_toggle_announce_user 
        def execute_toggle_announce_user(boolean)
          get_plugin('Conf/ConfUser').set_var(self, :announce, boolean)
        end
      end

      if options[:channel]
        has_usage '<boolean>', :scope => :channel, :permission => options[:channel], :function => :execute_toggle_announce_channel
        def execute_toggle_announce_channel(boolean)
          get_plugin('Conf/ConfChannel').set_var(self, :announce, boolean)
        end
      end
      
      def announce_channels(no_current_scope=false, &block)
        Ricer4::Channel.online.each do |channel|
          if get_channel_setting(channel, :announce)
            yield(channel) unless (no_current_scope && channel == current_message.channel)
          end
        end
        nil
      end

      def announce_users(no_current_scope=false, &block)
        Ricer4::User.online.each do |user|
          if get_user_setting(user, :announce)
            yield(user) unless (no_current_scope && user == sender)
          end
        end
        nil
      end
      
      def announce_targets(no_current_scope=false, &block)
        announce_channels(no_current_scope, &block)
        announce_users(no_current_scope, &block)
      end
      
    end
  end
end
Ricer4::Plugin.extend(Ricer4::Extend::IsAnnounceTrigger)
