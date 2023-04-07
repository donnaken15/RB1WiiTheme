
// yay


// use
// sidebar_x_offset1
// sidebar_y_offset1

// tweak overrides

// cringe messing up opens
//gem_star_scale1 = 1
fret_offset_tweak = 7.0
whammy_offset_tweak = -12.0
highway_fade1 = 50.0
highway_playline1 = 638.0
//highway_playline2 = 655.0
highway_top_width1 = 220.0
highway_height1 = 355.0
widthOffsetFactor1 = 1.4
fretbar_start_scale1 = 0.21
button_up_pixels = 15.0
gem_start_scale1 = 0.34
nowbar_scale_x1 = 0.82
whammy_cutoff = 1120.0
string_scale_x1 = 3.4
string_scale_y1 = 0.82
sidebar_x_scale1 = 0.35
nowbar_scale_x2 = 0.6
nowbar_scale_y2 = 0.6
highway_height2 = 300.0
highway_fade2 = 80.0
//highway_top_width2 = 190.0
string_scale_x2 = 2.6
string_scale_y2 = 0.7
//widthOffsetFactor2 = 1.1

color_white = [255 255 255 255]

StarPower_Out_SFX_struct = $FESFX_50_generic_struct
StarPower_Out_SFX_container = {
	command = PlaySound
	Randomness = none
	Sounds = {
		Sound1 = {
			sp_lose
			vol = 110
		}
	}
}
Star_SFX_struct = $FESFX_50_generic_struct
Star_SFX_container = {
	command = PlaySound
	Randomness = none
	Sounds = {
		Sound1 = {
			star
			vol = 110
		}
	}
}
script MakePair \{x = 0.0 y = 0.0}
	return pair = (((1.0,0.0)*<x>)+((0.0,1.0)*<y>))
endscript

script color_grid \{rgba = [255 255 255 255]}
	ExtendCrc grid <player_text> out = grid
	if ScreenElementExists id = <grid>
		SetScreenElementProps id = <grid> rgba = <rgba>
	endif
endscript

script GuitarEvent_StarPowerOn
	spawnscriptnow flash_highway params = { time = 1.0 player_status = <player_status> }
	spawnscriptnow pulse_highway params = { time = 0.5 player_status = <player_status> }
	ExtendCrc Overdrive_2D <player_text> out = highway_name
	if ScreenElementExists id = <highway_name>
		DoScreenElementMorph id = <highway_name> time = 0.4 alpha = 1
	endif
	color_grid player_text = <player_text> rgba = [255 219 0 255]
	GH_Star_Power_Verb_On
	FormatText checksumName = scriptID '%p_StarPower_StageFX' p = <player_text>
	SpawnScriptLater Do_StarPower_StageFX id = <scriptID> params = {<...> }
	StarPowerOn Player = <Player>
endscript
script GuitarEvent_StarPowerOff
	GH_Star_Power_Verb_Off
	spawnscriptnow rock_meter_star_power_off params = {player_text = <player_text>}
	SpawnScriptLater Kill_StarPower_StageFX params = { <...> }
	ExtendCrc starpower_container_left <player_text> out = cont
	if ScreenElementExists id = <cont>
		DoScreenElementMorph id = <cont> time = 0.4 alpha = 0
	endif
	ExtendCrc starpower_container_right <player_text> out = cont
	if ScreenElementExists id = <cont>
		DoScreenElementMorph id = <cont> time = 0.4 alpha = 0
	endif
	ExtendCrc Highway_2D <player_text> out = highway
	if ScreenElementExists id = <highway>
		SetScreenElementProps id = <highway> rgba = ($highway_normal)
	endif
	ExtendCrc Overdrive_2D <player_text> out = highway_name
	if ScreenElementExists id = <highway_name>
		DoScreenElementMorph id = <highway_name> time = 0.4 alpha = 0
	endif
	color_grid player_text = <player_text> rgba = [255 255 255 255]
	spawnscriptnow \{Kill_StarPower_Camera}
	// play starpower deplete sound
	SoundEvent \{event=StarPower_Out_SFX}
endscript
// starpower FX
script flash_highway \{time = 0.6 player_status = player1_status}
	<player_text> = ($<player_status>.text)
	ExtendCrc odglow <player_text> out = odglow
	if ScreenElementExists id = <odglow>
		SetScreenElementProps id = <odglow> alpha = 0.8
		DoScreenElementMorph id = <odglow> time = <time> alpha = 0
	endif
endscript
script GuitarEvent_StarSequenceBonus
	SoundEvent \{event=Star_Power_Awarded_SFX}
	spawnscriptnow flash_highway params = { player_status = <player_status> }
	spawnscriptnow pulse_highway params = { time = 0.5 player_status = <player_status> }
endscript

script create_highway_overlays
	hpos = ((640.0 - ($highway_top_width / 2.0)) * (1.0, 0.0))
	hDims = ($highway_top_width * (1.0, 0.0))
	ExtendCrc grid_2D <player_text> out = highway_name
	CreateScreenElement {
		Type = SpriteElement
		id = <highway_name>
		parent = <container_id>
		clonematerial = grid
		Pos = <hpos>
		dims = <hDims>
		just = [left left]
		z_priority = 3.5
		alpha = 1
	}
	ExtendCrc odglow <player_text> out = odglow
	CreateScreenElement {
		Type = SpriteElement
		id = <odglow>
		parent = <container_id>
		clonematerial = overdrive_highway // named wrong in SCN, whatever
		Pos = <hpos>
		dims = <hDims>
		just = [left left]
		z_priority = 3.6
		alpha = 0
	}
	ExtendCrc Overdrive_2D <player_text> out = highway_name
	CreateScreenElement {
		Type = SpriteElement
		id = <highway_name>
		parent = <container_id>
		clonematerial = overdrive_overlay
		rgba = [ 70 70 0 255 ]
		Pos = <hpos>
		dims = <hDims>
		just = [left left]
		z_priority = 3.7
		alpha = 0
	}
	highway_speed = (0.0 - ($gHighwayTiling / ($<player_status>.scroll_time - $destroy_time)))
	Set2DHighwaySpeed speed = <highway_speed> id = <highway_name> player_status = <player_status>
	fe = ($highway_playline - $highway_height)
	fs = (<fe> + $highway_fade)
	Set2DHighwayFade start = <fs> end = <fe> id = <highway_name> Player = <Player>
endscript

script update_score_fast
	UpdateScoreFastInit player_status = <player_status>
	last_health = -1.0
	last_score = -1
	last_stars = -1
	old_stars = 0
	<player_text> = ($<player_status>.text)
	ExtendCrc HUD2D_rock_needle <player_text> out = Needle
	ExtendCrc HUD2D_Score_Text <player_text> out = new_id
	if ScreenElementExists id = <new_id>
		SetScreenElementProps id = <new_id> font_spacing = 1 scale = 0.6
	endif
	//ExtendCrc HUD_star_glow ($<player_status>.text) out = star_glow

	// crust for putting my custom element creation and modding here
	ExtendCrc gem_container ($<player_status>.text) out = container_id
	create_highway_overlays <...>
	
	____profiling_interval = 120
	begin
		ProfilingStart
		GetSongTimeMs

		UpdateScoreFastPerFrame player_status = <player_status> time = <time>
		<health> = ($health_scale - $<player_status>.current_health)
		if NOT (<last_health> = <health>)
			if ($current_num_players = 1)
				if ScreenElementExists id = <needle>
					// modded to only move up and down and not rotate
					<last_health> = <health>
					//<rot> = (((<health> / $health_scale) * (0.65 * 2.0)) - 0.65)
					<pos> = ((262.0,77.0) - ((124.0,0.0) * <health>))
					SetScreenElementProps id = <Needle> pos = <pos> rot_angle = 0.0
				endif
			endif
		endif
		// fix score display
		<score> = ($<player_status>.score)
		if NOT (<last_score> = <score>)
			<last_score> = <score>
			if (<score> >= 100000)
				if ScreenElementExists id = <new_id>
					SetScreenElementProps id = <new_id> scale = 0.6
				endif
			endif
			// ripped out of WOR mod
			base_score = ($<player_status>.base_score)
			score = ($<player_status>.score)
			fraction = (<score> / <base_score>)
			if (<fraction> >= 2.8)
				stars = 5
				Progress = 1.0
			elseif (<fraction> >= 2.0)
				stars = 4
				Progress = ((<fraction> - 2.0) / 0.8)
			elseif (<fraction> >= 0.9)
				stars = 3
				Progress = ((<fraction> - 0.9) / 1.1)
			elseif (<fraction> >= 0.65)
				stars = 2
				Progress = ((<fraction> - 0.65) / 0.25)
			elseif (<fraction> >= 0.1)
				stars = 1
				Progress = ((<fraction> - 0.1) / 0.55)
			else
				stars = 0
				Progress = (<fraction> / 0.1)
			endif
			if ($<player_status>.max_notes > 0)
				completion = (100 * ($<player_status>.notes_hit / $<player_status>.max_notes))
				if (<completion> = 100)
					stars = 6
				endif
			endif
			if NOT (<last_stars> = <stars>)
				<old_stars> = <last_stars>
				<last_stars> = <stars>
				FormatText checksumName = star 'HUD2D_star%d' d = (<stars> + 1)
				if NOT (<stars> = 6)
					ExtendCrc <star> '_glow' out = star_glow
					ExtendCrc <star_glow> <player_text> out = star_glow
					ExtendCrc <star> '_mask' out = star_mask
					ExtendCrc <star_mask> <player_text> out = star_mask
				endif
				if NOT (<old_stars> = -1)
					SoundEvent \{event=Star_SFX}
					spawnscriptnow complete_star params = { <...> }
				endif
			endif
			if ScreenElementExists id = <star_glow>
				SetScreenElementProps id = <star_glow> rot_angle = (<progress> * 360.0)
			endif
			ExtendCrc <star> '_fill_' out = star_fill
			i = 1
			begin
				ExtendCrc <star_fill> 'i' out = star_fill
				ExtendCrc <star_fill> <player_text> out = star_fill2
				if (<progress> > (0.15 + (0.25 * <i>)))
					if ScreenElementExists id = <star_fill2>
						SetScreenElementProps id = <star_fill2> alpha = 1
					endif
				else
					break
				endif
				i = (<i> + 1)
			repeat 3
			if (<progress> > 0.48)
				if ScreenElementExists id = <star_mask>
					SetScreenElementProps id = <star_mask> alpha = 0
				endif
			endif
		endif
		ProfilingEnd <...> loop 'update_score_fast'
		wait \{1 gameframe}
	repeat
endscript

script complete_star
	// mess because of a bunch of crashes for basically no reason
	// literally trial and error BS, no free easy blind shot execution this time
	// thanks a lot
	// some of it was my fault though
	if (<stars> < 5)
		ExtendCrc HUD2D_star_container <player_text> out = container_id
		if ScreenElementExists id = <container_id>
			GetScreenElementPosition id = <container_id>
			pos = (<ScreenElementPos> - (23.5, 0.0))
			DoScreenElementMorph id = <container_id> pos = <pos> time = 0.4
		endif
	endif
	if (<stars> = 6)
		i = 1
		begin
			FormatText checksumName = star_gold 'HUD2D_star%d' d = <i>
			ExtendCrc <star_gold> '_gold' out = star_gold
			ExtendCrc <star_gold> <player_text> out = star_gold
			if ScreenElementExists id = <star_gold>
				SetScreenElementProps id = <star_gold> alpha = 1
			endif
			i = (<i> + 1)
		repeat 5
		return
	endif
	ExtendCrc <star> <player_text> out = star_obj
	if ScreenElementExists id = <star_obj>
		SetScreenElementProps id = <star_obj> alpha = 1
	endif
	FormatText checksumName = old_star 'HUD2D_star%d' d = (<old_stars> + 1)
	ExtendCrc <old_star> <player_text> out = old_star_obj
	ExtendCrc <old_star> '_whole' out = star_whole
	ExtendCrc <star_whole> <player_text> out = star_whole
	ExtendCrc <old_star> '_whole2' out = star_whole2
	ExtendCrc <star_whole2> <player_text> out = star_whole2
	ExtendCrc <old_star> '_glow' out = star_glow
	ExtendCrc <star_glow> <player_text> out = star_glow
	if ScreenElementExists id = <old_star_obj>
		// kill me
		// CANT EVEN HAVE COMMENTS ON THE SAME LINE AS AN IF STATEMENT NEXT TO ANOTHER
		if ScreenElementExists id = <star_whole2>
			if ScreenElementExists id = <star_whole>
				if ScreenElementExists id = <star_glow>
					DoScreenElementMorph id = <old_star_obj> time = 0.2 Scale = 1.5
					SetScreenElementProps id = <star_whole2> alpha = 0
					DoScreenElementMorph id = <star_whole2> time = 0.1 alpha = 1
					Wait \{0.1 seconds}
					SetScreenElementProps id = <star_whole> alpha = 1
					DoScreenElementMorph id = <star_whole2> time = 0.1 alpha = 0
					Wait \{0.1 seconds}
					DoScreenElementMorph id = <old_star_obj> time = 0.2 Scale = 1
					Wait \{0.2 seconds}
					SetScreenElementProps id = <star_glow> alpha = 0
					ExtendCrc <old_star> '_fill_' out = star_fill
					i = 1
					begin
						ExtendCrc <star_fill> 'i' out = star_fill
						ExtendCrc <star_fill> <player_text> out = star_fill2
						if ScreenElementExists id = <star_fill2>
							SetScreenElementProps id = <star_fill2> alpha = 0
						endif
						i = (<i> + 1)
					repeat 3
				endif
			endif
		endif
	endif
endscript

// yeah, try and animate the nowbar
// flying onto highway
intro_sequence_props = {
	song_title_pos = (0.0, 0.0)
	performed_by_pos = (0.0, 0.0)
	song_artist_pos = (0.0, 0.0)
	song_title_start_time = 0
	song_title_fade_time = 0
	song_title_on_time = 0
	highway_start_time = -1500
	highway_move_time = 1500
	button_ripple_start_time = -1500
	button_ripple_per_button_time = 1
	hud_start_time = -600
	hud_move_time = 300
}
sidebar_normal0 = $color_white
sidebar_normal1 = $color_white
sidebar_starready0 = $color_white
sidebar_starready1 = $color_white
sidebar_starpower0 = $color_white
sidebar_starpower1 = $color_white
highway_normal = [255 255 255 130]
highway_starpower = [249 249 78 165]

// get scale  : 1+(1*(<offset>/640))
// get offset : ((<scale>-1)*640)
// kick/sp gain animation just because
script pulse_highway \{time = 0.2 player_status = player1_status scale = (1.06,1.02)}
	time = (<time> / ($current_speedfactor))
	ExtendCrc gem_container ($<player_status>.text) out = container_id
	if NOT ScreenElementExists id = <container_id>
		return
	endif
	//time = (<time> / ($current_speedfactor))
	GetScreenElementPosition id = <container_id>
	offset = ((<scale> - (1.0,1.0))*640.0)
	Pos = (<ScreenElementPos> - <offset>)
	SetScreenElementProps id = <container_id> Pos = <Pos> Scale = <Scale>
	DoScreenElementMorph id = <container_id> Pos = <ScreenElementPos> time = <time> Scale = 1.0
endscript

script Open_NoteFX \{Player = 1 player_status = player1_status}
	if ($disable_particles > 1)
		return
	endif
	ProfilingStart
	open_color1 = [240 199 255 255]
	GetSongTimeMs
	ExtendCrc gem_container ($<player_status>.text) out = container_id
	FormatText textName = text '%t' t = <time>
	ExtendCrc open_particle ($<player_status>.text) out = fx_id
	ExtendCrc <fx_id> <text> out = fx_id
	ExtendCrc <fx_id> '2' out = fx2_id
	fx1_scale = (1.1, 1.4)
	if ($current_num_players = 2)
		fx1_scale = (0.8, 1.0)
	endif
	// kick flash
	pos = ($button_up_models.yellow.pos_2d)
	CreateScreenElement {
		id = <fx_id>
		Scale = <fx1_scale>
		rgba = <open_color1>
		type = SpriteElement
		parent = <container_id>
		just = [0.0 0.4]
		z_priority = 30
		Pos = <pos>
		alpha = 1
		material = sys_openfx1_sys_openfx1
	}
	CreateScreenElement {
		id = <fx2_id>
		Scale = <fx1_scale>
		rgba = <open_color1>
		type = SpriteElement
		parent = <container_id>
		just = [0.0 0.4]
		z_priority = 30
		Pos = <pos>
		alpha = 1
		material = sys_openfx1_sys_openfx1
	}

	time = 0.2
	spawnscriptnow pulse_highway params = { time = <time> player_status = <player_status> }
	time = (<time> / ($current_speedfactor))

	DoScreenElementMorph id = <fx_id> time = <time> alpha = 0 relative_scale
	DoScreenElementMorph id = <fx2_id> time = <time> alpha = 0 relative_scale
	ProfilingEnd <...> 'Open_NoteFX'
	wait <time> seconds
	if ScreenElementExists id = <fx_id>
		DestroyScreenElement id = <fx_id>
	endif
	if ScreenElementExists id = <fx2_id>
		DestroyScreenElement id = <fx2_id>
	endif
endscript

script GuitarEvent_HitNote_Spawned
	if ($game_mode = p2_battle || $boss_battle = 1)
		Change StructureName = <player_status> last_hit_note = <Color>
	endif
	wait \{1 gameframe}
	spawnscriptnow hit_note_fx params = {
		name = <fx_id>
		Pos = <Pos>
		player_text = <player_text>
		Star = ($<player_status>.star_power_used)
		Player = <Player>
		Color = <Color>
	}
	ExtendCrc jitter_ ($button_up_models.<Color>.name_string) out = name_scr
	ExtendCrc <name_scr> <player_text> out = name_scr
	KillSpawnedScript id = <name_scr>
	spawnscriptnow fret_jitter id = <name_scr> params = {
		player_status = <player_status>
		player_text = <player_text>
		Color = <Color>
	}
endscript

//fret_mask = [ 65536 4096 256 16 1 ]

script GuitarEvent_WhammyOn
	if ($disable_particles < 2)
		WhammyFXOn <...>
	endif
	ExtendCrc whammy_jitter ($<player_status>.text) out = name
	// cringe
	// Thanks Neversoft
	// but thank you lzss for making this not so big in compilation
	if (<pattern> & 65536)
		ExtendCrc <name> 'green' out = id
		spawnscriptnow fret_hold_jitter params = { color = green <...> }
	endif
	if (<pattern> & 4096)
		ExtendCrc <name> 'red' out = id
		spawnscriptnow fret_hold_jitter params = { color = red <...> }
	endif
	if (<pattern> & 256)
		ExtendCrc <name> 'yellow' out = id
		spawnscriptnow fret_hold_jitter params = { color = yellow <...> }
	endif
	if (<pattern> & 16)
		ExtendCrc <name> 'blue' out = id
		spawnscriptnow fret_hold_jitter params = { color = blue <...> }
	endif
	if (<pattern> & 1)
		ExtendCrc <name> 'orange' out = id
		spawnscriptnow fret_hold_jitter params = { color = orange <...> }
	endif
	/*GetArraySize \{gem_colors}
	i = 0
	begin
		if (<pattern> & ($fret_mask[<i>]))
			ExtendCrc <name> ($gem_colors_text[<i>]) out = id
			spawnscriptnow fret_hold_jitter params = { color = ($gem_colors[<i>]) <...> }
		endif
		i = (<i> + 1)
	repeat <array_size>*/
endscript

p2_scroll_time_factor = 1.0
p2_game_speed_factor = 1.0
global_hyperspeed_factor = 1.0

script fret_hold_jitter
	begin
		if ($currently_holding[(<player> - 1)] = 1)
			break
		endif
		Wait \{1 frame}
	repeat
	ExtendCrc ($button_up_models.<Color>.name) '_head' out = fret
	ExtendCrc <fret> ($<player_status>.text) out = fret
	SetScreenElementProps id=<fret> z_priority = 8
	exit = 0
	begin
		GetSongTime
		time2 = (<songtime> + ((0.033 * 7) / $current_speedfactor))
		spawnscriptnow fret_jitter params = { <...> }
		//Wait ((0.033 * 7) / $current_speedfactor) seconds
		begin
			if ($currently_holding[(<player> - 1)] = 0)
				exit = 1
				break
			endif
			GetSongTime
			if (<songtime> > <time2>) // crust
				break
			endif
			Wait \{1 frame}
		repeat
		if (<exit> = 1)
			break
		endif
	repeat
	SetScreenElementProps id=<fret> z_priority = 3.8
endscript

button_up_pixels = 0.0
script fret_jitter
	ExtendCrc ($button_up_models.<Color>.name) '_head' out = fret
	ExtendCrc <fret> <player_text> out = fret
	//FormatText checksumName = fret '%s_head%p' s = ($button_up_models.<Color>.name_string) p = <player_text> AddToStringLookup = true
	if ($<player_status>.lefthanded_button_ups = 0)
		<pos2d> = ($button_up_models.<Color>.pos_2d)
	else
		<pos2d> = ($button_up_models.<Color>.left_pos_2d)
	endif
	//SetScreenElementProps id=<fret> pos=(<pos2d>)
	SetScreenElementProps id=<fret> z_priority = 7 rot_angle = -3 pos=(<pos2d> + (1.0, -11.0))
	/*i = 0
	begin
		DoScreenElementMorph id=<fret> time = (0.0333 / $current_speedfactor) rot_angle = (<rots>[i]) pos=(<pos2d> + ((0.0, 1.0) * <poss>[i]))
		Wait (0.0333 / $current_speedfactor) seconds
		i = (<i> + 1)
	repeat 7*/
	time = (0.033333 / $current_speedfactor)
	DoScreenElementMorph id=<fret> time = <time> rot_angle = -3.8 pos=(<pos2d> + (0.0, -7.5))
	Wait <time> seconds
	DoScreenElementMorph id=<fret> time = <time> rot_angle = 3.2 pos=(<pos2d> + (0.0, 5.5))
	Wait <time> seconds
	DoScreenElementMorph id=<fret> time = <time> rot_angle = 0.0 pos=(<pos2d> + (0.0, -4.25))
	Wait <time> seconds
	DoScreenElementMorph id=<fret> time = <time> rot_angle = -1.8 pos=(<pos2d> + (0.0, 3.0))
	Wait <time> seconds
	DoScreenElementMorph id=<fret> time = <time> rot_angle = 1.2 pos=(<pos2d> + (0.0, -3.0))
	Wait <time> seconds
	DoScreenElementMorph id=<fret> time = <time> rot_angle = 0.0 pos=(<pos2d> + (0.0, 2.0))
	Wait <time> seconds
	DoScreenElementMorph id=<fret> time = <time> rot_angle = 0 pos=<pos2d>
	Wait <time> seconds
	//DoScreenElementMorph id=<fret> time = 0.02 rot_angle = -3.8 pos=<pos2d>
endscript

script hit_note_fx
	if ($disable_particles > 1)
		return
	endif
	ProfilingStart
	// get gem color for gem fill particles
	if StructureContains structure=$gib_colors <Color>
		col1 = ($gib_colors.<Color>)
	else
		col1 = [255 0 255 255]
		printf 'moron'
		printf '%s' s = <Color>
	endif
	col2 = <col1>
	SetArrayElement ArrayName = col2 index = 3 NewValue = (0.5 * <col2>[3])
	
	NoteFX <...>
	// scale and offset flame
	Pos = (<Pos> + (0.0, 24.0))
	SetScreenElementProps id = <fx_id> Pos = <Pos> Scale = (1.4, 1.4) relative_scale

	ExtendCrc gem_container <player_text> out = container_id
	time = (0.366666 / ($current_speedfactor))
	if ($disable_particles = 0)
		Pos = (<Pos> - (0.0, 36.0))
		// shockwave
		// changed to ExtendCrc for extreme speed
		//FormatText checksumName = shock_id '%s_shockwave' s = <fx_id>
		//ExtendCrc <fx_id> '_shockwave' out = shock_id // somehow crashes
		ExtendCrc <fx_id> ($button_up_models.<color>.name_string) out = fx2_id
		ExtendCrc <fx2_id> '_shock' out = shock_id
		CreateScreenElement {
			type = SpriteElement
			parent = <container_id>
			id = <shock_id>
			Scale = 2.0
			rgba = $color_white
			just = [center center]
			z_priority = 4
			Pos = <Pos>
			alpha = 0.15
			texture = shockwave
			// actually uses blend
		}
		// that one other gib sprite that scales up
		ExtendCrc <fx2_id> '_gib2' out = gib2_id
		CreateScreenElement {
			type = SpriteElement
			parent = <container_id>
			id = <gib2_id>
			Scale = 0.8
			rgba = <col1>
			just = [center center]
			z_priority = 4
			Pos = (<Pos> - (0.0, 16.0))
			alpha = 1
			texture = gem_gib2
			blend = add
			rot_angle = randomrange (0.0, 360.0)
		}
		// gem cylinder gibs
		ExtendCrc <fx2_id> '_gib1' out = gib1_id
		part_params = ($gib_particle_params)
		Create2DParticleSystem {
			<part_params>
			id = <gib1_id>
			Pos = <Pos>
			parent = <container_id>
			start_color = <col1>
			end_color = <col2>
		}
		DoScreenElementMorph id = <shock_id> time = <time> alpha = 0 Scale = 6.0 relative_scale
		time2 = (0.24 / ($current_speedfactor))
		DoScreenElementMorph id = <gib2_id> time = <time2> alpha = 0 Scale = 5.0 relative_scale
	endif
	ProfilingEnd <...> 'hit_note_fx'
	if ($disable_particles = 0)
		wait \{100 #"0x8d07dc15"} // what is this anyway??? the key doesn't exist in the EXE
		Destroy2DParticleSystem id = <particle_id> kill_when_empty
		Destroy2DParticleSystem id = <gib1_id> kill_when_empty
	endif
	if ($disable_particles = 1)
		Destroy2DParticleSystem id = <particle_id>
		wait \{100 #"0x8d07dc15"}
	endif
	wait \{167 #"0x8d07dc15"}
	if (ScreenElementExists id = <fx_id>)
		DestroyScreenElement id = <fx_id>
	endif
	wait <time> seconds
	if ScreenElementExists id = <shock_id>
		DestroyScreenElement id = <shock_id>
	endif
	if ScreenElementExists id = <gib2_id>
		DestroyScreenElement id = <gib2_id>
	endif
endscript

script GuitarEvent_CreateFirstGem
endscript

script show_star_power_ready
	if ($Cheat_PerformanceMode = 1)
		return
	endif
	if ($game_mode = p2_career || $game_mode = p2_coop)
		<player_status> = player1_status
	endif
	SoundEvent \{event = Star_Power_Ready_SFX}
endscript

gib_colors = {
	green	= [	 43 196	 75 255 ]
	red		= [ 200	 68	 68 255 ]
	yellow	= [ 255 255	  0 255 ]
	blue	= [	 66	 66 184 255 ]
	orange	= [ 255 127	  0 255 ]
}
default_particle_params = {
	z_priority = 8.0
	//start_angle_spread = 0.0
	//min_rotation = 0.0
	max_rotation = 360.0
	//emit_dir = 0.0
}
gib_particle_params = {
	$default_particle_params
	//z_priority = 8.0
	material = sys_Particle_lnzflare02_sys_Particle_lnzflare02
	// poor modder ^
	start_scale = (1.3, 1.3)
	end_scale = (1.8, 1.8)
	//start_angle_spread = 0.0
	//min_rotation = 0.0
	//max_rotation = 360.0
	emit_start_radius = 20.0
	emit_radius = 14.0
	Emit_Rate = 0.02
	//emit_dir = 0.0
	emit_spread = 130.0
	velocity = 8.0
	friction = (0.0, 60.0)
	time = 0.4
}
hit_particle_params = {
	$default_particle_params
	//z_priority = 8.0
	material = sys_gem_gib1_sys_gem_gib1
	start_color = $color_white
	end_color = [
		128
		128
		128
		255
	]
	start_scale = (2.0, 2.0)
	end_scale = (2.8, 2.8)
	//start_angle_spread = 0.0
	//min_rotation = 0.0
	//max_rotation = 360.0
	emit_start_radius = 30.0
	emit_radius = 20.0
	Emit_Rate = 0.04
	//emit_dir = 0.0
	emit_spread = 160.0
	velocity = 6.0
	friction = (0.0, 130.0)
	time = 0.25
}
star_hit_particle_params = $hit_particle_params
whammy_particle_params = {
	$default_particle_params
	//z_priority = 8.0
	material = sys_Particle_Spark01_sys_Particle_Spark01
	start_color = $color_white
	end_color = $color_white
	start_scale = (0.8, 0.8)
	end_scale = (0.6, 0.6)
	//start_angle_spread = 0.0
	//min_rotation = 0.0
	//max_rotation = 360.0
	emit_start_radius = 0.0
	emit_radius = 1.0
	Emit_Rate = 0.06
	//emit_dir = 0.0
	emit_spread = 60.0
	velocity = 15.0
	friction = (0.0, 50.0)
	time = 0.5
}

script solo_ui_create \{Player = 1}
	FormatText checksumName = lsh_p 'last_solo_hits_p%d' d = <Player>
	FormatText checksumName = lst_p 'last_solo_total_p%d' d = <Player>
	num = ((100 * $<lsh_p>) / $<lst_p>)
	FormatText textname = text '%d\%' d = <num>
	FormatText checksumName = solotxt 'solotxt%d' d = <Player>
	FormatText checksumName = gemcont 'gem_containerp%d' d = <Player>
	if ScreenElementExists id = <solotxt>
		DestroyScreenElement id = <solotxt>
		killspawnedscript \{name = solo_ui_end}
	endif
	CreateScreenElement {
		type = TextElement
		parent = <gemcont>
		id = <solotxt>
		font = chalet
		Scale = 0.8
		rgba = $color_white
		text = <text>
		just = [center center]
		z_priority = 20
		Pos = (640.0, 296.0)
	}
endscript

script solo_ui_end \{Player = 1}
	FormatText checksumName = solotxt 'solotxt%d' d = <Player>
	FormatText checksumName = lsh_p 'last_solo_hits_p%d' d = <Player>
	FormatText checksumName = lst_p 'last_solo_total_p%d' d = <Player>
	if ScreenElementExists id = <solotxt>
		Bonus = ($<lsh_p> * $solo_bonus_pts)
		perf = ((100 * $<lsh_p>)/ $<lst_p>)
		DoScreenElementMorph id = <solotxt> time = 0.3 Scale = 1.8 relative_scale
		wait \{1.5 seconds}
		// RB1 looks less lenient on grading text for this
		// should this performance thing be determined by
		// an absolute note/miss count like sections marked as red
		// for missing a lot despite if it's 99%
		perf_text = 'BAD'
		if (<perf> <= 56)
			perf_text = 'POOR'
		elseif (<perf> <= 64)
			perf_text = 'OKAY'
		elseif (<perf> <= 76)
			perf_text = 'GOOD'
		elseif (<perf> <= 88)
			perf_text = 'GREAT'
		elseif (<perf> < 100)
			perf_text = 'AWESOME'
		elseif (<perf> >= 100)
			perf_text = 'PERFECT'
		endif
		FormatText textname = text '%t SOLO!' t = <perf_text>
		if ScreenElementExists id = <solotxt>
			FormatText checksumName = gemcont 'gem_containerp%d' d = <Player>
			if ScreenElementExists id = <solotxt>
				DestroyScreenElement id = <solotxt>
			endif
			CreateScreenElement {
				type = TextElement
				parent = <gemcont>
				id = <solotxt>
				font = fontgrid_title_gh3
				Scale = 0
				rgba = $color_white
				text = <text>
				just = [center center]
				z_priority = 20
				Pos = (640.0, 296.0)
			}
			SetScreenElementProps id = <solotxt> text = <text>
			DoScreenElementMorph id = <solotxt> time = 0.1 Scale = 1
		endif
		wait \{1.5 seconds}
		FormatText textname = text '%d POINTS!' d = <Bonus>
		if ScreenElementExists id = <solotxt>
			SetScreenElementProps id = <solotxt> text = <text>
			DoScreenElementMorph id = <solotxt> Scale = 0
			DoScreenElementMorph id = <solotxt> time = 0.1 Scale = 1
			wait \{1.5 seconds}
			DoScreenElementMorph id = <solotxt> time = 0.1 Scale = 0
		endif
		wait \{0.1 seconds}
		if ScreenElementExists id = <solotxt>
			DestroyScreenElement id = <solotxt>
		endif
	endif
endscript
button_models = {
	green = {
		gem_material = sys_Gem2D_Green_sys_Gem2D_Green
		gem_hammer_material = sys_Gem2D_Green_hammer_sys_Gem2D_Green_hammer
		star_material = sys_Star2D_Green_sys_Star2D_Green
		star_hammer_material = sys_Star2D_Green_Hammer_sys_Star2D_Green_Hammer
		battle_star_material = sys_BattleGEM_Green01_sys_BattleGEM_Green01
		battle_star_hammer_material = sys_BattleGEM_Hammer_Green01_sys_BattleGEM_Hammer_Green01
		whammy_material = sys_Whammy2D_Green_sys_Whammy2D_Green
		star_power_material = sys_Gem2D_Green_sys_Gem2D_Green
		star_power_hammer_material = sys_Gem2D_Green_hammer_sys_Gem2D_Green_hammer
		star_power_whammy_material = sys_Whammy2D_StarPower_sys_Whammy2D_StarPower
		dead_whammy = sys_Whammy2D_Dead_sys_Whammy2D_Dead
		name = button_g
	}
	red = {
		gem_material = sys_Gem2D_Red_sys_Gem2D_Red
		gem_hammer_material = sys_Gem2D_Red_hammer_sys_Gem2D_Red_hammer
		star_material = sys_Star2D_Red_sys_Star2D_Red
		star_hammer_material = sys_Star2D_Red_Hammer_sys_Star2D_Red_Hammer
		battle_star_material = sys_BattleGEM_RED01_sys_BattleGEM_RED01
		battle_star_hammer_material = sys_BattleGEM_Hammer_RED01_sys_BattleGEM_Hammer_RED01
		whammy_material = sys_Whammy2D_Red_sys_Whammy2D_Red
		star_power_material = sys_Gem2D_Red_sys_Gem2D_Red
		star_power_hammer_material = sys_Gem2D_Red_hammer_sys_Gem2D_Red_hammer
		star_power_whammy_material = sys_Whammy2D_StarPower_sys_Whammy2D_StarPower
		dead_whammy = sys_Whammy2D_Dead_sys_Whammy2D_Dead
		name = button_r
	}
	yellow = {
		gem_material = sys_Gem2D_Yellow_sys_Gem2D_Yellow
		gem_hammer_material = sys_Gem2D_Yellow_hammer_sys_Gem2D_Yellow_hammer
		star_material = sys_Star2D_Yellow_sys_Star2D_Yellow
		star_hammer_material = sys_Star2D_Yellow_Hammer_sys_Star2D_Yellow_Hammer
		battle_star_material = sys_BattleGEM_Yellow01_sys_BattleGEM_Yellow01
		battle_star_hammer_material = sys_BattleGEM_Hammer_Yellow01_sys_BattleGEM_Hammer_Yellow01
		whammy_material = sys_Whammy2D_Yellow_sys_Whammy2D_Yellow
		star_power_material = sys_Gem2D_Yellow_sys_Gem2D_Yellow
		star_power_hammer_material = sys_Gem2D_Yellow_hammer_sys_Gem2D_Yellow_hammer
		star_power_whammy_material = sys_Whammy2D_StarPower_sys_Whammy2D_StarPower
		dead_whammy = sys_Whammy2D_Dead_sys_Whammy2D_Dead
		name = button_y
	}
	blue = {
		gem_material = sys_Gem2D_Blue_sys_Gem2D_Blue
		gem_hammer_material = sys_Gem2D_Blue_hammer_sys_Gem2D_Blue_hammer
		star_material = sys_Star2D_Blue_sys_Star2D_Blue
		star_hammer_material = sys_Star2D_Blue_Hammer_sys_Star2D_Blue_Hammer
		battle_star_material = sys_BattleGEM_Blue01_sys_BattleGEM_Blue01
		battle_star_hammer_material = sys_BattleGEM_Hammer_Blue01_sys_BattleGEM_Hammer_Blue01
		whammy_material = sys_Whammy2D_Blue_sys_Whammy2D_Blue
		star_power_material = sys_Gem2D_Blue_sys_Gem2D_Blue
		star_power_hammer_material = sys_Gem2D_Blue_hammer_sys_Gem2D_Blue_hammer
		star_power_whammy_material = sys_Whammy2D_StarPower_sys_Whammy2D_StarPower
		dead_whammy = sys_Whammy2D_Dead_sys_Whammy2D_Dead
		name = button_b
	}
	orange = {
		gem_material = sys_Gem2D_Orange_sys_Gem2D_Orange
		gem_hammer_material = sys_Gem2D_Orange_hammer_sys_Gem2D_Orange_hammer
		star_material = sys_Star2D_Orange_sys_Star2D_Orange
		star_hammer_material = sys_Star2D_Orange_Hammer_sys_Star2D_Orange_Hammer
		battle_star_material = sys_BattleGEM_Orange01_sys_BattleGEM_Orange01
		battle_star_hammer_material = sys_BattleGEM_Hammer_Orange01_sys_BattleGEM_Hammer_Orange01
		whammy_material = sys_Whammy2D_Orange_sys_Whammy2D_Orange
		star_power_material = sys_Gem2D_Orange_sys_Gem2D_Orange
		star_power_hammer_material = sys_Gem2D_Orange_hammer_sys_Gem2D_Orange_hammer
		star_power_whammy_material = sys_Whammy2D_StarPower_sys_Whammy2D_StarPower
		dead_whammy = sys_Whammy2D_Dead_sys_Whammy2D_Dead
		name = button_o
	}
}
sp_tube_base = {
	element_parent = HUD2D_highwaybar
	texture = None
	zoff = 49
	blend = add
	container
	full = {
		texture = None
		star_texture = None
		zoff = 49.5
		alpha = 0
	}
}
sp_tube_base2 = {
	zoff = 49.4
	pos_off = (0.0, 0.0)
	alpha = 1
}
streakpie_base = {
	element_parent = HUD2D_streakPie_2
	Scale = 0.9
	zoff = 51.1
	alpha = 0
	blend = add
}
nixie_base = {
	element_parent = HUD2D_streakPie_2
	pos_off = (34.0, 15.0)
	Scale = 0.72
	rot = 1.0
	zoff = 45
	alpha = 0
}
rocklight_base = {
	element_parent = HUD2D_rock_body
	pos_off = (0.0, -72.0)
	zoff = 18
	just = [
		left
		top
	]
	alpha = 0
}
career_hud_2d_elements = {
	offscreen_rock_pos = (106.0, 1300.0)
	offscreen_score_pos = (830.0, -770.0)
	rock_pos = (106.0, 462.0)
	score_pos = (840.0, 0.0)
	counter_pos = (40.0, 1520.0)
	offscreen_rock_pos_p1 = (-500.0, 100.0)
	offscreen_score_pos_p1 = (-500.0, 40.0)
	rock_pos_p1 = (550.0, 100.0)
	score_pos_p1 = (250.0, 40.0)
	counter_pos_p1 = (-2000.0, 200.0)
	offscreen_rock_pos_p2 = (2000.0, 100.0)
	offscreen_score_pos_p2 = (2000.0, 40.0)
	rock_pos_p2 = (1200.0, 100.0)
	score_pos_p2 = (900.0, 40.0)
	counter_pos_p2 = (-2000.0, 200.0)
	offscreen_note_streak_bar_off = (0.0, 300.0)
	#"0x936bb5fe" = $#"0x28381025"
	Scale = 1.1
	small_bulb_scale = 0.7
	big_bulb_scale = 1.0
	z = 0
	score_frame_width = 160.0
	offscreen_gamertag_pos = (0.0, -400.0)
	final_gamertag_pos = (0.0, 0.0)
	elements = [
		{
			parent_container
			element_id = #"0xa90fc148"
			pos_type = #"0x936bb5fe"
		}
		{
			element_id = #"0x99dd87cc"
			element_parent = #"0xa90fc148"
			texture = $#"0x1d52cdca"
			dims = $#"0x8d974f74"
			rot = -0.1
			just = [
				left
				top
			]
			rgba = $#"0x902ecc17"
			zoff = -2147483648
		}
		////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////
		//															  //
		// COMMENTS BECAUSE HAVING TO LOOK AROUND HERE FOR A SPECIFIC //
		// ELEMENT FOR 10 SECONDS MAKES ME CRINGE HARD				  //
		//															  //
		////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////
		{
			parent_container
			element_id = HUD2D_rock_container
			pos_type = offscreen_rock_pos
		}
		// STARPOWER READY FLASH
		// which i blanked the texture that uses this
		{
			element_id = HUD2D_rock_glow
			element_parent = HUD2D_rock_container
			texture = Char_Select_Hilite1
			pos_off = (-50.0, -100.0)
			dims = (350.0, 350.0)
			rgba = [
				95
				205
				255
				255
			]
			alpha = 0
			zoff = -10
		}
		// ROCK METER
		{
			element_id = HUD2D_rock_body
			element_parent = HUD2D_rock_container
			texture = hud_rock_body
			pos_off = (0.0, 0.0)
			zoff = 22
			rot = -90.0
			Scale = 1.2
		}
		{
			element_id = HUD2D_rock_lights_green
			texture = hud_rock_lights_green
			$rocklight_base
			// hardcore optimization
		}
		{
			element_id = HUD2D_rock_lights_red
			texture = hud_rock_lights_red
			$rocklight_base
		}
		{
			element_id = HUD2D_rock_lights_yellow
			texture = hud_rock_lights_yellow
			$rocklight_base
		}
		{
			element_id = HUD2D_rock_needle
			element_parent = HUD2D_rock_body
			texture = hud_rock_needle
			pos_off = (135.0, 78.0)
			zoff = 24
			just = [
				0.5
				0.8
			]
			Scale = 0.65
		}
		{
			parent_container
			element_id = HUD2D_score_container
			pos_type = offscreen_score_pos
		}
		// SCORE BOX
		{
			element_id = HUD2D_score_body
			element_parent = HUD2D_score_container
			texture = hud_score_body
			pos_type = score_pos
			pos_off = (0.0, -13.0)
			zoff = 5
			Scale = 1.0
		}
		/*{
			parent_container
			element_id = HUD2D_note_container
			pos_type = counter_pos
			note_streak_bar
		}
		{
			element_id = HUD2D_counter_body
			element_parent = HUD2D_note_container
			texture = hud_counter_body
			zoff = 9
		}
		{
			element_id = hud_counter_drum
			element_parent = HUD2D_note_container
			texture = hud_counter_drum
			pos_off = (4.0, 40.0)
			zoff = 8
		}
		{
			element_id = HUD2D_counter_drum_icon
			element_parent = HUD2D_note_container
			texture = hud_counter_drum_icon
			pos_off = (44.0, 40.0)
			zoff = 26
		}*/
		// HIGHWAY / ENERGY BAR
		{
			element_id = HUD2D_highwaybar
			element_parent = HUD2D_score_container
			pos_off = (-319.0, 585.0)
			Scale = 0.68
			texture = none
		}
		{
			element_id = HUD2D_energybar
			element_parent = HUD2D_highwaybar
			texture = HUD_energybar
			//pos_off = (-269.0, -30.0)
			pos_off = (-284.0, -34.0)
			dims = (750.0, 96.0)
			//scale = 1.4
			zoff = 47
		}
		// OVERDRIVE
		// black magic trickery but more
		// exposed because of blending being stupid
		{
			element_id = HUD2D_rock_tube_1
			pos_off = (-270.13, 24.5)
			rot = 85.5
			$sp_tube_base
			tube = {
				texture = HUD_energyfill_0
				star_texture = HUD_energyfill_0
				$sp_tube_base2
			}
		}
		{
			element_id = HUD2D_rock_tube_2
			pos_off = (-148.55, 15.4)
			rot = 87.5
			$sp_tube_base
			tube = {
				texture = HUD_energyfill_1
				star_texture = HUD_energyfill_1
				$sp_tube_base2
			}
		}
		{
			element_id = HUD2D_rock_tube_3
			pos_off = (-30.1, 10.4)
			rot = 89.0
			$sp_tube_base
			tube = {
				texture = HUD_energyfill_1b // stupid compensation for trimming off one pixel
				star_texture = HUD_energyfill_1b // on the middle fill texture and leaving pits due to that
				$sp_tube_base2
			}
		}
		{
			element_id = HUD2D_rock_tube_4
			pos_off = (91.1, 9.0)
			rot = 90.6
			$sp_tube_base
			tube = {
				texture = HUD_energyfill_1
				star_texture = HUD_energyfill_1
				$sp_tube_base2
			}
		}
		{
			element_id = HUD2D_rock_tube_5
			pos_off = (209.7, 10.7)
			rot = 92.5
			$sp_tube_base
			tube = {
				texture = HUD_energyfill_1
				star_texture = HUD_energyfill_1
				$sp_tube_base2
			}
		}
		{
			element_id = HUD2D_rock_tube_6
			pos_off = (328.0, 15.6)
			rot = 94
			$sp_tube_base
			tube = {
				texture = HUD_energyfill_2
				star_texture = HUD_energyfill_2
				$sp_tube_base2
			}
		}
		// STREAK PIE / CIRCLE THING
		{
			element_id = HUD2D_streakPie_1
			element_parent = HUD2D_highwaybar
			texture = HUD_streakPie_outline
			pos_off = (0.0, 0.0)
			Scale = 1.4
			zoff = 50
		}
		{
			element_id = HUD2D_streakPie_2
			element_parent = HUD2D_streakPie_1
			texture = HUD_streakPie_overlay
			pos_off = (31.0, -3.0)
			Scale = 1.05
			zoff = 52
		}
		// whatever
		{
			element_parent = HUD2D_streakPie_2
			element_id = HUD2D_score_flash
			texture = hud_score_flash
			blend = add
			just = [center center]
			pos_off = (24.0, 48.0)
			zoff = 53
			scale = 0.4
			alpha = 0
		}
		// 1/10
		{
			element_id = HUD2D_score_light_halflit_1
			texture = hud_score_light_1
			pos_off = (32.0, 5.0)
			$streakpie_base
		}
		// 3/10
		{
			element_id = HUD2D_score_light_halflit_2
			//texture = hud_score_light_1 // last variable is kept lol
			pos_off = (59.6, 24.0)
			rot = 72.0
			$streakpie_base
		}
		// 5/10
		{
			element_id = HUD2D_score_light_halflit_3
			//texture = hud_score_light_1
			pos_off = (50.0, 56.5)
			rot = 144.0
			$streakpie_base
		}
		// 7/10
		{
			element_id = HUD2D_score_light_halflit_4
			//texture = hud_score_light_1
			pos_off = (14.4, 57.4)
			rot = 216.0
			$streakpie_base
		}
		// 9/10
		{
			element_id = HUD2D_score_light_halflit_5
			//texture = hud_score_light_1
			pos_off = (4.1, 24.5)
			rot = 288.0
			$streakpie_base
		}
		// 2/10
		{
			element_id = HUD2D_score_light_allwaylit_1
			texture = hud_score_light_2
			pos_off = (32.0, 5.0)
			$streakpie_base
		}
		// 4/10
		{
			element_id = HUD2D_score_light_allwaylit_2
			//texture = hud_score_light_2
			pos_off = (59.6, 24.2)
			rot = 72.0
			$streakpie_base
		}
		// 6/10
		{
			element_id = HUD2D_score_light_allwaylit_3
			//texture = hud_score_light_2
			pos_off = (48.0, 56.5)
			rot = 144.0
			$streakpie_base
		}
		// 8/10
		{
			element_id = HUD2D_score_light_allwaylit_4
			//texture = hud_score_light_2
			pos_off = (14.8, 55.4)
			rot = 216.0
			$streakpie_base
		}
		// 10/10
		{
			element_id = HUD2D_score_light_allwaylit_5
			//texture = hud_score_light_2
			pos_off = (4.1, 24.5)
			rot = 288.0
			$streakpie_base
		}
		// MULTIPLIER BOX
		// THESE STACKED ELEMENTS ARE THE REASON
		// FOR WHY THERE ISN'T A CHANGE TEXTURE FUNCTION
		{
			element_id = HUD2D_score_nixie_2a
			texture = hud_score_nixie_2a
			$nixie_base
		}
		{
			element_id = HUD2D_score_nixie_2b
			texture = hud_score_nixie_2b
			$nixie_base
		}
		{
			element_id = HUD2D_score_nixie_3a
			texture = hud_score_nixie_3a
			$nixie_base
		}
		{
			element_id = HUD2D_score_nixie_4a
			texture = hud_score_nixie_4a
			$nixie_base
		}
		{
			element_id = HUD2D_score_nixie_4b
			texture = hud_score_nixie_4b
			$nixie_base
		}
		{
			element_id = HUD2D_score_nixie_6b
			texture = hud_score_nixie_6b
			$nixie_base
		}
		{
			element_id = HUD2D_score_nixie_8b
			texture = hud_score_nixie_8b
			$nixie_base
		}
		// STARS
		{
			element_id = HUD2D_star_container
			element_parent = HUD2D_score_container
			pos_off = (116.5, 95.0)
			Scale = 0.65
			texture = none
		}
		// :/
		// STAR 1
		{
			// BASE
			element_id = HUD2D_star1
			$star_base_params
			pos_off = (0.0, 0.0)
		}
		{
			// COUNTER CLOCKWISE ANIMATION
			element_id = HUD2D_star1_glow
			element_parent = HUD2D_star1
			$star_glow_params
		}
		{
			// HIDE CIRCLE LEAKING TO THE OTHER SIDE
			element_id = HUD2D_star1_mask
			element_parent = HUD2D_star1
			$star_glow_mask_params
		}
		{
			// ONE STAR DISPLAY
			element_id = HUD2D_star1_whole
			element_parent = HUD2D_star1
			$star_whole_params
		}
		{
			// ANIMATION FOR ABOVE
			element_id = HUD2D_star1_whole2
			element_parent = HUD2D_star1
			$star_whole2_params
		}
		{
			// FC STAR
			element_id = HUD2D_star1_gold
			element_parent = HUD2D_star1
			$star_gold_params
		}
		{
			element_id = HUD2D_star1_fill_i
			element_parent = HUD2D_star1
			rot = 90
			$hud_star_glow_params
			texture = hud_star_glow_4th
		}
		{
			element_id = HUD2D_star1_fill_ii
			element_parent = HUD2D_star1
			rot = 180
			$hud_star_glow_params
			texture = hud_star_glow_half
		}
		{
			element_id = HUD2D_star1_fill_iii
			element_parent = HUD2D_star1
			rot = 270
			$hud_star_glow_params
		}
		// STAR 2
		{
			element_id = HUD2D_star2
			$star_base_params
			pos_off = (72.0, 0.0)
			alpha = 0
		}
		{
			element_id = HUD2D_star2_glow
			element_parent = HUD2D_star2
			$star_glow_params
		}
		{
			element_id = HUD2D_star2_mask
			element_parent = HUD2D_star2
			$star_glow_mask_params
		}
		{
			element_id = HUD2D_star2_whole
			element_parent = HUD2D_star2
			$star_whole_params
		}
		{
			element_id = HUD2D_star2_whole2
			element_parent = HUD2D_star2
			$star_whole2_params
		}
		{
			element_id = HUD2D_star2_gold
			element_parent = HUD2D_star2
			$star_gold_params
		}
		{
			element_id = HUD2D_star2_fill_i
			element_parent = HUD2D_star2
			rot = 90
			$hud_star_glow_params
			texture = hud_star_glow_4th
		}
		{
			element_id = HUD2D_star2_fill_ii
			element_parent = HUD2D_star2
			rot = 180
			$hud_star_glow_params
			texture = hud_star_glow_half
		}
		{
			element_id = HUD2D_star2_fill_iii
			element_parent = HUD2D_star2
			rot = 270
			$hud_star_glow_params
		}
		// STAR 3
		{
			element_id = HUD2D_star3
			$star_base_params
			pos_off = (144.0, 0.0)
			alpha = 0
		}
		{
			element_id = HUD2D_star3_glow
			element_parent = HUD2D_star3
			$star_glow_params
		}
		{
			element_id = HUD2D_star3_mask
			element_parent = HUD2D_star3
			$star_glow_mask_params
		}
		{
			element_id = HUD2D_star3_whole
			element_parent = HUD2D_star3
			$star_whole_params
		}
		{
			element_id = HUD2D_star3_whole2
			element_parent = HUD2D_star3
			$star_whole2_params
		}
		{
			element_id = HUD2D_star3_gold
			element_parent = HUD2D_star3
			$star_gold_params
		}
		{
			element_id = HUD2D_star3_fill_i
			element_parent = HUD2D_star3
			rot = 90
			$hud_star_glow_params
			texture = hud_star_glow_4th
		}
		{
			element_id = HUD2D_star3_fill_ii
			element_parent = HUD2D_star3
			rot = 180
			$hud_star_glow_params
			texture = hud_star_glow_half
		}
		{
			element_id = HUD2D_star3_fill_iii
			element_parent = HUD2D_star3
			rot = 270
			$hud_star_glow_params
		}
		// STAR 4
		{
			element_id = HUD2D_star4
			$star_base_params
			pos_off = (216.0, 0.0)
			alpha = 0
		}
		{
			element_id = HUD2D_star4_glow
			element_parent = HUD2D_star4
			$star_glow_params
		}
		{
			element_id = HUD2D_star4_mask
			element_parent = HUD2D_star4
			$star_glow_mask_params
		}
		{
			element_id = HUD2D_star4_whole
			element_parent = HUD2D_star4
			$star_whole_params
		}
		{
			element_id = HUD2D_star4_whole2
			element_parent = HUD2D_star4
			$star_whole2_params
		}
		{
			element_id = HUD2D_star4_gold
			element_parent = HUD2D_star4
			$star_gold_params
		}
		{
			element_id = HUD2D_star4_fill_i
			element_parent = HUD2D_star4
			rot = 90
			$hud_star_glow_params
			texture = hud_star_glow_4th
		}
		{
			element_id = HUD2D_star4_fill_ii
			element_parent = HUD2D_star4
			rot = 180
			$hud_star_glow_params
			texture = hud_star_glow_half
		}
		{
			element_id = HUD2D_star4_fill_iii
			element_parent = HUD2D_star4
			rot = 270
			$hud_star_glow_params
		}
		// STAR 5
		{
			element_id = HUD2D_star5
			$star_base_params
			pos_off = (288.0, 0.0)
			alpha = 0
		}
		{
			element_id = HUD2D_star5_glow
			element_parent = HUD2D_star5
			$star_glow_params
		}
		{
			element_id = HUD2D_star5_mask
			element_parent = HUD2D_star5
			$star_glow_mask_params
		}
		{
			element_id = HUD2D_star5_whole
			element_parent = HUD2D_star5
			$star_whole_params
		}
		{
			element_id = HUD2D_star5_whole2
			element_parent = HUD2D_star5
			$star_whole2_params
		}
		{
			element_id = HUD2D_star5_gold
			element_parent = HUD2D_star5
			$star_gold_params
		}
		{
			element_id = HUD2D_star5_fill_i
			element_parent = HUD2D_star5
			rot = 90
			$hud_star_glow_params
			texture = hud_star_glow_4th
		}
		{
			element_id = HUD2D_star5_fill_ii
			element_parent = HUD2D_star5
			rot = 180
			$hud_star_glow_params
			texture = hud_star_glow_half
		}
		{
			element_id = HUD2D_star5_fill_iii
			element_parent = HUD2D_star5
			rot = 270
			$hud_star_glow_params
		}
	]
}
// simplify for 5 stars
star_base_params = {
	element_parent = HUD2D_star_container
	just = [center center]
	texture = hud_star_base
	zoff = 50
	scale = 1.0
}
star_glow_params = { // whatever
	pos_off = (32.0, 32.0)
	just = [center center]
	texture = hud_star_glow
	zoff = 50.1
	scale = 1//.05
	//alpha = 1
}
star_glow_mask_params = {
	pos_off = (32.0, 32.0)
	just = [center center]
	texture = hud_star_glow_mask
	zoff = 50.2
	scale = 1//.025
	//alpha = 1
}
star_whole_params = {
	texture = hud_star_whole
	zoff = 50.4
	alpha = 0
}
star_whole2_params = {
	texture = hud_star_whole
	zoff = 50.5
	alpha = 0
	rgba = [243 195 3]
}
star_gold_params = {
	texture = hud_star_gold
	zoff = 50.6
	alpha = 0
}
hud_star_glow_params = {
	pos_off = (32.0, 32.0)
	just = [center center]
	texture = hud_star_glow
	zoff = 50.3
	scale = 1//.05
	alpha = 0
}

script create_2d_hud_elements \{player_text = 'p1'}
	ProfilingStart
	Change \{g_flash_red_going_p1 = 0}
	Change \{g_flash_red_going_p2 = 0}
	Change \{old_animate_bulbs_star_power_p1 = 0.0}
	Change \{old_animate_bulbs_star_power_p2 = 0.0}
	GetArraySize (($g_hud_2d_struct_used).elements)
	parent_scale = (($g_hud_2d_struct_used).Scale)
	old_parent = <parent>
	parent_z = (($g_hud_2d_struct_used).z)
	i = 0
	begin
		just = [left top]
		myscale = 1.0
		zoff = 0.0
		rot = 0.0
		alpha = 1
		pos_off = (0.0, 0.0)
		blend = 0
		AddParams (($g_hud_2d_struct_used).elements [<i>])
		element_struct = (($g_hud_2d_struct_used).elements [<i>])
		if StructureContains structure = <element_struct> parent_container
			if StructureContains structure = <element_struct> element_parent
				ExtendCrc <element_parent> <player_text> out = container_parent
				if NOT ScreenElementExists id = <container_parent>
					ExtendCrc <element_parent> 'p1' out = container_parent
				endif
			else
				container_parent = <old_parent>
			endif
			container_pos = (0.0, 0.0)
			if StructureContains structure = <element_struct> pos_type
				<container_pos> = (($g_hud_2d_struct_used).<pos_type>)
				if (<player_text> = 'p2')
					ExtendCrc <pos_type> '_p2' out = new_pos_type
					<container_pos> = (($g_hud_2d_struct_used).<new_pos_type>)
				else
					if ($current_num_players = 2)
						ExtendCrc <pos_type> '_p1' out = new_pos_type
						<container_pos> = (($g_hud_2d_struct_used).<new_pos_type>)
					endif
				endif
			endif
			if StructureContains structure = <element_struct> note_streak_bar
				if StructureContains structure = ($g_hud_2d_struct_used)offscreen_note_streak_bar_off
					<container_pos> = (<container_pos> + (($g_hud_2d_struct_used).offscreen_note_streak_bar_off))
				else
					if (<player_text> = 'p1')
						<container_pos> = (<container_pos> + (($g_hud_2d_struct_used).offscreen_note_streak_bar_off_p1))
					else
						<container_pos> = (<container_pos> + (($g_hud_2d_struct_used).offscreen_note_streak_bar_off_p2))
					endif
				endif
			endif
			<container_pos> = (<container_pos> + <pos_off>)
			ExtendCrc <element_id> <player_text> out = new_id
			<create_it> = 1
			if StructureContains structure = <element_struct> create_once
				ExtendCrc <element_id> 'p1' out = p1_id
				if ScreenElementExists id = <p1_id>
					<create_it> = 0
				endif
			endif
			if ((StructureContains structure = <element_struct> rot_p2)& (<player_text> = 'p2'))
				<rot> = <rot_p2>
			endif
			if (<create_it>)
				CreateScreenElement {
					type = ContainerElement
					parent = <container_parent>
					id = <new_id>
					Pos = <container_pos>
					rot_angle = <rot>
					z_priority = <z_off>
				}
			endif
			parent = <new_id>
		endif
		if StructureContains structure = <element_struct> container
			if NOT StructureContains structure = <element_struct> parent_container
				ExtendCrc <element_id> <player_text> out = new_id
				ExtendCrc <element_parent> <player_text> out = myparent
				if StructureContains structure = <element_struct> small_bulb
					scaled_dims = (<element_dims> * (($g_hud_2d_struct_used).small_bulb_scale))
				else
					scaled_dims = (<element_dims> * (($g_hud_2d_struct_used).big_bulb_scale))
				endif
				if ((StructureContains structure = <element_struct> pos_off_p2)& (<player_text> = 'p2'))
					<pos_off> = <pos_off_p2>
				endif
				<create_it> = 1
				if StructureContains structure = <element_struct> create_once
					ExtendCrc <element_id> 'p1' out = p1_id
					if ScreenElementExists id = <p1_id>
						<create_it> = 0
					endif
				endif
				if (<create_it>)
					CreateScreenElement {
						type = SpriteElement
						parent = <myparent>
						id = <new_id>
						texture = <texture>
						Pos = <pos_off>
						just = <just>
						rgba = [255 255 255 255]
						rot_angle = <rot>
						z_priority = <zoff>
						alpha = <alpha>
						dims = <scaled_dims>
					}
					<new_id> ::SetTags morph = 0
					<new_id> ::SetTags index = <i>
					<parent> = <id>
					<rot> = 0.0
					<Pos> = (0.0, 0.0)
					if StructureContains structure = <element_struct> initial_pos
						if ((StructureContains structure = <element_struct> initial_pos_p2)& (<player_text> = 'p2'))
							SetScreenElementProps id = <new_id> Pos = <initial_pos_p2>
							<new_id> ::SetTags final_pos = <pos_off_p2>
							<new_id> ::SetTags initial_pos = <initial_pos_p2>
							<new_id> ::SetTags morph = 1
						else
							SetScreenElementProps id = <new_id> Pos = <initial_pos>
							<new_id> ::SetTags final_pos = <pos_off>
							<new_id> ::SetTags initial_pos = <initial_pos>
							<new_id> ::SetTags morph = 1
						endif
					endif
				endif
			endif
		else
			if NOT StructureContains structure = <element_struct> parent_container
				ExtendCrc <element_id> <player_text> out = new_id
				if StructureContains structure = <element_struct> initial_pos
					<pos_off> = <initial_pos>
				endif
				if StructureContains structure = <element_struct> battle_pos
					if (<player_text> = 'p2')
						<container_pos> = (($g_hud_2d_struct_used).rock_pos_p2)
						ExtendCrc <pos_type> '_p2' out = new_pos_type
						<pos_off> = ((($g_hud_2d_struct_used).<new_pos_type>))
					else
						<container_pos> = (($g_hud_2d_struct_used).rock_pos_p1)
						ExtendCrc <pos_type> '_p1' out = new_pos_type
						<pos_off> = ((($g_hud_2d_struct_used).<new_pos_type>))
					endif
				endif
				ExtendCrc <element_parent> <player_text> out = myparent
				flags = {}
				if StructureContains structure = <element_struct> flags
					if StructureContains structure = (<element_struct>.flags)flip_v
						if StructureContains structure = (<element_struct>.flags)p1
							if (<player_text> = 'p1')
								<flags> = flip_v
							endif
						endif
					endif
					if StructureContains structure = (<element_struct>.flags)flip_h
						if StructureContains structure = (<element_struct>.flags)p1
							if (<player_text> = 'p1')
								<flags> = flip_h
							endif
						endif
						if StructureContains structure = (<element_struct>.flags)p2
							if (<player_text> = 'p2')
								<flags> = flip_h
							endif
						endif
					endif
				endif
				mydims = {}
				if StructureContains structure = <element_struct> dims
					<mydims> = <dims>
				endif
				<create_it> = 1
				if StructureContains structure = <element_struct> create_once
					ExtendCrc <element_id> 'p1' out = p1_id
					if ScreenElementExists id = <p1_id>
						<create_it> = 0
					endif
				endif
				if ((StructureContains structure = <element_struct> initial_pos_p2)& (<player_text> = 'p2'))
					<pos_off> = <initial_pos_p2>
				elseif ((StructureContains structure = <element_struct> pos_off_p2)& (<player_text> = 'p2'))
					<pos_off> = <pos_off_p2>
				endif
				my_rgba = [255 255 255 255]
				if (StructureContains structure = <element_struct> rgba)
					<my_rgba> = <rgba>
				endif
				if (<create_it>)
					CreateScreenElement {
						type = SpriteElement
						parent = <myparent>
						id = <new_id>
						texture = <texture>
						Pos = <pos_off>
						rgba = <my_rgba>
						just = <just>
						z_priority = <zoff>
						alpha = <alpha>
						<flags>
						rot_angle = <rot>
						dims = <mydims>
						blend = <blend>
					}
				endif
				if StructureContains structure = <element_struct> Scale
					if (<create_it>)
						GetScreenElementDims id = <new_id>
						new_width = (<width> * <Scale>)
						new_height = (<height> * <Scale>)
						SetScreenElementProps id = <new_id> dims = (((1.0, 0.0) * <new_width>)+ ((0.0, 1.0) * <new_height>))
					endif
				endif
			endif
		endif
		if StructureContains structure = <element_struct> tube
			ExtendCrc <new_id> 'tube' out = new_child_id
			<zoff> = (<tube>.zoff)
			<alpha> = (<tube>.alpha)
			ExtendCrc <element_parent> <player_text> out = myparent
			if StructureContains structure = <element_struct> small_bulb
				scaled_dims = (<tube>.element_dims * (($g_hud_2d_struct_used).small_bulb_scale))
			else
				scaled_dims = (<tube>.element_dims * (($g_hud_2d_struct_used).big_bulb_scale))
			endif
			if ScreenElementExists id = <myparent>
				CreateScreenElement {
					type = SpriteElement
					parent = <myparent>
					id = <new_child_id>
					texture = (<tube>.texture)
					Pos = (<pos_off> + (<tube>.pos_off))
					rot_angle = (<element_struct>.rot)
					rgba = [255 255 255 255]
					blend = <blend>
					just = [center bottom]
					z_priority = <zoff>
					alpha = <alpha>
				}
				<parent> = <id>
				<new_child_id> ::SetTags morph = 0
				<new_child_id> ::SetTags old_dims = <element_dims>
				if StructureContains structure = <element_struct> initial_pos
					SetScreenElementProps id = <new_child_id> Pos = (<initial_pos> + (<tube>.pos_off))
					<new_child_id> ::SetTags {
						final_pos = (<pos_off> + (<tube>.pos_off))
						initial_pos = (<initial_pos> + (<tube>.pos_off))
						morph = 1
					}
				endif
			endif
		endif
		if StructureContains structure = <element_struct> full
			ExtendCrc <new_id> 'full' out = new_child_id
			<zoff> = (<full>.zoff)
			<alpha> = (<full>.alpha)
			ExtendCrc <element_parent> <player_text> out = myparent
			if StructureContains structure = <element_struct> small_bulb
				scaled_dims = (<element_dims> * (($g_hud_2d_struct_used).small_bulb_scale))
			else
				scaled_dims = (<element_dims> * (($g_hud_2d_struct_used).big_bulb_scale))
			endif
			if ScreenElementExists id = <myparent>
				CreateScreenElement {
					type = SpriteElement
					parent = <myparent>
					id = <new_child_id>
					texture = (<full>.texture)
					Pos = <pos_off>
					rgba = [255 255 255 255]
					blend = <blend>
					just = <just>
					z_priority = <zoff>
					alpha = <alpha>
				}
				<new_child_id> ::SetTags morph = 0
				if StructureContains structure = <element_struct> initial_pos
					SetScreenElementProps id = <new_child_id> Pos = <initial_pos>
					<new_child_id> ::SetTags final_pos = <pos_off>
					<new_child_id> ::SetTags initial_pos = <initial_pos>
					<new_child_id> ::SetTags morph = 1
				endif
			endif
		endif
		<i> = (<i> + 1)
	repeat <array_Size>
	if NOT ($game_mode = p2_battle || $boss_battle = 1)
		ExtendCrc HUD2D_Score_Text <player_text> out = new_id
		ExtendCrc HUD2D_score_container <player_text> out = new_score_container
		score_text_pos = (222.0, 70.0)
		if ($game_mode = p2_career || $game_mode = p2_coop)
			<score_text_pos> = (226.0, 85.0)
		endif
		if ScreenElementExists id = <new_score_container>
			displayText {
				parent = <new_score_container>
				id = <new_id>
				font = num_a9
				Pos = <score_text_pos>
				z = 20
				Scale = (1.1, 1.1)
				just = [right right]
				rgba = [255 255 255 255]
			}
			SetScreenElementProps id = <id> font_spacing = 5
		endif
		i = 1
		begin
			FormatText checksumName = note_streak_text_id 'HUD2D_Note_Streak_Text_%d' d = <i>
			ExtendCrc <note_streak_text_id> <player_text> out = new_id
			ExtendCrc HUD2D_note_container <player_text> out = new_note_container
			if ScreenElementExists id = <new_note_container>
				rgba = [230 230 230 200]
				displayText {
					parent = <new_note_container>
					id = <new_id>
					font = num_a7
					text = "0"
					Pos = ((222.0, 78.0) + (<i> * (-37.0, 0.0)))
					z = 25
					just = [center center]
					rgba = <rgba>
					noshadow
				}
				<id> ::SetTags intial_pos = ((222.0, 78.0) + (<i> * (-37.0, 0.0)))
			endif
			<i> = (<i> + 1)
		repeat 4
	endif
	ProfilingEnd <...> 'create_2d_hud_elements'
endscript
