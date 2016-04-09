module Ricer4::Plugins::Abbo::Abbonementable
  def abbonementable_by(abbo_classes)
    class_eval do |klass|

      @abbo_classes = abbo_classes
      def abbo_classes; self.class.abbo_classes; end;
      def self.abbo_classes; @abbo_classes; end;
      def self.abbonements; Ricer4::Plugins::Abbo::Abbonement.joins(:abbo_item).where("abbo_items.item_type = ?", self.name); end
      def self.abbonements_for(abbo_class); abbonements.joins(:abbo_target).where("abbo_targets.target_type = ?", abbo_class.name); end
      
      def can_abbonement?(abbonement)
        abbo_classes.include?(abbonement.class)
      end
      
      def abbonemented?(abbonement)
        abbo(abbonement) != nil
      end
      
      def abbonement!(abbonement)
        return false unless can_abbonement?(abbonement)
        return true if abbonemented?(abbonement)
        Ricer4::Plugins::Abbo::Abbonement.create!({abbo_target:abbo_target(abbonement), abbo_item:abbo_item})
        return true
      end
      
      def unabbonement!(abbonement)
        return true unless abbonemented?(abbonement)
        abbo_relation(abbonement).delete_all
      end
      
      def abbonements
        Ricer4::Plugins::Abbo::Abbonement.where(abbo_item:abbo_item)
      end
  
      private
      
      def abbo_item
        Ricer4::Plugins::Abbo::AbboItem.for(self)
      end
      
      def abbo_target(abbonement)
        self.class.abbo_target(abbonement)
      end
      
      def self.abbo_target(abbonement)
        Ricer4::Plugins::Abbo::AbboTarget.for(abbonement)
      end
      
      def abbo_relation(abbonement)
        Ricer4::Plugins::Abbo::Abbonement.where({abbo_target:abbo_target(abbonement), abbo_item:abbo_item})        
      end
      
      def abbo(abbonement)
        abbo_relation(abbonement).first
      end
      
    end
  end
end

ActiveRecord::Base.extend Ricer4::Plugins::Abbo::Abbonementable
