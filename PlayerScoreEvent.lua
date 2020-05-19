ListenToGameEvent("player_score", ScoreTracker, nil)

function ScoreTracker(event)
	userid = tostring(event.userid);
	kills = tostring(event.kills);
	deaths = tostring(event.deaths);
	score = tostring(event.score);
	
	GameRules:SendCustomMessage(userid .. ":" .. kills .. ":" .. deaths .. ":" .. score, 1, 1);
end

function InitMessage()
	
	GameRules:SendCustomMessage("Player Score Listener Initialized!", 1, 1);
end

InitMessage()