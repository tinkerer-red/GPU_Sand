function log(_param) {
	show_debug_message(string(_param))
}

function log_struct_low_level(_struct) {
	if (is_struct(_struct))
	&& (variable_struct_exists(_struct, "toString")) {
		var _to_string = variable_struct_get(_struct, "toString")
		variable_struct_remove(_struct, "toString")
		show_debug_message(string(_struct))
		variable_struct_set(_struct, "toString", _to_string)
	}
	else{
		show_debug_message(string(_struct));
	}
}

#region jsDoc
/// @func    trace()
/// @desc    This function will create a custom debug message  that is shown in the compiler window at runtime.
///
///          .
///
///          output: `<file>/<function>:<line>: <string>`
/// @param   {string} str : The string you wish to log
/// @returns {undefined}
#endregion
#macro trace  __trace(_GMFILE_+"/"+_GMFUNCTION_+":"+string(_GMLINE_)+": ")
function __trace(_location) {
		static __struct = {};
		__struct.__location = _location;
		return method(__struct, function(_str)
    {
        show_debug_message(__location + ": " + string(_str));
    });
}
