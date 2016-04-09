module Ricer4::Plugins::Abbo
  class Abbonement < ActiveRecord::Base
    
    belongs_to :abbo_item,   :class_name => 'Ricer4::Plugins::Abbo::AbboItem'
    belongs_to :abbo_target, :class_name => 'Ricer4::Plugins::Abbo::AbboTarget'
    
    arm_install do |m|
      m.create_table table_name do |t|
        t.integer :abbo_item_id,   :null => false
        t.integer :abbo_target_id, :null => false
        t.timestamps :null => false
      end
      m.add_index table_name, :abbo_item_id,   :name => :abbo_item_index
      m.add_index table_name, :abbo_target_id, :name => :abbo_target_index
    end
    
    def self.for_target(target)
      where(:abbo_target => AbboTarget.for(target))
    end
    
    def target
      abbo_target.target
    end

    def item
      abbo_item.item
    end
    
    def display_list_item(n=0)
      item.display_list_item(n)
    end
    def display_show_item(n=0)
      item.display_show_item(n)
    end
    
    search_syntax do
      search_by :text do |scope, phrases|
        scope
      end
    end
    
  end
  
end
