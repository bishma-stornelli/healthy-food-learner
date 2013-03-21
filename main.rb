#encoding: UTF-8
require './data_processor.rb'

# Cargar datos
number_of_features = 6
number_of_outputs = 1
raw_inputs, raw_outputs = DataProcessor.load_raw_data("data.csv", number_of_features, number_of_outputs)

# Normalizar datos primera vez: mapear strings a Float 
# OJO: Esto supone que todos los datos son numeros. Si hubiesen datos nominales habría
# que llevarlos a numero primero
raw_inputs.map!{|e| e.map!{|e1| e1.to_f}}
raw_outputs.map!{|e| e.map!{|e1| e1.to_f}}

# Tratar missing values

# Normalizar datos por segunda vez: (llevar continuos a clases) (Creo que esto no es necesario)

# Separar datos en entrenamiento y prueba
split_ratio = 0.5
training_inputs, training_outputs = DataProcessor.split_examples!(raw_inputs, raw_outputs, split_ratio, :uniformly)
testing_inputs, testing_outputs = raw_inputs, raw_outputs

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
