use std::env;
use std::path::PathBuf;

fn main() {
    // Tell cargo to tell rustc to link the system nix-expr-c shared library.
    let nix_expr_c = pkg_config::probe_library("nix-expr-c").unwrap();

    let bindings = bindgen::Builder::default()
        .clang_args(
            nix_expr_c
                .include_paths
                .iter()
                .map(|path| format!("-I{}", path.to_string_lossy())),
        )
        .header("src/wrapper.h")
        .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
        .generate()
        .expect("Unable to generate bindings");

    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");
}
