#pragma shady: skip_compilation

void main() {

	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	_elem_static_data = make_empty_static_data();
	_elem_static_data.id = ELEM_ID_ACID;
	_elem_static_data.state_of_matter = MATTER_LIQUID;
	_elem_static_data.movement_class = MOVE_CLASS_LIQUID;
	_elem_static_data.feature_flags = FEATURE_CAN_CORRODE;
	_elem_static_data.dynamic_mode = DYNAMIC_MODE_CORROSION;
	_elem_static_data.gravity_force = 1.0;
	_elem_static_data.max_vel_x = 4.0;
	_elem_static_data.max_vel_y = 5.0;
	_elem_static_data.can_slip = true;
	_elem_static_data.x_slip_search_range = 5.0;
	_elem_static_data.y_slip_search_range = 2.0;
	_elem_static_data.wake_chance = 1.0;
	_elem_static_data.stickiness_chance = 0.0;
	_elem_static_data.bounce_chance = 0.0;
	_elem_static_data.bounce_dampening_multiplier = 0.0;
	_elem_static_data.airborne_vel_decay_chance = 0.20;
	_elem_static_data.friction_vel_decay_chance = 0.06;
	_elem_static_data.mass = 85.0;
	_elem_static_data.density = 1100.0;
	_elem_static_data.immovable = false;
	_elem_static_data.replace_mode = REPLACE_MODE_LESS_DENSE_OR_EQUAL;
	_elem_static_data.replace_mask = REPLACE_MASK_EMPTY + REPLACE_MASK_GAS + REPLACE_MASK_LIQUID;
	_elem_static_data.replace_count = 0;
	_elem_static_data.replace_id_0 = 0;
	_elem_static_data.replace_id_1 = 0;
	_elem_static_data.replace_id_2 = 0;
	_elem_static_data.replace_id_3 = 0;
	_elem_static_data.interaction_group = INTERACTION_GROUP_ACID_LIKE;
	_elem_static_data.interaction_mask = 0;
	_elem_static_data.lifetime_max = 0.0;
	_elem_static_data.lifetime_decay_chance = 0.0;
	_elem_static_data.transition_on_life_end = ELEM_ID_ACID;
	_elem_static_data.temperature_decay = 0.01;
	_elem_static_data.temperature_spread_chance = 0.10;
	_elem_static_data.temperature_min = -128.0;
	_elem_static_data.temperature_max = 127.0;
	_elem_static_data.transition_on_temp_low = ELEM_ID_ACID;
	_elem_static_data.transition_on_temp_high = ELEM_ID_ACID;
	_elem_static_data.ignition_threshold = 0.0;
	_elem_static_data.burn_product = ELEM_ID_EMPTY;
	_elem_static_data.cooling_product = ELEM_ID_ACID;
	_elem_static_data.corrosion_resistance = 0.2;
	_elem_static_data.wetness_capacity = 255.0;
	_elem_static_data.quench_threshold = 0.0;
	_elem_static_data.viscosity = 0.04;
	_elem_static_data.base_color = 6750003.0;
	#pragma shady: macro_end
	#endregion

}
