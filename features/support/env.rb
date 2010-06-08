lomic_file = File.join(File.dirname(__FILE__), *%w[.. .. lib Lomic.rb])
puts lomic_file
require lomic_file