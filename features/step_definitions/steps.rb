Given /^the Lomic inherited class (\w*)/ do |klass|
  eval "class #{klass} < Lomic\nend"
  @class = Kernel.const_get(klass)
end

When /^I create a new (\w*) object named (\w*)/ do |klass,obj_name|
  eval "$#{obj_name} = #{klass}.new"
end

Then /^the result of (\w+)\.(\w+) should be (\w+)/ do |obj_name,var_name,result|
  result == (eval "$#{obj_name}.#{var_name}")
end

Then /^the results of each <var> should be <val>/ do |table|
  @alltrue = true
  table.hashes.each do |h|
    @alltrue = @alltrue and h[:val] == (eval "$#{h[:var]}")
  end
  @alltrue
end

### general variables

When /^I (add|subtract) (\d+) (?:to|from) (.*)/ do |type,amt,var|
  op = (type=='add') ? '+' : '-'
  eval "$#{var} #{op}= #{amt}"
end

### var declaration

Given /^the following var declarations:/ do |vars|
  vars.hashes.each { |h| @class.class_eval h[:var_decl] }
end

### resources

Given /^the resource declaration (\w+) with value (\[.*\]|\d+)/ do |name,val|
  @class.class_eval "resource :#{name} => #{val}"
end
