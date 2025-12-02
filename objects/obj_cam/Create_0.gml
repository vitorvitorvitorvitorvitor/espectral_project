#region definindo alvo da camera
//alvo
global.cam_alvo = obj_player;
#endregion
#region tamanho, posição e visão da camera
//tamanho da camera
global.cam_w	= camera_get_view_width(view_camera[0]);
global.cam_h	= camera_get_view_height(view_camera[0]);

//posição da camera
global.cam_x	= global.cam_alvo.x;
global.cam_y	= global.cam_alvo.y;


//limitando visão da camera
global.cam_x_min	= 0;
global.cam_x_max	= room_width - global.cam_w;
global.cam_y_min	= 0;
global.cam_y_max	= room_height - global.cam_h;


cam_x_min_lerp	= 0;
cam_x_max_lerp	= room_width - global.cam_w;
cam_y_min_lerp	= 0;
cam_y_max_lerp	= room_height - global.cam_h;
#endregion
#region definindo posição inicial da camera
var _room = instance_position(global.cam_alvo.x, global.cam_alvo.y, obj_room);

if(_room)
{
	global.cam_x_min = _room.x;
	global.cam_x_max = _room.x + (global.cam_w * _room.image_xscale) - global.cam_w;
	global.cam_y_min = _room.y;
	global.cam_y_max = _room.y + (global.cam_h * _room.image_yscale) - global.cam_h;
}
else
{
	global.cam_x_min	= 0;
	global.cam_x_max	= room_width - global.cam_w;
	global.cam_y_min	= 0;
	global.cam_y_max	= room_height - global.cam_h;
}

cam_x_min_lerp = global.cam_x_min;
cam_x_max_lerp = global.cam_x_max;
cam_y_min_lerp = global.cam_y_min;
cam_y_max_lerp =  global.cam_y_max;
#endregion
