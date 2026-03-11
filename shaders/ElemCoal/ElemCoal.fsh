#pragma shady: skip_compilation

void main() {

	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	_elem_static_data = make_empty_static_data();
	_elem_static_data.id = ELEM_ID_COAL;
	_elem_static_data.state_of_matter = MATTER_SOLID;
	_elem_static_data.movement_class = MOVE_CLASS_HEAVY_POWDER;
	_elem_static_data.feature_flags = FEATURE_CAN_IGNITE + FEATURE_USES_TEMPERATURE;
	_elem_static_data.dynamic_mode = DYNAMIC_MODE_TEMPERATURE;
	_elem_static_data.gravity_force = 1.0;
	_elem_static_data.max_vel_x = 1.5;
	_elem_static_data.max_vel_y = 2.5;
	_elem_static_data.can_slip = true;
	_elem_static_data.x_slip_search_range = 2.0;
	_elem_static_data.y_slip_search_range = 2.0;
	_elem_static_data.wake_chance = 0.8;
	_elem_static_data.stickiness_chance = 0.1;
	_elem_static_data.bounce_chance = 0.03;
	_elem_static_data.bounce_dampening_multiplier = 0.15;
	_elem_static_data.airborne_vel_decay_chance = 0.45;
	_elem_static_data.friction_vel_decay_chance = 0.75;
	_elem_static_data.mass = 220.0;
	_elem_static_data.density = 1400.0;
	_elem_static_data.immovable = false;
	_elem_static_data.replace_mode = REPLACE_MODE_LESS_DENSE;
	_elem_static_data.replace_mask = REPLACE_MASK_EMPTY + REPLACE_MASK_GAS + REPLACE_MASK_LIQUID;
	_elem_static_data.replace_count = 0;
	_elem_static_data.replace_id_0 = 0;
	_elem_static_data.replace_id_1 = 0;
	_elem_static_data.replace_id_2 = 0;
	_elem_static_data.replace_id_3 = 0;
	_elem_static_data.interaction_group = INTERACTION_GROUP_ORGANIC;
	_elem_static_data.interaction_mask = 0;
	_elem_static_data.lifetime_max = 0.0;
	_elem_static_data.lifetime_decay_chance = 0.0;
	_elem_static_data.transition_on_life_end = ELEM_ID_COAL;
	_elem_static_data.temperature_decay = 0.01;
	_elem_static_data.temperature_spread_chance = 0.10;
	_elem_static_data.temperature_min = -128.0;
	_elem_static_data.temperature_max = 80.0;
	_elem_static_data.transition_on_temp_low = ELEM_ID_COAL;
	_elem_static_data.transition_on_temp_high = ELEM_ID_EMBER;
	_elem_static_data.ignition_threshold = 110.0;
	_elem_static_data.burn_product = ELEM_ID_EMBER;
	_elem_static_data.cooling_product = ELEM_ID_COAL;
	_elem_static_data.corrosion_resistance = 0.7;
	_elem_static_data.wetness_capacity = 40.0;
	_elem_static_data.quench_threshold = 0.0;
	_elem_static_data.viscosity = 0.1;
	_elem_static_data.base_color = 2236962.0;
	#pragma shady: macro_end
	#endregion

}
