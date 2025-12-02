event_inherited();

can_move = 0;
move_spd = 0;
move_spd_max = 3.2;   // vel → equivalente
acc = 0.3;
dcc = 0.3;

jump_height = 10;     // pulo → equivalente
coyote_time_max = 6;  // coyote_timer → equivalente
coyote_time = 0;

dash = true;
dash_delay = 30;
dash_force = 8;      // dash_force novo
dash_time = 0;
dash_distance = 15;   // dash_distance novo

damage_dir = 0;
damage_recoil = 8;
damage_time = 0;
damage_distance = 10;

life_max = 5;
life = life_max;

state = player_state_free;
