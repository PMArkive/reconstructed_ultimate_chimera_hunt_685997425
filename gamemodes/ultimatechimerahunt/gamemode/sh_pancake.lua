
local meta = FindMetaTable("Player");


function meta:IsPancake()
	return (self:GetNWBool("Pancaked"));
end


if (SERVER) then
	
	
	function meta:SetPancake(b)
		self:SetNWBool("Pancaked", b);
	end
	
	
	function meta:Pancake()
		
		local uc = GetUC();
		
		if (self:IsGhost() || self == uc) then
			return;
		end
		
		if (!self:IsPancake()) then
			self:SetPancake(true);
			
			self:EmitSound("uch/pigs/squeal_" .. tostring(math.random(1, 3)) .. ".mp3", 92, math.random(90, 105));
			
			timer.Simple(.32, function()
				self.Squished = true;
				timer.Simple(.5, function()
					self.Squished = false;
				end);
				
				if (uc:GetStock() < 2) then
					uc:GainStock();
				end
				
				self:Kill();
				self:ResetRank();
			end);
		end
		
	end
	
	
else
	
	
	function meta:DoPancakeEffect()
		
		self.PancakeNum = (self.PancakeNum || 1);
		
		local num = 1;
		local spd = 8;
		
		self.PancakeNum = math.Approach(self.PancakeNum, .2, (FrameTime() * (self.PancakeNum * spd)));
		
		local scale = Vector(1, 1, self.PancakeNum)
		local mat = Matrix()
		mat:Scale( scale )
		self:EnableMatrix( "RenderMultiply", mat )
		
	end
	
	
end
