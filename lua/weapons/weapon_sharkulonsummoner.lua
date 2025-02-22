if SERVER then
	AddCSLuaFile()
end

if CLIENT then
	SWEP.PrintName       = "SharkuSummoner"
	SWEP.ShopName = "Sharkulon Summoner"
	SWEP.Author			= "Spaaz"
	SWEP.Contact			= "";
	SWEP.Instructions	= "Target the ground or a wall"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.IconLetter		= "M"
   	SWEP.Icon = "vgui/ttt/icon_sharkulon_summoner"
	SWEP.ViewModelFOV = 54
   	SWEP.EquipMenuData = {
      		type = "Weapon",
      		desc = "Summons a Sharkulon, a fast\nshark-shaped killer drone\n\ndoes less damage to traitors"
   	};
end

	SWEP.Base = "weapon_tttbase"
	SWEP.InLoadoutFor = nil
	SWEP.AllowDrop = true
	SWEP.IsSilent = false
	SWEP.NoSights = false
	SWEP.LimitedStock = true

	SWEP.Spawnable = true
	SWEP.AdminOnly = false

	SWEP.HoldType              = "revolver"
	SWEP.ReloadHoldType        = "pistol"
	SWEP.ViewModel  = "models/weapons/v_pistol.mdl"
	SWEP.WorldModel = "models/weapons/w_pistol.mdl"
	SWEP.Kind = 42
	SWEP.CanBuy = { ROLE_TRAITOR }
	SWEP.AutoSpawnable = false

	SWEP.Primary.ClipSize		= 1
	SWEP.Primary.DefaultClip	= 1
	SWEP.Primary.Automatic		= false
	SWEP.Primary.Ammo		= "none"

	SWEP.Weight					= 7
	SWEP.DrawAmmo				= true
	SWEP.shark			= nil


local function FindRespawnLocCustshark(pos, ply)
    local offsets = {}
	table.insert( offsets, Vector(0,0,0))
	
    for i = 0, 360, 15 do
        table.insert( offsets, Vector( math.sin( i ), math.cos( i ), 0 ) )
    end
        local midsize = Vector( 64, 64, 64 )
        local tstart = pos + Vector( 0, 0, midsize.z / 2 )

        for i = 1, #offsets do
            local o = offsets[ i ]
            local v = tstart + o * midsize * 1.5

            local t = {
                start = v,
                endpos = v,
                filter = target,
                mins = midsize / -2,
                maxs = midsize / 2
            }
            local tr = util.TraceHull( t )

            if not tr.Hit then return ( v - Vector( 0, 0, midsize.z/2 ) ) end
            
        end
		
        tstart = pos + Vector( 0, 0, -2 * midsize.z )
		
        for i = 1, #offsets do
            local o = offsets[ i ]
            local v = tstart + o * midsize * 1.5

            local t = {
                start = v,
                endpos = v,
                filter = target,
                mins = midsize / -2,
                maxs = midsize / 2
            }
            local tr = util.TraceHull( t )

            if not tr.Hit then return ( v - Vector( 0, 0, -2 * midsize.z ) ) end
            
        end

        return false
end

local function place_shark( tracedata, self )
	
	if ( CLIENT ) then return end

	self.shark = ents.Create( "npc_sharkulon" )
	local owner = self:GetOwner()

	if ( !IsValid( self.shark ) ) then return end

            local spawnereasd = FindRespawnLocCustshark(tracedata.pos, owner)
            if spawnereasd == false then
            else
				self.shark:SetPos( spawnereasd )
				self.shark:Spawn()
				local moveNPC = self.shark.npc.move
				if IsValid(moveNPC) then
					local targetPly = nil
					local smallestDist = math.huge	
					local npcPos = moveNPC:GetPos()	
					for _, ply in ipairs( player.GetAll()) do
						if ( ply != owner ) then
							local plyPos = ply:GetPos()
							local dist = npcPos:DistToSqr( plyPos )

							if ( dist < smallestDist ) then
								targetPly = ply
								smallestDist = dist
							end
						end		
					end
					if targetPly then
						local vec = targetPly:GetPos() - npcPos
						vec = vec * Vector(1,1,0)
						vec:Normalize()
						local angle = vec:Angle()
						moveNPC:SetAngles(angle)			
					end
				end
            end


end
	
function SWEP:PrimaryAttack()

	local ply = self:GetOwner()
	
	local tr = ply:GetEyeTrace()
	local tracedata = {}
	
	tracedata.pos = tr.HitPos + Vector(0,0,20)
    
	if (!SERVER) then return end
	
	if self:Clip1() > 0 then
		
		
		local myPosition = ply:EyePos() + ( ply:GetAimVector() * 16 )
		local data = EffectData()
		data:SetOrigin( myPosition )

		util.Effect("MuzzleFlash", data)

        local spawnereasd = FindRespawnLocCustshark(tracedata.pos)
        if spawnereasd == false then
			ply:PrintMessage(HUD_PRINTTALK, "Can't Place there." )
        else
			if engine.ActiveGamemode() == "terrortown" then
				self:TakePrimaryAmmo(1)
			end
		
			place_shark(tracedata, self)
		
		end

	else
		self:EmitSound( "Weapon_AR2.Empty" )
	end
end


function SWEP:Equip()
	if ( !IsValid( self.Owner ) ) then return end
		if engine.ActiveGamemode() == "terrortown" then
			self.Owner:PrintMessage(HUD_PRINTTALK, "Sharkulon Summoner:\nSummons a Sharkulon, a fast\nshark-shaped killer drone")
		end
end

	
	function SWEP:SecondaryAttack()

		self:PrimaryAttack()

	end

	function SWEP:Reload()
		return false
	end