require 'DataTables'
require 'AwardBonus'

for _, bot in pairs(Bots) do
	AwardBonus:Levels(bot, 3)
end