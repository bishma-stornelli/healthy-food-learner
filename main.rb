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
  Dir.mkdir("outputs") unless File.directory? "outputs"
  Dir.mkdir("outputs/correct") unless File.directory? "outputs/correct"
  Dir.mkdir("outputs/error") unless File.directory? "outputs/error"
  
  # Look the best combination for each file
  bests = {}
  file_path = "data.csv"

  number_of_features = 27
  number_of_outputs = 1
  configuration = 1
              
  f_config = File.open("outputs/configuration.csv", "w")
  f_config.puts "Configuración,Neuronas ocultas,tasa de aprendizaje,unbalanced data,missing data,split ration,Tiempo de entrenamiento,Error sobre entrenamiento,Error sobre prueba,Numero de iteraciones,Correctos en entrenamiento,Tamaño entrenamiento,Correctos en prueba,Tamaño prueba,positivos en entrenamiento,positivos en prueba"  
  
  (6..15).each do |n_hidden|
    [0.01, 0.05, 0.1, 0.2, 0.3].each do |learning_rate|
      [nil].each do |unbalance_method|
        [:zero, :mean].each do |missing_data_method| # Pudiese usarse para algunas columnas un metodo y para otras otro pero es ponerse muy exquisito
          [0.3, 0.5, 0.7].each do |split_ratio|
            raw_inputs, raw_outputs = DataProcessor.load_raw_data(file_path, number_of_features, number_of_outputs)
            
            # Normalizar datos primera vez: mapear strings a Float 
            # OJO: Esto supone que todos los datos son numeros. Si hubiesen datos nominales habría
            # que llevarlos a numero primero
            raw_inputs.map!{|e| e.map!{|e1| e1.empty? ? nil : e1.to_f}}
            raw_outputs.map!{|e| e.map!{|e1| e1.empty? ? nil : e1.to_f}}
            
            # Tratar missing values
            raw_inputs, column_info = DataProcessor.treat_missing_values!(raw_inputs, [missing_data_method] * number_of_features)

            # Separar datos en entrenamiento y prueba
            training_inputs, training_outputs = DataProcessor.split_examples!(raw_inputs, raw_outputs, split_ratio) # Este metodo acepta :random o :uniformly como ultimo parametro
            testing_inputs, testing_outputs = raw_inputs, raw_outputs


            l = Learner.new(number_of_features, n_hidden, learning_rate)
            l.training_examples = training_inputs
            l.testing_examples = testing_inputs
            l.training_outputs = training_outputs
            l.testing_outputs = testing_outputs
            
            # Empezar con entrenamiento
            puts "Probando configuración #{configuration}"
            
            file_correct = File.open("outputs/correct/#{configuration}", "w")
            file_error = File.open("outputs/error/#{configuration}", "w")
            
            t_ini = Time.now
            t_fin = Time.now
            while (l.current_error > 0.01 && (t_fin - t_ini) < 60)
              correct = l.train
              
              file_correct.puts("#{l.current_iteration},#{correct}")
              file_error.puts("#{l.current_iteration},#{l.current_error}")
              
              if l.current_iteration % 100 == 0
                puts "> #{l.current_iteration}, Correct = #{correct}/#{l.training_examples.size}, error = #{l.current_error}"
              end
              t_fin = Time.now
            end
            
            file_correct.close
            file_error.close
            
            testing_error = l.error(l.testing_examples, l.testing_outputs)
            testing_correct = l.correct_classified( l.testing_examples, l.testing_outputs )
            puts "Error en prueba: #{testing_error},Error en entrenamiento: #{l.error(l.training_examples, l.training_outputs)}"
            f_config.puts "#{configuration},#{n_hidden},#{learning_rate},#{unbalance_method},#{missing_data_method},#{split_ratio},#{t_fin - t_ini},#{l.current_error},#{testing_error},#{l.current_iteration},#{correct},#{l.training_outputs.size},#{testing_correct},#{l.testing_outputs.size},#{l.training_outputs.count [1.0]},#{l.testing_outputs.count [1.0]}"  
            f_config.flush
            configuration += 1
          end
        end
      end
      
    end
  end
  
  f_config.close
end
