event_user(15);

window_set_size(1700, 1000);
window_center();

simulation = new CanvasSandShader();

gmui_init();

dev_settings = {
	color: make_color_rgb(255, 64, 255),
	state_of_matter: StateOfMatter.SOLID,
	movement_class: MovementClass.POWDER,
	feature_flags: 0,
	gravity_force: 1.0,
	max_vel_x: 2.0,
	max_vel_y: 2.0,
	can_slip: true,
	x_slip_search_range: 1.0,
	y_slip_search_range: 1.0,
	wake_chance: 1.0,
	stickiness_chance: 0.0,
	bounce_chance: 0.1,
	bounce_dampening_multiplier: 0.4,
	airborne_vel_decay_chance: 0.35,
	friction_vel_decay_chance: 0.65,
	mass: 150.0,
	density: 150.0,
	immovable: false,
	replace_mode: ReplaceMode.LESS_DENSE_OR_EQUAL,
	replace_mask: ReplaceMask.EMPTY | ReplaceMask.LIQUID | ReplaceMask.GAS,
	interaction_group: InteractionGroup.MINERAL,
	interaction_mask: 0,
	viscosity: 0.0,
	temp_contribute: true,
	temp_locked: false,
	temp_transfer_rate: 0.25,
	temp_idle_value: 0.0,
	temp_on_low: ElementId.DEV,
	temp_on_high: ElementId.DEV,
	moisture_contribute: false,
	moisture_locked: true,
	moisture_transfer_rate: 0.0,
	moisture_idle_value: 0.0,
	moisture_on_low: ElementId.DEV,
	moisture_on_high: ElementId.DEV,
	corrosion_contribute: false,
	corrosion_locked: true,
	corrosion_transfer_rate: 0.0,
	corrosion_idle_value: 0.0,
	corrosion_on_low: ElementId.DEV,
	corrosion_on_high: ElementId.DEV,
	magic_contribute: false,
	magic_locked: true,
	magic_transfer_rate: 0.0,
	magic_idle_value: 0.0,
	magic_on_low: ElementId.DEV,
	magic_on_high: ElementId.DEV
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
selected_element_id = ElementId.SAND;
selected_element_name = "Sand";

ui_panel_anim_lerp = 0.18;
ui_panel_anim_epsilon = 0.25;

ui_elements = [
	{ name: "Sand", color: make_color_rgb(194, 178, 128), element_id: ElementId.SAND },
	{ name: "Water", color: make_color_rgb(64, 128, 255), element_id: ElementId.WATER },
	{ name: "Stone", color: make_color_rgb(120, 120, 120), element_id: ElementId.STONE },
	{ name: "Wall", color: make_color_rgb(96, 96, 104), element_id: ElementId.WALL },
	{ name: "Wood", color: make_color_rgb(139, 94, 60), element_id: ElementId.WOOD },
	{ name: "Fire", color: make_color_rgb(255, 120, 32), element_id: ElementId.FIRE },
	{ name: "Smoke", color: make_color_rgb(96, 96, 96), element_id: ElementId.SMOKE },
	{ name: "Steam", color: make_color_rgb(210, 210, 210), element_id: ElementId.STEAM },
	{ name: "Ice", color: make_color_rgb(196, 232, 255), element_id: ElementId.ICE },
	{ name: "Snow", color: make_color_rgb(245, 245, 255), element_id: ElementId.SNOW },
	{ name: "Mud", color: make_color_rgb(101, 72, 50), element_id: ElementId.MUD },
	{ name: "Dirt", color: make_color_rgb(120, 84, 56), element_id: ElementId.DIRT },
	{ name: "Wet Sand", color: make_color_rgb(164, 150, 110), element_id: ElementId.WET_SAND },
	{ name: "Oil", color: make_color_rgb(48, 48, 20), element_id: ElementId.OIL },
	{ name: "Lava", color: make_color_rgb(255, 80, 0), element_id: ElementId.LAVA },
	{ name: "Ash", color: make_color_rgb(126, 126, 126), element_id: ElementId.ASH },
	{ name: "Ember", color: make_color_rgb(255, 160, 72), element_id: ElementId.EMBER },
	{ name: "Acid", color: make_color_rgb(120, 255, 64), element_id: ElementId.ACID },
	{ name: "Metal", color: make_color_rgb(160, 168, 176), element_id: ElementId.METAL },
	{ name: "Rust", color: make_color_rgb(164, 88, 44), element_id: ElementId.RUST },
	{ name: "Glass", color: make_color_rgb(180, 220, 220), element_id: ElementId.GLASS },
	{ name: "Salt", color: make_color_rgb(236, 236, 236), element_id: ElementId.SALT },
	{ name: "Salt Water", color: make_color_rgb(88, 148, 255), element_id: ElementId.SALT_WATER },
	{ name: "Plant", color: make_color_rgb(64, 160, 72), element_id: ElementId.PLANT },
	{ name: "Seed", color: make_color_rgb(170, 130, 70), element_id: ElementId.SEED },
	{ name: "Coal", color: make_color_rgb(36, 36, 36), element_id: ElementId.COAL },
	{ name: "Gas Fuel", color: make_color_rgb(180, 140, 64), element_id: ElementId.GAS_FUEL },
	{ name: "Slime", color: make_color_rgb(84, 200, 104), element_id: ElementId.SLIME },
	{ name: "Obsidian", color: make_color_rgb(34, 22, 48), element_id: ElementId.OBSIDIAN },
	{ name: "Gravel", color: make_color_rgb(132, 132, 132), element_id: ElementId.GRAVEL },
	{ name: "Clay", color: make_color_rgb(168, 110, 86), element_id: ElementId.CLAY },
	{ name: "Dev", color: undefined, element_id: ElementId.DEV }
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
ui_dev_section_interaction_open = false;
ui_dev_section_temperature_open = false;
ui_dev_section_moisture_open = false;
ui_dev_section_corrosion_open = false;
ui_dev_section_magic_open = false;

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
	{
		name: "Render",
		view_type: "display_mode",
		display_mode: DisplayMode.RENDER,
		surface_name: "",
		shader_id: -1,
		use_simulation_draw: true
	},
	{
		name: "Element",
		view_type: "display_mode",
		display_mode: DisplayMode.ELEMENT,
		surface_name: "surf_element",
		shader_id: -1,
		use_simulation_draw: false
	},
	{
		name: "Velocity",
		view_type: "display_mode",
		display_mode: DisplayMode.VELOCITY,
		surface_name: "surf_velocity",
		shader_id: shdSandSimDebugVelocity,
		use_simulation_draw: false
	},
	{
		name: "Valid Pre",
		view_type: "display_mode",
		display_mode: DisplayMode.ACCEPT,
		surface_name: "surf_valid_pre",
		shader_id: shdSandSimDebugVelocity,
		use_simulation_draw: false
	},
	{
		name: "Valid Post",
		view_type: "display_mode",
		display_mode: DisplayMode.CONFIRM,
		surface_name: "surf_valid_post",
		shader_id: shdSandSimDebugVelocity,
		use_simulation_draw: false
	},
	{
		name: "Resolve",
		view_type: "display_mode",
		display_mode: DisplayMode.RESOLVE,
		surface_name: "surf_element",
		shader_id: -1,
		use_simulation_draw: false
	},
	{
		name: "Temperature",
		view_type: "display_mode",
		display_mode: DisplayMode.ELEMENT,
		surface_name: "surf_element",
		shader_id: shdSandSimDebugTemperature,
		use_simulation_draw: false
	},
	{
		name: "Moisture",
		view_type: "display_mode",
		display_mode: DisplayMode.ELEMENT,
		surface_name: "surf_element",
		shader_id: shdSandSimDebugMoisture,
		use_simulation_draw: false
	},
	{
		name: "Corrosion",
		view_type: "display_mode",
		display_mode: DisplayMode.ELEMENT,
		surface_name: "surf_element",
		shader_id: shdSandSimDebugCorrosion,
		use_simulation_draw: false
	},
	{
		name: "Magic",
		view_type: "display_mode",
		display_mode: DisplayMode.ELEMENT,
		surface_name: "surf_element",
		shader_id: shdSandSimDebugMagic,
		use_simulation_draw: false
	}
];

ui_pass_preview_width = 180;
ui_pass_preview_scale = 0.18;
