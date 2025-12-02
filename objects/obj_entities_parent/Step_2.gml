repeat(abs(hspd)){
	
	if(place_meeting(x+sign(hspd),y,obj_colisor)){
		if(!place_meeting(x+sign(hspd),y-1,obj_colisor)){
			y--;	
		}
	}else{
		if(!place_meeting(x+sign(hspd),y+1,obj_colisor)){
			if(place_meeting(x+sign(hspd),y+2,obj_colisor)){
				y++;
			}
		}
	}
	
	if(place_meeting(x+sign(hspd),y,obj_colisor)){
		hspd = 0;
		break;
	}else{
		x+=sign(hspd);	
	}
}
repeat(abs(vspd)){
	if(place_meeting(x,y+sign(vspd),obj_colisor)){
		vspd = 0;
		break;
	}else{
		y+=sign(vspd);	
	}
}