-- the function itself
function GPM()
      -- defione the current game time
      gold_time=GameRules:GetDOTATime(false, true)
      --condition for the bonuses to be given: game not paused, time has passed next gold time period.
      gold_run_condition= GameRules:IsGamePaused()==false and gold_time>=next_gold
      if gold_run_condition then -- if the condition or bonuses is met
            for _,bot in pairs(bots) do
                  bot:ModifyGold(GPM_value(next_gold), true, 0) -- give the gold of the currently set gpm
            end
            GameRules:SendCustomMessage("Gave Bots " .. tostring(GPM_value(next_gold)) .. " Gold", 1, 1)
            next_gold=next_gold+gold_freq -- advance the next_gold by the frequency
            return 1 -- check every second
      else 
            return 1 -- check every second
      end
end

--the function that gives the value the bots should recieve
function GPM_value(time)
      if time >=0 and time <60 then
            return 500
      elseif time >=60 and time <300 then -- 0 to 5 mins, 130 gpm
            return 130
      elseif time >=300 and time <600 then -- 5 to 10 mins, 150 gpm
            return 150
      elseif time >=600 and time <900 then -- 10 to 15 mins, 180 gpm
            return 180
      elseif time >=900 and time <1200 then -- 15 to 20 mins, 250 gpm
            return 250
      elseif time >=1200 and time <1500 then -- 20 to 25 mins, 300 gpm
            return 300
      elseif time >=1500 and time <1800 then -- 25 to 30 mins, 350 gpm
            return 350
      elseif time >=1800 and time <2100 then -- 30 to 35 mins, 400 gpm
            return 400
      elseif time >=2100 and time <2400 then -- 35 to 40 mins, 400 gpm
            return 400
      elseif time >=2400 and time <2700 then -- 40 to 45 mins, 400 gpm
            return 400
      else                                   -- above 45 mins, 0 gpm
            return 0
      end
end

-- things done immediately when running GPM.lua
function initiate_gold()
      -- starting the script with 1000 gold
      for _,bot in pairs(bots) do
            bot:ModifyGold(1000, false, 0)
      end

      -- define the functions for the thinker to take
      -- frequency that the script should give gold
      gold_freq= 60 -- every minute

      -- define the time of the next gold bonus, start at 0 secs
      next_gold=0
end

-- if GPM is already running, dont run another instance
if GPM_is_running==nil then
      GPM_is_running=true
      initiate_gold()
      thinker_player:SetThink(GPM, nil, "GPM")
else 
      GameRules:SendCustomMessage("GPM start failed. GPM Is already running!",1,1)
end
