# rust/extconf.rb
raise 'You have to install Rust with Cargo (https://www.rust-lang.org/)' if !system('cargo --version') || !system('rustc --version')
