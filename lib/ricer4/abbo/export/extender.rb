module Ricer4::Extend::AbboTriggers
  def is_abbo_trigger(options={})
    class_eval do |klass|
  
      klass.define_class_variable('@abbo_for_class', options[:for])
      
      def abbo_class; self.class.instance_variable_get('@abbo_for_class'); end
      def abbo_search(relation, term)
        relation.where(:id => term)
      end
      def _abbo_search(relation, term)
        if relation.respond_to?(:search)
          relation = relation.search(term)
        else
          relation = abbo_search(relation, term)
        end
        case relation.count
        when 0
          raise Ricer4::ExecutionException.new(tr('extender.is_list_trigger.err_not_found', classname: abbo_class.model_name.human))
        when 1
          relation.first
        else
          raise Ricer4::ExecutionException.new(tr('extender.is_search_trigger.err_ambigious', classname: abbo_class.model_name.human))
        end
      end
      def abbos_enabled(relation)
        relation
      end
      def abbos_visible(relation)
        relation
      end
      # def abbo_find(relation, term)
        # relation.find(term)
      # end
      protected
      def abbo_classname
        abbo_class.model_name.human
      end
      def abbos_item(abbo_item)
        Ricer4::Plugins::Abbo::AbboItem.for(abbo_item)
      end
      def abbo_item(arg)
        relation = abbo_class.all
        relation = abbos_enabled(relation)
        relation = abbos_visible(relation)
        _abbo_search(relation, arg)
      end
      def abbos_target
        Ricer4::Plugins::Abbo::AbboTarget.for(abbo_target)
      end
      def abbo_target
        current_message.channel || current_message.sender
      end
    end
  end
  
  def is_add_abbo_trigger(options={})
    class_eval do |klass|
      is_abbo_trigger(options)
      trigger_is options[:trigger] || :abbo
      def plugin_description(long); t!(:description) rescue I18n.t('ricer4.plugins.abbos.add_abbo.description', classname: abbo_classname); end
      has_usage  '<id>', function: :execute
      has_usage  '<search_term>', function: :execute
      def execute(arg)
        abbo_item = self.abbo_item(arg)
        return rplyr 'plugins.abbos.err_abbo_item', classname:abbo_classname if abbo_item.nil?
        return rplyr 'plugins.abbos.err_invalid_target', classname:abbo_classname unless abbo_item.can_abbonement?(abbo_target)
        return rplyr 'plugins.abbos.err_abbo_twice', classname:abbo_classname if abbo_item.abbonemented?(abbo_target)
        Ricer4::Plugins::Abbo::Abbonement.create({abbo_target:abbos_target, abbo_item:abbos_item(abbo_item)})
        return rplyr 'plugins.abbos.msg_abbonemented', classname:abbo_classname
      end
    end
  end

  def is_remove_abbo_trigger(options={})
    class_eval do |klass|
      is_abbo_trigger(options)
      trigger_is options[:trigger] || :unabbo
#      def description; I18n.t('ricer4.plugins.abbos.remove_abbo.description'); end
      has_usage  '<id>', function: :execute
      has_usage  '<search_term>', function: :execute
      def execute(arg)
        abbo_item = self.abbo_item(arg)
        return rplyr 'plugins.abbos.err_abbo_item', classname:abbo_classname if abbo_item.nil?
        return rplyr 'plugins.abbos.err_invalid_target', classname:abbo_classname unless abbo_item.can_abbonement?(abbo_target)
        return rplyr 'plugins.abbos.err_not_abboed', classname:abbo_classname unless abbo_item.abbonemented?(abbo_target)
        Ricer4::Plugins::Abbo::Abbonement.where({abbo_target:abbos_target, abbo_item:abbos_item(abbo_item)}).delete_all
        return rplyr 'plugins.abbos.msg_unabbonemented', classname:abbo_classname
      end
    end
  end

  def is_abbo_list_trigger(options={})
    class_eval do |klass|
      is_abbo_trigger(options)
      trigger = options.delete(:trigger)
      is_list_trigger trigger||:abbos, options
      def visible_relation(relation)
        Ricer4::Plugins::Abbo::Abbonement.for_target(abbo_target).joins(:abbo_item).where("abbo_items.item_type = ?", abbo_class.name)
      end
    end
  end

end

Ricer4::Plugin.extend Ricer4::Extend::AbboTriggers
