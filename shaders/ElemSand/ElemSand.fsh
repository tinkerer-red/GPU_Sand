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
	    ELEM_ID_SAND, // The ID of the element
		
	    // Gravity and movement behavior
	    1.0,   // gravity_force         (constant gravity every frame)
	    1.0,   // x_search              (can move 1 cell left/right)
	    1.0,   // y_search              (can fall 1 cell per fallback)
	    2.0,   // max_vel_x             (caps horizontal speed)
	    3.0,   // max_vel_y             (caps vertical speed)
	    0.0,   // stickiness            (no clumping behavior)
	    1.0,   // inertial_resistance   (modest horizontal drag)
	    0.1,   // bounce_chance         (low chance of bouncing)
		true,  // can_slip              (can diagonally fallback)
	    
	    // Physical characteristics
	    150,    // mass                  (affects force transfer)
	    9,      // friction_factor       (how much to reduce movement when hitting)
	    3,      // state_of_matter       (3 = solid)
		
	    // Heat and flammability
	    0,      // flammable             (won’t ignite)
	    0,      // heat_factor           (does not apply heat)
	    0,      // fire_damage           (no fire damage)
		
	    // Explosive properties
	    1,      // explosion_resist      (mild resistance)
	    0,      // explosion_radius      (not explosive)
		
	    // Lifecycle
	    -1,     // lifespan              (infinite lifetime)
		
	    // Interaction rules
	    1,      // replace_count         (can only replace water)
	    sand_replace_ids // replace_ids[4]  (allowed replacement targets)
	);

	
	#pragma shady: macro_end
	#endregion
	
	#region INTENT
	#pragma shady: macro_begin INTENT
	if (elem_dynamic_data.id == ELEM_ID_SAND) {
	    #pragma shady: inline(ElemSand.DefineElementStaticData)
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
