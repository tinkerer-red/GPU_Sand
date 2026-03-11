#pragma shady: skip_compilation

void main() {

	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	_elem_static_data = make_empty_static_data();
	_elem_static_data.id = ELEM_ID_WOOD;
	_elem_static_data.state_of_matter = MATTER_SOLID;
	_elem_static_data.movement_class = MOVE_CLASS_NONE_STATIC;
	_elem_static_data.feature_flags = FEATURE_CAN_IGNITE + FEATURE_USES_TEMPERATURE;
	_elem_static_data.dynamic_mode = DYNAMIC_MODE_TEMPERATURE;
	_elem_static_data.gravity_force = 0.0;
	_elem_static_data.max_vel_x = 0.0;
	_elem_static_data.max_vel_y = 0.0;
	_elem_static_data.can_slip = false;
	_elem_static_data.x_slip_search_range = 0.0;
	_elem_static_data.y_slip_search_range = 0.0;
	_elem_static_data.wake_chance = 0.0;
	_elem_static_data.stickiness_chance = 0.0;
	_elem_static_data.bounce_chance = 0.0;
	_elem_static_data.bounce_dampening_multiplier = 0.0;
	_elem_static_data.airborne_vel_decay_chance = 0.0;
	_elem_static_data.friction_vel_decay_chance = 0.0;
	_elem_static_data.mass = 500.0;
	_elem_static_data.density = 700.0;
	_elem_static_data.immovable = true;
	_elem_static_data.replace_mode = REPLACE_MODE_EMPTY_ONLY;
	_elem_static_data.replace_mask = REPLACE_MASK_EMPTY;
	_elem_static_data.replace_count = 0;
	_elem_static_data.replace_id_0 = 0;
	_elem_static_data.replace_id_1 = 0;
	_elem_static_data.replace_id_2 = 0;
	_elem_static_data.replace_id_3 = 0;
	_elem_static_data.interaction_group = INTERACTION_GROUP_ORGANIC;
	_elem_static_data.interaction_mask = 0;
	_elem_static_data.lifetime_max = 0.0;
	_elem_static_data.lifetime_decay_chance = 0.0;
	_elem_static_data.transition_on_life_end = ELEM_ID_WOOD;
	_elem_static_data.temperature_decay = 0.02;
	_elem_static_data.temperature_spread_chance = 0.25;
	_elem_static_data.temperature_min = -128.0;
	_elem_static_data.temperature_max = 48.0;
	_elem_static_data.transition_on_temp_low = ELEM_ID_WOOD;
	_elem_static_data.transition_on_temp_high = ELEM_ID_EMBER;
	_elem_static_data.ignition_threshold = 96.0;
	_elem_static_data.burn_product = ELEM_ID_EMBER;
	_elem_static_data.cooling_product = ELEM_ID_WOOD;
	_elem_static_data.corrosion_resistance = 0.25;
	_elem_static_data.wetness_capacity = 120.0;
	_elem_static_data.quench_threshold = 0.0;
	_elem_static_data.viscosity = 1.0;
	_elem_static_data.base_color = 9132587.0;
	#pragma shady: macro_end
	#endregion

}
