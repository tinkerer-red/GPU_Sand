#pragma shady: skip_compilation

void main() {

	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	_elem_static_data = make_empty_static_data();
	_elem_static_data.id = ELEM_ID_OBSIDIAN;
	_elem_static_data.base_color = 2955576.0;
	_elem_static_data.state_of_matter = MATTER_SOLID;
	_elem_static_data.flow_mode = FLOW_MODE_STATIC;
	_elem_static_data.vertical_drive = 0.0;
	_elem_static_data.max_speed = 0.0;
	_elem_static_data.lateral_spread = 0.0;
	_elem_static_data.momentum_retention = 1.0;
	_elem_static_data.support_resistance = 1.0;
	_elem_static_data.clump_factor = 1.0;
	_elem_static_data.surface_response = 0.0;
	_elem_static_data.density = 2800.0;
	_elem_static_data.immovable = true;
	_elem_static_data.replace_mask = REPLACE_MASK_EMPTY;
	_elem_static_data.temp_contribute = true;
	_elem_static_data.temp_locked = false;
	_elem_static_data.temp_transfer_rate = 0.05;
	_elem_static_data.temp_idle_value = 0.0;
	_elem_static_data.temp_on_low = ELEM_ID_OBSIDIAN;
	_elem_static_data.temp_on_high = ELEM_ID_LAVA;
	_elem_static_data.moisture_contribute = false;
	_elem_static_data.moisture_locked = true;
	_elem_static_data.moisture_transfer_rate = 0.0;
	_elem_static_data.moisture_idle_value = 0.0;
	_elem_static_data.moisture_on_low = ELEM_ID_OBSIDIAN;
	_elem_static_data.moisture_on_high = ELEM_ID_OBSIDIAN;
	_elem_static_data.corrosion_contribute = false;
	_elem_static_data.corrosion_locked = true;
	_elem_static_data.corrosion_transfer_rate = 0.0;
	_elem_static_data.corrosion_idle_value = 0.0;
	_elem_static_data.corrosion_on_low = ELEM_ID_OBSIDIAN;
	_elem_static_data.corrosion_on_high = ELEM_ID_OBSIDIAN;
	_elem_static_data.magic_contribute = false;
	_elem_static_data.magic_locked = true;
	_elem_static_data.magic_transfer_rate = 0.0;
	_elem_static_data.magic_idle_value = 0.0;
	_elem_static_data.magic_on_low = ELEM_ID_OBSIDIAN;
	_elem_static_data.magic_on_high = ELEM_ID_OBSIDIAN;
	#pragma shady: macro_end
	#endregion

}
