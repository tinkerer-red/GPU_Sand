event_user(15);

window_set_size(1700, 1000);
window_center();

simulation = new CanvasSandShader();

gmui_init();

dev_settings = {
	color: make_color_rgb(255, 64, 255),
	
	// === (0) (1)Solid (2)Liquid (3)Gas ===
	state_of_matter: 3,
	
	// === Gravity & Movement ===
	gravity_force: 1,
	max_vel_x: 2.0,
	max_vel_y: 2.0,
	
	can_slip: true,
	x_slip_search_range: 1.0,
	y_slip_search_range: 1.0,
	
	wake_chance: 1.0,
	
	stickiness_chance: 0.0,
	
	bounce_chance: 0.1,
	bounce_dampening_multiplier: 0.4,
	
	// === Velocity Decay ===
	airborne_vel_decay_chance: 0.35,
	friction_vel_decay_chance: 0.65,
	
	// === Physical ===
	mass: 150.0,
	
	// === Heat and Flammability ===
	can_ignite: false,
	temperature_decay: 0.0,
	temperature_spread_chance: 0.0,
	
	// === Explosive Properties ===
	explosion_resistance: 1.0,
	explosion_radius: 0.0,
	
	// === Lifecycle Control ===
	custom_event_chance: 0.0,
	
	// === Replacement Rules ===
	replace_count: 1.0,
	replace_id_0: 0.0,
	replace_id_1: 0.0,
	replace_id_2: 0.0,
	replace_id_3: 0.0,
	
};
simulation.dev_settings = dev_settings;

viewport_focused = false;
paint_radius = 64;

fps_window = 60;
fps_buffer = array_create(fps_window, 60);
frame_index = 0;
below_60 = false;
drop_timer = 0;
frame_count = 0;

step_times = array_create(fps_window, 0);
draw_times = array_create(fps_window, 0);

selected_element_index = 0;
selected_element_id = 1;
selected_element_name = "Sand";

ui_panel_anim_lerp = 0.18;
ui_panel_anim_epsilon = 0.25;

ui_elements = [
	{ name: "Sand", color: make_color_rgb(194, 178, 128), element_id: 1 },
	{ name: "Dev", color: undefined, element_id: 2 },
	{ name: "Water", color: make_color_rgb(64, 128, 255), element_id: 3 },
	{ name: "Stone", color: make_color_rgb(120, 120, 120), element_id: 4 },
	{ name: "Fire", color: make_color_rgb(255, 120, 32), element_id: 5 },
	{ name: "Smoke", color: make_color_rgb(96, 96, 96), element_id: 6 },
	{ name: "Steam", color: make_color_rgb(210, 210, 210), element_id: 7 },
	{ name: "Oil", color: make_color_rgb(48, 48, 20), element_id: 8 },
	{ name: "Acid", color: make_color_rgb(120, 255, 64), element_id: 9 },
	{ name: "Lava", color: make_color_rgb(255, 80, 0), element_id: 10 }
];

ui_elem_title = "Elements";
ui_elem_wants_open = false;
ui_elem_margin = 8;
ui_elem_nub_width = 28;
ui_elem_expanded_width = 220;
ui_elem_height = display_get_gui_height() - (ui_elem_margin * 2);
ui_elem_nub_height = 96;
ui_elem_nub_y = 8;
ui_elem_closed_x = -(ui_elem_expanded_width + ui_elem_margin);
ui_elem_open_x = ui_elem_margin + ui_elem_nub_width;
ui_elem_x = ui_elem_closed_x;
ui_elem_target_x = ui_elem_closed_x;

ui_dev_title = "Dev Controls";
ui_dev_wants_open = false;
ui_dev_margin = 8;
ui_dev_nub_width = 28;
ui_dev_expanded_width = 320;
ui_dev_height = display_get_gui_height() - (ui_dev_margin * 2);
ui_dev_nub_height = 96;
ui_dev_nub_y = ui_elem_nub_y + ui_elem_nub_height + 8;
ui_dev_closed_x = -(ui_dev_expanded_width + ui_dev_margin);
ui_dev_open_x = ui_dev_margin + ui_dev_nub_width;
ui_dev_x = ui_dev_closed_x;
ui_dev_target_x = ui_dev_closed_x;

ui_dev_section_identity_open = false;
ui_dev_section_movement_open = false;
ui_dev_section_motion_open = false;
ui_dev_section_decay_open = false;
ui_dev_section_physical_open = false;
ui_dev_section_heat_open = false;
ui_dev_section_explosion_open = false;
ui_dev_section_lifecycle_open = false;
ui_dev_section_replace_open = false;

ui_pass_title = "Pass Views";
ui_pass_wants_open = false;
ui_pass_margin = 8;
ui_pass_nub_width = 28;
ui_pass_expanded_width = 240;
ui_pass_preview_width = 180;
ui_pass_preview_scale = 0.18;
ui_pass_row_gap = 8;
ui_pass_nub_height = 96;
ui_pass_nub_y = 8;
ui_pass_closed_x = display_get_gui_width() + ui_pass_margin + ui_pass_margin;
ui_pass_open_x = display_get_gui_width() - ui_pass_expanded_width - ui_pass_nub_width - ui_pass_margin;
ui_pass_x = ui_pass_closed_x;
ui_pass_target_x = ui_pass_closed_x;
ui_pass_height = display_get_gui_height() - (ui_pass_margin * 2);
ui_pass_last_gui_width = -1;

selected_pass_index = 0;

ui_passes = [
	{ name: "Render", mode: 0, surf_name: "render", shader_id: -1 },
	{ name: "Element", mode: 1, surf_name: "surf_element", shader_id: -1 },
	{ name: "Velocity", mode: 2, surf_name: "surf_velocity", shader_id: shdSandSimVelocityDebug },
	{ name: "Valid Pre", mode: 3, surf_name: "surf_valid_pre", shader_id: shdSandSimVelocityDebug },
	{ name: "Valid Post", mode: 4, surf_name: "surf_valid_post", shader_id: shdSandSimVelocityDebug },
	{ name: "Temp", mode: 5, surf_name: "surf_temp", shader_id: -1 }
];

ui_pass_preview_width = 180;
ui_pass_preview_scale = 0.18;