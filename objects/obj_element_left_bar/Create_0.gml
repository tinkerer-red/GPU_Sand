owner = noone;

panel_title = "Elements";

panel_wants_open = false;

panel_margin = 8;
panel_nub_width = 28;
panel_expanded_width = 220;
panel_header_height = 28;
panel_height = 260;

panel_closed_x = -(panel_expanded_width - panel_nub_width);
panel_open_x = panel_margin;

panel_x = panel_closed_x;
panel_target_x = panel_closed_x;

panel_width = panel_expanded_width;
panel_target_width = panel_expanded_width;

panel_anim_lerp = 0.18;
panel_anim_epsilon = 0.25;

nub_height = 96;
nub_y = 8;

element_button_width = panel_expanded_width - 24;
element_swatch_size = 12;

selected_element_index = 0;
selected_element_id = 1;
selected_element_name = "Sand";

elements = [
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

if (instance_exists(owner)) {
	if (variable_instance_exists(owner, "selected_element_index")) {
		selected_element_index = owner.selected_element_index;
	}
	if (variable_instance_exists(owner, "selected_element_id")) {
		selected_element_id = owner.selected_element_id;
	}
	if (variable_instance_exists(owner, "selected_element_name")) {
		selected_element_name = owner.selected_element_name;
	}
}

gmui_init();