module DataProcessor
  
  # Read all lines of csv file +file_path+ and take +features+
  # columns as the features of the data and +outputs+ columns
  # after +features+ columns as the outputs of the data.
  #
  # => Return an array where first element is an array with the features
  #    and second element is an array with the outputs.
  #
  # For example. If file data.csv is:
  #   1,5,2,5,6
  #   4,3,4,6,4
  #   2,4,7,4,8
  #
  # Then +load_raw_data("data.csv", 3, 2)+ will return
  #   [
  #     [
  #       [1,5,2],
  #       [4,3,4],
  #       [2,4,7]
  #     ],
  #     [
  #       [5,6],
  #       [6,4],
  #       [4,8]
  #     ]
  #   ]
  #
  # If +features+ + +outputs+ is greater than the file columns,
  # it will take as many features as it can and as many outputs as it can.
  # For example: +load_raw_data("data.csv", 3, 80) == load_raw_data("data.csv", 3, 2)+
  def load_raw_data(file_path, features, outputs)
    
  end
  
  # If raw_data can have missing values, this method can be used
  # to estimate these.
  # +raw_data+ must be an array such that 
  # +raw_data.all?{|d| d.size == methods.size }+
  #
  # It will apply +methods[j]+ to all +raw_data[i][j]+ when
  # +raw_data[i][j] == nil+.
  # +methods[j]+ can be:
  #   * +nil+: Do nothing with column +j+
  #   * +:mean+: Replace missing values with the mean for that column
  #   * +:mode+: Replace missing values with the mode for that column
  #
  # => returns an array which first element is the modified data and the
  #    second element is an array of +methods.size+ elements and the value
  #    of each element will depend on the value of +methods+. For example:
  #      +data, info = treat_missing_values(raw_data, [nil, :mean, :mode])+
  #      +info[0] # nil+
  #      +info[1] # mean of column 1 of raw_data+
  #      +info[2] # mode of column 2 of raw_data+
  def treat_missing_values(raw_data, methods)
    
  end
  
  # Process the data in +raw_data+ using +mapper+.
  # +raw_data+ must be an array such that 
  # +raw_data.all?{|d| d.size == mapper.size }+
  # 
  # It will map element +raw_data[i][j]+ according to
  # +mapper[j]+. +mapper[j]+ can be:
  #   * +Hash+: +raw_data[i][j] = mapper[j][raw_data[i][j]] || raw_data[i][j]+
  #   * +Fixnum+: Assume that +raw_data[i][j]+ is a continuous variable
  #     and divide it in +mapper[j]+ classes
  #   * +nil+: Do not map +raw_data[i][j]+
  # => 
  def map_raw_data(raw_data, mapper)
    
  end
  
  # Divide +data+ in 2 sets of size +data.size * ratio+ and
  # +data.size * (1 - ratio)+. The division is made according to 
  # +method+:
  #   * +:random+: Split data randomly
  #   * +:uniformly+: Split data randomly but taking +data.size * ratio / n+
  #     elements for each classification where +n+ is the number of classes.
  #
  # Return an array of two elements where first element is an
  # array with +data.size * ratio+ elements taken from +data+ and 
  # the second element is an array with +data.size * (1 - ratio)+ taken
  # from +data+.
  def split_examples(data, ratio, method = :random)
    
  end
end