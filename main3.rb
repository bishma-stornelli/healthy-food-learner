require './learner'

begin
  # Main to solve question 3 and plot the charts needed
  file_path = "input/bupa.data"
  bests = {}
  [0.5,0.6,0.7,0.8,0.9].each do |percentage|
    (2..10).each do |n_hidden|
      [0.01, 0.05, 0.1, 0.2, 0.3, 0.5].each do |learning_rate|
        puts "Probando porcentaje #{percentage} con #{n_hidden} neuronas y tasa de aprendizaje #{learning_rate}"
        l = Learner.new(6, n_hidden, learning_rate, 1100)
        l.load_training_examples(file_path, {"1\n" => "1", "2\n" => "0"})
        l.split_examples(percentage)
        r = l.train
        
        bests[percentage] = {
            :n_hidden => -1, 
            :learning_rate => -1, 
            :error => {
              :testing => Float::INFINITY, :training => Float::INFINITY 
            },
            :learner => nil
          } if bests[percentage].nil?
        
        testing_error = l.error(l.testing_examples, l.testing_outputs)
        if testing_error < bests[percentage][:error][:testing]
          bests[percentage][:n_hidden] = n_hidden
          bests[percentage][:learning_rate] = learning_rate
          bests[percentage][:error][:testing] = testing_error
          bests[percentage][:error][:training] = l.error(l.training_examples, l.training_outputs)
          bests[percentage][:report] = r
        end
      end
    end
  end
  
  f_config = File.open("outputs/configuration2", "w")
  f_config.write("percentage\t\tn_hidden\t\tlearning_rate\t\ttesting_error\t\ttraining_error\n")
    
  bests.each do |percentage, conf|
    f_config.write("#{percentage}\t\t#{conf[:n_hidden]}\t\t#{conf[:learning_rate]}" +
      "\t\t#{conf[:error][:testing]}\t\t#{conf[:error][:training]}\n")
    
    f = File.open("outputs/bupa_#{percentage}", "w") do |f|
      conf[:report].each do |l|
        f.write "#{l.join(",")}\n"
      end
    end
  end
  f_config.close
end
