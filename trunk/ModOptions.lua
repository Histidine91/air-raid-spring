--  Custom Options Definition Table format
--  NOTES:
--  - using an enumerated table lets you specify the options order

--
--  These keywords must be lowercase for LuaParser to read them.
--
--  key:      the string used in the script.txt
--  name:     the displayed name
--  desc:     the description (could be used as a tooltip)
--  type:     the option type ('list','string','number','bool')
--  def:      the default value
--  min:      minimum value for number options
--  max:      maximum value for number options
--  step:     quantization step, aligned to the def value
--  maxlen:   the maximum string length for string options
--  items:    array of item strings for list options
--  section:  so lobbies can order options in categories/panels
--  scope:    'all', 'player', 'team', 'allyteam'      <<< not supported yet >>>
--

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local options= {
	{
		key    = 'gamemode',
		name   = 'Game Mode',
		desc   = 'Change the game mode.',
		type   = 'list',
		def    = 'raid',
		items  = {
			{
				key  = 'raid',
				name = 'Raid',
				desc = 'Fly around attacking anything you encounter. The game ends when all teams run out of planes.',
			},
			{
				key  = 'dogfight',
				name = 'Dogfight',
				desc = 'Team deathmatch.',
			},
			{
				key  = 'dogfightplus',
				name = 'Dogfight Plus',
				desc = "Team deathmatch with Raid's neutral spawns.",
			},
			{
				key  = 'intercept',
				name = 'Intercept',
				desc = "Survive ten waves of air-to-air action.",
			},				
		},
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
		key    = 'raid',
		name   = 'Raid Spawner',
		desc   = 'Options for Raid mode spawning',
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
		section	= "raid",
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
		section	= "raid",
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
		section = "experimental",
		type = "bool",
		def = false
	},	
}

return options
