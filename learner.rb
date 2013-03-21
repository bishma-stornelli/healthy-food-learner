# Uso de la clase:
#   1. l = Learner.new n_features, n_hidden, learning_rate
#   2. l.load_training_examples(file_path, output_map)
#   3. (Opcional) l.load_testing_examples(file_path, output_map) 
#   4. (Opcional) (Warning: override testing examples) l.split_examples(percentage)
#   5. l.train
#   6. l.error(l.testing_examples, l.testing_outputs)

class Learner
  
  # Detalles de implementacion:
  #   n_features (Fixnum): numero de neuronas de entrada
  #   n_hidden (Fixnum): numero de neuronas ocultas
  #   learning_rate (Float): tasa de aprendizaje
  #   weights (Array[Array[Float]]): pesos de la red. weights[i][j] contiene el 
  #     peso desde la neurona j a la i (NOTE QUE ESTA INVERSO)
  #   training_examples (Array[Float]): conjunto de datos usados como entrenamiento
  #   testing_examples (Array[Float]): conjunto de datos usado como prueba
  #   training_outputs (Array[Fixnum]): conjunto de salidas de entrenamiento. 
  #     Posicion i corresponde a salida de training_examples[i]
  #   testing_outputs (Array[Fixnum]): conjunto de salidas de prueba. 
  #     Posicion i corresponde a salida de testing_examples[i]
  #   input_neurons (Array[Fixnum]): vector que contiene los ids de las neuronas
  #     de entrada (e.g.: [0, 1, 2, 3] para n_features = 4
  #   hidden_neurons (Array[Fixnum]): vector que contiene los ids de las neuronas
  #     en la capa oculta (e.g.: [4, 5, 6] para n_features = 4 y n_hidden = 3)
  #   output_neurons (Array[Fixnum]): vector que contiene los ids de las neuronas
  #     en la capa de salida (por ahora solo es una neurona de salida y su valor sera [n_features + n_hidden])
  attr_reader :training_examples, :training_outputs,
    :testing_examples, :testing_outputs,
    :n_features, :n_hidden, :weights,
    :input_neurons, :hidden_neurons, :output_neurons
  attr_accessor :learning_rate, :max_iterations, :error_tolerance
  def initialize(n_features, n_hidden, learning_rate = 0.1, max_iterations = 1000, error_tolerance = 0.01)
    @n_features = n_features + 1
    @n_hidden = n_hidden + 1
    @learning_rate = learning_rate
    @weights = []
    @training_examples = []
    @testing_examples = []
    @raw_examples = []
    @training_outputs = []
    @testing_outputs = []
    @raw_outputs = []
    @input_neurons = Array.new(@n_features){ |i| i }
    @hidden_neurons = Array.new(@n_hidden){ |i| @n_features + i }
    @output_neurons = [@n_features + @n_hidden]
    @max_iterations = max_iterations
    @error_tolerance = error_tolerance
  end

  # Split the training_examples in 2 sets, storing raw_examples.size * percentage
  # in training_examples and the rest in testing_examples
  # The split might be done in three ways (pick one):
  #    randomly (medium good)
  #    first raw_examples.size * percentage elements (poor)
  #    randomly and uniformly (half classified 0 and half classified 1) (good)
  # param percentage is a float between 0 and 1
  def split_examples(percentage)
    @testing_examples = []
    @testing_outputs = []
    n = (@training_examples.size*percentage).round
    n.times do
      i = rand @training_examples.size
      @testing_examples << @training_examples.delete_at(i)
      @testing_outputs << @training_outputs.delete_at(i)
    end
  end

  def train
    @weights = initialize_weights
    report = []

    iteration = 0
    
    e = Float::INFINITY
    past_e = e

    while (e > @error_tolerance && iteration < @max_iterations) do
      e = 0
      correct = 0
      @training_examples.each_with_index do |ei, i|
        lambdas = Array.new
        
        o = evaluate(ei)
        correct += 1 if o.last.round == @training_outputs[i]

        for k in @output_neurons do
          lambdas[k] = o[k] * (1 - o[k] ) * (@training_outputs[i] - o[k] )        
        end 

        for h in @hidden_neurons do
          lambdas[h] = o[h] * (1 - o[h]) * @output_neurons.inject(0) {|acc, k| acc + @weights[k][h] * lambdas[k]}
        end
        
        e += ((@training_outputs[i] - o.last)**2) / @training_outputs.size

        update_weights(lambdas, o)
      end
      #puts "#{past_e} - #{e} = #{(past_e - e).abs}"
      #if (past_e - e).abs <= 0.000000001
      #  return
      #end
      past_e = e
      report << [iteration, e]
      #sleep 0.2
      if iteration % 100 == 0
        puts "> #{iteration}, Correct = #{correct}/#{@training_outputs.size}"
      end
      
      iteration += 1
    end
    report
  end

  # Evaluate the input example with the current weights and
  # returns an array such that o[k] is the output for neuron k
  # o tiene que tener las posiciones definidas para las neuronas de entrada tambien (TODAS)
  def evaluate(example)
    outs = example.dup    
    
    @hidden_neurons.each do |h|
      tmp = 0
      @input_neurons.each do |i|
        tmp = tmp + @weights[h][i] * outs[i]
      end
      outs[h] = sig(tmp)
    end

    @output_neurons.each do |o|
      tmp = 0
      @hidden_neurons.each do |h|
        tmp = tmp + @weights[o][h] * outs[h]
      end
      outs[o] = sig(tmp)
    end
    outs
  end

  def sig(x)
    1.0 / (1.0 + Math.exp(-x))
  end

  # Calculate the error in examples with respect to the expected
  # outputs outputs
  def error(examples, outputs)
    outputs.each_with_index.inject(0) do |acc, (output, index)| 
      acc + ((output - evaluate(examples[index]).last)**2 ) / outputs.size
    end
  end  
  
  def load_training_examples(file_path, output_map = {}, sep = ",")
    load_examples(@training_examples, @training_outputs, file_path, output_map, sep)
  end
  
  def load_testing_examples(file_path, output_map = {}, sep = ",")
    load_examples(@testing_examples, @testing_outputs, file_path, output_map, sep)
  end
  
  
  
  # Load the examples from the file file_path taking the first n_features 
  # (from 0 to n_features) columns as features and 
  # the n_features column as the outputs while mapping them
  # using the hash output_map (which is in the form of
  # {"1" => "1", "2" => "0"} for example).
  # It stores the inputs in the inputs variable and the outputs in the 
  # outputs variable (they must be initialized before calling this method).
  def load_examples(inputs, outputs, file_path, output_map = {}, separator = ",")
    File.open(file_path, "r") do |infile|
      while (line = infile.gets)
        tmp = line.split(separator)
        tmp[n_features - 1 ] = output_map[tmp[n_features - 1]].nil? ? tmp[n_features - 1] : output_map[tmp[n_features - 1]]
        tmp.map!{|a| a.to_f}
        outputs << tmp[n_features - 1]
        inputs << (tmp[0,n_features - 1].concat([1.0]))
      end
    end
  end

  # Update weights with the differences in lambdas
  def update_weights(lambdas, outs)
    # Orden n_hidden * n_features <= 20
    @hidden_neurons.each do |h|
      @input_neurons.each do |i|
        @weights[h][i] = @weights[h][i] + learning_rate*lambdas[h]*outs[i]
      end
    end
    # Orden n_hidden <= 10
    @output_neurons.each do |o|
      @hidden_neurons.each do |h|
        @weights[o][h] = @weights[o][h] + learning_rate*lambdas[o]*outs[h]
      end
    end 
  end  
  
  # Initialize the weights of the network randomly
  # returns an array such that w[i][j] is the weight from neuron j to i
  def initialize_weights
    w = Array.new( n_features + n_hidden + 1 )
    w.map! {|e| [] }
    @input_neurons.each do |i|
      @hidden_neurons.each do |h|
        w[h][i] = (rand - rand) * 0.2
      end
    end
    @hidden_neurons.each do |h|
      @output_neurons.each do |o|
        w[o][h] = (rand - rand) * 5
      end
    end
    w
  end

end
