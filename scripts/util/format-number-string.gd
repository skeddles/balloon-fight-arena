var threeCharLong = RegEx.new()
func _init(): threeCharLong.compile(".{1,3}")

func format(number):
	var reversed_str = str(number).reverse() # convert it to a backwards string
	var matches = threeCharLong.search_all(reversed_str) # split into groups up to 3 in length
	var matches_str = matches.map(func (m): return m.get_string()) # convert to array of strings
	return ",".join(matches_str).reverse() #join into csv string, reverse again
