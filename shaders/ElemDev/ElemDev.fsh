#pragma shady: skip_compilation
#ifdef EXCLUDE
#region Uniforms
#pragma shady: macro_begin Uniforms
uniform float u_dev_state_of_matter;

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

uniform float u_dev_can_ignite;
uniform float u_dev_temperature_decay;
uniform float u_dev_temperature_spread_chance;

uniform float u_dev_explosion_resistance;
uniform float u_dev_explosion_radius;

uniform float u_dev_custom_event_chance;

uniform float u_dev_replace_count;
uniform float u_dev_replace_id_0;
uniform float u_dev_replace_id_1;
uniform float u_dev_replace_id_2;
uniform float u_dev_replace_id_3;
#pragma shady: macro_end
#endregion
#endif

void main()
{
    
	//this is only here to prevent errors
	#ifdef EXCLUDE
	
	#region DefineElementStaticData
	#pragma shady: macro_begin DefineElementStaticData
	int dev_replace_ids[4];
	dev_replace_ids[0] = int(u_dev_replace_id_0);
	dev_replace_ids[1] = int(u_dev_replace_id_1);
	dev_replace_ids[2] = int(u_dev_replace_id_2);
	dev_replace_ids[3] = int(u_dev_replace_id_3);
	
	
	ElementStaticData elem_static_data = ElementStaticData(
	    ELEM_ID_DEV,                           // id
	    int(u_dev_state_of_matter),            // state_of_matter

	    // === Gravity & Movement ===
	    u_dev_gravity_force,                   // gravity_force
	    u_dev_max_vel_x,                       // max_vel_x
	    u_dev_max_vel_y,                       // max_vel_y

	    (u_dev_can_slip > 0.5),                // can_slip
	    u_dev_x_slip_search_range,             // x_slip_search_range
	    u_dev_y_slip_search_range,             // y_slip_search_range
		
		u_dev_wake_chance,                     // wake_chance

	    u_dev_stickiness_chance,              // stickiness_chance

	    u_dev_bounce_chance,                  // bounce_chance
	    u_dev_bounce_dampening_multiplier,    // bounce_dampening_multiplier

	    // === Velocity Decay ===
	    u_dev_airborne_vel_decay_chance,      // airborne_vel_decay_chance
	    u_dev_friction_vel_decay_chance,      // friction_vel_decay_chance

	    // === Physical ===
	    u_dev_mass,                           // mass

	    // === Heat and Flammability ===
	    (u_dev_can_ignite > 0.5),             // can_ignite
	    u_dev_temperature_decay,              // temperature_decay
	    u_dev_temperature_spread_chance,      // temperature_spread_chance

	    // === Explosive Properties ===
	    u_dev_explosion_resistance,           // explosion_resistance
	    u_dev_explosion_radius,               // explosion_radius

	    // === Lifecycle Control ===
	    u_dev_custom_event_chance,            // custom_event_chance

	    // === Replacement Rules ===
	    int(u_dev_replace_count),             // replace_count
	    dev_replace_ids                       // replace_ids[4]
	);


	
	#pragma shady: macro_end
	#endregion
	
	#region INTENT
	#pragma shady: macro_begin INTENT
	if (elem_dynamic_data.id == ELEM_ID_DEV) {
		
	    #pragma shady: inline(ElemDev.DefineElementStaticData)
		#pragma shady: inline(shdSandSimCommon.GENERIC_INTENT)
		
	    break;
	}
	#pragma shady: macro_end
	#endregion
	
	#region ACCEPT
	#pragma shady: macro_begin ACCEPT
	if (elem_dynamic_data.id == ELEM_ID_DEV) {
		
		// By default the dev element behaves like sand and does not accept anything else
		accepted = false;
		
		break;
	}
	#pragma shady: macro_end
	#endregion
	
	#endif
}