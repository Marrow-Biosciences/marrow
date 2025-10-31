/// This file is used to test the glibc version at runtime.
///
/// 1. bazel run //risingwave:glibc_test_load to build and load the container image to local container runtime
/// 2. podman run localhost/risingwave-glibc_test:latest to run the container
///
/// We assume the base container image is linux/amd64.
///
/// Running this test is necessary to ensure the glibc version of the build environment is compatible with the runtime environment.
/// Refer to the BUILD.bazel file in this directory for build configuration, including base container image.
use std::process::Command;
use tap::prelude::*;

fn main() {
  Command::new("/lib/x86_64-linux-gnu/libc.so.6")
    .output()
    .expect("failed to execute process")
    .stdout
    .pipe_deref(String::from_utf8_lossy)
    .pipe(|stdout| println!("{stdout}"));
}
