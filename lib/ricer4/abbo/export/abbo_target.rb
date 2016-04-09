module Ricer4::Plugins::Abbo
  class AbboTarget < ActiveRecord::Base
    
    belongs_to :target, :polymorphic => true
    
    arm_install do |m|
      m.create_table table_name do |t|
        t.integer :target_id,   :null => false
        t.string  :target_type, :null => false, :charset => :ascii, :collation => :ascii_bin
      end
    end
    
    def self.for(target)
      find_or_create_by({target: target})
    end
    
  end
  
end