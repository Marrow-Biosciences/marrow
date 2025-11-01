# RisingWave Kernel

Here are the custom native kernels we patch into the RisingWave binary.

## Contribute a Kernel

### 1. Development

1. Reference `add_one.rs` and create a new file with similar structure.
2. Add Bazel build rules, one rust library and rust test, to `BUILD.bazel`.
3. Implement the kernel in the new file and add unit tests. Build to verify correctness.
   For example, to build the `add_one` kernel:
   ```sh
   bazel build //risingwave/kernel:add_one
   ```
4. Run the tests to verify that the kernel works as expected.
   For example, to test the `add_one` kernel:
   ```sh
   bazel test //risingwave/kernel:add_one_test
   ```

### 2. Integration

1. Update `/patches/risingwave_proto_expr.patch` with a new variant for the kernel.
   Assign an increment to the previous variant, with the first as `AddOne = 900`.
2. Update `/patches/risingwave_frontend.patch` to register the kernel. Refer to the RisingWave GitHub repository.
   1. Add the name of the kernel to the built-in function names list, following `add_one`.
   2. Set the purity of the kernel, based on whether the output is deterministic with regards to the input. Reference `/src/frontend/src/expr/pure.rs`.
   3. Configure the plan optimizer with the nullability of the kernel, how the kernel output nullability varies with the input nullability. Reference `/src/frontend/src/optimizer/plan_expr_visitor/strong.rs`.
3. Update `/patches/risingwave_cmd.patch` to link the kernel to standalone binary. Clone the `use add_one as _;` statement.
4. Update `/patches/risingwave_cmd_all.patch` to link the kernel to distributed binaries. Clone the `use add_one as _;` statement.
5. Update `BUILD.bazel` at `kernel` target to include the kernel library into the `rust_library_group`.
6. Launch the entrypoint `bazel run @crates_risingwave//:risingwave_cmd_all__risingwave` to verify build correctness.
