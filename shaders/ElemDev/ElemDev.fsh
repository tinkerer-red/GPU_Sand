#pragma shady: skip_compilation

void main() {
	
	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	_elem_static_data = make_empty_static_data();
	_elem_static_data.id = ELEM_ID_DEV;
	_elem_static_data.base_color = u_dev_color;
	_elem_static_data.state_of_matter = int(u_dev_state_of_matter);
	_elem_static_data.flow_mode = int(u_dev_flow_mode);
	_elem_static_data.vertical_drive = u_dev_vertical_drive;
	_elem_static_data.max_speed = u_dev_max_speed;
	_elem_static_data.lateral_spread = u_dev_lateral_spread;
	_elem_static_data.momentum_retention = u_dev_momentum_retention;
	_elem_static_data.support_resistance = u_dev_support_resistance;
	_elem_static_data.clump_factor = u_dev_clump_factor;
	_elem_static_data.surface_response = u_dev_surface_response;
	_elem_static_data.density = u_dev_density;
	_elem_static_data.immovable = (u_dev_immovable > 0.5);
	_elem_static_data.replace_mask = int(u_dev_replace_mask);
	_elem_static_data.temp_contribute = (u_dev_temp_contribute > 0.5);
	_elem_static_data.temp_locked = (u_dev_temp_locked > 0.5);
	_elem_static_data.temp_transfer_rate = u_dev_temp_transfer_rate;
	_elem_static_data.temp_idle_value = u_dev_temp_idle_value;
	_elem_static_data.temp_on_low = int(u_dev_temp_on_low);
	_elem_static_data.temp_on_high = int(u_dev_temp_on_high);
	_elem_static_data.moisture_contribute = (u_dev_moisture_contribute > 0.5);
	_elem_static_data.moisture_locked = (u_dev_moisture_locked > 0.5);
	_elem_static_data.moisture_transfer_rate = u_dev_moisture_transfer_rate;
	_elem_static_data.moisture_idle_value = u_dev_moisture_idle_value;
	_elem_static_data.moisture_on_low = int(u_dev_moisture_on_low);
	_elem_static_data.moisture_on_high = int(u_dev_moisture_on_high);
	_elem_static_data.corrosion_contribute = (u_dev_corrosion_contribute > 0.5);
	_elem_static_data.corrosion_locked = (u_dev_corrosion_locked > 0.5);
	_elem_static_data.corrosion_transfer_rate = u_dev_corrosion_transfer_rate;
	_elem_static_data.corrosion_idle_value = u_dev_corrosion_idle_value;
	_elem_static_data.corrosion_on_low = int(u_dev_corrosion_on_low);
	_elem_static_data.corrosion_on_high = int(u_dev_corrosion_on_high);
	_elem_static_data.magic_contribute = (u_dev_magic_contribute > 0.5);
	_elem_static_data.magic_locked = (u_dev_magic_locked > 0.5);
	_elem_static_data.magic_transfer_rate = u_dev_magic_transfer_rate;
	_elem_static_data.magic_idle_value = u_dev_magic_idle_value;
	_elem_static_data.magic_on_low = int(u_dev_magic_on_low);
	_elem_static_data.magic_on_high = int(u_dev_magic_on_high);
	#pragma shady: macro_end
	#endregion

}
