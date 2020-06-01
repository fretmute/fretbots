function randomDecimal(low, high)
  local percentage = math.random()
  local range = high - low
  local scaled = range * percentage
  return scaled + low
end

math.randomseed( os.time() )

for i = 1, 20 do
  print(randomDecimal(1,3))
end