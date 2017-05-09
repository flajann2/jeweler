require 'ffi'

module <%= constant_name %>
  extend FFI::Library
  ffi_lib 'rust/target/release/<%= constant_name %>.so'
  attach_function :hello_world, [ :string ], :int      
end

if $0 == __FILE__
  <%= constant_name %>::hello_world
end
