
local ranks = {};

ranks[1] = "Ensign";
ranks[2] = "Captain";
ranks[3] = "Major";
ranks[4] = "Colonel";

local meta = FindMetaTable("Player");


//Get rank functions
function meta:GetRank()
	
	local ranknum = self:GetRankNum();
	
	return ranks[ranknum];
	
end


function meta:GetRankColor()
	
	local rank = self:GetRank();
	
	local clr = {250, 180, 180};
	
	if (rank == "Captain") then
		clr = {150, 200, 250};
	elseif (rank == "Major") then
		clr = {90, 200, 90};
	elseif (rank == "Colonel") then
		clr = {250, 250, 250};
	end
	
	if (self:IsUC()) then
		clr = {230, 30, 110};
	end
	
	return unpack(clr);
	
end


function meta:GetRankColorSat()
	
	local rank = self:GetRank();
	
	local clr = {255, 255, 255};
	
	if (rank == "Captain") then
		clr = {153, 204, 255};
	elseif (rank == "Major") then
		clr = {115, 255, 115};
	elseif (rank == "Colonel") then
		clr = {225, 225, 225};
	end
	
	return unpack(clr);
	
end


function meta:GetRankNum()
	
	return self:GetNWInt("UC_Rank", 1);
	
end


if (SERVER) then
	
	
	function meta:SetRank(num)
		
		local uid = self:UniqueID();
		
		num = math.Clamp(num, 1, 4);
		
		self:SetNWInt("UC_Rank", num);
		
		if (!self:IsGhost()) then
			self:SetRankBodygroups();
			self:SetRankSkin();
		end
		
	end
	
	
	function meta:RankUp()
		self.NextRank = math.Clamp((self:GetRankNum() + 1), 1, 4);
	end
	
	
	function meta:RankDown()
		self.NextRank = math.Clamp((self:GetRankNum() - 1), 1, 4);
	end
	
	
	function meta:ResetRank()
		self.NextRank = 1;
	end
	
	
	local function SendRank(length, player)
		
		local ply = net:ReadEntity();
		net.Start("SendRank")
			net.WriteString(ply:GetRank());
		net.Send(player)
		
	end
	net.Receive("GetRank", SendRank)
	
	
else
	
	
	function GetRankCL( ply )
		
		net.Start("GetRank")
		net.WriteEntity(ply);
		net.SendToServer();
		
	end
	
	
end
