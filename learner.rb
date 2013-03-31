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
  attr_reader :n_features, :n_hidden, :current_iteration, :current_error, :weights
  attr_accessor :learning_rate, :training_examples, :testing_examples, :training_outputs, :testing_outputs
  def initialize(n_features, n_hidden, learning_rate, options = {})
    @learning_rate = learning_rate
    @n_features = n_features
    @n_hidden = n_hidden
    @training_examples = []
    @testing_examples = []
    @training_outputs = []
    @testing_outputs = []
    @input_neurons = Array.new(@n_features){ |i| i }
    @hidden_neurons = Array.new(@n_hidden){ |i| @n_features + i }
    @output_neurons = [@n_features + @n_hidden]
    @weights = initialize_weights
    @current_iteration = 0
    @current_error = Float::INFINITY
  end

  # a
  # returns the number of examples classified correctly
  def train
    e = 0
    correct = 0
    @training_examples.each_with_index do |ei, i|
      lambdas = Array.new
      
      o = evaluate(ei)

      correct += 1 if o.last.round == @training_outputs[i][0]

      for k in @output_neurons do
        lambdas[k] = o[k] * (1.0 - o[k] ) * (@training_outputs[i][0] - o[k] )
      end 

      for h in @hidden_neurons do
        lambdas[h] = o[h] * (1.0 - o[h]) * @output_neurons.inject(0) {|acc, k| acc + @weights[k][h] * lambdas[k]}
      end
      
      e += ((@training_outputs[i][0] - o.last)**2.0) / @training_outputs.size

      update_weights(lambdas, o)
    end
    
    @current_error = e
    
    @current_iteration += 1
    
    correct
  end

  # Evaluate the input example with the current weights and
  # returns an array such that o[k] is the output for neuron k
  # o tiene que tener las posiciones definidas para las neuronas de entrada tambien (TODAS)
  def evaluate(example)
    outs = example.dup
    
    @hidden_neurons.each do |h|
      tmp = 0
      @input_neurons.each do |i|
        # puts "tamano: " + @weights[h].length.to_s + "\n"
        # puts "weights[#{h}][#{i}]: " + @weights[h][i].to_s + " outs: " + outs[i].to_s + "\n"
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

  # Calculate the error in examples with respect to the expected
  # outputs outputs
  def error(examples, outputs)
    outputs.each_with_index.inject(0) do |acc, (output, index)|
      a = evaluate(examples[index])
      #puts a.to_s + "\n"
      acc + ((output[0] - a.last)**2.0 ) / outputs.size
    end
  end  
  
  private

  def sig(x)
    1.0 / (1.0 + Math.exp(-x))
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
