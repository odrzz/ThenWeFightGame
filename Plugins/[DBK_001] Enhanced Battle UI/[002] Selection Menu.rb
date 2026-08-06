#===============================================================================
# Battle Info UI - Selection menu.
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  # Explicitly hides all custom party icon sprites.
  #-----------------------------------------------------------------------------
  def pbHidePartyIcons
    2.times do |s|
      NUM_BALLS.times do |slot|
        sprite_key = "party_icon_#{s}_#{slot}"
        @sprites[sprite_key].visible = false if @sprites[sprite_key]
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Aliased to automatically hide party icons whenever Info UI is hidden.
  #-----------------------------------------------------------------------------
  alias party_icon_pbHideInfoUI pbHideInfoUI
  def pbHideInfoUI
    party_icon_pbHideInfoUI
    pbHidePartyIcons
  end

  #-----------------------------------------------------------------------------
  # Toggles the visibility of the selection menu.
  #-----------------------------------------------------------------------------
  def pbToggleBattleInfo
    return if pbInSafari?
    pbHideInfoUI if @enhancedUIToggle != :battler
    @enhancedUIToggle = (@enhancedUIToggle.nil?) ? :battler : nil
    (@enhancedUIToggle) ? pbSEPlay("GUI party switch") : pbPlayCloseMenuSE
    @sprites["enhancedUI"].visible = !@enhancedUIToggle.nil?
    index = (@battle.pbSideBattlerCount(0) == 3) ? 1 : 0
    pbUpdateBattlerSelection(0, index, true)
  end
  
  #-----------------------------------------------------------------------------
  # Updates icon sprites to be used for the selection menu.
  #-----------------------------------------------------------------------------
  def pbUpdateBattlerIcons
    @battle.allBattlers.each do |b|
      next if !b
      poke = (b.opposes?) ? b.displayPokemon : b.pokemon
      if !b.fainted?
        @sprites["info_icon#{b.index}"].pokemon = poke
        @sprites["info_icon#{b.index}"].visible = @enhancedUIToggle == :battler
        @sprites["info_icon#{b.index}"].setOffset(PictureOrigin::CENTER)
        if b.shadowPokemon?
          @sprites["info_icon#{b.index}"].set_shadow_icon_pattern
        elsif b.dynamax?
          @sprites["info_icon#{b.index}"].set_dynamax_icon_pattern
          color = (b.isSpecies?(:CALYREX)) ? Color.new(36, 243, 243) : Color.new(250, 57, 96)
        elsif b.tera?
          @sprites["info_icon#{b.index}"].set_tera_icon_pattern
        else
          @sprites["info_icon#{b.index}"].zoom_x = 1
          @sprites["info_icon#{b.index}"].zoom_y = 1
          @sprites["info_icon#{b.index}"].pattern = nil
        end
      else
        @sprites["info_icon#{b.index}"].visible = false
      end
      pbUpdateOutline("info_icon#{b.index}", poke)
      pbColorOutline("info_icon#{b.index}", color)
      pbShowOutline("info_icon#{b.index}", false)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draws the selection menu and mini party Pokémon icons.
  #-----------------------------------------------------------------------------
  def pbUpdateBattlerSelection(idxSide, idxPoke, select = false)
    @enhancedUIOverlay.clear if @enhancedUIOverlay
    
    # Hide all party icons FIRST so they don't linger on sub-screens
    pbHidePartyIcons

    return if @enhancedUIToggle != :battler
    ypos = 68
    textPos = []
    imagePos = [[@path + "select_bg", 0, ypos]]
    
    # Load background graphic for grey owner bar
    owner_bmp = AnimatedBitmap.new(@path + "info_owner")
    owner_bg = owner_bmp.bitmap

    2.times do |side|
      trainers = []
      count = @battle.pbSideBattlerCount(side)
      case side
      #-------------------------------------------------------------------------
      # Player's side.
      #-------------------------------------------------------------------------
      when 0
        @battle.allSameSideBattlers.each_with_index do |b, i|
          case count
          when 1 then iconX, bgX = 202, 173
          when 2 then iconX, bgX = 96 + (208 * i), 68 + (208 * i)
          when 3 then iconX, bgX = 32 + (168 * i), 4 + (169 * i)
          end
          iconY = ypos + 114
          nameX = iconX + 82
          if idxSide == side && idxPoke == i
            base, shadow = BASE_LIGHT, SHADOW_LIGHT
            if b.dynamax?
              shadow = (b.isSpecies?(:CALYREX)) ? Color.new(48, 206, 216) : Color.new(248, 32, 32)
            end
            imagePos.push([@path + "select_cursor", bgX, iconY - 28, 0, 52, 166, 52])
          else
            base, shadow = BASE_DARK, SHADOW_DARK
            imagePos.push([@path + "select_cursor", bgX, iconY - 28, 0, 0, 166, 52])
          end
          @sprites["info_icon#{b.index}"].x = iconX
          @sprites["info_icon#{b.index}"].y = iconY
          pbSetWithOutline("info_icon#{b.index}", [iconX, iconY, 300])
          imagePos.push([@path + "info_owner", bgX + 36, iconY + 12, 0, 0, 128, 20],
                        [@path + "info_gender", bgX + 148, iconY - 34, b.gender * 22, 0, 22, 22])
          textPos.push([_INTL("{1}", b.pokemon.name), nameX, iconY - 16, :center, base, shadow],
                       [@battle.pbGetOwnerFromBattlerIndex(b.index).name, nameX - 10, iconY + 14, 2, BASE_LIGHT, SHADOW_LIGHT])
        end
        @battle.player.each_with_index { |t, i| trainers.push([t, i]) if t.able_pokemon_count > 0 }
        
        # Shifted down to clear player's main selection box
        ballY = ypos + 172
        ballXFirst = 20
        ballXLast = Graphics.width - 168 - 20
        ballOffset = 2
      #-------------------------------------------------------------------------
      # Opponent's side.
      #-------------------------------------------------------------------------
      when 1
        @battle.allOtherSideBattlers.reverse.each_with_index do |b, i|
          case count
          when 1 then iconX, bgX = 202, 173
          when 2 then iconX, bgX = 96 + (208 * i), 68 + (208 * i)
          when 3 then iconX, bgX = 32 + (168 * i), 4 + (169 * i)
          end
          iconY = ypos + 38
          nameX = iconX + 82
          if idxSide == side && idxPoke == i
            base, shadow = BASE_LIGHT, SHADOW_LIGHT
            if b.dynamax?
              shadow = (b.isSpecies?(:CALYREX)) ? Color.new(48, 206, 216) : Color.new(248, 32, 32)
            end
            imagePos.push([@path + "select_cursor", bgX, iconY - 28, 0, 52, 166, 52])
          else
            base, shadow = BASE_DARK, SHADOW_DARK
            imagePos.push([@path + "select_cursor", bgX, iconY - 28, 0, 0, 166, 52])
          end
          @sprites["info_icon#{b.index}"].x = iconX
          @sprites["info_icon#{b.index}"].y = iconY
          pbSetWithOutline("info_icon#{b.index}", [iconX, iconY, 400])
          textPos.push([_INTL("{1}", b.displayPokemon.name), nameX, iconY - 16, :center, base, shadow])
          if @battle.trainerBattle?
            imagePos.push([@path + "info_owner", bgX + 36, iconY + 12, 0, 0, 128, 20])
            textPos.push([@battle.pbGetOwnerFromBattlerIndex(b.index).name, nameX - 10, iconY + 14, :center, BASE_LIGHT, SHADOW_LIGHT])
          end
          imagePos.push([@path + "info_gender", bgX + 148, iconY - 36, b.displayPokemon.gender * 22, 0, 22, 22]) if !b.isRaidBoss?
        end
        if @battle.opponent
          @battle.opponent.each_with_index { |t, i| trainers.push([t, i]) if t.able_pokemon_count > 0 } 
          
          # Shifted up to clear opponent's main selection box
          ballY = ypos - 32
          ballXFirst = Graphics.width - 168 - 20
          ballXLast = 20
          ballOffset = 3
        end
      end
      #-------------------------------------------------------------------------
      # Draws party icon lineups (Replacing Pokeball icons).
      #-------------------------------------------------------------------------
      if !trainers.empty?
        ballXMiddle = (Graphics.width / 2) - 72
        ballX = ballXMiddle
        trainers.each do |array|
          trainer, idxTrainer = *array
          if trainers.length > 1
            case trainer
            when trainers.first[0] then ballX = ballXFirst
            when trainers.last[0]  then ballX = ballXLast
            else                        ballX = ballXMiddle
            end
          end

          # Stretch info_owner graphic horizontally (168px) and vertically (24px)
          barX = ballX - 12
          barWidth = 168
          barHeight = 24
          @enhancedUIOverlay.stretch_blt(
            Rect.new(barX, ballY - ballOffset - 2, barWidth, barHeight),
            owner_bg,
            Rect.new(0, 0, 128, 20)
          )
          
          NUM_BALLS.times do |slot|
            pkmn = trainer.party[slot]
            sprite_key = "party_icon_#{side}_#{slot}"
            
            # Create sprite dynamically if it doesn't exist
            if !@sprites[sprite_key]
              @sprites[sprite_key] = PokemonIconSprite.new(nil, @viewport)
              @sprites[sprite_key].setOffset(PictureOrigin::CENTER)
            end
            
            icon_sprite = @sprites[sprite_key]
            
            if pkmn
              icon_sprite.pokemon = pkmn
              icon_sprite.x = ballX + (slot * 24) + 12  # Spaced 24px apart
              icon_sprite.y = ballY + 8
              icon_sprite.z = 500
              icon_sprite.zoom_x = 0.60
              icon_sprite.zoom_y = 0.60
              icon_sprite.visible = true
              
              # Visual feedback: Darkness for fainted, subtle tone for status conditions
              if !pkmn.able?
                icon_sprite.color = Color.new(0, 0, 0, 180)
              elsif pkmn.status != :NONE
                icon_sprite.color = Color.new(200, 50, 50, 80)
              else
                icon_sprite.color = Color.new(0, 0, 0, 0)
              end
            else
              icon_sprite.visible = false
            end
          end
          
          # Draws each trainer's Wonder Launcher points.
          if @battle.launcherBattle?
            path = Settings::WONDER_LAUNCHER_PATH
            maxPoints = Settings::WONDER_LAUNCHER_MAX_POINTS
            points = @battle.launcherPoints[side][idxTrainer]
            x = ballX - 16 + ((128 - (10 * maxPoints + 2)) / 2).floor
            y = (side == 0) ? ballY + 18 : ballY - 17
            maxPoints.times do |i|
              imagePos.push([path + "points", x + 10 * i, y, 0, 0, 12, 14])
              imagePos.push([path + "points", x + 10 * i, y, 12, 0, 12, 14]) if points >= i + 1
            end
          end
        end
      end
    end
    
    owner_bmp.dispose
    pbUpdateBattlerIcons
    pbDrawImagePositions(@enhancedUIOverlay, imagePos)
    pbDrawTextPositions(@enhancedUIOverlay, textPos)
    pbSelectBattlerInfo if select
  end
  
  #-----------------------------------------------------------------------------
  # Handles the controls for the selection menu.
  #-----------------------------------------------------------------------------
  def pbSelectBattlerInfo
    return if @enhancedUIToggle != :battler
    pbHideUIPrompt
    idxSide = 0
    idxPoke = (@battle.pbSideBattlerCount(0) < 3) ? 0 : 1
    battlers = [[], []]
    @battle.allSameSideBattlers.each { |b| battlers[0].push(b) }
    @battle.allOtherSideBattlers.reverse.each { |b| battlers[1].push(b) }
    battler = battlers[idxSide][idxPoke]
    idxBattler = @sprites["enhancedUIPrompts"].battler
    pbShowOutline("info_icon#{battler.index}")
    cw = @sprites["fightWindow"]
    switchUI = 0
    loop do
      pbUpdate(cw)
      pbUpdateInfoSprites
      oldSide = idxSide
      oldPoke = idxPoke
      break if Input.trigger?(Input::BACK) || Input.trigger?(Input::JUMPUP)
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        pbHidePartyIcons  # Hide party icons before opening inspect window
        ret = pbOpenBattlerInfo(battler, battlers)
        case ret
        when Array
          idxSide, idxPoke = ret[0], ret[1]
          battler = battlers[idxSide][idxPoke]
          pbUpdateBattlerSelection(idxSide, idxPoke)
          pbShowOutline("info_icon#{battler.index}")
        when Numeric
          switchUI = ret
          break
        when nil then break
        end
      elsif Input.trigger?(Input::LEFT) && @battle.pbSideBattlerCount(idxSide) > 1
        idxPoke -= 1
        idxPoke = @battle.pbSideBattlerCount(idxSide) - 1 if idxPoke < 0
        pbPlayCursorSE
      elsif Input.trigger?(Input::RIGHT) && @battle.pbSideBattlerCount(idxSide) > 1
        idxPoke += 1
        idxPoke = 0 if idxPoke > @battle.pbSideBattlerCount(idxSide) - 1
        pbPlayCursorSE
      elsif Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        idxSide = (idxSide == 0) ? 1 : 0
        if idxPoke > @battle.pbSideBattlerCount(idxSide) - 1
          until idxPoke == @battle.pbSideBattlerCount(idxSide) - 1
            idxPoke -= 1
          end
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::JUMPDOWN)
        if cw.visible
          switchUI = 1
          break
        elsif @battle.pbCanUsePokeBall?(idxBattler)
          switchUI = 2
          break
        end
      end
      if oldSide != idxSide || oldPoke != idxPoke
        pbUpdateBattlerSelection(idxSide, idxPoke)
        battler = battlers[idxSide][idxPoke]
        @battle.allBattlers.each do |b|
          showOutline = b.index == battler.index
          pbShowOutline("info_icon#{b.index}", showOutline)
        end
      end
    end
    pbHideInfoUI
    pbUpdateBattlerIcons
    case switchUI
    when 0 then pbPlayCloseMenuSE; pbRefreshUIPrompt
    when 1 then pbToggleMoveInfo(cw.battler, :none, cw)
    when 2 then pbToggleBallInfo(idxBattler)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Edited to allow the selection menu to be opened outside of the fight menu.
  #-----------------------------------------------------------------------------
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    pbRefreshUIPrompt(idxBattler, COMMAND_BOX)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler], mode)
    pbSelectBattler(idxBattler)
    ret = -1
    promptTimer = System.uptime
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      if Settings::UI_PROMPT_DISPLAY == 2 && pbShowingPrompt?
        pbToggleUIPrompt if System.uptime - promptTimer > 2
      end
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index & 1) == 1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if (cw.index & 0) == 0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index & 2) == 2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if (cw.index & 2) == 0
      end
      pbPlayCursorSE if cw.index != oldIndex
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::BACK) && mode > 0
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG
        pbPlayDecisionSE
        pbHideInfoUI
        ret = -2
        break
      elsif Input.trigger?(Input::JUMPUP) && !pbInSafari?
        pbToggleBattleInfo
        promptTimer = System.uptime
      elsif Input.trigger?(Input::JUMPDOWN) && !pbInSafari?
        if pbToggleBallInfo(idxBattler)
          ret = 1
          break
        end
        promptTimer = System.uptime
      end
    end
    return ret
  end
end