/// This file is used to test the glibc version at runtime.
///
/// 1. bazel run //risingwave:glibc_test_load to build and load the container image to local container runtime
/// 2. podman run localhost/risingwave-glibc_test:latest to run the container
///
/// We assume the base container image is linux/arm64/v8.
///
/// Running this test is necessary to ensure the glibc version of the build environment is compatible with the runtime environment.
/// Refer to the BUILD.bazel file in this directory for build configuration, including base container image.
use std::{env::vars, process::Command, thread::sleep, time::Duration};
use tap::prelude::*;
use tracing::{Level, info};

fn main() {
  tracing_subscriber::fmt().with_max_level(Level::INFO).init();
  vars().into_iter().for_each(|(key, value)| {
    info!("{key}: {value}");
  });
  Command::new("/lib/aarch64-linux-gnu/libc.so.6")
    .output()
    .expect("failed to execute process")
    .stdout
    .pipe_deref(String::from_utf8_lossy)
    .pipe(|stdout| info!("{stdout}"));
  sleep(Duration::MAX);
}
