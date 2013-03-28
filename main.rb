#encoding: UTF-8
require './data_processor.rb'
require './learner.rb'

# Cargar datos


# Para todas las configuraciones que se quieran
#   Crear la red neural
#   Mientras no se cumpla el criterio de parada
#     Entrenamos
#
# Datos de interes durante entrenamiento:
#   * Error por iteración
#   * # de ejemplos de entrenamiento clasificados correctamente por iteración
#   * Tiempo de entrenamiento
#   * Tiempo de entrenamiento por iteración???
#   * Tiempo que toma cada paso por iteración?? Permitiria evaluar que métodos se deben optimizar
# 
# Se debe guardar siempre la configuración de la red (pesos) que permitieron obtener la menor tasa de error
# Una vez finalizado el entrenamiento, se obtiene el error con respecto al conjunto de prueba.
#
# Se debe variar:
#   * Tasa de aprendizaje
#   * Número de neuronas en capa intermedia
#   * Tasa de división de datos en entrenamiento y prueba
#
# Se creó un archivo data_processor.rb porque la red neural es independiente de los
# datos que se entrenen. Por este motivo, es bueno tratar los datos aparte y luego
# usar el aprendíz (Learner) como un framework para entrenar una red con cuales sean los datos
# proporcionados.
#
# También sería bueno separar el criterio de parada del aprendíz de manera que 
# diferentes clientes puedan usar el criterio que quieran. Se debe modificar el método train
# para que en vez de entrenar hasta que se cumpla un criterio de parada, simplemente procese
# una vez los datos, ajuste los pesos y ya. Luego en el main se hace como dicen las lineas 6-8.
begin
  # Look the best combination for each file
  bests = {}
  file_path = "data.csv"

  number_of_features = 52
  number_of_outputs = 1
  raw_inputs, raw_outputs = DataProcessor.load_raw_data(file_path, number_of_features, number_of_outputs)

# Normalizar datos primera vez: mapear strings a Float 
# OJO: Esto supone que todos los datos son numeros. Si hubiesen datos nominales habría
# que llevarlos a numero primero
  raw_inputs.map!{|e| e.map!{|e1| e1.to_f}}
  raw_outputs.map!{|e| e.map!{|e1| e1.to_f}}

# Tratar missing values

  DataProcessor.treat_missing_values!(raw_inputs)

# Normalizar datos por segunda vez: (llevar continuos a clases) (Creo que esto no es necesario)

# Separar datos en entrenamiento y prueba
  split_ratio = 0.5
  training_inputs, training_outputs = DataProcessor.split_examples!(raw_inputs, raw_outputs, split_ratio, :uniformly)
  testing_inputs, testing_outputs = raw_inputs, raw_outputs

  (6..15).each do |n_hidden|
    [0.01, 0.05, 0.1, 0.2, 0.3].each do |learning_rate|
      puts "Probando archivo #{file_path} con #{n_hidden} neuronas y tasa de aprendizaje #{learning_rate}"
      l = Learner.new(number_of_features, n_hidden, learning_rate)
      # puts "training_examples: " + training_inputs[0].include?(nil).to_s
      # puts "testing_examples: " + testing_inputs.length.to_s
      l.training_examples = training_inputs
      l.testing_examples = testing_inputs
      l.training_outputs = training_outputs
      l.testing_outputs = testing_outputs
      l.train
      
      bests[file_path] = {
          :n_hidden => -1, 
          :learning_rate => -1, 
          :error => {
            :testing => Float::INFINITY, :training => Float::INFINITY
          },
          :learner => nil
        } if bests[file_path].nil?
      
      testing_error = l.error(l.testing_examples, l.testing_outputs)
      if testing_error < bests[file_path][:error][:testing]
        bests[file_path][:n_hidden] = n_hidden
        bests[file_path][:learning_rate] = learning_rate
        bests[file_path][:error][:testing] = testing_error
        bests[file_path][:error][:training] = l.error(l.training_examples, l.training_outputs)
        bests[file_path][:learner] = l
      end
      puts "\tError en prueba: #{testing_error}\tError en entrenamiento: #{l.error(l.training_examples, l.training_outputs)}"
    end
  end
  
  f_config = File.open("configuration", "w")
  f_config.write("File\t\tn_hidden\t\tlearning_rate\t\ttesting_error\t\ttraining_error\n")
    
  bests.each do |file_path, conf|
    f_config.write("#{file_path}\t\t#{conf[:n_hidden]}\t\t#{conf[:learning_rate]}" +
      "\t\t#{conf[:error][:testing]}\t\t#{conf[:error][:training]}\n")
    
    f1 = File.open("#{file_path}_0", "w")
    f2 = File.open("#{file_path}_1", "w")
    
    l = conf[:learner]
    l.training_examples.each do |e|
      o = e.dup
      o << l.evaluate(e).last
      f = o.last.round == 0 ? f1 : f2
      f.write("#{o.join(",")}\n")
    end
    f1.close
    f2.close
  end
  f_config.close
end