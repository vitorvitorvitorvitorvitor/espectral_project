function ui()
{
	global.inimigos_restantes = instance_number(obj_enemy);
	if(global.inimigos_restantes == 0)
	{
		room_goto(rm_win);
	}
}
