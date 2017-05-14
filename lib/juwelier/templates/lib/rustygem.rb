require 'ffi'

module <%= constant_name %>
  extend FFI::Library
  ffi_lib 'rust/target/release/<%= extension_name %>'
  
  attach_function :simple_test, [ :string, :uint ], :uint
  attach_function :hello_world, [ :string, :uint ], :uint
end

if $0 == __FILE__
  json = <<-JSON
  {"hello":"Hello", "world":"World" }
JSON
 
  puts <%= constant_name %>::simple_test "Hi there!", 21
  puts <%= constant_name %>::hello_world json, 3
end
