ListenToGameEvent('dota_player_kill', ScoreTracker, nil)

function ScoreTracker(event)
	local victimID = event.victim_userid;
	local killer = event.killer1_userid; 
	GameRules:SendCustomMessage('A player has died: ' .. tostring(victimID) .. ' : ' .. tostring(killer), 1, 1);
end

function InitMessage()	
	GameRules:SendCustomMessage('Player Kill Listener Initialized!', 1, 1);
end

InitMessage()