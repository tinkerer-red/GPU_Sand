function json_beautify(_json) {
	/// json_beautify(json_string)
	gml_pragma("global", "global.g_json_beautify_fb = buffer_create(1024, buffer_fast, 1); global.g_json_beautify_rb = buffer_create(1024, buffer_grow, 1);");
	
	// copy text to string buffer:
	var rb = global.g_json_beautify_rb;
	buffer_seek(rb, buffer_seek_start, 0);
	buffer_write(rb, buffer_string, _json);
	var size = buffer_tell(rb) - 1;
	/// --- var rbsize = buffer_get_size(rb);
	// then copy it to "fast" input buffer for peeking:
	var fb = global.g_json_beautify_fb;
	if (buffer_get_size(fb) < size) buffer_resize(fb, size);
	buffer_copy(rb, 0, size, fb, 0);
	buffer_seek(rb, buffer_seek_start, 0);
	//
	/// --- var rbpos = 0; // writing position in output buffer
	var start = 0; // start offset in input buffer
	var pos = 0; // reading position in input buffer
	var next; // number of bytes to be copied
	var need;
	var nest = 0;
	while (pos < size) {
	    var c = buffer_peek(fb, pos++, buffer_u8);
	    switch (c) {
	        case 9: case 10: case 13: case 32: // `\t\n\r `
	            buffer_write_slice(rb, fb, start, pos - 1);
	            // skip over trailing whitespace:
	            while (pos < size) {
	                switch (buffer_peek(fb, pos, buffer_u8)) {
	                    case 9: case 10: case 13: case 32: pos += 1; continue;
	                    // default -> break
	                } break;
	            }
	            start = pos;
	            break;
	        case 34: // `"`
	            while (pos < size) {
	                switch (buffer_peek(fb, pos++, buffer_u8)) {
	                    case 92: pos++; continue; // `\"`
	                    case 34: break; // `"` -> break
	                    default: continue; // else
	                } break;
	            }
	            break;
	        case ord("["): case ord("{"):
	            buffer_write_slice(rb, fb, start, pos);
	            // skip over trailing whitespace:
	            while (pos < size) {
	                switch (buffer_peek(fb, pos, buffer_u8)) {
	                    case 9: case 10: case 13: case 32: pos += 1; continue;
	                    // default -> break
	                } break;
	            }
	            // indent or contract `[]`/`{}`
	            c = buffer_peek(fb, pos, buffer_u8);
	            switch (c) {
	                case ord("]"): case ord("}"): // `[]` or `{}`
	                    buffer_write(rb, buffer_u8, c);
	                    pos += 1;
	                    break;
	                default: // `[\r\n\t
	                    buffer_write(rb, buffer_u16, 2573); // `\r\n`
	                    repeat (++nest) buffer_write(rb, buffer_u8, 9); // `\t`
	            }
	            start = pos;
	            break;
	        case ord("]"): case ord("}"):
	            buffer_write_slice(rb, fb, start, pos - 1);
	            buffer_write(rb, buffer_u16, 2573); // `\r\n`
	            repeat (--nest) buffer_write(rb, buffer_u8, 9); // `\t`
	            buffer_write(rb, buffer_u8, c);
	            start = pos;
	            break;
	        case ord(","):
	            buffer_write_slice(rb, fb, start, pos);
	            buffer_write(rb, buffer_u16, 2573); // `\r\n`
	            repeat (nest) buffer_write(rb, buffer_u8, 9); // `\t`
	            start = pos;
	            break;
	        case ord(":"):
	            if (buffer_peek(fb, pos, buffer_u8) != ord(" ")) {
	                buffer_write_slice(rb, fb, start, pos);
	                buffer_write(rb, buffer_u8, ord(" "));
	                start = pos;
	            } else pos += 1;
	            break;
	        default:
	            if (c >= ord("0") && c <= ord("9")) { // `0`..`9`
	                var pre = true; // whether reading pre-dot or not
	                var till = pos - 1; // index at which meaningful part of the number ends
	                while (pos < size) {
	                    c = buffer_peek(fb, pos, buffer_u8);
	                    if (c == ord(".")) {
	                        pre = false; // whether reading pre-dot or not
	                        pos += 1; // index at which meaningful part of the number ends
	                    } else if (c >= ord("0") && c <= ord("9")) {
	                        // write all pre-dot, and till the last non-zero after dot:
	                        if (pre || c != ord("0")) till = pos;
	                        pos += 1;
	                    } else break;
	                }
	                if (till < pos) { // flush if number can be shortened
	                    buffer_write_slice(rb, fb, start, till + 1);
	                    start = pos;
	                }
	            }
	    }
	}
	if (start == 0) return _json; // source string was unchanged
	buffer_write_slice(rb, fb, start, pos);
	buffer_write(rb, buffer_u8, 0); // terminating byte
	buffer_seek(rb, buffer_seek_start, 0);
	
	return buffer_read(rb, buffer_string);
}

function json_minify(_json) {
	/// json_minify(json_string)
	// initialization
	// in old versions of GMS, you'd have this ran separately instead.
	// in GMS2 it'd need to be @"..." instead of just "..."
	gml_pragma("global", "global.g_json_minify_fb = buffer_create(1024, buffer_fast, 1); global.g_json_minify_rb = buffer_create(1024, buffer_grow, 1);");
	
	var src = _json;
	// copy text to string buffer:
	var rb = global.g_json_minify_rb;
	buffer_seek(rb, buffer_seek_start, 0);
	buffer_write(rb, buffer_string, src);
	var size = buffer_tell(rb) - 1;
	// then copy it to "fast" input buffer for peeking:
	var fb = global.g_json_minify_fb;
	if (buffer_get_size(fb) < size) buffer_resize(fb, size);
	buffer_copy(rb, 0, size, fb, 0);
	//
	var rbpos = 0; // writing position in output buffer
	var start = 0; // start offset in input buffer
	var pos = 0; // reading position in input buffer
	var next; // number of bytes to be copied
	while (pos < size) {
	    var c = buffer_peek(fb, pos++, buffer_u8);
	    switch (c) {
	        case 9: case 10: case 13: case 32: // `\t\n\r `
	            // flush:
	            next = pos - 1 - start;
	            buffer_copy(fb, start, next, rb, rbpos);
	            rbpos += next;
	            // skip over trailing whitespace:
	            while (pos < size) {
	                switch (buffer_peek(fb, pos, buffer_u8)) {
	                    case 9: case 10: case 13: case 32: pos += 1; continue;
	                    // default -> break
	                } break;
	            }
	            start = pos;
	            break;
	        case 34: // `"`
	            while (pos < size) {
	                switch (buffer_peek(fb, pos++, buffer_u8)) {
	                    case 92: pos++; continue; // `\"`
	                    case 34: break; // `"` -> break
	                    default: continue; // else
	                } break;
	            }
	            break;
	        default:
	            if (c >= ord("0") && c <= ord("9")) { // `0`..`9`
	                var pre = true; // whether reading pre-dot or not
	                var till = pos - 1; // index at which meaningful part of the number ends
	                while (pos < size) {
	                    c = buffer_peek(fb, pos, buffer_u8);
	                    if (c == ord(".")) {
	                        pre = false; // whether reading pre-dot or not
	                        pos += 1; // index at which meaningful part of the number ends
	                    } else if (c >= ord("0") && c <= ord("9")) {
	                        // write all pre-dot, and till the last non-zero after dot:
	                        if (pre || c != ord("0")) till = pos;
	                        pos += 1;
	                    } else break;
	                }
	                if (till < pos) { // flush if number can be shortened
	                    next = till + 1 - start;
	                    buffer_copy(fb, start, next, rb, rbpos);
	                    rbpos += next;
	                    start = pos;
	                }
	            }
	    } // switch (c)
	} // while (pos < size)
	if (start == 0) return src; // source string was unchanged
	if (start < pos) { // flush if there's more data left
	    next = pos - start;
	    buffer_copy(fb, start, next, rb, rbpos);
	    rbpos += next;
	}
	buffer_poke(rb, rbpos, buffer_u8, 0); // terminating byte
	buffer_seek(rb, buffer_seek_start, 0);
	return buffer_read(rb, buffer_string);
}

function lag() {
	return game_get_speed(gamespeed_fps) * 0.000001 * delta_time;
}

function empty_function(){
	//really only use this if your code is dependant on a function being called
}

//this is very rarely used, but it essentially is just a point direction/distance loop which scans over points with no repeating numbers, great for use in a point_free_nearest function
// it's min max values are 0-10, so if using it you may wish to noomalize the output
#macro offset_loop = [{x:0,y:0},{x:1,y:0},{x:0,y:-1},{x:-1,y:0},{x:0,y:1},{x:1,y:-1},{x:-1,y:-1},{x:1,y:1},{x:-1,y:1},{x:2,y:0},{x:0,y:-2},{x:-2,y:0},{x:0,y:2},{x:1,y:2},{x:2,y:-1},{x:-1,y:-2},{x:-1,y:2},{x:-2,y:-1},{x:1,y:-2},{x:-2,y:1},{x:2,y:1},{x:-2,y:-2},{x:2,y:-2},{x:2,y:2},{x:-2,y:2},{x:3,y:0},{x:0,y:3},{x:-3,y:0},{x:0,y:-3},{x:-3,y:-1},{x:3,y:-1},{x:3,y:1},{x:-3,y:1},{x:1,y:-3},{x:1,y:3},{x:-1,y:3},{x:-1,y:-3},{x:-2,y:3},{x:3,y:-2},{x:-2,y:-3},{x:-3,y:-2},{x:2,y:-3},{x:3,y:2},{x:-3,y:2},{x:2,y:3},{x:4,y:0},{x:0,y:4},{x:-4,y:0},{x:0,y:-4},{x:1,y:-4},{x:4,y:-1},{x:3,y:-3},{x:-4,y:-1},{x:-4,y:1},{x:1,y:4},{x:-1,y:4},{x:4,y:1},{x:-1,y:-4},{x:-3,y:3},{x:3,y:3},{x:-3,y:-3},{x:-2,y:4},{x:4,y:-2},{x:-4,y:-2},{x:2,y:-4},{x:2,y:4},{x:-4,y:2},{x:4,y:2},{x:-2,y:-4},{x:4,y:3},{x:3,y:4},{x:-3,y:4},{x:-4,y:-3},{x:4,y:-3},{x:3,y:-4},{x:-4,y:3},{x:-3,y:-4},{x:5,y:0},{x:0,y:5},{x:-5,y:0},{x:0,y:-5},{x:5,y:1},{x:1,y:5},{x:-1,y:5},{x:-5,y:1},{x:-5,y:-1},{x:-1,y:-5},{x:5,y:-1},{x:1,y:-5},{x:5,y:2},{x:-2,y:-5},{x:2,y:5},{x:5,y:-2},{x:-5,y:-2},{x:-2,y:5},{x:-5,y:2},{x:2,y:-5},{x:-4,y:4},{x:-4,y:-4},{x:4,y:-4},{x:4,y:4},{x:3,y:5},{x:-5,y:3},{x:-5,y:-3},{x:5,y:-3},{x:-3,y:5},{x:-3,y:-5},{x:5,y:3},{x:3,y:-5},{x:6,y:0},{x:0,y:-6},{x:-6,y:0},{x:0,y:6},{x:1,y:-6},{x:6,y:1},{x:6,y:-1},{x:1,y:6},{x:-6,y:-1},{x:-1,y:6},{x:-1,y:-6},{x:-6,y:1},{x:-6,y:-2},{x:-2,y:-6},{x:6,y:2},{x:5,y:4},{x:-4,y:-5},{x:-6,y:2},{x:6,y:-2},{x:-5,y:4},{x:5,y:-4},{x:4,y:-5},{x:-4,y:5},{x:2,y:-6},{x:-2,y:6},{x:2,y:6},{x:-5,y:-4},{x:4,y:5},{x:-3,y:6},{x:-6,y:-3},{x:3,y:-6},{x:6,y:3},{x:6,y:-3},{x:3,y:6},{x:-6,y:3},{x:-3,y:-6},{x:5,y:-5},{x:5,y:5},{x:-5,y:-5},{x:-5,y:5},{x:7,y:0},{x:0,y:-7},{x:-7,y:0},{x:0,y:7},{x:1,y:-7},{x:-7,y:1},{x:7,y:1},{x:-1,y:-7},{x:-1,y:7},{x:7,y:-1},{x:-6,y:-4},{x:-7,y:-1},{x:-4,y:-6},{x:1,y:7},{x:4,y:-6},{x:-6,y:4},{x:-4,y:6},{x:4,y:6},{x:6,y:4},{x:6,y:-4},{x:2,y:-7},{x:2,y:7},{x:-7,y:2},{x:-7,y:-2},{x:7,y:-2},{x:-2,y:-7},{x:-2,y:7},{x:7,y:2},{x:7,y:-3},{x:7,y:3},{x:3,y:7},{x:-3,y:-7},{x:-7,y:3},{x:3,y:-7},{x:-3,y:7},{x:-7,y:-3},{x:-5,y:6},{x:6,y:5},{x:5,y:6},{x:6,y:-5},{x:-5,y:-6},{x:-6,y:5},{x:5,y:-6},{x:-6,y:-5},{x:4,y:7},{x:7,y:-4},{x:-7,y:4},{x:-4,y:7},{x:-4,y:-7},{x:7,y:4},{x:4,y:-7},{x:-7,y:-4},{x:8,y:0},{x:0,y:-8},{x:-8,y:0},{x:0,y:8},{x:-8,y:1},{x:-1,y:8},{x:-1,y:-8},{x:1,y:-8},{x:1,y:8},{x:8,y:-1},{x:8,y:1},{x:-8,y:-1},{x:-8,y:2},{x:2,y:-8},{x:8,y:-2},{x:2,y:8},{x:-2,y:8},{x:-8,y:-2},{x:8,y:2},{x:-2,y:-8},{x:6,y:6},{x:-6,y:6},{x:6,y:-6},{x:-6,y:-6},{x:-3,y:-8},{x:8,y:3},{x:-8,y:3},{x:3,y:-8},{x:-5,y:-7},{x:7,y:-5},{x:3,y:8},{x:7,y:5},{x:-7,y:5},{x:-8,y:-3},{x:-3,y:8},{x:8,y:-3},{x:-5,y:7},{x:-7,y:-5},{x:5,y:7},{x:5,y:-7},{x:-8,y:-4},{x:8,y:-4},{x:4,y:8},{x:4,y:-8},{x:-4,y:8},{x:-4,y:-8},{x:8,y:4},{x:-8,y:4},{x:9,y:0},{x:0,y:9},{x:-9,y:0},{x:0,y:-9},{x:-9,y:1},{x:-1,y:9},{x:1,y:9},{x:9,y:-1},{x:-9,y:-1},{x:9,y:1},{x:-1,y:-9},{x:1,y:-9},{x:6,y:-7},{x:-6,y:7},{x:7,y:6},{x:-6,y:-7},{x:-7,y:-6},{x:7,y:-6},{x:-7,y:6},{x:6,y:7},{x:-2,y:-9},{x:9,y:2},{x:-9,y:2},{x:2,y:-9},{x:9,y:-2},{x:2,y:9},{x:-2,y:9},{x:-9,y:-2},{x:-5,y:-8},{x:-5,y:8},{x:8,y:-5},{x:-8,y:-5},{x:5,y:-8},{x:8,y:5},{x:-8,y:5},{x:5,y:8},{x:3,y:-9},{x:-3,y:-9},{x:9,y:-3},{x:-3,y:9},{x:9,y:3},{x:3,y:9},{x:-9,y:-3},{x:-9,y:3},{x:4,y:-9},{x:-7,y:7},{x:4,y:9},{x:9,y:-4},{x:7,y:7},{x:-9,y:-4},{x:-9,y:4},{x:-4,y:9},{x:-4,y:-9},{x:9,y:4},{x:-7,y:-7},{x:7,y:-7},{x:-8,y:-6},{x:6,y:8},{x:-6,y:8},{x:8,y:6},{x:-6,y:-8},{x:8,y:-6},{x:6,y:-8},{x:-8,y:6},{x:10,y:0},{x:0,y:10},{x:-10,y:0},{x:0,y:-10},{x:-10,y:1},{x:-1,y:10},{x:10,y:1},{x:1,y:10},{x:-10,y:-1},{x:-1,y:-10},{x:1,y:-10},{x:10,y:-1},{x:10,y:2},{x:5,y:-9},{x:-9,y:-5},{x:-10,y:-2},{x:-10,y:2},{x:-9,y:5},{x:2,y:10},{x:9,y:-5},{x:-2,y:10},{x:10,y:-2},{x:2,y:-10},{x:5,y:9},{x:-5,y:9},{x:-2,y:-10},{x:9,y:5},{x:-5,y:-9},{x:10,y:3},{x:-3,y:-10},{x:-3,y:10},{x:-10,y:-3},{x:3,y:-10},{x:3,y:10},{x:10,y:-3},{x:-10,y:3},{x:-8,y:7},{x:7,y:8},{x:-8,y:-7},{x:8,y:-7},{x:-7,y:8},{x:8,y:7},{x:-7,y:-8},{x:10,y:0}]