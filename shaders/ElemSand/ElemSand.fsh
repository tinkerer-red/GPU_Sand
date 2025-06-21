void main()
{
    
	//this is only here to prevent errors
	#ifdef EXCLUDE
	
	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	int sand_replace_ids[4];
	sand_replace_ids[0] = ELEM_ID_WATER;
	sand_replace_ids[1] = 0;
	sand_replace_ids[2] = 0;
	sand_replace_ids[3] = 0;
	
	
	ElementStaticData elem_static_data = ElementStaticData(
		ELEM_ID_SAND, //ID
		
	    // Gravity and movement behavior
	    1,      // gravity_dir
	    1,      // x_search
	    1,      // y_search
	    0,      // stickiness
	    1,      // can_slip
	    1,      // inertial_resistance

	    // Physical characteristics
	    150,    // mass
	    9,      // friction_factor
	    5,      // stopped_moving_threshold
	    3,      // state_of_matter (solid)

	    // Heat and flammability
	    0,      // flammable
	    0,      // heat_factor
	    0,      // fire_damage

	    // Explosive properties
	    1,      // explosion_resist
	    0,      // explosion_radius

	    // Lifecycle
	    -1,     // lifespan

	    // Interaction rules
	    1,      // replace_count
	    sand_replace_ids
	);
	
	#pragma shady: macro_end
	#endregion
	
	#region INTENT
	#pragma shady: macro_begin INTENT
	if (elem_dynamic_data.id == ELEM_ID_SAND) {
		
	    #pragma shady: inline(ElemSand.DefineElementStaticData)
		#pragma shady: inline(shdSandSimCommon.GENERIC_INTENT)
		
	    break;
	}
	#pragma shady: macro_end
	#endregion
	
	#region ACCEPT
	#pragma shady: macro_begin ACCEPT
	if (elem_dynamic_data.id == ELEM_ID_SAND) {
		
		//currently sand doesnt accept anything else
		accepted = false;
		
		break;
	}
	#pragma shady: macro_end
	#endregion
	
	#endif
}
