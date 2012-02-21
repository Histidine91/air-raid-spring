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
			default = 1500,
		},
		
		dropped                 = true,
		edgeEffectiveness		= 0.5,
		explosionGenerator      = [[custom:air_explo]],
		manualBombSettings      = true,
		model                   = [[gpbomb.s3o]],
		projectiles			  = 2,
		range                   = 100,
		reloadtime              = 10,
		soundHit                = [[bombhit]],
		soundStart              = [[bomb_drop_short]],
		sprayangle              = 16384,
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
			default = 1500,
		},
		
		dropped                 = true,
		edgeEffectiveness		= 0.5,
		explosionGenerator      = [[custom:air_explo]],
		manualBombSettings      = true,
		model                   = [[gpbomb.s3o]],
		projectiles			  = 4,
		range                   = 100,
		reloadtime              = 10,
		soundHit                = [[bombhit]],
		soundStart              = [[bomb_drop_short]],
		sprayangle              = 16384,
		weaponType              = [[AircraftBomb]],
	   },
           
	clusterbomb = {
		name                    = [[Cluster Bomb]],
		areaOfEffect            = 24,
		commandfire             = false,
		craterBoost             = 0,
		craterMult              = 0,
		
                customParams            = {
                    submunitions = [[wep_clusterbomb]],
                    submunitionsheight = 40,
                },
                
		damage                  = {
			default = -0.0001,
		},
		
		dropped                 = true,
		edgeEffectiveness	= 0.5,
		explosionGenerator      = [[custom:blast_explo]],
		manualBombSettings      = true,
		model                   = [[gpbomb.s3o]],
		range                   = 100,
		reloadtime              = 10,
		--soundHit                = [[bombhit]],
                --soundHitVolume          = 1,
		soundStart              = [[bomb_drop_short]],
		soundTrigger		= true,
		weaponType              = [[AircraftBomb]],
	},
        
	clusterbomb_sub = {
		name                    = [[Cluster Bombs]],
		areaOfEffect            = 24,
		burst                   = 32,
		burstrate               = 0.03,		
		commandfire             = false,
		craterBoost             = 0,
		craterMult              = 0,
		
		customParams        	  = {
                        ap	= "20",
		},
		
		damage                  = {
			default = 250,
		},
		
		dropped                 = true,
		edgeEffectiveness       = 0.5,
		explosionGenerator      = [[custom:air_explo]],
		manualBombSettings      = true,
		model                   = [[bombcanister.s3o]],
		projectiles				= 2,
		range                   = 100,
		reloadtime              = 10,
		size					= 0,
		soundHit                = [[bombhit]],
                soundHitVolume          = 1,
		--soundStart              = [[bomb_drop_short]],
		soundTrigger		= true,
		sprayangle              = 20000,
                weaponVelocity          = 150,
		weaponType              = [[Cannon]],
	},
	fuelairbomb = {
		name                    = [[Fuel Air Bomb]],
		areaOfEffect            = 128,
		commandfire             = false,
		craterBoost             = 0,
		craterMult              = 0,
		
		customParams        	  = {
			ap	= "25",
		},
		
		damage                  = {
			default = 3500,
		},
		
		dropped                 = true,
		edgeEffectiveness       = 0.75,
		explosionGenerator      = [[custom:exp_medium_building]],
		manualBombSettings      = true,
		model                   = [[guidedbomb.s3o]],
		range                   = 100,
		reloadtime              = 4,
		soundHit                = [[unitexplodemedium]],
                soundHitVolume          = 5,
		soundStart              = [[bomb_drop]],
		weaponType              = [[AircraftBomb]],
	},        
}