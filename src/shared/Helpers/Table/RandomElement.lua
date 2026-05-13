return function(weights: { [any]: number }): any
	local totalWeight = 0
	for _, weight in weights do
		totalWeight = totalWeight + weight
	end
	local randomNumber = math.random() * totalWeight
	local selectedOption
	for option, weight in weights do
		randomNumber = randomNumber - weight
		if randomNumber <= 0 then
			selectedOption = option
			break
		end
	end
	return selectedOption
end