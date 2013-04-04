require 'rubygems'
require 'knn'

data = Array.new(100000) { Array.new(4) { rand } }

knn = KNN.new(data)

knn.nearest_neighbours([1,2,3,4], 4)  # ([data], k's)
  #=> [[4837, 7.43033158269445, [0.966558570073977, 0.903158898673566, 0.954567901514261, 0.988114355901207]], ...

# Data is returned in the format
# [data index, distance to the input, [data points]]

# So if we called queried the data array for 4837...
data[4837]
  #=> [0.966558570073977, 0.903158898673566, 0.954567901514261, 0.988114355901207]