if(image_index == 0)
{
	image_index = 1;
	if(instance_exists(obj_door))
	{
		with(obj_door)
		{
			if(ativar == other.ativar)
			{
				ativo = true;
			}
		}
	}
}