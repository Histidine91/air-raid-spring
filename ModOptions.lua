local options= {
	{
		key = "nospawns",
		name = "Disable spawns",
		desc = "Disables the enemy spawning if you want to have a little PvP action",
		type = "bool",
		def = false
	},
    {
		key    = 'numlives',
		name   = 'Lives',
		desc   = 'How many lives you have (0 = unlimited)',
		type   = 'number',
		def    = 3,
		min    = 0,
		max    = 5,
		step   = 1,
	},
	{
		key    = 'sandbox',
		name   = 'Sandbox Spawner',
		desc   = 'Options for sandbox spawning',
		type   = 'section',
	},	
    {
		key    = 'spawnrate',
		name   = 'Spawn rate',
		desc   = 'How often convoys arrive in seconds',
		type   = 'number',
		def    = 60,
		min    = 15,
		max    = 180,
		step   = 15,
		section	= "sandbox",
	}, 
    {
		key    = 'spawnmult',
		name   = 'Spawn multiplier',
		desc   = 'Size of spawns',
		type   = 'number',
		def    = 1,
		min    = 1,
		max    = 10,
		step   = 0.1,
		section	= "sandbox",
	}, 	
	{
		key    = 'experimental',
		name   = 'Experimental',
		desc   = 'Test stuff',
		type   = 'section',
	},
	{
		key = "enabledestiny",
		name = "Enable Destiny",
		desc = "Enables the B-3 Destiny strike bomber (not balanced!)",
		type = "bool",
		def = false
	},	
}

return options
