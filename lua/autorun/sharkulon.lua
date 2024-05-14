AddCSLuaFile()

sound.Add( {
	name = "ben_death01",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	sound = "ben_death01.wav"
} )

sound.Add( {
	name = "ben_death02",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	sound = "ben_death02.wav"
} )

sound.Add( {
	name = "ben_death03",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	sound = "ben_death03.wav"
} )

sound.Add( {
	name = "sharkulon_loop",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 50,
	sound = "sharkulon_loop.wav"
} )

local NPC = {	Name = "Sharkulon",
				Class = "npc_sharkulon",
				Category = "Combine" }

list.Set( "NPC", "isharkulon", NPC )

CreateConVar( "ttt_sharkulon_health", 160 ,{ FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Initial health of a Sharkulon" )