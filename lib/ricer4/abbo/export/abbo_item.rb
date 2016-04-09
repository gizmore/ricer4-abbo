module Ricer4::Plugins::Abbo
  class AbboItem < ActiveRecord::Base
    
    belongs_to :item, :polymorphic => true
    
    arm_install do |m|
      m.create_table table_name do |t|
        t.integer :item_id,   :null => false
        t.string  :item_type, :null => false, :charset => :ascii, :collation => :ascii_bin
      end
    end
    
    def self.for(abbonementable)
      find_or_create_by({item: abbonementable})
    end
    
  end
  
end

