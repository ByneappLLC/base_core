typedef _Fn<R> = R Function();
typedef _Cond<T> = bool Function(T t);

class _Matcher<T, R> {
  final T _t;
  late _Fn<R> _default;

  final Map<_Cond<T>, _Fn<R>> _m;

  _Matcher(this._t, this._m);

  _Matcher<T, R> on(_Cond<T> con, _Fn<R> fn) {
    _m.addAll({con: fn});
    return this;
  }

  _Matcher<T, R> orElse(_Fn<R> fn) {
    _default = fn;
    return this;
  }

  R run() {
    final entry = _m.entries.firstWhere(
      (e) => e.key(_t),
      orElse: () => MapEntry((_) => true, _default),
    );

    return entry.value();
  }
}

_Matcher<T, R> match<T, R>(T t) {
  Map<_Cond<T>, _Fn<R>> _m = {};
  return _Matcher<T, R>(t, _m);
}
