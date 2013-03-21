require './learner'

begin
  # Look the best combination for each file
  bests = {}
  INFINITY = 1.0/0.0
  %w(input/datos_r6_n1000.txt input/datos_r6_n2000.txt input/own_500 input/own_1000 input/own_2000).each do |file_path|
      file_path = "input/datos_r6_n2000.txt"
      (2..10).each do |n_hidden|
        [0.01, 0.05, 0.1, 0.2, 0.3].each do |learning_rate|
          puts "Probando archivo #{file_path} con #{n_hidden} neuronas y tasa de aprendizaje #{learning_rate}"
          l = Learner.new(2, n_hidden, learning_rate)
          l.load_training_examples(file_path, {"1" => "1", "-1" => "0"}, " ")
          l.load_testing_examples('input/own_10000', {"1" => "1", "-1" => "0"}, " ")
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
  end
  
  f_config = File.open("outputs/configuration", "w")
  f_config.write("File\t\tn_hidden\t\tlearning_rate\t\ttesting_error\t\ttraining_error\n")
    
  bests.each do |file_path, conf|
    f_config.write("#{file_path}\t\t#{conf[:n_hidden]}\t\t#{conf[:learning_rate]}" +
      "\t\t#{conf[:error][:testing]}\t\t#{conf[:error][:training]}\n")
    
    f1 = File.open("outputs/#{file_path}_0", "w")
    f2 = File.open("outputs/#{file_path}_1", "w")
    
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
