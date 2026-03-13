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
uniform float u_dev_flow_mode;

uniform float u_dev_vertical_drive;
uniform float u_dev_max_speed;
uniform float u_dev_lateral_spread;
uniform float u_dev_momentum_retention;
uniform float u_dev_support_resistance;
uniform float u_dev_clump_factor;
uniform float u_dev_surface_response;
uniform float u_dev_density;
uniform float u_dev_immovable;
uniform float u_dev_replace_mask;

uniform float u_dev_temp_contribute;
uniform float u_dev_temp_locked;
uniform float u_dev_temp_transfer_rate;
uniform float u_dev_temp_idle_value;
uniform float u_dev_temp_on_low;
uniform float u_dev_temp_on_high;

uniform float u_dev_moisture_contribute;
uniform float u_dev_moisture_locked;
uniform float u_dev_moisture_transfer_rate;
uniform float u_dev_moisture_idle_value;
uniform float u_dev_moisture_on_low;
uniform float u_dev_moisture_on_high;

uniform float u_dev_corrosion_contribute;
uniform float u_dev_corrosion_locked;
uniform float u_dev_corrosion_transfer_rate;
uniform float u_dev_corrosion_idle_value;
uniform float u_dev_corrosion_on_low;
uniform float u_dev_corrosion_on_high;

uniform float u_dev_magic_contribute;
uniform float u_dev_magic_locked;
uniform float u_dev_magic_transfer_rate;
uniform float u_dev_magic_idle_value;
uniform float u_dev_magic_on_low;
uniform float u_dev_magic_on_high;

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

#define FLOW_MODE_STATIC 0
#define FLOW_MODE_POWDER 1
#define FLOW_MODE_LIQUID 2
#define FLOW_MODE_GAS 3
#define FLOW_MODE_GOO 4

#define LANE_TEMPERATURE 0
#define LANE_MOISTURE 1
#define LANE_CORROSION 2
#define LANE_MAGIC 3

#define REPLACE_MASK_EMPTY 1
#define REPLACE_MASK_GAS 2
#define REPLACE_MASK_LIQUID 4
#define REPLACE_MASK_SOLID_MOVABLE 8
#define REPLACE_MASK_SAME_ELEMENT 16

#endregion

#region Data Structures
struct ElementStaticData {
	// -------------------------------------------------------------------------
	// Identity / visual authoring
	// -------------------------------------------------------------------------
	// Unique element id used throughout the simulation.
	int id;

	// Packed or encoded base color used for rendering this element.
	float base_color;

	// -------------------------------------------------------------------------
	// Material classification
	// -------------------------------------------------------------------------
	// What this element fundamentally is for broader simulation meaning.
	// Example values:
	// - MATTER_EMPTY
	// - MATTER_SOLID
	// - MATTER_LIQUID
	// - MATTER_GAS
	//
	// This is the "what is it?" classification.
	int state_of_matter;

	// How this element should behave in the movement solver.
	// Example values:
	// - FLOW_MODE_STATIC
	// - FLOW_MODE_POWDER
	// - FLOW_MODE_LIQUID
	// - FLOW_MODE_GAS
	// - FLOW_MODE_GOO
	//
	// This is the "how does it move?" classification.
	int flow_mode;

	// -------------------------------------------------------------------------
	// Core movement profile
	// -------------------------------------------------------------------------
	// Vertical motion drive.
	// Positive values prefer falling.
	// Negative values prefer rising.
	// Zero means no natural vertical preference.
	float vertical_drive;

	// Maximum travel tendency / movement strength.
	// Higher values allow the element to preserve and use stronger velocity.
	// This replaces the need to author separate max X / max Y in most cases.
	float max_speed;

	// How aggressively the element spreads sideways when blocked or settling.
	// Higher values help liquids level out faster and gases diffuse more.
	// Lower values keep powders tighter and more column-like.
	float lateral_spread;

	// How strongly previous motion should persist from frame to frame.
	// Higher values preserve momentum longer.
	// Lower values make the element settle and lose motion faster.
	float momentum_retention;

	// How resistant the element is to losing its current support structure.
	// Lower values make piles destabilize and slough more easily.
	// Higher values make the element hold its shape more stubbornly.
	//
	// For powders, lowering this helps prevent perfect pyramid stability.
	float support_resistance;

	// How strongly the element prefers to stay near like neighbors.
	// This is a generalized "clump / cohesion / viscosity-like" control.
	//
	// Uses:
	// - Slightly helps sand cluster instead of forming perfect clean slopes
	// - Makes goo, slime, or lava feel more connected
	// - Higher values can encourage blob-like or stream-like behavior
	float clump_factor;

	// Broad collision / contact response when hitting surfaces or blockers.
	// Lower values favor dead settling.
	// Higher values favor livelier rebound / slide / reaction.
	//
	// Keep this broad for now. Only split it later if a proven need appears.
	float surface_response;

	// Relative displacement priority between materials.
	// This controls who tends to pass through / settle through / displace who.
	//
	// Example:
	// - denser powders can sink through lighter liquids
	// - lighter gases can rise around denser materials
	float density;

	// Hard override to prevent movement entirely.
	// Useful for indestructible walls or materials that must never move
	// even if their other fields would otherwise allow it.
	bool immovable;

	// -------------------------------------------------------------------------
	// Replacement / movement eligibility
	// -------------------------------------------------------------------------
	// Bitmask describing which materials this element is allowed to replace
	// when attempting to move into another cell.
	//
	// This should be expressive enough to replace old replace_mode logic.
	// Example:
	// - water may replace empty and some gases
	// - lava may replace snow
	// - sand may replace empty and some liquids depending on design
	int replace_mask;

	// -------------------------------------------------------------------------
	// Temperature lane behavior
	// -------------------------------------------------------------------------
	// Whether this element contributes to / participates in temperature transfer.
	bool temp_contribute;

	// If true, this lane is fixed and should not be altered by transfer logic.
	bool temp_locked;

	// How quickly this element exchanges this property with neighbors.
	float temp_transfer_rate;

	// Natural resting value this property tends toward when left alone.
	float temp_idle_value;

	// Element transformation when this property reaches a low threshold.
	int temp_on_low;

	// Element transformation when this property reaches a high threshold.
	int temp_on_high;

	// -------------------------------------------------------------------------
	// Moisture lane behavior
	// -------------------------------------------------------------------------
	bool moisture_contribute;
	bool moisture_locked;
	float moisture_transfer_rate;
	float moisture_idle_value;
	int moisture_on_low;
	int moisture_on_high;

	// -------------------------------------------------------------------------
	// Corrosion lane behavior
	// -------------------------------------------------------------------------
	bool corrosion_contribute;
	bool corrosion_locked;
	float corrosion_transfer_rate;
	float corrosion_idle_value;
	int corrosion_on_low;
	int corrosion_on_high;

	// -------------------------------------------------------------------------
	// Magic lane behavior
	// -------------------------------------------------------------------------
	bool magic_contribute;
	bool magic_locked;
	float magic_transfer_rate;
	float magic_idle_value;
	int magic_on_low;
	int magic_on_high;
};

struct ElementDynamicData {
	int id;
	vec2 vel;

	int x_dir;
	int y_dir;
	int x_speed;
	int y_speed;

	int temp_dir;
	int temp_magnitude;

	int moisture_dir;
	int moisture_magnitude;

	int corrosion_dir;
	int corrosion_magnitude;

	int magic_dir;
	int magic_magnitude;
};
#endregion

#region General Helpers
bool flag_enabled(int _mask_value, int _flag_value) {
	if (_flag_value <= 0) {
		return false;
	}
	return imod(int(floor(float(_mask_value) / float(_flag_value))), 2) == 1;
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
	_elem_static_data.base_color = 0.0;
	_elem_static_data.state_of_matter = MATTER_EMPTY;
	_elem_static_data.flow_mode = FLOW_MODE_STATIC;
	_elem_static_data.vertical_drive = 0.0;
	_elem_static_data.max_speed = 0.0;
	_elem_static_data.lateral_spread = 0.0;
	_elem_static_data.momentum_retention = 0.0;
	_elem_static_data.support_resistance = 1.0;
	_elem_static_data.clump_factor = 0.0;
	_elem_static_data.surface_response = 0.0;
	_elem_static_data.density = 0.0;
	_elem_static_data.immovable = false;
	_elem_static_data.replace_mask = REPLACE_MASK_EMPTY;
	
	_elem_static_data.temp_contribute = false;
	_elem_static_data.temp_locked = true;
	_elem_static_data.temp_transfer_rate = 0.0;
	_elem_static_data.temp_idle_value = 0.0;
	_elem_static_data.temp_on_low = ELEM_ID_EMPTY;
	_elem_static_data.temp_on_high = ELEM_ID_EMPTY;
	
	_elem_static_data.moisture_contribute = false;
	_elem_static_data.moisture_locked = true;
	_elem_static_data.moisture_transfer_rate = 0.0;
	_elem_static_data.moisture_idle_value = 0.0;
	_elem_static_data.moisture_on_low = ELEM_ID_EMPTY;
	_elem_static_data.moisture_on_high = ELEM_ID_EMPTY;
	
	_elem_static_data.corrosion_contribute = false;
	_elem_static_data.corrosion_locked = true;
	_elem_static_data.corrosion_transfer_rate = 0.0;
	_elem_static_data.corrosion_idle_value = 0.0;
	_elem_static_data.corrosion_on_low = ELEM_ID_EMPTY;
	_elem_static_data.corrosion_on_high = ELEM_ID_EMPTY;
	
	_elem_static_data.magic_contribute = false;
	_elem_static_data.magic_locked = true;
	_elem_static_data.magic_transfer_rate = 0.0;
	_elem_static_data.magic_idle_value = 0.0;
	_elem_static_data.magic_on_low = ELEM_ID_EMPTY;
	_elem_static_data.magic_on_high = ELEM_ID_EMPTY;
	
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

int lane_pack_nibble(int _lane_value) {
	int _lane_sign = (_lane_value < 0) ? 1 : 0;
	int _lane_magnitude = clamp(abs_int(_lane_value), 0, 7);
	if (_lane_magnitude == 0) {
		return 0;
	}
	return bitwise_or(bit_shift_left(_lane_sign, 3), _lane_magnitude);
}

int lane_unpack_nibble(int _lane_nibble) {
	int _lane_sign = imod(bit_shift_right(_lane_nibble, 3), 2);
	int _lane_magnitude = imod(_lane_nibble, 8);
	if (_lane_magnitude == 0) {
		return 0;
	}
	return (_lane_sign == 1) ? -_lane_magnitude : _lane_magnitude;
}

int lane_value_from_parts(int _lane_dir, int _lane_magnitude) {
	if (_lane_magnitude <= 0) {
		return 0;
	}
	return (_lane_dir == 1) ? -_lane_magnitude : _lane_magnitude;
}

int dynamic_temperature_get(ElementDynamicData _elem_dynamic_data) {
	return lane_value_from_parts(_elem_dynamic_data.temp_dir, _elem_dynamic_data.temp_magnitude);
}

ElementDynamicData dynamic_temperature_set(ElementDynamicData _elem_dynamic_data, int _lane_value) {
	int _lane_dir = (_lane_value < 0) ? 1 : 0;
	int _lane_magnitude = clamp(abs_int(_lane_value), 0, 7);

	if (_lane_magnitude == 0) {
		_lane_dir = 0;
	}

	_elem_dynamic_data.temp_dir = _lane_dir;
	_elem_dynamic_data.temp_magnitude = _lane_magnitude;
	return _elem_dynamic_data;
}

int dynamic_moisture_get(ElementDynamicData _elem_dynamic_data) {
	return lane_value_from_parts(_elem_dynamic_data.moisture_dir, _elem_dynamic_data.moisture_magnitude);
}

ElementDynamicData dynamic_moisture_set(ElementDynamicData _elem_dynamic_data, int _lane_value) {
	int _lane_dir = (_lane_value < 0) ? 1 : 0;
	int _lane_magnitude = clamp(abs_int(_lane_value), 0, 7);

	if (_lane_magnitude == 0) {
		_lane_dir = 0;
	}

	_elem_dynamic_data.moisture_dir = _lane_dir;
	_elem_dynamic_data.moisture_magnitude = _lane_magnitude;
	return _elem_dynamic_data;
}

int dynamic_corrosion_get(ElementDynamicData _elem_dynamic_data) {
	return lane_value_from_parts(_elem_dynamic_data.corrosion_dir, _elem_dynamic_data.corrosion_magnitude);
}

ElementDynamicData dynamic_corrosion_set(ElementDynamicData _elem_dynamic_data, int _lane_value) {
	int _lane_dir = (_lane_value < 0) ? 1 : 0;
	int _lane_magnitude = clamp(abs_int(_lane_value), 0, 7);

	if (_lane_magnitude == 0) {
		_lane_dir = 0;
	}

	_elem_dynamic_data.corrosion_dir = _lane_dir;
	_elem_dynamic_data.corrosion_magnitude = _lane_magnitude;
	return _elem_dynamic_data;
}

int dynamic_magic_get(ElementDynamicData _elem_dynamic_data) {
	return lane_value_from_parts(_elem_dynamic_data.magic_dir, _elem_dynamic_data.magic_magnitude);
}

ElementDynamicData dynamic_magic_set(ElementDynamicData _elem_dynamic_data, int _lane_value) {
	int _lane_dir = (_lane_value < 0) ? 1 : 0;
	int _lane_magnitude = clamp(abs_int(_lane_value), 0, 7);

	if (_lane_magnitude == 0) {
		_lane_dir = 0;
	}

	_elem_dynamic_data.magic_dir = _lane_dir;
	_elem_dynamic_data.magic_magnitude = _lane_magnitude;
	return _elem_dynamic_data;
}

bool static_lane_contribute(ElementStaticData _elem_static_data, int _lane_index) {
	if (_lane_index == LANE_TEMPERATURE) return _elem_static_data.temp_contribute;
	if (_lane_index == LANE_MOISTURE) return _elem_static_data.moisture_contribute;
	if (_lane_index == LANE_CORROSION) return _elem_static_data.corrosion_contribute;
	return _elem_static_data.magic_contribute;
}

bool static_lane_locked(ElementStaticData _elem_static_data, int _lane_index) {
	if (_lane_index == LANE_TEMPERATURE) return _elem_static_data.temp_locked;
	if (_lane_index == LANE_MOISTURE) return _elem_static_data.moisture_locked;
	if (_lane_index == LANE_CORROSION) return _elem_static_data.corrosion_locked;
	return _elem_static_data.magic_locked;
}

float static_lane_transfer_rate(ElementStaticData _elem_static_data, int _lane_index) {
	if (_lane_index == LANE_TEMPERATURE) return _elem_static_data.temp_transfer_rate;
	if (_lane_index == LANE_MOISTURE) return _elem_static_data.moisture_transfer_rate;
	if (_lane_index == LANE_CORROSION) return _elem_static_data.corrosion_transfer_rate;
	return _elem_static_data.magic_transfer_rate;
}

bool static_lane_ignored(ElementStaticData _elem_static_data, int _lane_index) {
	if (static_lane_locked(_elem_static_data, _lane_index)) {
		return true;
	}
	if (!static_lane_contribute(_elem_static_data, _lane_index) && static_lane_transfer_rate(_elem_static_data, _lane_index) <= 0.0) {
		return true;
	}
	return false;
}

float static_lane_idle_value(ElementStaticData _elem_static_data, int _lane_index) {
	if (_lane_index == LANE_TEMPERATURE) return _elem_static_data.temp_idle_value;
	if (_lane_index == LANE_MOISTURE) return _elem_static_data.moisture_idle_value;
	if (_lane_index == LANE_CORROSION) return _elem_static_data.corrosion_idle_value;
	return _elem_static_data.magic_idle_value;
}

int static_lane_on_low(ElementStaticData _elem_static_data, int _lane_index) {
	if (_lane_index == LANE_TEMPERATURE) return _elem_static_data.temp_on_low;
	if (_lane_index == LANE_MOISTURE) return _elem_static_data.moisture_on_low;
	if (_lane_index == LANE_CORROSION) return _elem_static_data.corrosion_on_low;
	return _elem_static_data.magic_on_low;
}

int static_lane_on_high(ElementStaticData _elem_static_data, int _lane_index) {
	if (_lane_index == LANE_TEMPERATURE) return _elem_static_data.temp_on_high;
	if (_lane_index == LANE_MOISTURE) return _elem_static_data.moisture_on_high;
	if (_lane_index == LANE_CORROSION) return _elem_static_data.corrosion_on_high;
	return _elem_static_data.magic_on_high;
}

float lane_saturated_effective_value(ElementStaticData _elem_static_data, int _lane_index, bool _toward_high) {
	int _target_id = _toward_high ? static_lane_on_high(_elem_static_data, _lane_index) : static_lane_on_low(_elem_static_data, _lane_index);
	ElementStaticData _target_static_data = get_element_static_data(_target_id);
	float _current_idle_value = static_lane_idle_value(_elem_static_data, _lane_index);
	float _target_idle_value = static_lane_idle_value(_target_static_data, _lane_index);
	return _current_idle_value + ((_target_idle_value - _current_idle_value) * 0.5);
}

float lane_effective_value(ElementStaticData _elem_static_data, int _lane_index, int _lane_value) {
	float _current_idle_value;
	float _high_saturated_value;
	float _low_saturated_value;

	if (static_lane_ignored(_elem_static_data, _lane_index)) {
		return 0.0;
	}

	_current_idle_value = static_lane_idle_value(_elem_static_data, _lane_index);
	if (_lane_value == 0) {
		return _current_idle_value;
	}
	if (_lane_value > 0) {
		_high_saturated_value = lane_saturated_effective_value(_elem_static_data, _lane_index, true);
		return _current_idle_value + ((_high_saturated_value - _current_idle_value) * (float(_lane_value) / 7.0));
	}
	_low_saturated_value = lane_saturated_effective_value(_elem_static_data, _lane_index, false);
	return _current_idle_value + ((_low_saturated_value - _current_idle_value) * (float(abs_int(_lane_value)) / 7.0));
}
#endregion

#region Pack / Unpack
ElementDynamicData unpack_elem_dynamic_data(vec4 _pixel) {
	ElementDynamicData _elem_dynamic_data;
	ElementStaticData _elem_static_data = get_element_static_data(element_id_from_pixel(_pixel));
	int _green_byte = float_to_byte(_pixel.g);
	int _lane_byte_b = float_to_byte(_pixel.b);
	int _lane_byte_a = float_to_byte(_pixel.a);
	int _temp_nibble = imod(bit_shift_right(_lane_byte_b, 4), 16);
	int _moisture_nibble = imod(_lane_byte_b, 16);
	int _corrosion_nibble = imod(bit_shift_right(_lane_byte_a, 4), 16);
	int _magic_nibble = imod(_lane_byte_a, 16);
	int _temp_value = lane_unpack_nibble(_temp_nibble);
	int _moisture_value = lane_unpack_nibble(_moisture_nibble);
	int _corrosion_value = lane_unpack_nibble(_corrosion_nibble);
	int _magic_value = lane_unpack_nibble(_magic_nibble);

	_elem_dynamic_data.id = element_id_from_pixel(_pixel);
	_elem_dynamic_data.y_dir = imod(bit_shift_right(_green_byte, 7), 2);
	_elem_dynamic_data.y_speed = imod(bit_shift_right(_green_byte, 4), 8);
	_elem_dynamic_data.x_dir = imod(bit_shift_right(_green_byte, 3), 2);
	_elem_dynamic_data.x_speed = imod(_green_byte, 8);

	_elem_dynamic_data.temp_dir = (_temp_value < 0) ? 1 : 0;
	_elem_dynamic_data.temp_magnitude = clamp(abs_int(_temp_value), 0, 7);
	_elem_dynamic_data.moisture_dir = (_moisture_value < 0) ? 1 : 0;
	_elem_dynamic_data.moisture_magnitude = clamp(abs_int(_moisture_value), 0, 7);
	_elem_dynamic_data.corrosion_dir = (_corrosion_value < 0) ? 1 : 0;
	_elem_dynamic_data.corrosion_magnitude = clamp(abs_int(_corrosion_value), 0, 7);
	_elem_dynamic_data.magic_dir = (_magic_value < 0) ? 1 : 0;
	_elem_dynamic_data.magic_magnitude = clamp(abs_int(_magic_value), 0, 7);

	_elem_dynamic_data.vel = vec2(0.0);
	if (_elem_static_data.max_speed > 0.0) {
		_elem_dynamic_data.vel.x = (float(_elem_dynamic_data.x_speed) / 7.0) * _elem_static_data.max_speed;
		if (_elem_dynamic_data.x_dir == 1) {
			_elem_dynamic_data.vel.x = -_elem_dynamic_data.vel.x;
		}
	}
	if (_elem_static_data.max_speed > 0.0) {
		_elem_dynamic_data.vel.y = (float(_elem_dynamic_data.y_speed) / 7.0) * _elem_static_data.max_speed;
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
	int _temp_nibble = lane_pack_nibble(dynamic_temperature_get(_elem_dynamic_data));
	int _moisture_nibble = lane_pack_nibble(dynamic_moisture_get(_elem_dynamic_data));
	int _corrosion_nibble = lane_pack_nibble(dynamic_corrosion_get(_elem_dynamic_data));
	int _magic_nibble = lane_pack_nibble(dynamic_magic_get(_elem_dynamic_data));
	int _lane_byte_b = (_temp_nibble * 16) + _moisture_nibble;
	int _lane_byte_a = (_corrosion_nibble * 16) + _magic_nibble;

	if (_elem_static_data.max_speed > 0.0) {
		_x_speed = int(round(clamp(abs_float(_elem_dynamic_data.vel.x) / _elem_static_data.max_speed, 0.0, 1.0) * 7.0));
	}
	if (_elem_static_data.max_speed > 0.0) {
		_y_speed = int(round(clamp(abs_float(_elem_dynamic_data.vel.y) / _elem_static_data.max_speed, 0.0, 1.0) * 7.0));
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
		byte_to_float(clamp(_lane_byte_b, 0, 255)),
		byte_to_float(clamp(_lane_byte_a, 0, 255))
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

bool element_can_enter(ElementStaticData _source_static_data, ElementStaticData _target_static_data, int _target_id) {
	if (_source_static_data.id == ELEM_ID_EMPTY) {
		return false;
	}

	if (_target_static_data.immovable) {
		return false;
	}

	if (!replace_mask_allows(_source_static_data, _target_static_data)) {
		return false;
	}

	if (elem_is_empty(_target_static_data)) {
		return true;
	}

	if (_source_static_data.id == _target_static_data.id) {
		return flag_enabled(_source_static_data.replace_mask, REPLACE_MASK_SAME_ELEMENT);
	}

	return _source_static_data.density > _target_static_data.density;
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
	_velocity.x = clamp(_velocity.x, -_elem_static_data.max_speed, _elem_static_data.max_speed);
	_velocity.y = clamp(_velocity.y, -_elem_static_data.max_speed, _elem_static_data.max_speed);
	return _velocity;
}

vec2 snap_velocity_to_storage(vec2 _velocity, ElementStaticData _elem_static_data) {
	float _step_x = 0.0;
	float _step_y = 0.0;

	if (_elem_static_data.max_speed > 0.0) {
		_step_x = _elem_static_data.max_speed / 7.0;
		if (abs_float(_velocity.x) < (_step_x * 0.5)) {
			_velocity.x = 0.0;
		}
	} else {
		_velocity.x = 0.0;
	}

	if (_elem_static_data.max_speed > 0.0) {
		_step_y = _elem_static_data.max_speed / 7.0;
		if (abs_float(_velocity.y) < (_step_y * 0.5)) {
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
