require 'rubygems'
require 'knn'

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
  #   * +:zero+: Replace missing values with 0.0
  #
  # => returns an array which first element is the modified data and the
  #    second element is an array of +methods.size+ elements and the value
  #    of each element will depend on the value of +methods+. For example:
  #      +data, info = treat_missing_values(raw_data, [nil, :mean, :mode, :zero])+
  #      +info[0] # nil+
  #      +info[1] # mean of column 1 of raw_data+
  #      +info[2] # mode of column 2 of raw_data+
  #      +info[3] # 0.0+
  # WARNING: raw_data is changed, i.e. it modifies the input data
  def self.treat_missing_values!(raw_data, methods = nil)
    return [[],[]] if raw_data.empty?
    
    methods ||= Array.new(raw_data.first.size)
    info = Array.new raw_data.first.size
    
    raw_data.each_with_index do | val, i |
      val.each_with_index do | item, j |
        
        case methods[j]
        when nil
          info[j] ||= nil
        when :mean
          if info[j].nil?
            no_missing_values = raw_data.map{|row| row[j] }.compact
            info[j] = no_missing_values.reduce(0.0, :+) / no_missing_values.size
          end
        when :zero
          info[j] = 0.0
        end
        
        raw_data[i][j] = info[j] if item.nil?
      end
    end
    
    [raw_data, info]
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

  # Balance data for the learning machine 
  # dth la proporcion que podemos tolerar de la clase minoritaria (1 => 1:1)
  def self.balance_data!(raw_data, outputs, dth = 1.0, beta = 1.0, k = 10)
    #k ||= (raw_data.size * 0.1).round
    #puts "Se buscaran #{k} vecinos"
    ms = Array.new()
    ml = Array.new()

    raw_data.each_with_index do |variable, i|
      if outputs[i] == [0]
        #puts "Ejemplo #{i} es min"
        ms << variable
      else
        #puts "Ejemplo #{i} es MAY"
        ml << variable
      end
    end

    knn = KNN.new raw_data

    d = ms.length.to_f / ml.length.to_f
    #puts "Hay #{d}% ejemplos mayoritarios"
    
    if d < dth

      gm = (ml.length - ms.length) * beta
      
      #puts "Se tienen que generar #{gm} ejemplos minoritarios"
      
      r = Array.new()
      neighbours = Array.new ms.size
      ms.each_with_index do |example, i|
        neighbours[i] = knn.nearest_neighbours(example, k + 1) 
        neighbours[i].delete_at 0 # example is inside the set so the closest element will be itself.
        #puts "Neighbours of #{i} are: #{neighbours[i].inspect}"
        number_of_neighbours_in_majority = neighbours[i].count do |neighbour|
          outputs[neighbour.first] != [0]
        end
        #puts "There are #{number_of_neighbours_in_majority} neighbours positive in neighborhood of example #{i}"
        r << number_of_neighbours_in_majority / k.to_f
      end
      
      #puts "Los ri antes de normalizar son: #{r.inspect}"

      sum = r.reduce(0.0, :+)
      
      r.map! { |a| a / sum }
      
      #puts "Y despues son: #{r.inspect}"
      
      g = Array.new()

      r.each do |variable|
        g << (variable * gm).round
      end

      #puts "Los g son: #{g.inspect}"
      
      new_data = Array.new()

      ms.each_with_index do |variable, i|
        #puts "A partir del ejemplo #{i} minoritario se van a generar #{g[i]} ejemplos mas" if g[i] > 0
        g[i].times do
          lambda = rand
          xzi = neighbours[i].sample[2]
          #puts "El vecino elegido es:"
          tmp = 0
          si = variable.each_with_index.map {|f, j| f + (xzi[j] - f) * lambda}
          raw_data << si
          outputs << [0]
        end
      end
    end
  end

  # Balance data for the learning machine 
  def self.balance_data_oversampling!(raw_data, outputs)

    ms = Array.new()
    ml = Array.new()

    raw_data.each_with_index do |variable,i|
      if outputs[i] == [0.0]
        ms << variable
      else
        ml << variable
      end
    end

    new_data = Array.new()
    new_outputs = Array.new()

    if ms.length == 0
      return
    end

    while new_data.length + ms.length < ml.length
      new_data.concat(ms)
    end

    if new_data.length < ml.length
      new_data.concat(ms.take(ml.length - new_data.length))
    end

    new_outputs = Array.new(new_data.length) { [0.0] }

    raw_data.concat(new_data)

    outputs.concat(new_outputs)

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