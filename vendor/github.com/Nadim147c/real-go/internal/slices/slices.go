package slices

//revive:disable

// TODO: enable linting

func LastItemFunc[T any](s []T, f func(T) bool) T {
	if len(s) == 0 {
		var v T
		return v
	}

	var idx int
	for i, v := range s {
		if !f(v) {
			break
		}
		idx = i
	}

	return s[idx]
}

func OptionalValue[T any](d T, s []T) T {
	if len(s) != 0 {
		return s[0]
	}
	return d
}
