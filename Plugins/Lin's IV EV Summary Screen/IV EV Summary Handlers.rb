#===============================================================================
# Pokemon Summary handlers.
#===============================================================================
UIHandlers.add(:summary, :page_ivev, { 
  "name"      => "IV/EV",
  "suffix"    => "ivev",
  "order"     => 33,
  "options"   => [:item, :nickname, :pokedex, :mark, "Reset EV's"],
  "layout"    => proc { |pkmn, scene| scene.drawPageIVEV }
})
