/// @function player_state_free()
function player_state_free()
{
    event_inherited();

    // -------------------------------------------------------------
    // ENTRADA
    // -------------------------------------------------------------
    var left   = keyboard_check(ord("A"));
    var right  = keyboard_check(ord("D"));
    var jump_p = keyboard_check_pressed(vk_space);
    var jump_r = keyboard_check_released(vk_space);
    var dash_p = keyboard_check_pressed(vk_lcontrol);

    // -------------------------------------------------------------
    // GARANTIAS / COOLDOWNS
    // -------------------------------------------------------------
    if (!variable_instance_exists(self, "deslizando")) deslizando = false;
    if (!variable_instance_exists(self, "dash_distance_default")) dash_distance_default = dash_distance;
    if (!variable_instance_exists(self, "dash_distance_remaining")) dash_distance_remaining = dash_distance_default;
    if (!variable_instance_exists(self, "dash_time")) dash_time = 0;

    // decrementa cooldown do dash (se houver)
    if (dash_time > 0) dash_time -= 1;

    // -------------------------------------------------------------
    // CHECAGENS
    // -------------------------------------------------------------
    var chao = place_meeting(x, y + 1, obj_colisor);
    // definir parede_dir e parede_esq cedo (evita erro de leitura)
    var parede_dir = place_meeting(x + 1, y, obj_colisor);
    var parede_esq = place_meeting(x - 1, y, obj_colisor);
    var pressionando_dir = parede_dir && right;
    var pressionando_esq = parede_esq && left;

    // -------------------------------------------------------------
    // MOVIMENTO HORIZONTAL
    // -------------------------------------------------------------
    var dir_input = right - left;
    move_dir = dir_input;

    if (dir_input != 0)
        move_spd = clamp(move_spd + acc, 0, move_spd_max);
    else
        move_spd = max(move_spd - dcc, 0);

    hspd = move_spd * dir_input;

    if (hspd != 0)
        x_scale = sign(hspd);

    sprite_index = (hspd != 0) ? spr_player_run : spr_player_idle;

    // -------------------------------------------------------------
    // GRAVIDADE E PULO
    // -------------------------------------------------------------
    if (!chao)
    {
        coyote_time -= 1;
        vspd += grv;

        if (jump_r && vspd < 0)
            vspd *= 0.4;

        sprite_index = (vspd < 0) ? spr_player_jump : spr_player_fall;
    }
    else
    {
        coyote_time = coyote_time_max;

        // reseta dash ao tocar no chão
        dash = true;
        dash_time = 0;
        dash_distance_remaining = dash_distance_default;
    }

    // pulo normal (inclui wall-jump quando deslizando)
	// --- PULO NORMAL NO CHÃO ---
	if (jump_p && chao)
	{
	    vspd = -jump_height;
	    deslizando = false;
	}
	
	// --- WALL JUMP (DESLIZANDO) ---
	if (jump_p && deslizando)
	{
	    vspd = -jump_height;

	    var away = (parede_esq ? 1 : 0) - (parede_dir ? 1 : 0);
	    if (away == 0) away = (right - left);

	    var extra = move_spd_max * 2.2;
	    hspd = away * extra;

	    move_spd = abs(hspd);
	    x_scale = sign(hspd);

	    deslizando = false;
	    wall_jump_lock = 6; // opcional para não perder impulso
	}

    vspd = clamp(vspd, vspd_min, vspd_max);

    // -------------------------------------------------------------
    // COLISÃO HORIZONTAL (subpixel)
    // -------------------------------------------------------------
    var steps_x = ceil(abs(hspd));
    var step_x = hspd / max(steps_x, 1);

    repeat (steps_x)
    {
        if (!place_meeting(x + step_x, y, obj_colisor))
            x += step_x;
        else
        {
            while (!place_meeting(x + sign(step_x) * 0.1, y, obj_colisor))
                x += sign(step_x) * 0.1;
            hspd = 0;
            break;
        }
    }

    // -------------------------------------------------------------
    // COLISÃO VERTICAL (subpixel)
    // -------------------------------------------------------------
    var steps_y = ceil(abs(vspd));
    var step_y = vspd / max(steps_y, 1);

    repeat (steps_y)
    {
        if (!place_meeting(x, y + step_y, obj_colisor))
            y += step_y;
        else
        {
            while (!place_meeting(x, y + sign(step_y) * 0.1, obj_colisor))
                y += sign(step_y) * 0.1;
            vspd = 0;
            break;
        }
    }

    // -------------------------------------------------------------
    // SLIDE NA PAREDE (entra em slide se estiver pressionando contra a parede e caindo)
    // -------------------------------------------------------------
    if (!chao)
    {
        if ((pressionando_dir || pressionando_esq) && vspd > 0)
            deslizando = true;

        if (deslizando && (parede_dir || parede_esq))
        {
            sprite_index = spr_player_wall;
            // controla a velocidade de descida durante slide
            vspd = min(vspd, 1.2);

            // reseta dash ao deslizar (permite dash enquanto desliza)
            dash = true;
            dash_time = 0;
            dash_distance_remaining = dash_distance_default;

            coyote_time = coyote_time_max;
        }
        else
            deslizando = false;
    }
    else
        deslizando = false;

    // -------------------------------------------------------------
    // WALL JUMP (comportamento padrão quando NÃO está deslizando)
    // -------------------------------------------------------------
    if (coyote_time > 0 && jump_p && !chao && state != player_state_dash && !deslizando)
    {
        vspd = -jump_height;
        var impulse = (parede_esq ? 1 : 0) - (parede_dir ? 1 : 0);
        impulse *= move_spd_max * 1.8;

        if (!parede_dir && !parede_esq)
            impulse = (right - left) * move_spd_max * 2.0;

        hspd = impulse;
        move_spd = abs(impulse);
        x_scale = sign(hspd);
    }

    // -------------------------------------------------------------
    // DASH (inicia dash se puder)
    // -------------------------------------------------------------
    if (dash_p && dash && dash_time <= 0)
    {
        // inicia dash e evita spam imediato
        dash = false;
        dash_time = dash_delay;

        // cria contador local por instância para a distância do dash
        dash_distance_remaining = dash_distance_default;

        // se estiver deslizando, direciona o dash para longe da parede automaticamente
        if (deslizando)
        {
            if (parede_dir) x_scale = -1; // parede à direita -> olhar esquerda
            else if (parede_esq) x_scale = 1; // parede à esquerda -> olhar direita
        }

        state = player_state_dash;
        sprite_index = spr_player_dash;
        exit;
    }
		//Colidindo com o inimigo
	if(!chao and vspd > 0){
		var collision_e = instance_place(x,y+1,obj_spike);
		if(collision_e){
			vspd = 0;
			vspd-=jump_height;
		}
	}
	
	//Tomando dano do inimigo
	var spikes = instance_place(x+hspd,y,obj_spike);
	
	if(spikes){
		hspd = 0;
		vspd-=5;
		damage_dir = point_direction(spikes.x,spikes.y,x,y);
		life-=1;
		state = player_state_damage;
	}
	
			//Colidindo com o inimigo
	if(!chao and vspd > 0){
		var collision_e = instance_place(x,y+1,obj_enemy_parent);
		if(collision_e){
			vspd = 0;
			vspd-=jump_height;
			instance_destroy(collision_e.id);
		}
	}
	
	//Tomando dano do inimigo
	var enemy = instance_place(x+hspd,y,obj_enemy);
	
	if(enemy){
		hspd= 0;
		vspd-=5;
		damage_dir = point_direction(enemy.x,enemy.y,x,y);
		life-=1;
		state = player_state_damage;
	}
}

/// @function player_state_dash()
function player_state_dash()
{
    // garante variáveis por instância
    if (!variable_instance_exists(self, "dash_distance_remaining")) dash_distance_remaining = dash_distance_default;
    if (!variable_instance_exists(self, "dash_time")) dash_time = dash_delay;

    // calcula deslocamento por frame a partir da direção atual (x_scale)
    var dir_angle = (x_scale >= 0) ? 0 : 180;
    var hx = lengthdir_x(dash_force, dir_angle);
    var vy = lengthdir_y(dash_force, dir_angle);

    var bateu_h = false;
    var bateu_v = false;

    // colisão horizontal
    if (place_meeting(x + hx, y, obj_colisor))
    {
        while (!place_meeting(x + sign(hx) * 0.1, y, obj_colisor))
            x += sign(hx) * 0.1;
        hx = 0;
        bateu_h = true;
    }
    x += hx;

    // colisão vertical
    if (place_meeting(x, y + vy, obj_colisor))
    {
        while (!place_meeting(x, y + sign(vy) * 0.1, obj_colisor))
            y += sign(vy) * 0.1;
        vy = 0;
        bateu_v = true;
    }
    y += vy;

    // consome distância do dash (por instância)
    dash_distance_remaining -= 1;

    // se bateu horizontalmente contra uma parede durante o dash -> entra em deslize
    if (bateu_h)
    {
        // determina qual parede encostou (olhando left/right)
        var parede_dir = place_meeting(x + 1, y, obj_colisor);
        var parede_esq = place_meeting(x - 1, y, obj_colisor);

        // entra em deslize automaticamente
        deslizando = true;
        dash = true; // reseta dash para permitir novo dash enquanto desliza
        dash_time = 0;
        dash_distance_remaining = dash_distance_default;

        // posiciona o player exatamente encostado na parede já feito; agora volta ao estado livre como deslizando
        state = player_state_free;
        vspd = 0;
        hspd = 0;
        return; // sai da função para processar comportamento de slide no state_free
    }

    // fim do dash por colisão vertical ou distância
    if (bateu_v || dash_distance_remaining <= 0)
    {
        dash_distance_remaining = dash_distance_default;
        dash_time = 0;

        // ao terminar dash sem bater horizontalmente, volta ao estado livre
        state = player_state_free;
        vspd = 0;
        hspd = 0;
        return;
    }

    // decrementa dash_time enquanto em dash (caso seja usado como cooldown)
    if (dash_time > 0) dash_time -= 1;
}

function player_state_damage(){
	hspd = lengthdir_x(damage_recoil,damage_dir);
	
	damage_time = approach(damage_time,damage_distance,.1);
	sprite_index = spr_player_dano;
	
	if(damage_time >= damage_distance){
		damage_time = 0;
		hspd = 0;
		state = player_state_free;
	}
}

