var cooldowns = {}

func ifCool(cooldownName, cooldownFrequency, executeFunction:Callable):
	if not cooldownName in cooldowns: cooldowns[cooldownName] = 0
	
	if Time.get_ticks_msec() - cooldowns[cooldownName] > cooldownFrequency: 
		executeFunction.call()
		cooldowns[cooldownName] = Time.get_ticks_msec()
