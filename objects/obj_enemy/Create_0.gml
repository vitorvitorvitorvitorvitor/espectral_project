event_inherited();
move_spd = 1.20;
move_dir = 1;

state_walk = function(){

    sprite_index = spr_enemy;

    var ground = place_meeting(x, y + 1, obj_colisor);

    // Só anda se estiver no chão
    if (ground) {
        hspd = move_dir * move_spd;
        if (hspd != 0) x_scale = sign(hspd);
    } else {
        hspd = 0; // evita tremer no ar
    }

    // Se bater numa parede
    if (place_meeting(x + hspd, y, obj_colisor)) {
        move_dir *= -1;
        hspd = move_dir * move_spd;
    }

    // Se estiver chegando na beirada
    if (!place_meeting(x + (20 * move_dir), y + 1, obj_colisor)) {
        move_dir *= -1;
        hspd = move_dir * move_spd;
    }

    // >>> AQUI ESTAVA O PROBLEMA! <<<
    // Aplica o movimento
    x += hspd;
}

state = state_walk;
