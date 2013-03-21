def generate_input(file_name, n, uniformly_distributed = true)
  examples = []
  outputs = []
  while examples.size < n
    input = [rand * 20, rand * 20]
    output = (input[0] - 10)**2 + (input[1] - 10)**2 <= 36 ? -1 : 1
    insert = uniformly_distributed ? 
      (
        outputs.select{ |o| -1 * o == output }.count >= outputs.select{ |o| o == output }.count ?
        true : 
        false
      ) : 
      true
    insert = insert && !examples.include?( input )
    if insert
      examples << input
      outputs << output
    end
  end
  puts "Outputs en 1: #{outputs.select{ |o| o == 1 }.count} y en -1 #{outputs.select { |o| o == -1}.count}"
  File.open(file_name, "w") do |f|
    examples.each_with_index do |e, i|
      f.write("#{e.join(" ")} #{outputs[i]}\n")
    end
  end
end

def generate_test_examples(file_name)
  examples = []
  outputs = []
  
  p = 100
  step = 20.0 / p
  e = []
  p.times do |i|
    e << i * step 
  end
  
  e.each do |x|
    e.each do |y|
      input = [x,y]
      output = (input[0] - 10)**2 + (input[1] - 10)**2 <= 36 ? -1 : 1
      examples << input
      outputs << output
    end
  end
  puts "Outputs en 1: #{outputs.select{ |o| o == 1 }.count} y en -1 #{outputs.select { |o| o == -1}.count}"
  File.open(file_name, "w") do |f|
    examples.each_with_index do |e, i|
      f.write("#{e.join(" ")} #{outputs[i]}\n")
    end
  end
end

begin
  generate_test_examples("input/own_10000")
  generate_input("input/own_500", 500)
  generate_input("input/own_1000", 1000)
  generate_input("input/own_2000", 2000)
end
