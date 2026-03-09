event_user(15);

window_set_size(900, 900);
window_center();

simulation = new CanvasSandShader();

fps_window = 60;
fps_buffer = array_create(fps_window, 60);
frame_index = 0;
below_60 = false;
drop_timer = 0;
frame_count = 0;

step_times = array_create(fps_window, 0);
draw_times = array_create(fps_window, 0);

ui_init();