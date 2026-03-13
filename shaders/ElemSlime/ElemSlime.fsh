#pragma shady: skip_compilation

void main() {

	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	_elem_static_data = make_empty_static_data();
	_elem_static_data.id = ELEM_ID_SLIME;
	_elem_static_data.base_color = 7265111.0;
	_elem_static_data.state_of_matter = MATTER_LIQUID;
	_elem_static_data.flow_mode = FLOW_MODE_GOO;
	_elem_static_data.vertical_drive = 1.0;
	_elem_static_data.max_speed = 3.0;
	_elem_static_data.lateral_spread = 2.0;
	_elem_static_data.momentum_retention = 0.79;
	_elem_static_data.support_resistance = 0.35;
	_elem_static_data.clump_factor = 0.85;
	_elem_static_data.surface_response = 0.35;
	_elem_static_data.density = 1050.0;
	_elem_static_data.immovable = false;
	_elem_static_data.replace_mask = REPLACE_MASK_EMPTY + REPLACE_MASK_GAS + REPLACE_MASK_LIQUID;
	_elem_static_data.temp_contribute = true;
	_elem_static_data.temp_locked = false;
	_elem_static_data.temp_transfer_rate = 0.05;
	_elem_static_data.temp_idle_value = 0.0;
	_elem_static_data.temp_on_low = ELEM_ID_SLIME;
	_elem_static_data.temp_on_high = ELEM_ID_SLIME;
	_elem_static_data.moisture_contribute = true;
	_elem_static_data.moisture_locked = false;
	_elem_static_data.moisture_transfer_rate = 0.40;
	_elem_static_data.moisture_idle_value = 80.0;
	_elem_static_data.moisture_on_low = ELEM_ID_SLIME;
	_elem_static_data.moisture_on_high = ELEM_ID_SLIME;
	_elem_static_data.corrosion_contribute = false;
	_elem_static_data.corrosion_locked = true;
	_elem_static_data.corrosion_transfer_rate = 0.0;
	_elem_static_data.corrosion_idle_value = 0.0;
	_elem_static_data.corrosion_on_low = ELEM_ID_SLIME;
	_elem_static_data.corrosion_on_high = ELEM_ID_SLIME;
	_elem_static_data.magic_contribute = false;
	_elem_static_data.magic_locked = true;
	_elem_static_data.magic_transfer_rate = 0.0;
	_elem_static_data.magic_idle_value = 0.0;
	_elem_static_data.magic_on_low = ELEM_ID_SLIME;
	_elem_static_data.magic_on_high = ELEM_ID_SLIME;
	#pragma shady: macro_end
	#endregion

}
