#![feature(used_with_arg)]

use risingwave_expr::{ExprError, Result, function};

#[function("add_one(int8) -> int8")]
pub fn add_one(value: i64) -> Result<i64> {
  value.checked_add(1).ok_or(ExprError::NumericOverflow)
}

#[cfg(test)]
mod tests {
  use super::*;
  use rstest::rstest;
  use similar_asserts::assert_eq;

  #[rstest]
  #[case(1i64, 2i64)]
  #[case(-1i64, 0i64)]
  #[case(0i64, 1i64)]
  fn test_add_one_parameterized_ok(#[case] value: i64, #[case] expected: i64) {
    assert_eq!(add_one(value).unwrap(), expected);
  }

  #[test]
  fn test_add_one_err_numeric_overflow() {
    assert_eq!(
      add_one(i64::MAX).unwrap_err().to_string(),
      "Numeric out of range: overflow"
    );
  }
}
