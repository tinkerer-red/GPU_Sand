#pragma shady: skip_compilation

void main() {
	
	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	_elem_static_data = make_empty_static_data();
	_elem_static_data.id = ELEM_ID_DEV;
	_elem_static_data.state_of_matter = int(u_dev_state_of_matter);
	_elem_static_data.movement_class = int(u_dev_movement_class);
	_elem_static_data.feature_flags = int(u_dev_feature_flags);
	_elem_static_data.dynamic_mode = int(u_dev_dynamic_mode);

	_elem_static_data.gravity_force = u_dev_gravity_force;
	_elem_static_data.max_vel_x = u_dev_max_vel_x;
	_elem_static_data.max_vel_y = u_dev_max_vel_y;

	_elem_static_data.can_slip = (u_dev_can_slip > 0.5);
	_elem_static_data.x_slip_search_range = u_dev_x_slip_search_range;
	_elem_static_data.y_slip_search_range = u_dev_y_slip_search_range;

	_elem_static_data.wake_chance = u_dev_wake_chance;
	_elem_static_data.stickiness_chance = u_dev_stickiness_chance;

	_elem_static_data.bounce_chance = u_dev_bounce_chance;
	_elem_static_data.bounce_dampening_multiplier = u_dev_bounce_dampening_multiplier;

	_elem_static_data.airborne_vel_decay_chance = u_dev_airborne_vel_decay_chance;
	_elem_static_data.friction_vel_decay_chance = u_dev_friction_vel_decay_chance;

	_elem_static_data.mass = u_dev_mass;
	_elem_static_data.density = u_dev_density;
	_elem_static_data.immovable = (u_dev_immovable > 0.5);

	_elem_static_data.replace_mode = int(u_dev_replace_mode);
	_elem_static_data.replace_mask = int(u_dev_replace_mask);
	_elem_static_data.replace_count = int(u_dev_replace_count);
	_elem_static_data.replace_id_0 = int(u_dev_replace_id_0);
	_elem_static_data.replace_id_1 = int(u_dev_replace_id_1);
	_elem_static_data.replace_id_2 = int(u_dev_replace_id_2);
	_elem_static_data.replace_id_3 = int(u_dev_replace_id_3);

	_elem_static_data.interaction_group = int(u_dev_interaction_group);
	_elem_static_data.interaction_mask = int(u_dev_interaction_mask);

	_elem_static_data.lifetime_max = u_dev_lifetime_max;
	_elem_static_data.lifetime_decay_chance = u_dev_lifetime_decay_chance;
	_elem_static_data.transition_on_life_end = int(u_dev_transition_on_life_end);

	_elem_static_data.temperature_decay = u_dev_temperature_decay;
	_elem_static_data.temperature_spread_chance = u_dev_temperature_spread_chance;
	_elem_static_data.temperature_min = u_dev_temperature_min;
	_elem_static_data.temperature_max = u_dev_temperature_max;
	_elem_static_data.transition_on_temp_low = int(u_dev_transition_on_temp_low);
	_elem_static_data.transition_on_temp_high = int(u_dev_transition_on_temp_high);
	_elem_static_data.ignition_threshold = u_dev_ignition_threshold;
	_elem_static_data.burn_product = int(u_dev_burn_product);
	_elem_static_data.cooling_product = int(u_dev_cooling_product);

	_elem_static_data.corrosion_resistance = u_dev_corrosion_resistance;
	_elem_static_data.wetness_capacity = u_dev_wetness_capacity;
	_elem_static_data.quench_threshold = u_dev_quench_threshold;
	_elem_static_data.viscosity = u_dev_viscosity;
	_elem_static_data.base_color = u_dev_color;
	#pragma shady: macro_end
	#endregion

}
