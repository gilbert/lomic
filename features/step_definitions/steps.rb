Given /^the Lomic inherited class (\w*)/ do |klass|
  eval "class #{klass} < Lomic\nend"
  @class = Kernel.const_get(klass)
end

Given /^the following var declarations:/ do |vars|
  vars.hashes.each { |h| @class.class_eval h[:var_decl] }
end

When /^I create a new (\w*) object named (\w*)/ do |klass,obj_name|
  eval "$#{obj_name} = #{klass}.new"
end

Then /^the result of (\w+)\.(\w+) should be (\w+)/ do |obj_name,var_name,result|
  result == (eval "$#{obj_name}.#{var_name}")
end
