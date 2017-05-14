
#[cfg(test)]

extern crate serde;
extern crate libc;
extern crate serde_json;

#[macro_use]
extern crate serde_derive;

use serde_json::from_str;
use serde_json::Error;
use std::result::Result;
use std::ffi::CStr;
use libc::c_char;
    
/// HelloWorld as a target from the JSON from Ruby
#[derive(Debug)]
#[derive(Serialize, Deserialize)]
pub struct HelloWorld {
    hello: String,
    world: String
}

/// Super-simple test
#[no_mangle]
pub extern "C" fn simple_test(cs: *const c_char, i: u32) ->  u32 {
    let s = unsafe {
        assert!(!cs.is_null());
        CStr::from_ptr(cs).to_str().unwrap()
    };
    println!("got a string of {}", s);
    println!("got an integer of {}", i);
    i + 10
}

/// This is an example of passing complex objects
/// from Ruby to Rust with strong type checking as JSON
#[no_mangle]
pub extern "C" fn hello_world(cjson: *const c_char, count: u32) ->  Result<u32, Error> {
    let json = unsafe {
        assert!(!cjson.is_null());
        CStr::from_ptr(cjson).to_str().unwrap()
    };
    let hw: HelloWorld = from_str(json)?;

    println!("hello_world called with {:?} to be printed {} times.", hw, count);

    // We simply want to show how to pass primitives as well
    for i in 0..count {
        println!("{}: hw: {:?}", i, hw);
    }

    // return one less than the count given
    Ok(count - 1)
}

/// Here we must free strings from Rust when we are done
/// with them.
#[no_mangle]
pub extern fn rust_free(c_ptr: *mut libc::c_void) {
    unsafe {
        libc::free(c_ptr);
    }
}
