module Ricer4::Plugins::Abbo
  class Abbos < Ricer4::Plugin
    
    is_abbo_list_trigger :trigger => :abbos, :for => Ricer4::Plugins::Abbo::Abbonement

    def visible_relation(relation)
      Ricer4::Plugins::Abbo::Abbonement.for_target(abbo_target).joins(:abbo_item)
    end
    
  end
end
