event_user(15);

window_set_size(1700, 1000);
window_center();

simulation = new CanvasSandShader();

gmui_init();

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
	replace_id_3: 0.0,
	color: make_color_rgb(255, 64, 255),
};

paint_radius = 8;

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
	{ name: "Dev", color: make_color_rgb(255, 64, 255), element_id: 2 },
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