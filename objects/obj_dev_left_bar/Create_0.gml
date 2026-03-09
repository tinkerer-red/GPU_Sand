owner = noone;

panel_title = "Dev Controls";

panel_wants_open = false;

panel_margin = 8;
panel_nub_width = 28;
panel_expanded_width = 320;
panel_header_height = 28;
panel_height = display_get_gui_height() - (panel_margin * 2);

panel_closed_x = -(panel_expanded_width + panel_margin);
panel_open_x = panel_margin;

panel_x = panel_closed_x;
panel_target_x = panel_closed_x;

panel_width = panel_expanded_width;
panel_target_width = panel_expanded_width;

panel_anim_lerp = 0.18;
panel_anim_epsilon = 0.25;

selected_state_of_matter = 3;

dev_settings = {
	state_of_matter: 3,
	gravity_force: 0.35,
	max_vel_x: 1.0,
	max_vel_y: 3.0,
	can_slip: 1.0,
	x_slip_search_range: 1.0,
	y_slip_search_range: 3.0,
	wake_chance: 0.0,
	stickiness_chance: 0.0,
	bounce_chance: 0.0,
	bounce_dampening_multiplier: 0.5,
	airborne_vel_decay_chance: 0.02,
	friction_vel_decay_chance: 0.05,
	mass: 1.0,
	can_ignite: 0.0,
	temperature_decay: 0.0,
	temperature_spread_chance: 0.0,
	explosion_resistance: 0.0,
	explosion_radius: 0.0,
	custom_event_chance: 0.0,
	replace_count: 0.0,
	replace_id_0: 0.0,
	replace_id_1: 0.0,
	replace_id_2: 0.0,
	replace_id_3: 0.0
};

selected_state_of_matter = dev_settings.state_of_matter;

gmui_init();