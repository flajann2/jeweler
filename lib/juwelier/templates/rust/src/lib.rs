
#[cfg(test)]

extern crate serde;
extern crate libc;
extern crate serde_json;

#[macro_use]
extern crate serde_derive;

use serde_json::from_str;
use serde_json::Error;
use std::result::Result;

/// HelloWorld as a target from the JSON from Ruby
#[derive(Debug)]
#[derive(Serialize, Deserialize)]
pub struct HelloWorld {
    hello: String,
    world: String
}

/// This is an example of passing complex objects
/// from Ruby to Rust with strong type checking as JSON
#[no_mangle]
pub extern "C" fn hello_world(json: &str, count: u32) ->  Result<u32, Error> {
    let hw: HelloWorld = from_str(json)?;
    
    // We simply want to show how to pass primitives as well
    for i in 0..count {
        println!("{}: vec: {:?}", i, hw);
    }
    // return one less than the count given
    Ok(count - 1)
}

/// Here we must free strings from Rust when we are done
/// with them.
#[no_mangle]
pub extern "C" fn rust_free(c_ptr: *mut libc::c_void) {
    unsafe {
        libc::free(c_ptr);
    }
}
