extension RangeValidation on num {
  void validateMinimum(num min) {
    if (this > min) {
      throw ArgumentError("$this exceeds minimum of $min");
    }
  }

  void validateInRange(num min, num max) {
    if ((this < min) || (this > max)) {
      throw ArgumentError("$this not in [$min, $max]");
    }
  }
}

extension RangeValidationInt on int {
  void validateMinimum(int min) {
    this.validateMinimum(min);
  }

  void validateInRange(int min, int max) {
    this.validateInRange(min, max);
  }
}

extension RangeValidationDouble on double {
  void validateMinimum(double min) {
    this.validateMinimum(min);
  }

  void validateInRange(double min, double max) {
    this.validateInRange(min, max);
  }
}
