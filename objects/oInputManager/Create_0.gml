EVENT_METHOD;

//Note: If you're looking for a key's ID use https://keycode.info 

mouse_coordinates = [device_mouse_x_to_gui(0),device_mouse_y_to_gui(0)];
global.device_current = -1;
global.device_guid = undefined;
global.device_type = -1;
global.mouse_enabled = true;

enum ACTION {
	MOVE_UP,
	MOVE_DOWN,
	MOVE_LEFT,
	MOVE_RIGHT,
	
	ACTION1,
	ACTION2,
	ACTION3,
	ACTION4,
	
	LEFT_CLICK,
	MIDDLE_CLICK,
	RIGHT_CLICK,
	
	CANCEL,
	PAUSE,
	
	Size
}

enum Event {
	Pressed,
	Down,
	Released,
	Held,
}

#region Define Actions
input_action_assign_key(ACTION.LEFT_CLICK,mb_left);
input_action_assign_key(ACTION.MIDDLE_CLICK,mb_middle);
input_action_assign_key(ACTION.RIGHT_CLICK,mb_right);

input_action_assign_key(ACTION.MOVE_UP,ord("W"),vk_up,input_axislu);
input_action_assign_key(ACTION.MOVE_DOWN,ord("S"),vk_down,input_axisld);
input_action_assign_key(ACTION.MOVE_LEFT,ord("A"),vk_left,input_axisll);
input_action_assign_key(ACTION.MOVE_RIGHT,ord("D"),vk_right,input_axislr);

input_action_assign_key(ACTION.ACTION1,ord("W"),vk_up,input_axislu);
input_action_assign_key(ACTION.ACTION2,ord("S"),vk_down,input_axisld);
input_action_assign_key(ACTION.ACTION3,ord("A"),vk_left,input_axisll);
input_action_assign_key(ACTION.ACTION4,ord("D"),vk_right,input_axislr);

input_action_assign_key(ACTION.PAUSE,vk_escape,gp_start);
input_action_assign_key(ACTION.CANCEL,vk_backspace,vk_escape,gp_face2);
#endregion

#region Extra Functions
global.input_gamepad_connected_val = [];
global.input_held_timers = [];
global.input_held_time = GAME_FPS*0.5;

pressed  = input_action_check_pressed;  //pressed
check    = input_action_check;					//down
released = input_action_check_released;	//released
held     = input_action_check_held;	    //held

var _i = 0; repeat(ACTION.Size) {
	global.input_held_timers[_i] = 0;
_i+=1;}


update_cache = function() {
	var _size = array_length(global.input_gamepad_connected_val);
	var _i = 0; repeat(_size){
		global.input_gamepad_connected_val[_i] = -1;
	_i++;}
	
	global.input_gamepad_exists = -1;
	
	var _i = 0; repeat(ACTION.Size) {
		global.input_action_events[_i][Event.Pressed]  = -1; //pressed
		global.input_action_events[_i][Event.Down]     = -1; //down
		global.input_action_events[_i][Event.Released] = -1; //released
		global.input_action_events[_i][Event.Held]     = -1; //held
	_i+=1;}
}
#endregion

update_cache();

input_stack = [];

input = {
	x: mouse_x,
	y: mouse_y,
	x_previous: mouse_x,
	y_previous: mouse_y,
	x_gui: device_mouse_x_to_gui(0),
	y_gui: device_mouse_y_to_gui(0),
	x_gui_previous: device_mouse_x_to_gui(0),
	y_gui_previous: device_mouse_y_to_gui(0),
	consumed: false,	// consumed this step
};

