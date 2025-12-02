if (instance_exists(obj_player)) {

    var player = obj_player; // referência ao player

    // Movimento orbital
    angle += rot_speed;

    // Altura média acima do player
    var hover_offset = -12; // negativo = acima
    
    // Alvo orbital com flutuação
    var ideal_x = player.x + lengthdir_x(dist, angle);
    var ideal_y = player.y + hover_offset
                  + sin(current_time * float_speed) * float_height;

    // Suaviza o alvo (evita microtremores)
    if (!variable_global_exists("lamp_target_x")) {
        global.lamp_target_x = x;
        global.lamp_target_y = y;
    }

    global.lamp_target_x = lerp(global.lamp_target_x, ideal_x, 0.1);
    global.lamp_target_y = lerp(global.lamp_target_y, ideal_y, 0.1);

    var target_x = global.lamp_target_x;
    var target_y = global.lamp_target_y;

    var move_x = target_x - x;
    var move_y = target_y - y;

    // ---------------------------
    // 🧭 EVITAÇÃO SUAVE DE OBSTÁCULOS
    // ---------------------------
    var avoid_vec_x = 0;
    var avoid_vec_y = 0;
    var avoid_count = 0;
    var check_dist = 10; // raio de detecção (um pouco maior ajuda a prever)

    for (var i = 0; i < 360; i += 45) {
        var check_x = x + lengthdir_x(check_dist, i);
        var check_y = y + lengthdir_y(check_dist, i);

        if (position_meeting(check_x, check_y, obj_colisor)) {
            avoid_vec_x += lengthdir_x(1, i + 180);
            avoid_vec_y += lengthdir_y(1, i + 180);
            avoid_count++;
        }
    }

    if (avoid_count > 0) {
        avoid_vec_x /= avoid_count;
        avoid_vec_y /= avoid_count;

        // Amortece a força de evitação (evita "chacoalhar")
        target_x += avoid_vec_x * 5;
        target_y += avoid_vec_y * 5;
    }

    // Movimento suave até o alvo final
    x = lerp(x, target_x, 0.07);
    y = lerp(y, target_y, 0.07);

    // ---------------------------
    // 📏 INCLINAÇÃO (TILT)
    // ---------------------------
    var dir_x = sign(move_x);

    if (dir_x != 0)
    { 
		image_angle = lerp(image_angle, dir_x * -10, 0.02);
	}
    // ---------------------------
    // 🔽 PROFUNDIDADE
    // ---------------------------
    if (sin(degtorad(angle)) > 0) {
        depth = player.depth + 1;
    } else {
        depth = player.depth - 1;
    }
}
