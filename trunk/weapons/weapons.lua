return {    
	multibombs = {
		name                    = [[General Purpose Bombs]],
		areaOfEffect            = 64,
		burst                   = 8,
		burstrate               = 0.12,
		commandfire             = false,
		craterBoost             = 0,
		craterMult              = 0,
		
		customParams        	  = {
			ap	= "50",
		},
		
		damage                  = {
			default = 400,
		},
		
		dropped                 = true,
		explosionGenerator      = [[custom:air_explo]],
		manualBombSettings      = true,
		model                   = [[gpbomb.s3o]],
		projectiles			  = 2,
		range                   = 100,
		reloadtime              = 10,
		soundHit                = [[bombhit]],
		soundStart              = [[bomb_drop_short]],
		sprayangle              = 32767,
		weaponType              = [[AircraftBomb]],
	},
	
	multibombsplus = {
		name                    = [[General Purpose Bombs]],
		areaOfEffect            = 64,
		burst                   = 8,
		burstrate               = 0.12,
		commandfire             = false,
		craterBoost             = 0,
		craterMult              = 0,
		
		customParams        	  = {
			ap	= "50",
		},
		
		damage                  = {
			default = 400,
		},
		
		dropped                 = true,
		explosionGenerator      = [[custom:air_explo]],
		manualBombSettings      = true,
		model                   = [[gpbomb.s3o]],
		projectiles			  = 4,
		range                   = 100,
		reloadtime              = 10,
		soundHit                = [[bombhit]],
		soundStart              = [[bomb_drop_short]],
		sprayangle              = 32767,
		weaponType              = [[AircraftBomb]],
	   },
	clusterbombs = {
		name                    = [[Cluster Bomblets]],
		areaOfEffect            = 24,
		commandfire             = false,
		craterBoost             = 0,
		craterMult              = 0,
		
		customParams        	  = {
			ap	= "20",
		},
		
		damage                  = {
			default = 60,
		},
		
		dropped                 = true,
		explosionGenerator      = [[custom:blast_explo]],
		manualBombSettings      = true,
		model                   = [[bombcanister.s3o]],
		projectiles		= 32,
		range                   = 100,
		reloadtime              = 10,
		soundHit                = [[bombhit]],
		soundStart              = [[bomb_drop_short]],
		soundTrigger		= true,
		sprayangle              = 16384,
		weaponType              = [[AircraftBomb]],
	},	   
}