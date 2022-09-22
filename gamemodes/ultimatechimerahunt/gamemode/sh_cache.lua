
function CacheStuff()
	
	for k, v in pairs(file.Find("*", "../uch/mghost.*")) do
		util.PrecacheModel("uch/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../uch/uchimeragm.*")) do
		util.PrecacheModel("uch/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../models/uch/birdgib.*")) do
		util.PrecacheModel("uch/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../models/uch/pigmask.*")) do
		util.PrecacheModel("uch/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../sound/uch/music/cues/*")) do
		util.PrecacheSound("uch/music/cues/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../sound/uch/music/waiting/*")) do
		util.PrecacheSound("uch/music/waiting/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../sound/uch/music/round/*")) do
		util.PrecacheSound("uch/music/round/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../sound/uch/music/voting/*")) do
		util.PrecacheSound("uch/music/voting/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../sound/uch/player/*")) do
		util.PrecacheSound("uch/player/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../sound/uch/chimera/*")) do
		util.PrecacheSound("uch/chimera/" .. v);
	end
	
	for k, v in pairs(file.Find("*", "../sound/uch/pigs/*")) do
		util.PrecacheSound("uch/pigs/" .. v);
	end
	
end
