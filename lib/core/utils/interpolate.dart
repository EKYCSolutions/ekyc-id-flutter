enum Extrapolate {
  extend,
  clamp,
  clampStart,
  clampEnd,
}

/// @param: List<double> inputRage
/// @param: List<double> outputRage
/// @param: Extrapolate extrapolate =  Extrapolate.extend
class Interpolate {
  late List<double> _x;
  late List<double> _y;
  Extrapolate extrapolate;

  Interpolate(
      {required List<double> inputRange,
      required List<double> outputRange,
      this.extrapolate = Extrapolate.extend}) {
    _x = inputRange.map((e) => e.toDouble()).toList();
    _y = outputRange.map((e) => e.toDouble()).toList();
    assert(_x.length == _y.length,
        "interpolate: the length of inputRange must be equal to the length ot the outputRange");
    assert(_x.length >= 2 && _y.length >= 2,
        "interpolate: the range should have more than two data points");
  }

  /// execute the interpolation in the range
  /// if the interpolation is clamped the return value will not be extended
  double eval(double val) {
    if (val <= _x.first) {
      if (extrapolate == Extrapolate.clampStart ||
          extrapolate == Extrapolate.clamp) {
        return _y.first;
      } else {
        return _interpolateLine([_x.first, _x[1]], [_y.first, _y[1]], val);
      }
    } else {
      for (var i = 0; i < _x.length; i++) {
        if (val < _x[i]) {
          return _interpolateLine([_x[i - 1], _x[i]], [_y[i - 1], _y[i]], val);
        }
        if (val == _x[i]) {
          return _y[i];
        }
      }

      if (val > _x.last) {
        if (extrapolate == Extrapolate.clamp ||
            extrapolate == Extrapolate.clampEnd) {
          return _y.last;
        } else {
          var i = _x.length - 1;
          return _interpolateLine(
              [_x[i - 1], _x.last], [_y[i - 1], _y.last], val);
        }
      }
    }
    return 0;
  }

  static double _interpolateLine(List<double> x, List<double> y, double val) {
    var x0 = x[0];
    var x1 = x[1];
    var y0 = y[0];
    var y1 = y[1];
    var _val = y0 + (val - x0) * ((y1 - y0) / (x1 - x0));
    return _val;
  }
}
