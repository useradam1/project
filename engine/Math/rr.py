


print(
"""





cdef inline mat4 mat4_mul_num(mat4 a, float b):
	return mat4(
		a._m11 * b,
		a._m12 * b,
		a._m13 * b,
		a._m14 * b,
		a._m21 * b,
		a._m22 * b,
		a._m23 * b,
		a._m24 * b,
		a._m31 * b,
		a._m32 * b,
		a._m33 * b,
		a._m34 * b,
		a._m41 * b,
		a._m42 * b,
		a._m43 * b,
		a._m44 * b
	)
cdef inline mat4 num_mul_mat4(float a, mat4 b):
	return mat4(
		a * b._m11,
		a * b._m12,
		a * b._m13,
		a * b._m14,
		a * b._m21,
		a * b._m22,
		a * b._m23,
		a * b._m24,
		a * b._m31,
		a * b._m32,
		a * b._m33,
		a * b._m34,
		a * b._m41,
		a * b._m42,
		a * b._m43,
		a * b._m44,
	)

cdef inline mat4 mat4_inverse(mat4 a):
	cdef float s0 = a._m11 * a._m22 - a._m12 * a._m21
	cdef float s1 = a._m11 * a._m23 - a._m13 * a._m21
	cdef float s2 = a._m11 * a._m24 - a._m14 * a._m21
	cdef float s3 = a._m12 * a._m23 - a._m13 * a._m22
	cdef float s4 = a._m12 * a._m24 - a._m14 * a._m22
	cdef float s5 = a._m13 * a._m24 - a._m14 * a._m23
	cdef float c5 = a._m33 * a._m44 - a._m34 * a._m43
	cdef float c4 = a._m32 * a._m44 - a._m34 * a._m42
	cdef float c3 = a._m32 * a._m43 - a._m33 * a._m42
	cdef float c2 = a._m31 * a._m44 - a._m34 * a._m41
	cdef float c1 = a._m31 * a._m43 - a._m33 * a._m41
	cdef float c0 = a._m31 * a._m42 - a._m32 * a._m41

	cdef float det = (s0 * c5 - s1 * c4 + s2 * c3 + s3 * c2 - s4 * c1 + s5 * c0)
	det = onefloat / (onefloat if(det == zerfloat) else det)

	return mat4(
		(a._m22 * c5 - a._m23 * c4 + a._m24 * c3) * det,
		(-a._m12 * c5 + a._m13 * c4 - a._m14 * c3) * det,
		(a._m42 * s5 - a._m43 * s4 + a._m44 * s3) * det,
		(-a._m32 * s5 + a._m33 * s4 - a._m34 * s3) * det,
		(-a._m21 * c5 + a._m23 * c2 - a._m24 * c1) * det,
		(a._m11 * c5 - a._m13 * c2 + a._m14 * c1) * det,
		(-a._m41 * s5 + a._m43 * s2 - a._m44 * s1) * det,
		(a._m31 * s5 - a._m33 * s2 + a._m34 * s1) * det,
		(a._m21 * c4 - a._m22 * c2 + a._m24 * c0) * det,
		(-a._m11 * c4 + a._m12 * c2 - a._m14 * c0) * det,
		(a._m41 * s4 - a._m42 * s2 + a._m44 * s0) * det,
		(-a._m31 * s4 + a._m32 * s2 - a._m34 * s0) * det,
		(-a._m21 * c3 + a._m22 * c1 - a._m23 * c0) * det,
		(a._m11 * c3 - a._m12 * c1 + a._m13 * c0) * det,
		(-a._m41 * s3 + a._m42 * s1 - a._m43 * s0) * det,
		(a._m31 * s3 - a._m32 * s1 + a._m33 * s0) * det
	)




""".
replace("._x",".x").
replace("._y",".y").
replace("._z",".z").
replace("._w",".w").

replace("._m11",".m11").
replace("._m12",".m12").
replace("._m13",".m13").
replace("._m14",".m14").
replace("._m21",".m21").
replace("._m22",".m22").
replace("._m23",".m23").
replace("._m24",".m24").
replace("._m31",".m31").
replace("._m32",".m32").
replace("._m33",".m33").
replace("._m34",".m34").
replace("._m41",".m41").
replace("._m42",".m42").
replace("._m43",".m43").
replace("._m44",".m44")

)
input()