//checando se surface existe
if (!surface_exists(surf))
{
	surf = surface_create(room_width, room_height);
}

else
{
	surface_set_target(surf);
	draw_clear_alpha(c_black, .7);

	
	gpu_set_blendmode(bm_subtract);
	
	with(obj_light)
	{
		var _valor = random_range(-.07, .07);
		draw_sprite_ext(sprite_index, image_index, x, y, image_xscale + _valor, image_yscale + _valor, image_angle, c_white, 1)
	}
	//criando a luz do player
	with(obj_lamp)
	{
		
		draw_sprite_ext(spr_light, 0, x - 255 , y - 265, 4, 4, 0, c_blue, 5);
	}
	
	gpu_set_blendmode(bm_normal);
	
	surface_reset_target();
	draw_surface(surf, 0, 0);
}