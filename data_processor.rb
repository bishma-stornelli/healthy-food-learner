class DataProcessor
  
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
  # If can't take any output, it will return nil for each output
  # For example: +load_raw_data("data.csv", 3, 80) == load_raw_data("data.csv", 3, 2)+
  def self.load_raw_data(file_path, features, outputs)
    f = []
    o = []
    File.open(file_path, "r") do |infile|
      while (line = infile.gets)
        tmp = line.split(";")
        tmp.map!{|e| e.chomp.strip }
        f << tmp[0, features]
        o << (features >= tmp.size || outputs <= 0 ? [nil] : tmp[features, outputs])
      end
    end
    [f, o]
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
  # WARNING: raw_data is changed, i.e. it modifies the input data
  def self.treat_missing_values!(raw_data)
    raw_data.each_with_index do | val, i |
      val.each_with_index do | item, j |
        if item == 0
          array = Array.new()
          raw_data.each do |variable|
            array << variable[j]
          end
          array = array.compact
          mean = 0
          if array.length != 0
            mean = array.reduce(:+) / array.length.to_f
          end
          raw_data[i][j] = mean
        end
      end
    end
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
  # WARNING: raw_data is changed, i.e. it modify the input data
  def self.map_raw_data!(raw_data, mapper)
    
  end
  
  # Divide +features+ in 2 sets of size +features.size * ratio+ and
  # +features.size * (1 - ratio)+. The division is made according to 
  # +method+:
  #   * +:random+: Split data randomly
  #   * +:uniformly+: Split data randomly but taking +outputs.size * ratio / n+
  #     elements for each classification where +n+ is the number of different
  #     elements in +outputs+ (the number of classes)
  #
  # Return an array of two elements where first element is an
  # array of +features.size * ratio+ features and the second element are
  # the corresponding outputs (taken from +features+ and +outputs+).
  # WARNING: Elements selected are deleted from features and outputs
  def self.split_examples!(features, outputs, ratio, method = :random)
    features2 = []
    outputs2 = []
    n = (features.size*ratio).round
    m = features.size - n
    case method
    when :random
      n.times do
        i = rand features.size
        features2 << features.delete_at(i)
        outputs2 << outputs.delete_at(i)
      end # After this, all elements not selected will be in set2
    when :uniformly
      classes = outputs.uniq
      max_elems_by_class = [(n / classes.size.to_f).round, 1].max
      elems_in_each_class = Array.new classes.size, 0
      if classes.any?{|c| outputs.count(c) < max_elems_by_class}
        raise "Can't return a balanced set" and return
      end
      n.times do
        i = rand outputs.size
        class_selected = classes.index(outputs[i])
        redo if elems_in_each_class[class_selected] >= max_elems_by_class
        features2 << features.delete_at(i)
        outputs2 << outputs.delete_at(i)
        elems_in_each_class[class_selected] += 1
      end
    else
      raise "Incorrect method"
    end
    [features2, outputs2]
  end
end