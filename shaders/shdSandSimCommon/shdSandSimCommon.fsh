#pragma shady: skip_compilation
#pragma shady: import(shdMaths)
#pragma shady: import(ElemDev)
#pragma shady: import(ElemSand)
#pragma shady: import(ElemWater)
#pragma shady: import(ElemStone)
#pragma shady: import(ElemWall)
#pragma shady: import(ElemWood)
#pragma shady: import(ElemFire)
#pragma shady: import(ElemSmoke)
#pragma shady: import(ElemSteam)
#pragma shady: import(ElemIce)
#pragma shady: import(ElemSnow)
#pragma shady: import(ElemMud)
#pragma shady: import(ElemDirt)
#pragma shady: import(ElemWetSand)
#pragma shady: import(ElemOil)
#pragma shady: import(ElemLava)
#pragma shady: import(ElemAsh)
#pragma shady: import(ElemEmber)
#pragma shady: import(ElemAcid)
#pragma shady: import(ElemMetal)
#pragma shady: import(ElemRust)
#pragma shady: import(ElemGlass)
#pragma shady: import(ElemSalt)
#pragma shady: import(ElemSaltWater)
#pragma shady: import(ElemPlant)
#pragma shady: import(ElemSeed)
#pragma shady: import(ElemCoal)
#pragma shady: import(ElemGasFuel)
#pragma shady: import(ElemSlime)
#pragma shady: import(ElemObsidian)
#pragma shady: import(ElemGravel)
#pragma shady: import(ElemClay)

#region Uniforms
#pragma shady: macro_begin Uniforms
uniform float u_dev_state_of_matter;
uniform float u_dev_movement_class;
uniform float u_dev_feature_flags;
uniform float u_dev_dynamic_mode;

uniform float u_dev_gravity_force;
uniform float u_dev_max_vel_x;
uniform float u_dev_max_vel_y;

uniform float u_dev_can_slip;
uniform float u_dev_x_slip_search_range;
uniform float u_dev_y_slip_search_range;

uniform float u_dev_wake_chance;
uniform float u_dev_stickiness_chance;

uniform float u_dev_bounce_chance;
uniform float u_dev_bounce_dampening_multiplier;

uniform float u_dev_airborne_vel_decay_chance;
uniform float u_dev_friction_vel_decay_chance;

uniform float u_dev_mass;
uniform float u_dev_density;
uniform float u_dev_immovable;

uniform float u_dev_replace_mode;
uniform float u_dev_replace_mask;
uniform float u_dev_replace_count;
uniform float u_dev_replace_id_0;
uniform float u_dev_replace_id_1;
uniform float u_dev_replace_id_2;
uniform float u_dev_replace_id_3;

uniform float u_dev_interaction_group;
uniform float u_dev_interaction_mask;

uniform float u_dev_lifetime_max;
uniform float u_dev_lifetime_decay_chance;
uniform float u_dev_transition_on_life_end;

uniform float u_dev_temperature_decay;
uniform float u_dev_temperature_spread_chance;
uniform float u_dev_temperature_min;
uniform float u_dev_temperature_max;
uniform float u_dev_transition_on_temp_low;
uniform float u_dev_transition_on_temp_high;
uniform float u_dev_ignition_threshold;
uniform float u_dev_burn_product;
uniform float u_dev_cooling_product;

uniform float u_dev_corrosion_resistance;
uniform float u_dev_wetness_capacity;
uniform float u_dev_quench_threshold;
uniform float u_dev_viscosity;

uniform float u_dev_color;
#pragma shady: macro_end
#endregion

#region Constants
#define SIM_MAX_MOVE_RADIUS 4
#define SIM_BOUNCE_SAMPLE_RADIUS 3

#define ELEM_ID_EMPTY 0
#define ELEM_ID_DEV 1
#define ELEM_ID_SAND 2
#define ELEM_ID_WATER 3
#define ELEM_ID_STONE 4
#define ELEM_ID_WALL 5
#define ELEM_ID_WOOD 6
#define ELEM_ID_FIRE 7
#define ELEM_ID_SMOKE 8
#define ELEM_ID_STEAM 9
#define ELEM_ID_ICE 10
#define ELEM_ID_SNOW 11
#define ELEM_ID_MUD 12
#define ELEM_ID_DIRT 13
#define ELEM_ID_WET_SAND 14
#define ELEM_ID_OIL 15
#define ELEM_ID_LAVA 16
#define ELEM_ID_ASH 17
#define ELEM_ID_EMBER 18
#define ELEM_ID_ACID 19
#define ELEM_ID_METAL 20
#define ELEM_ID_RUST 21
#define ELEM_ID_GLASS 22
#define ELEM_ID_SALT 23
#define ELEM_ID_SALT_WATER 24
#define ELEM_ID_PLANT 25
#define ELEM_ID_SEED 26
#define ELEM_ID_COAL 27
#define ELEM_ID_GAS_FUEL 28
#define ELEM_ID_SLIME 29
#define ELEM_ID_OBSIDIAN 30
#define ELEM_ID_GRAVEL 31
#define ELEM_ID_CLAY 32

#define MATTER_EMPTY 0
#define MATTER_GAS 1
#define MATTER_LIQUID 2
#define MATTER_SOLID 3

#define MOVE_CLASS_NONE_STATIC 0
#define MOVE_CLASS_POWDER 1
#define MOVE_CLASS_LIQUID 2
#define MOVE_CLASS_GAS 3
#define MOVE_CLASS_VISCOUS_LIQUID 4
#define MOVE_CLASS_DRIFTING_SOLID 5
#define MOVE_CLASS_HEAVY_POWDER 6
#define MOVE_CLASS_STICKY_POWDER 7

#define FEATURE_USES_LIFETIME 1
#define FEATURE_USES_TEMPERATURE 2
#define FEATURE_CAN_IGNITE 4
#define FEATURE_PHASE_CHANGES 8
#define FEATURE_CAN_WET 16
#define FEATURE_CAN_CORRODE 32
#define FEATURE_EMITS_HEAT 64
#define FEATURE_REACTS_AS_COOLANT 128

#define DYNAMIC_MODE_NONE 0
#define DYNAMIC_MODE_LIFETIME 1
#define DYNAMIC_MODE_TEMPERATURE 2
#define DYNAMIC_MODE_MOISTURE 3
#define DYNAMIC_MODE_CORROSION 4
#define DYNAMIC_MODE_CHARGE_RESERVED 5

#define REPLACE_MODE_EMPTY_ONLY 0
#define REPLACE_MODE_LESS_DENSE 1
#define REPLACE_MODE_LESS_DENSE_OR_EQUAL 2
#define REPLACE_MODE_CLASS_MASK 3
#define REPLACE_MODE_EXPLICIT_IDS_FALLBACK 4

#define REPLACE_MASK_EMPTY 1
#define REPLACE_MASK_GAS 2
#define REPLACE_MASK_LIQUID 4
#define REPLACE_MASK_SOLID_MOVABLE 8
#define REPLACE_MASK_SAME_ELEMENT 16
#define REPLACE_MASK_SAME_GROUP 32

#define INTERACTION_GROUP_INERT 0
#define INTERACTION_GROUP_WATER_LIKE 1
#define INTERACTION_GROUP_OIL_LIKE 2
#define INTERACTION_GROUP_MOLTEN 3
#define INTERACTION_GROUP_ACID_LIKE 4
#define INTERACTION_GROUP_COMBUSTIBLE_GAS 5
#define INTERACTION_GROUP_SMOKE_LIKE 6
#define INTERACTION_GROUP_CRYOGENIC 7
#define INTERACTION_GROUP_ORGANIC 8
#define INTERACTION_GROUP_MINERAL 9
#define INTERACTION_GROUP_METAL 10
#endregion

#region Data Structures
struct ElementStaticData {
	int id;
	int state_of_matter;
	int movement_class;
	int feature_flags;
	int dynamic_mode;
	float gravity_force;
	float max_vel_x;
	float max_vel_y;
	bool can_slip;
	float x_slip_search_range;
	float y_slip_search_range;
	float wake_chance;
	float stickiness_chance;
	float bounce_chance;
	float bounce_dampening_multiplier;
	float airborne_vel_decay_chance;
	float friction_vel_decay_chance;
	float mass;
	float density;
	bool immovable;
	int replace_mode;
	int replace_mask;
	int replace_count;
	int replace_id_0;
	int replace_id_1;
	int replace_id_2;
	int replace_id_3;
	int interaction_group;
	int interaction_mask;
	float lifetime_max;
	float lifetime_decay_chance;
	int transition_on_life_end;
	float temperature_decay;
	float temperature_spread_chance;
	float temperature_min;
	float temperature_max;
	int transition_on_temp_low;
	int transition_on_temp_high;
	float ignition_threshold;
	int burn_product;
	int cooling_product;
	float corrosion_resistance;
	float wetness_capacity;
	float quench_threshold;
	float viscosity;
	float base_color;
};

struct ElementDynamicData {
	int id;
	vec2 vel;
	int x_dir;
	int y_dir;
	int x_speed;
	int y_speed;
	int dynamic_byte;
};
#endregion

#region General Helpers
bool flag_enabled(int _mask_value, int _flag_value) {
	if (_flag_value <= 0) {
		return false;
	}
	return imod(int(floor(float(_mask_value) / float(_flag_value))), 2) == 1;
}

bool feature_enabled(int _feature_flags, int _flag_value) {
	return flag_enabled(_feature_flags, _flag_value);
}

int element_id_from_pixel(vec4 _pixel) {
	return int(floor(_pixel.r * 255.0 + 0.5));
}

int dynamic_byte_from_pixel(vec4 _pixel) {
	return float_to_byte(_pixel.b);
}

bool uv_in_bounds(vec2 _texcoord) {
	return _texcoord.x >= 0.0 && _texcoord.y >= 0.0 && _texcoord.x <= 1.0 && _texcoord.y <= 1.0;
}

float color_channel_r(float _color_value) {
	return mod(floor(_color_value / 65536.0), 256.0) / 255.0;
}

float color_channel_g(float _color_value) {
	return mod(floor(_color_value / 256.0), 256.0) / 255.0;
}

float color_channel_b(float _color_value) {
	return mod(_color_value, 256.0) / 255.0;
}

vec3 color_to_vec3(float _color_value) {
	return vec3(
		color_channel_r(_color_value),
		color_channel_g(_color_value),
		color_channel_b(_color_value)
	);
}

int signed_byte_to_int(int _byte_value) {
	return _byte_value - 128;
}

int int_to_signed_byte(float _signed_value) {
	return clamp(int(floor(_signed_value + 128.5)), 0, 255);
}
#endregion

#region Static Data Constructors
ElementStaticData make_empty_static_data() {
	ElementStaticData _elem_static_data;
	_elem_static_data.id = ELEM_ID_EMPTY;
	_elem_static_data.state_of_matter = MATTER_EMPTY;
	_elem_static_data.movement_class = MOVE_CLASS_NONE_STATIC;
	_elem_static_data.feature_flags = 0;
	_elem_static_data.dynamic_mode = DYNAMIC_MODE_NONE;
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
	_elem_static_data.mass = 0.0;
	_elem_static_data.density = 0.0;
	_elem_static_data.immovable = false;
	_elem_static_data.replace_mode = REPLACE_MODE_EMPTY_ONLY;
	_elem_static_data.replace_mask = REPLACE_MASK_EMPTY;
	_elem_static_data.replace_count = 0;
	_elem_static_data.replace_id_0 = 0;
	_elem_static_data.replace_id_1 = 0;
	_elem_static_data.replace_id_2 = 0;
	_elem_static_data.replace_id_3 = 0;
	_elem_static_data.interaction_group = INTERACTION_GROUP_INERT;
	_elem_static_data.interaction_mask = 0;
	_elem_static_data.lifetime_max = 0.0;
	_elem_static_data.lifetime_decay_chance = 0.0;
	_elem_static_data.transition_on_life_end = ELEM_ID_EMPTY;
	_elem_static_data.temperature_decay = 0.0;
	_elem_static_data.temperature_spread_chance = 0.0;
	_elem_static_data.temperature_min = -128.0;
	_elem_static_data.temperature_max = 127.0;
	_elem_static_data.transition_on_temp_low = ELEM_ID_EMPTY;
	_elem_static_data.transition_on_temp_high = ELEM_ID_EMPTY;
	_elem_static_data.ignition_threshold = 0.0;
	_elem_static_data.burn_product = ELEM_ID_EMPTY;
	_elem_static_data.cooling_product = ELEM_ID_EMPTY;
	_elem_static_data.corrosion_resistance = 1.0;
	_elem_static_data.wetness_capacity = 0.0;
	_elem_static_data.quench_threshold = 0.0;
	_elem_static_data.viscosity = 0.0;
	_elem_static_data.base_color = 0.0;
	return _elem_static_data;
}

#endregion

#region Element Static Data
ElementStaticData get_element_static_data(int _element_id) {
	ElementStaticData _elem_static_data = make_empty_static_data();

	if (_element_id == ELEM_ID_DEV) {
		#pragma shady: inline(ElemDev.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_SAND) {
		#pragma shady: inline(ElemSand.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_WATER) {
		#pragma shady: inline(ElemWater.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_STONE) {
		#pragma shady: inline(ElemStone.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_WALL) {
		#pragma shady: inline(ElemWall.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_WOOD) {
		#pragma shady: inline(ElemWood.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_FIRE) {
		#pragma shady: inline(ElemFire.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_SMOKE) {
		#pragma shady: inline(ElemSmoke.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_STEAM) {
		#pragma shady: inline(ElemSteam.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_ICE) {
		#pragma shady: inline(ElemIce.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_SNOW) {
		#pragma shady: inline(ElemSnow.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_MUD) {
		#pragma shady: inline(ElemMud.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_DIRT) {
		#pragma shady: inline(ElemDirt.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_WET_SAND) {
		#pragma shady: inline(ElemWetSand.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_OIL) {
		#pragma shady: inline(ElemOil.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_LAVA) {
		#pragma shady: inline(ElemLava.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_ASH) {
		#pragma shady: inline(ElemAsh.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_EMBER) {
		#pragma shady: inline(ElemEmber.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_ACID) {
		#pragma shady: inline(ElemAcid.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_METAL) {
		#pragma shady: inline(ElemMetal.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_RUST) {
		#pragma shady: inline(ElemRust.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_GLASS) {
		#pragma shady: inline(ElemGlass.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_SALT) {
		#pragma shady: inline(ElemSalt.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_SALT_WATER) {
		#pragma shady: inline(ElemSaltWater.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_PLANT) {
		#pragma shady: inline(ElemPlant.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_SEED) {
		#pragma shady: inline(ElemSeed.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_COAL) {
		#pragma shady: inline(ElemCoal.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_GAS_FUEL) {
		#pragma shady: inline(ElemGasFuel.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_SLIME) {
		#pragma shady: inline(ElemSlime.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_OBSIDIAN) {
		#pragma shady: inline(ElemObsidian.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_GRAVEL) {
		#pragma shady: inline(ElemGravel.DefineElementStaticData)
		return _elem_static_data;
	}
	if (_element_id == ELEM_ID_CLAY) {
		#pragma shady: inline(ElemClay.DefineElementStaticData)
		return _elem_static_data;
	}

	return _elem_static_data;
}
#endregion

#region Dynamic Data
bool dynamic_has_motion(ElementDynamicData _elem_dynamic_data) {
	return _elem_dynamic_data.x_speed != 0 || _elem_dynamic_data.y_speed != 0;
}

ElementDynamicData unpack_elem_dynamic_data(vec4 _pixel) {
	ElementDynamicData _elem_dynamic_data;
	ElementStaticData _elem_static_data = get_element_static_data(element_id_from_pixel(_pixel));
	int _green_byte = float_to_byte(_pixel.g);

	_elem_dynamic_data.id = element_id_from_pixel(_pixel);
	_elem_dynamic_data.dynamic_byte = dynamic_byte_from_pixel(_pixel);

	_elem_dynamic_data.y_dir = bitwise_and(bit_shift_right(_green_byte, 7), 1);
	_elem_dynamic_data.y_speed = bitwise_and(bit_shift_right(_green_byte, 4), 7);
	_elem_dynamic_data.x_dir = bitwise_and(bit_shift_right(_green_byte, 3), 1);
	_elem_dynamic_data.x_speed = bitwise_and(_green_byte, 7);

	_elem_dynamic_data.vel = vec2(0.0);
	if (_elem_static_data.max_vel_x > 0.0) {
		_elem_dynamic_data.vel.x = (float(_elem_dynamic_data.x_speed) / 7.0) * _elem_static_data.max_vel_x;
		if (_elem_dynamic_data.x_dir == 1) {
			_elem_dynamic_data.vel.x = -_elem_dynamic_data.vel.x;
		}
	}
	if (_elem_static_data.max_vel_y > 0.0) {
		_elem_dynamic_data.vel.y = (float(_elem_dynamic_data.y_speed) / 7.0) * _elem_static_data.max_vel_y;
		if (_elem_dynamic_data.y_dir == 1) {
			_elem_dynamic_data.vel.y = -_elem_dynamic_data.vel.y;
		}
	}

	return _elem_dynamic_data;
}

vec4 pack_elem_dynamic_data(ElementDynamicData _elem_dynamic_data, ElementStaticData _elem_static_data) {
	int _green_byte = 0;
	int _x_speed = 0;
	int _y_speed = 0;
	int _x_dir = 0;
	int _y_dir = 0;

	if (_elem_static_data.max_vel_x > 0.0) {
		_x_speed = int(round(clamp(abs(_elem_dynamic_data.vel.x) / _elem_static_data.max_vel_x, 0.0, 1.0) * 7.0));
	}
	if (_elem_static_data.max_vel_y > 0.0) {
		_y_speed = int(round(clamp(abs(_elem_dynamic_data.vel.y) / _elem_static_data.max_vel_y, 0.0, 1.0) * 7.0));
	}
	_x_dir = (_elem_dynamic_data.vel.x < 0.0) ? 1 : 0;
	_y_dir = (_elem_dynamic_data.vel.y < 0.0) ? 1 : 0;

	_green_byte = bitwise_or(_green_byte, bit_shift_left(clamp(_y_dir, 0, 1), 7));
	_green_byte = bitwise_or(_green_byte, bit_shift_left(clamp(_y_speed, 0, 7), 4));
	_green_byte = bitwise_or(_green_byte, bit_shift_left(clamp(_x_dir, 0, 1), 3));
	_green_byte = bitwise_or(_green_byte, clamp(_x_speed, 0, 7));

	return vec4(
		byte_to_float(clamp(_elem_dynamic_data.id, 0, 255)),
		byte_to_float(_green_byte),
		byte_to_float(clamp(_elem_dynamic_data.dynamic_byte, 0, 255)),
		1.0
	);
}
#endregion

#region State Helpers
bool elem_is_empty(ElementStaticData _elem_static_data) {
	return _elem_static_data.id == ELEM_ID_EMPTY || _elem_static_data.state_of_matter == MATTER_EMPTY;
}

bool elem_is_gas(ElementStaticData _elem_static_data) {
	return _elem_static_data.state_of_matter == MATTER_GAS;
}

bool elem_is_liquid(ElementStaticData _elem_static_data) {
	return _elem_static_data.state_of_matter == MATTER_LIQUID;
}

bool elem_is_solid(ElementStaticData _elem_static_data) {
	return _elem_static_data.state_of_matter == MATTER_SOLID;
}

bool cell_is_empty(vec4 _pixel) {
	return elem_is_empty(get_element_static_data(element_id_from_pixel(_pixel)));
}

bool cell_is_gas(vec4 _pixel) {
	return elem_is_gas(get_element_static_data(element_id_from_pixel(_pixel)));
}

bool cell_is_liquid(vec4 _pixel) {
	return elem_is_liquid(get_element_static_data(element_id_from_pixel(_pixel)));
}

bool cell_is_solid(vec4 _pixel) {
	return elem_is_solid(get_element_static_data(element_id_from_pixel(_pixel)));
}
#endregion

#region Compatibility Helpers
bool replace_mask_allows(ElementStaticData _source_static_data, ElementStaticData _target_static_data) {
	if (elem_is_empty(_target_static_data)) {
		return flag_enabled(_source_static_data.replace_mask, REPLACE_MASK_EMPTY);
	}

	if (_source_static_data.id == _target_static_data.id) {
		return flag_enabled(_source_static_data.replace_mask, REPLACE_MASK_SAME_ELEMENT);
	}

	if (_source_static_data.interaction_group != INTERACTION_GROUP_INERT && _source_static_data.interaction_group == _target_static_data.interaction_group) {
		return flag_enabled(_source_static_data.replace_mask, REPLACE_MASK_SAME_GROUP);
	}

	if (elem_is_gas(_target_static_data)) {
		return flag_enabled(_source_static_data.replace_mask, REPLACE_MASK_GAS);
	}

	if (elem_is_liquid(_target_static_data)) {
		return flag_enabled(_source_static_data.replace_mask, REPLACE_MASK_LIQUID);
	}

	if (elem_is_solid(_target_static_data) && !_target_static_data.immovable) {
		return flag_enabled(_source_static_data.replace_mask, REPLACE_MASK_SOLID_MOVABLE);
	}

	return false;
}

bool replace_ids_match(ElementStaticData _source_static_data, int _target_id) {
	if (_source_static_data.replace_count <= 0) {
		return false;
	}
	if (_source_static_data.replace_id_0 == _target_id) {
		return true;
	}
	if (_source_static_data.replace_count > 1 && _source_static_data.replace_id_1 == _target_id) {
		return true;
	}
	if (_source_static_data.replace_count > 2 && _source_static_data.replace_id_2 == _target_id) {
		return true;
	}
	if (_source_static_data.replace_count > 3 && _source_static_data.replace_id_3 == _target_id) {
		return true;
	}
	return false;
}

bool element_can_enter(ElementStaticData _source_static_data, ElementStaticData _target_static_data, int _target_id) {
	if (_source_static_data.id == ELEM_ID_EMPTY) {
		return false;
	}

	if (elem_is_empty(_target_static_data)) {
		return true;
	}

	if (_target_static_data.immovable) {
		return false;
	}

	if (!replace_mask_allows(_source_static_data, _target_static_data)) {
		if (_source_static_data.replace_mode != REPLACE_MODE_EXPLICIT_IDS_FALLBACK) {
			return false;
		}
		return replace_ids_match(_source_static_data, _target_id);
	}

	if (_source_static_data.replace_mode == REPLACE_MODE_EMPTY_ONLY) {
		return false;
	}

	if (_source_static_data.replace_mode == REPLACE_MODE_LESS_DENSE) {
		return _source_static_data.density > _target_static_data.density;
	}

	if (_source_static_data.replace_mode == REPLACE_MODE_LESS_DENSE_OR_EQUAL) {
		return _source_static_data.density >= _target_static_data.density;
	}

	if (_source_static_data.replace_mode == REPLACE_MODE_CLASS_MASK) {
		return true;
	}

	if (_source_static_data.replace_mode == REPLACE_MODE_EXPLICIT_IDS_FALLBACK) {
		if (_source_static_data.density >= _target_static_data.density) {
			return true;
		}
		return replace_ids_match(_source_static_data, _target_id);
	}

	return false;
}
#endregion

#region Velocity Packing For Intent Surfaces
vec2 vel_to_rg(vec2 _velocity) {
	return (_velocity + 128.0) / 255.0;
}

vec2 rg_to_vel(vec2 _encoded_rg) {
	return vec2(floor(_encoded_rg * 255.0 + 0.5)) - vec2(128.0);
}

vec2 rand_round_vel(vec2 _velocity, vec2 _texcoord, float _seed) {
	vec2 _rounded;
	float _rand_x = rand(_texcoord, _seed);
	float _rand_y = rand(_texcoord, _seed + 1.0);

	if (_velocity.x > 0.0) {
		float _frac_x = fract(_velocity.x);
		_rounded.x = floor(_velocity.x) + (_rand_x < _frac_x ? 1.0 : 0.0);
	} else if (_velocity.x < 0.0) {
		float _frac_x = fract(-_velocity.x);
		_rounded.x = ceil(_velocity.x) - (_rand_x < _frac_x ? 1.0 : 0.0);
	} else {
		_rounded.x = 0.0;
	}

	if (_velocity.y > 0.0) {
		float _frac_y = fract(_velocity.y);
		_rounded.y = floor(_velocity.y) + (_rand_y < _frac_y ? 1.0 : 0.0);
	} else if (_velocity.y < 0.0) {
		float _frac_y = fract(-_velocity.y);
		_rounded.y = ceil(_velocity.y) - (_rand_y < _frac_y ? 1.0 : 0.0);
	} else {
		_rounded.y = 0.0;
	}

	return _rounded;
}


vec2 clamp_velocity_to_static(vec2 _velocity, ElementStaticData _elem_static_data) {
	_velocity.x = clamp(_velocity.x, -_elem_static_data.max_vel_x, _elem_static_data.max_vel_x);
	_velocity.y = clamp(_velocity.y, -_elem_static_data.max_vel_y, _elem_static_data.max_vel_y);
	return _velocity;
}

vec2 snap_velocity_to_storage(vec2 _velocity, ElementStaticData _elem_static_data) {
	float _step_x = 0.0;
	float _step_y = 0.0;

	if (_elem_static_data.max_vel_x > 0.0) {
		_step_x = _elem_static_data.max_vel_x / 7.0;
		if (abs(_velocity.x) < (_step_x * 0.5)) {
			_velocity.x = 0.0;
		}
	} else {
		_velocity.x = 0.0;
	}

	if (_elem_static_data.max_vel_y > 0.0) {
		_step_y = _elem_static_data.max_vel_y / 7.0;
		if (abs(_velocity.y) < (_step_y * 0.5)) {
			_velocity.y = 0.0;
		}
	} else {
		_velocity.y = 0.0;
	}

	return _velocity;
}

vec2 sanitize_velocity_to_static(vec2 _velocity, ElementStaticData _elem_static_data) {
	_velocity = clamp_velocity_to_static(_velocity, _elem_static_data);
	_velocity = snap_velocity_to_storage(_velocity, _elem_static_data);
	return _velocity;
}

#endregion

void main() {
	
}
