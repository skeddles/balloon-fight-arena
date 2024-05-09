var cooldowns = {}

func ifCool(cooldownName, cooldownFrequency, executeFunction:Callable):
	if not cooldownName in cooldowns: cooldowns[cooldownName] = 0
	if Time.get_ticks_msec() - cooldowns[cooldownName] > cooldownFrequency: 
		cooldowns[cooldownName] = Time.get_ticks_msec()
		executeFunction.call()

func setCooldown(cooldownName, cooldownLength):
	if not cooldownName in cooldowns: cooldowns[cooldownName] = 0
	cooldowns[cooldownName] = Time.get_ticks_msec() + cooldownLength
	
