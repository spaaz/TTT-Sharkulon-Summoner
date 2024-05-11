AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

function ENT:SpawnFunction( tr )

	if not tr.Hit then return end
	
	local ent = ents.Create( "npc_sharkulon" )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:Initialize()	

	self:SetModel( "models/items/battery.mdl" )
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetName(self.PrintName)
	self:SetOwner(self.Owner)

	self.npc = ents.Create( "npc_turret_ceiling" )
	self.npc:SetPos(self:GetPos() + Vector(0,0,6))
	self.npc:SetAngles(self:GetAngles() + Angle(20,0,0))
	self.npc:SetSpawnEffect(false)
	self.npc:SetSaveValue("spawnflags",32)

	self.npc:Spawn()
	self.npc:Activate()
	self.npc:SetName("sharkulon")

	self:SetParent(self.npc)

	if( IsValid(self.npc))then
		self.npc:SetModelScale(0.15)
		self.npc:SetModel("models/beepulon/Ceiling_turret2.mdl")
	end

	self.npc.move = ents.Create( "npc_clawscanner" )
	local sPos = self:GetPos()+ Vector(0,0,12)
	self.npc.move:SetPos(sPos)
	self.npc.move.startPos = (sPos)
	self.npc.move:SetAngles(self:GetAngles())
	self.npc.move:SetSpawnEffect(false)
	self.npc.move:SetSaveValue("speed",1200)

	self.npc.move:Spawn()
	self.npc.move:Activate()
	self.npc.move:SetName("sharkulon")
	self.npc.move.npc = self.npc

	self.npc:SetParent(self.npc.move)


	if( IsValid(self.npc.move))then
		self.npc.move:SetModelScale(1)
		self.npc.move:SetModel("models/beepulon/beepulon_body.mdl")
		self.npc.move:SetMoveCollide(1)
		local phy = self.npc.move:GetPhysicsObject()
		phy:SetMaterial("metal_bouncy")
		local sharkulonHealth = GetConVar("ttt_sharkulon_health"):GetFloat()
		self.npc.move:SetHealth(sharkulonHealth)
		self.npc.move:SetMaxHealth(sharkulonHealth)
	end

	if SERVER then
		hook.Add( "Think", "sharkulonThink" , function()		
			for i, ent in ipairs(ents.FindByClass( "npc_clawscanner" )) do
				if ent:GetName() == "sharkulon" then
					local npc = ent.npc
					local move = ent

					if !IsValid( move ) and IsValid( npc )  then
						npc:Remove()
					end
					if IsValid( move ) then
						if not timer.Exists(tostring(move).."sharkulon_loop") then
							timer.Create(tostring(move).."sharkulon_loop",3.331,1,function() end)
							move:EmitSound("sharkulon_loop1.wav")
						end
						local enemy =  move:GetEnemy()
						if IsValid( enemy ) then
							local isTurretEnabled = true
							if npc:GetInternalVariable("spawnflags") == 256 then
								isTurretEnabled = false
							end
							local fwd = enemy:GetForward()
							local diff = move:GetPos() - enemy:GetPos()
							local moveVec = Vector(0,0,0)
							if isTurretEnabled then
								moveVec = (fwd * -192) - diff
							else
								moveVec = (fwd * 192) - diff
							end
							diff = diff * Vector(1,1,0)
							diff:Normalize()
							local dot = 0
							if isTurretEnabled then
								dot = fwd:Dot(diff)
							else
								dot = (-1 * fwd):Dot(diff)
							end
							if dot > 0 then
								local cross = fwd:Cross(diff)
								if cross.z > 0 then
									dot = -1 * dot
								end
								moveVec:Rotate(Angle(0,(45*dot),0))
							end
							local heightDiff = moveVec.z				
							moveVec.z = 0
							moveVec:Normalize()
							local vel = move:GetInternalVariable("m_vCurrentVelocity")
							vel.x = moveVec.x * 1600
							vel.y = moveVec.y * 1600
							if move:Health()/move:GetMaxHealth() > 0.5 then
								if heightDiff < -160 then
									vel.z = -800
								else
									vel.z = 400
								end
							else
								if heightDiff < -160 then
									vel.z = -1600
								else
									vel.z = 800
								end						
							end
							local lastSeen = CurTime() - move:GetEnemyLastTimeSeen(enemy)
							if not lastSeen then
								move:ClearEnemyMemory()
								move:SetEnemy(null)
							end
							if lastSeen and lastSeen < 1 then
								move:SetSaveValue("m_vCurrentVelocity",vel)
							elseif lastSeen and lastSeen > 6 then
								move:ClearEnemyMemory()
								move:SetEnemy(null)
							end
							
							npc:SetAngles((-diff):Angle()+ Angle(20,0,0))
										
						else
							local shortest = 4000000
							local targetEnemy = null
							for _, e in ipairs(ents.FindInSphere(move:GetPos(),2000)) do
								if e:IsPlayer() and e:Alive() then
									local dis = move:Disposition(e)
									local dist = (e:GetPos()):DistToSqr(move:GetPos())
									if dist < shortest then
										if dis == 1 then
											if move:IsLineOfSightClear(e) then
												shortest = dist
												targetEnemy = e
											end
										end
									end
								end
							end
							if targetEnemy then
								move:SetEnemy( targetEnemy )
								move:UpdateEnemyMemory( targetEnemy, targetEnemy:GetPos() )
							end
							local direction = move.startPos - move:GetPos()
							local distToStart = (direction):Length()
							if distToStart > 400 then
								move:SetLastPosition(move.startPos)
								move:SetSchedule(SCHED_FORCED_GO_RUN)
							end
						end
					end
				end
			end
		end)

		local function sharkDamage(target, dmginfo)
			if dmginfo:GetAttacker():GetName() == "sharkulon" then
				if engine.ActiveGamemode() == "terrortown" then	
					if target:IsPlayer() then
						if target:Alive() and not target:IsSpec() then
							if target:IsActiveTraitor() or (CR_VERSION and target:IsActiveTraitorTeam()) then
								dmginfo:ScaleDamage(0.2)
							else
								dmginfo:ScaleDamage(0.35)
							end
						end
					else
						dmginfo:ScaleDamage(0.35)
					end
				else
					dmginfo:ScaleDamage(0.35)
				end
			end
			if target:GetClass() == "npc_clawscanner" and target:GetName() == "sharkulon" then
				local att = dmginfo:GetAttacker()
				if att:GetName() == "sharkulon" then
					dmginfo:ScaleDamage(0)
				else
					if att and IsValid(att) and att:IsPlayer() then 
						timer.Create(tostring(move).."sharkulon_yeet",0.005,10,function()
							if target and IsValid(target) then
								target:SetSaveValue("m_vCurrentVelocity",Vector(0,0,800))
							end
						end)
						
						target:ClearEnemyMemory()
						target:SetEnemy(null)
						target:SetEnemy(att)
					end
				end
			
			end

		end

		hook.Add( "EntityTakeDamage", "sharkulonDamage", sharkDamage)	
		
		hook.Add( "OnNPCKilled", "sharkulonDeath", function( npc, attacker, inflictor )
			if npc:GetName() == "sharkulon" then
				EmitSound("ben_death0"..tostring(math.random(1,3)),npc:GetPos() , 1, CHAN_AUTO, 1, 75, 0, 100 )
				npc:StopSound("sharkulon_loop1.wav")
			end
		end)
		hook.Add( "EntityEmitSound", "sharkulon_silence", function( sound )
			if sound.OriginalSoundName == "NPC_SScanner.Die"then
				if sound.Entity:GetName() == "sharkulon" then
					sound.Volume = 0
					return true
				end
			end
			if sound.OriginalSoundName == "npc/scanner/combat_scan_loop6.wav"then
				if sound.Entity:GetName() == "sharkulon" then
					sound.Volume = 0
					return true
				end
			end
		end)
	end
end