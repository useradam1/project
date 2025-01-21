# cython: language_level=3, boundscheck=False, wraparound=False, cdivision=True, nonecheck=False
from cpython.float cimport PyFloat_Check
from libc.stdlib cimport malloc, free
from libc.string cimport memset
from libc.math cimport isnan, fabsf, sqrtf, acosf, cosf, sinf, tanf, powf, copysignf, fmodf, floorf
from ctypes import c_float, Array
from typing import Optional, Union, List
from numpy import radians


def sin(float value) -> float:
	return funsin(value)
cdef inline float funsin(float value):
	return sinf(value)

def cos(float value) -> float:
	return funcos(value)
cdef inline float funcos(float value):
	return cosf(value)

def tan(float value) -> float:
	return funtan(value)
cdef inline float funtan(float value):
	return tanf(value)




cdef float c_zero_float = 0.0
cdef float c_neg_one_float = -1.0
cdef float c_one_float = 1.0
cdef bint c_false_bool = <bint>False
cdef bint c_true_bool = <bint>True




cdef class vec2_ptr_static(vec2):

	def LinkVector(self, vec2 value) -> None:
		for i in range(2): self._global_data_ptr[i] = value._global_data_ptr[i]
		self._global_magnitude_ptr = value._global_magnitude_ptr
		self._global_sqrMagnitude_ptr = value._global_sqrMagnitude_ptr
	
	def Unlink(self) -> None:
		for i in range(2): self._global_data_ptr[i] = &self._global_data[i]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude

	def __repr__(self) -> str:
		return f"vec2({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f})"

	def __len__(self) -> int:
		return 2

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		print("Not allowed")

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		print("Not allowed")

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		print("Not allowed")

	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>2).from_address(<size_t>&self._global_data_ptr[0][0])

	def SetValues(self, float x, float y) -> None:
		print("Not allowed")

	def SetVector(self, vec2 value) -> None:
		print("Not allowed")


	@property
	def magnitude(self) -> float:
		return vec2_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec2_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		print("Not allowed")

	def NormalizeFrom(self, vec2 value) -> None:
		print("Not allowed")

	@staticmethod
	def GetNormalized(vec2 value) -> vec2:
		cdef vec2 result = vec2()
		vec2_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec2>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec2 valueA, vec2 valueB) -> float:
		return vec2_dot_product_vec2(valueA._global_data_ptr, valueB._global_data_ptr)


	def __contains__(self, float value) -> bool:
		return vec2_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_lt_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_le_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_eq_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_ne_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_gt_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_ge_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec2:
		cdef vec2 result = vec2()
		vec2_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec2:
		cdef vec2 result = vec2()
		vec2_set_vec2(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec2:
		cdef vec2 result = vec2()
		vec2_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec2') -> vec2_ptr_static:
		print("Not allowed")
		return self
	def __add__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_add_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_add_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec2') -> vec2_ptr_static:
		print("Not allowed")
		return self
	def __sub__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_sub_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_sub_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec2') -> vec2_ptr_static:
		print("Not allowed")
		return self
	def __pow__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_pow_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_pow_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec2') -> vec2_ptr_static:
		print("Not allowed")
		return self
	def __truediv__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_truediv_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_truediv_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec2') -> vec2_ptr_static:
		print("Not allowed")
		return self
	def __floordiv__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_floordiv_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_floordiv_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec2') -> vec2_ptr_static:
		print("Not allowed")
		return self
	def __mod__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_mod_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_mod_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec2') -> vec2_ptr_static:
		print("Not allowed")
		return self
	def __mul__(self, value: 'allowed_types_vec2_mul') -> Union[vec2, mat2]:
		if isinstance(value, vec2):
			result = vec2()
			vec2_mul_vec2((<vec2>result)._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
			return result
		elif isinstance(value, mat2):
			result = mat2()
			vec2_mul_mat2((<mat2>result)._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
			return result
		else:
			result = vec2()
			vec2_mul_float((<vec2>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		vec2_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat2 value) -> vec2_ptr_static:
		print("Not allowed")
		return self
	def __matmul__(self, mat2 value) -> vec2:
		cdef vec2 result = vec2()
		vec2_matmul_mat2(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result





cdef class vec2:

	cdef float[2] _global_data
	cdef float _global_magnitude
	cdef float _global_sqrMagnitude

	cdef float* _global_data_ptr[2]
	cdef float* _global_magnitude_ptr
	cdef float* _global_sqrMagnitude_ptr

	def __repr__(self) -> str:
		return f"vec2({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f})"

	def __len__(self) -> int:
		return 2

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		self._global_data_ptr[0][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		self._global_data_ptr[1][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	def __init__(self, float x = c_zero_float, float y = c_zero_float) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		for i in range(2): self._global_data_ptr[i] = &self._global_data[i]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>2).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def SetVector(self, vec2 value) -> None:
		vec2_set_vec2(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	@property
	def magnitude(self) -> float:
		return vec2_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec2_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		vec2_normalize_in_place(self._global_data_ptr, self._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def NormalizeFrom(self, vec2 value) -> None:
		vec2_normalize_from(self._global_data_ptr, self._global_magnitude_ptr, value._global_data_ptr, (<vec2>value)._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@staticmethod
	def GetNormalized(vec2 value) -> vec2:
		cdef vec2 result = vec2()
		vec2_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec2>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec2 valueA, vec2 valueB) -> float:
		return vec2_dot_product_vec2(valueA._global_data_ptr, valueB._global_data_ptr)


	def __contains__(self, float value) -> bool:
		return vec2_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_lt_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_le_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_eq_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_ne_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_gt_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec2') -> bool:
		if isinstance(value, vec2):
			return vec2_ge_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		return vec2_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec2:
		cdef vec2 result = vec2()
		vec2_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec2:
		cdef vec2 result = vec2()
		vec2_set_vec2(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec2:
		cdef vec2 result = vec2()
		vec2_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec2') -> vec2:
		if isinstance(value, vec2):
			vec2_iadd_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_iadd_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __add__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_add_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_add_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec2') -> vec2:
		if isinstance(value, vec2):
			vec2_isub_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_isub_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __sub__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_sub_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_sub_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec2') -> vec2:
		if isinstance(value, vec2):
			vec2_ipow_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_ipow_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __pow__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_pow_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_pow_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec2') -> vec2:
		if isinstance(value, vec2):
			vec2_itruediv_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_itruediv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __truediv__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_truediv_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_truediv_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec2') -> vec2:
		if isinstance(value, vec2):
			vec2_ifloordiv_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_ifloordiv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __floordiv__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_floordiv_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_floordiv_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec2') -> vec2:
		if isinstance(value, vec2):
			vec2_imod_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_imod_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __mod__(self, value: 'allowed_types_vec2') -> vec2:
		cdef vec2 result = vec2()
		if isinstance(value, vec2):
			vec2_mod_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		float_mod_vec2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec2') -> vec2:
		if isinstance(value, vec2):
			vec2_imul_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			vec2_imul_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __mul__(self, value: 'allowed_types_vec2_mul') -> Union[vec2, mat2]:
		if isinstance(value, vec2):
			result = vec2()
			vec2_mul_vec2((<vec2>result)._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
			return result
		elif isinstance(value, mat2):
			result = mat2()
			vec2_mul_mat2((<mat2>result)._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
			return result
		else:
			result = vec2()
			vec2_mul_float((<vec2>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec2:
		cdef vec2 result = vec2()
		vec2_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat2 value) -> vec2:
		vec2_imatmul_mat2(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __matmul__(self, mat2 value) -> vec2:
		cdef vec2 result = vec2()
		vec2_matmul_mat2(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result


allowed_types_vec2 = Union[vec2, float]
allowed_types_vec2_mul = Union[vec2, 'mat2', float]


cdef inline void vec2_set_vec2(float* target[2], float* source[2]):
	for i in range(2): target[i][0] = source[i][0]

cdef inline float vec2_magnitude(float* vector[2], float* magnitude):
	if magnitude[0] == c_neg_one_float:
		magnitude[0] = c_zero_float
		for i in range(2): magnitude[0] += vector[i][0] * vector[i][0]
		magnitude[0] = sqrtf(magnitude[0])
	return magnitude[0]
cdef inline float vec2_sqrMagnitude(float* vector[2], float* sqrMagnitude):
	if sqrMagnitude[0] == c_neg_one_float:
		sqrMagnitude[0] = c_zero_float
		for i in range(2): sqrMagnitude[0] += vector[i][0] * vector[i][0]
	return sqrMagnitude[0]

cdef inline void vec2_normalize_in_place(float* vector[2], float* magnitude):
	cdef float mag = vec2_magnitude(vector, magnitude)
	if mag == c_zero_float: return
	cdef float inverse_magnitude = c_one_float / mag
	for i in range(2): vector[i][0] *= inverse_magnitude
	magnitude[0] = c_one_float
cdef inline void vec2_normalize_from(float* target_vector[2], float* target_magnitude, float* source_vector[2], float* source_magnitude):
	cdef float mag = vec2_magnitude(source_vector, source_magnitude)
	if mag == c_zero_float: return
	cdef float inverse_magnitude = c_one_float / mag
	for i in range(2): target_vector[i][0] = source_vector[i][0] * inverse_magnitude
	target_magnitude[0] = c_one_float

cdef inline float vec2_dot_product_vec2(float* valueA[2], float* valueB[2]):
	cdef float result = c_zero_float
	for i in range(2): result += valueA[i][0] * valueB[i][0]
	return result


cdef inline bint vec2_contains_float(float* target[2], float value):
	for i in range(2):
		if target[i][0] == value: return c_true_bool
	return c_false_bool

cdef inline bint vec2_lt_vec2(float* valueA[2], float* valueB[2]):
	for i in range(2):
		if valueA[i][0] >= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec2_lt_float(float* valueA[2], float valueB):
	for i in range(2):
		if valueA[i][0] >= valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec2_le_vec2(float* valueA[2], float* valueB[2]):
	for i in range(2):
		if valueA[i][0] > valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec2_le_float(float* valueA[2], float valueB):
	for i in range(2):
		if valueA[i][0] > valueB: return c_false_bool
	return c_true_bool

cdef inline bint vec2_eq_vec2(float* valueA[2], float* valueB[2]):
	for i in range(2):
		if valueA[i][0] != valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec2_eq_float(float* valueA[2], float valueB):
	for i in range(2):
		if valueA[i][0] != valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec2_ne_vec2(float* valueA[2], float* valueB[2]):
	for i in range(2):
		if valueA[i][0] != valueB[i][0]: return c_true_bool
	return c_false_bool
cdef inline bint vec2_ne_float(float* valueA[2], float valueB):
	for i in range(2):
		if valueA[i][0] != valueB: return c_true_bool
	return c_false_bool

cdef inline bint vec2_gt_vec2(float* valueA[2], float* valueB[2]):
	for i in range(2):
		if valueA[i][0] <= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec2_gt_float(float* valueA[2], float valueB):
	for i in range(2):
		if valueA[i][0] <= valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec2_ge_vec2(float* valueA[2], float* valueB[2]):
	for i in range(2):
		if valueA[i][0] < valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec2_ge_float(float* valueA[2], float valueB):
	for i in range(2):
		if valueA[i][0] < valueB: return c_false_bool
	return c_true_bool

cdef inline void vec2_neg_from(float* target[2], float* source[2]):
	for i in range(2): target[i][0] = -source[i][0]
cdef inline void vec2_abs_from(float* target[2], float* source[2]):
	for i in range(2): target[i][0] = fabsf(source[i][0])

cdef inline void vec2_iadd_vec2(float* target[2], float* value[2]):
	for i in range(2): target[i][0] += value[i][0]
cdef inline void vec2_iadd_float(float* target[2], float value):
	for i in range(2): target[i][0] += value
cdef inline void vec2_add_vec2(float* target[2], float* valueA[2], float* valueB[2]):
	for i in range(2): target[i][0] = valueA[i][0] + valueB[i][0]
cdef inline void vec2_add_float(float* target[2], float* valueA[2], float valueB):
	for i in range(2): target[i][0] = valueA[i][0] + valueB
cdef inline void float_add_vec2(float* target[2], float valueA, float* valueB[2]):
	for i in range(2): target[i][0] = valueA + valueB[i][0]

cdef inline void vec2_isub_vec2(float* target[2], float* value[2]):
	for i in range(2): target[i][0] -= value[i][0]
cdef inline void vec2_isub_float(float* target[2], float value):
	for i in range(2): target[i][0] -= value
cdef inline void vec2_sub_vec2(float* target[2], float* valueA[2], float* valueB[2]):
	for i in range(2): target[i][0] = valueA[i][0] - valueB[i][0]
cdef inline void vec2_sub_float(float* target[2], float* valueA[2], float valueB):
	for i in range(2): target[i][0] = valueA[i][0] - valueB
cdef inline void float_sub_vec2(float* target[2], float valueA, float* valueB[2]):
	for i in range(2): target[i][0] = valueA - valueB[i][0]

cdef inline void vec2_ipow_vec2(float* target[2], float* value[2]):
	for i in range(2): target[i][0] = powf(target[i][0], value[i][0])
cdef inline void vec2_ipow_float(float* target[2], float value):
	for i in range(2): target[i][0] = powf(target[i][0], value)
cdef inline void vec2_pow_vec2(float* target[2], float* valueA[2], float* valueB[2]):
	for i in range(2): target[i][0] = powf(valueA[i][0], valueB[i][0])
cdef inline void vec2_pow_float(float* target[2], float* valueA[2], float valueB):
	for i in range(2): target[i][0] = powf(valueA[i][0], valueB)
cdef inline void float_pow_vec2(float* target[2], float valueA, float* valueB[2]):
	for i in range(2): target[i][0] = powf(valueA, valueB[i][0])

cdef inline void vec2_itruediv_vec2(float* target[2], float* value[2]):
	for i in range(2): target[i][0] /= value[i][0]
cdef inline void vec2_itruediv_float(float* target[2], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(2): target[i][0] *= inverse_value
cdef inline void vec2_truediv_vec2(float* target[2], float* valueA[2], float* valueB[2]):
	for i in range(2): target[i][0] = valueA[i][0] / valueB[i][0]
cdef inline void vec2_truediv_float(float* target[2], float* valueA[2], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(2): target[i][0] = valueA[i][0] * inverse_value
cdef inline void float_truediv_vec2(float* target[2], float valueA, float* valueB[2]):
	for i in range(2): target[i][0] = valueA / valueB[i][0]

cdef inline void vec2_ifloordiv_vec2(float* target[2], float* value[2]):
	for i in range(2): target[i][0] = floorf(target[i][0] / value[i][0])
cdef inline void vec2_ifloordiv_float(float* target[2], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(2): target[i][0] = floorf(target[i][0] * inverse_value)
cdef inline void vec2_floordiv_vec2(float* target[2], float* valueA[2], float* valueB[2]):
	for i in range(2): target[i][0] = floorf(valueA[i][0] / valueB[i][0])
cdef inline void vec2_floordiv_float(float* target[2], float* valueA[2], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(2): target[i][0] = floorf(valueA[i][0] * inverse_value)
cdef inline void float_floordiv_vec2(float* target[2], float valueA, float* valueB[2]):
	for i in range(2): target[i][0] = floorf(valueA / valueB[i][0])

cdef inline void vec2_imod_vec2(float* target[2], float* value[2]):
	for i in range(2): target[i][0] = fmodf(target[i][0], value[i][0])
cdef inline void vec2_imod_float(float* target[2], float value):
	for i in range(2): target[i][0] = fmodf(target[i][0], value)
cdef inline void vec2_mod_vec2(float* target[2], float* valueA[2], float* valueB[2]):
	for i in range(2): target[i][0] = fmodf(valueA[i][0], valueB[i][0])
cdef inline void vec2_mod_float(float* target[2], float* valueA[2], float valueB):
	for i in range(2): target[i][0] = fmodf(valueA[i][0], valueB)
cdef inline void float_mod_vec2(float* target[2], float valueA, float* valueB[2]):
	for i in range(2): target[i][0] = fmodf(valueA, valueB[i][0])

cdef inline void vec2_imul_vec2(float* target[2], float* value[2]):
	for i in range(2): target[i][0] *= value[i][0]
cdef inline void vec2_imul_float(float* target[2], float value):
	for i in range(2): target[i][0] *= value
cdef inline void vec2_mul_vec2(float* target[2], float* valueA[2], float* valueB[2]):
	for i in range(2): target[i][0] = valueA[i][0] * valueB[i][0]
cdef inline void vec2_mul_mat2(float* target_matrix[4], float* vector[2], float* matrix[4]):
	cdef int i
	cdef int j = -1
	for i in range(4):
		if(i)%2 == 0: j += 1
		target_matrix[i][0] = vector[j][0] * matrix[i][0]
cdef inline void vec2_mul_float(float* target[2], float* valueA[2], float valueB):
	for i in range(2): target[i][0] = valueA[i][0] * valueB

cdef inline void vec2_imatmul_mat2(float* target_vector[2], float* matrix[4]):
	cdef int i = 0
	cdef int j = 0
	cdef float[2] result
	for i in range(2): result[i] = c_zero_float
	for i in range(2):
		for j in range(2): result[i] += target_vector[j][0] * matrix[j * 2 + i][0]
	for i in range(2): target_vector[i][0] = result[i]
cdef inline void vec2_matmul_mat2(float* target_vector[2], float* vector[2], float* matrix[4]):
	cdef int i = 0
	cdef int j = 0
	cdef float[2] result
	for i in range(2): result[i] = c_zero_float
	for i in range(2):
		for j in range(2): result[i] += vector[j][0] * matrix[j * 2 + i][0]
	for i in range(2): target_vector[i][0] = result[i]



cdef class mat2:

	cdef float[4] _global_data
	cdef float _global_determinant

	cdef float* _global_data_ptr[4]
	cdef float* _global_determinant_ptr

	def __repr__(self) -> str:
		return f"mat2(\n{self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}\n{self._global_data_ptr[2][0]:.2f}, {self._global_data_ptr[3][0]:.2f}\n)"

	def __len__(self) -> int:
		return 4

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_determinant_ptr[0] = c_neg_one_float


	def __init__(self, 
		float m11 = c_one_float, float m12 = c_zero_float, 
		float m21 = c_zero_float, float m22 = c_one_float) -> None:

		self._global_data[0] = m11
		self._global_data[1] = m12
		self._global_data[2] = m21
		self._global_data[3] = m22
		self._global_determinant = c_neg_one_float

		for i in range(4): self._global_data_ptr[i] = &self._global_data[i]
		self._global_determinant_ptr = &self._global_determinant


	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>2).from_address(<size_t>&self._global_data_ptr[0][0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>2).from_address(<size_t>&self._global_data_ptr[2][0])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self,
		float m11, float m12, 
		float m21, float m22) -> None:

		self._global_data_ptr[0][0] = m11
		self._global_data_ptr[1][0] = m12
		self._global_data_ptr[2][0] = m21
		self._global_data_ptr[3][0] = m22
		self._global_determinant_ptr[0] = c_neg_one_float

	def SetMatrix(self, mat2 value) -> None:
		mat2_set_mat2(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float

	def SetIdentity(self) -> None:
		self._global_data_ptr[0][0] = c_one_float
		self._global_data_ptr[1][0] = c_zero_float
		self._global_data_ptr[2][0] = c_zero_float
		self._global_data_ptr[3][0] = c_one_float
		self._global_determinant_ptr[0] = c_neg_one_float


	@property
	def determinant(self) -> float:
		return mat2_determinant(self._global_data_ptr, self._global_determinant_ptr)
	
	def Inverse(self) -> None:
		mat2_inverse_in_place(self._global_data_ptr, self._global_determinant_ptr)
	def InverseFrom(self, mat2 value) -> None:
		mat2_inverse_from(self._global_data_ptr, self._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
	@staticmethod
	def GetInverse(mat2 value) -> mat2:
		cdef mat2 result = mat2()
		mat2_inverse_from(result._global_data_ptr, result._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		return result

	def Transpose(self) -> None:
		mat2_transpose_in_place(self._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
	def TransposeFrom(self, mat2 value) -> None:
		mat2_transpose_from(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
	@staticmethod
	def GetTransposed(mat2 value) -> mat2:
		cdef mat2 result = mat2()
		mat2_transpose_from(result._global_data_ptr, value._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return mat2_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_mat2') -> bool:
		if isinstance(value, mat2):
			return mat2_lt_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		return mat2_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_mat2') -> bool:
		if isinstance(value, mat2):
			return mat2_le_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		return mat2_le_float(self._global_data_ptr, value)
	
	def __eq__(self, value: 'allowed_types_mat2') -> bool:
		if isinstance(value, mat2):
			return mat2_eq_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		return mat2_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_mat2') -> bool:
		if isinstance(value, mat2):
			return mat2_ne_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		return mat2_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_mat2') -> bool:
		if isinstance(value, mat2):
			return mat2_gt_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		return mat2_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_mat2') -> bool:
		if isinstance(value, mat2):
			return mat2_ge_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		return mat2_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> mat2:
		cdef mat2 result = mat2()
		mat2_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> mat2:
		cdef mat2 result = mat2()
		mat2_set_mat2(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> mat2:
		cdef mat2 result = mat2()
		mat2_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_mat2') -> mat2:
		if isinstance(value, mat2):
			mat2_iadd_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_iadd_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __add__(self, value: 'allowed_types_mat2') -> mat2:
		cdef mat2 result = mat2()
		if isinstance(value, mat2):
			mat2_add_mat2(result._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> mat2:
		cdef mat2 result = mat2()
		float_add_mat2(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __isub__(self, value: 'allowed_types_mat2') -> mat2:
		if isinstance(value, mat2):
			mat2_isub_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_isub_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __sub__(self, value: 'allowed_types_mat2') -> mat2:
		cdef mat2 result = mat2()
		if isinstance(value, mat2):
			mat2_sub_mat2(result._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> mat2:
		cdef mat2 result = mat2()
		float_sub_mat2(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ipow__(self, value: 'allowed_types_mat2') -> mat2:
		if isinstance(value, mat2):
			mat2_ipow_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_ipow_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __pow__(self, value: 'allowed_types_mat2') -> mat2:
		cdef mat2 result = mat2()
		if isinstance(value, mat2):
			mat2_pow_mat2(result._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> mat2:
		cdef mat2 result = mat2()
		float_pow_mat2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __itruediv__(self, value: 'allowed_types_mat2') -> mat2:
		if isinstance(value, mat2):
			mat2_itruediv_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_itruediv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __truediv__(self, value: 'allowed_types_mat2') -> mat2:
		cdef mat2 result = mat2()
		if isinstance(value, mat2):
			mat2_truediv_mat2(result._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> mat2:
		cdef mat2 result = mat2()
		float_truediv_mat2(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_mat2') -> mat2:
		if isinstance(value, mat2):
			mat2_ifloordiv_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_ifloordiv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __floordiv__(self, value: 'allowed_types_mat2') -> mat2:
		cdef mat2 result = mat2()
		if isinstance(value, mat2):
			mat2_floordiv_mat2(result._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> mat2:
		cdef mat2 result = mat2()
		float_floordiv_mat2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_mat2') -> mat2:
		if isinstance(value, mat2):
			mat2_imod_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_imod_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __mod__(self, value: 'allowed_types_mat2') -> mat2:
		cdef mat2 result = mat2()
		if isinstance(value, mat2):
			mat2_mod_mat2(result._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
		else:
			mat2_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> mat2:
		cdef mat2 result = mat2()
		float_mod_mat2(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_mat2_mul') -> mat2:
		if isinstance(value, mat2):
			mat2_imul_mat2(self._global_data_ptr, (<mat2>value)._global_data_ptr)
		elif isinstance(value, vec2):
			mat2_imul_vec2(self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			mat2_imul_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __mul__(self, value: 'allowed_types_mat2_mul') -> mat2:
		cdef mat2 result = mat2()
		if isinstance(value, mat2):
			mat2_mul_mat2(result._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
		elif isinstance(value, vec2):
			mat2_mul_vec2(result._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
		else:
			mat2_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmul__(self, float value) -> mat2:
		cdef mat2 result = mat2()
		mat2_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat2 value) -> mat2:
		mat2_imatmul_mat2(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self	
	def __matmul__(self, value: 'allowed_types_mat2_matmul') -> Union[mat2, vec2]:
		if isinstance(value, mat2):
			result = mat2()
			mat2_matmul_mat2((<mat2>result)._global_data_ptr, self._global_data_ptr, (<mat2>value)._global_data_ptr)
			return result
		else:
			result = vec2()
			mat2_matmul_vec2((<vec2>result)._global_data_ptr, self._global_data_ptr, (<vec2>value)._global_data_ptr)
			return result

allowed_types_mat2 = Union[mat2, float]
allowed_types_mat2_mul = Union[mat2, vec2, float]
allowed_types_mat2_matmul = Union[mat2, vec2]


cdef inline void mat2_set_mat2(float* target[4], float* value[4]):
	for i in range(4): target[i][0] = value[i][0]


cdef inline float mat2_determinant(float* matrix[4], float* determinant):
	if determinant[0] == c_neg_one_float:
		determinant[0] = (
			matrix[0][0] * matrix[3][0] - matrix[1][0] * matrix[2][0]
		)
	return determinant[0]

cdef inline void mat2_inverse_in_place(float* matrix[4], float* determinant):
	cdef float det = mat2_determinant(matrix, determinant)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	cdef float[4] result
	result[0] = matrix[3][0] * inv_det
	result[1] = -matrix[1][0] * inv_det
	result[2] = -matrix[2][0] * inv_det
	result[3] = matrix[0][0] * inv_det

	for i in range(4): matrix[i][0] = result[i]

	determinant[0] = inv_det

cdef inline void mat2_inverse_from(float* target_matrix[4], float* target_determinant, float* source_matrix[4], float* source_determinant):
	cdef float det = mat2_determinant(source_matrix, source_determinant)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	target_matrix[0][0] = source_matrix[3][0] * inv_det
	target_matrix[1][0] = -source_matrix[1][0] * inv_det
	target_matrix[2][0] = -source_matrix[2][0] * inv_det
	target_matrix[3][0] = source_matrix[0][0] * inv_det

	target_determinant[0] = inv_det

cdef inline void mat2_transpose_in_place(float* matrix[4]):
	cdef int i, j
	for i in range(2):
		for j in range(i+1, 2):
			matrix[i*2 + j][0], matrix[j*2 + i][0] = matrix[j*2 + i][0], matrix[i*2 + j][0]

cdef inline void mat2_transpose_from(float* target_matrix[4], float* source_matrix[4]):
	cdef int i, j
	for i in range(2):
		for j in range(i+1, 2):
			target_matrix[i*2 + j][0], target_matrix[j*2 + i][0] = source_matrix[j*2 + i][0], source_matrix[i*2 + j][0]

cdef inline bint mat2_contains_float(float* target[4], float value):
	for i in range(4):
		if target[i][0] == value: return c_true_bool
	return c_false_bool

cdef inline bint mat2_lt_mat2(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] >= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat2_lt_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] >= valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat2_le_mat2(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] > valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat2_le_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] > valueB: return c_false_bool
	return c_true_bool

cdef inline bint mat2_eq_mat2(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] != valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat2_eq_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] != valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat2_ne_mat2(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] != valueB[i][0]: return c_true_bool
	return c_false_bool
cdef inline bint mat2_ne_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] != valueB: return c_true_bool
	return c_false_bool

cdef inline bint mat2_gt_mat2(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] <= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat2_gt_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] <= valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat2_ge_mat2(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] < valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat2_ge_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] < valueB: return c_false_bool
	return c_true_bool


cdef inline void mat2_neg_from(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = -source[i][0]

cdef inline void mat2_abs_from(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = fabsf(source[i][0])


cdef inline void mat2_iadd_mat2(float* target[4], float* source[4]):
	for i in range(4): target[i][0] += source[i][0]
cdef inline void mat2_iadd_float(float* target[4], float value):
	for i in range(4): target[i][0] += value
cdef inline void mat2_add_mat2(float* target[4], float* sourceA[4], float* sourceB[4]):
	for i in range(4): target[i][0] = sourceA[i][0] + sourceB[i][0]
cdef inline void mat2_add_float(float* target[4], float* sourceA[4], float value):
	for i in range(4): target[i][0] = sourceA[i][0] + value
cdef inline void float_add_mat2(float* target[4], float value, float* sourceA[4]):
	for i in range(4): target[i][0] = value + sourceA[i][0]

cdef inline void mat2_isub_mat2(float* target[4], float* source[4]):
	for i in range(4): target[i][0] -= source[i][0]
cdef inline void mat2_isub_float(float* target[4], float value):
	for i in range(4): target[i][0] -= value
cdef inline void mat2_sub_mat2(float* target[4], float* sourceA[4], float* sourceB[4]):
	for i in range(4): target[i][0] = sourceA[i][0] - sourceB[i][0]
cdef inline void mat2_sub_float(float* target[4], float* sourceA[4], float value):
	for i in range(4): target[i][0] = sourceA[i][0] - value
cdef inline void float_sub_mat2(float* target[4], float value, float* sourceA[4]):
	for i in range(4): target[i][0] = value - sourceA[i][0]

cdef inline void mat2_ipow_mat2(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = powf(target[i][0], source[i][0])
cdef inline void mat2_ipow_float(float* target[4], float value):
	for i in range(4): target[i][0] = powf(target[i][0], value)
cdef inline void mat2_pow_mat2(float* target[4], float* sourceA[4], float* sourceB[4]):
	for i in range(4): target[i][0] = powf(sourceA[i][0], sourceB[i][0])
cdef inline void mat2_pow_float(float* target[4], float* sourceA[4], float value):
	for i in range(4): target[i][0] = powf(sourceA[i][0], value)
cdef inline void float_pow_mat2(float* target[4], float value, float* sourceA[4]):
	for i in range(4): target[i][0] = powf(value, sourceA[i][0])

cdef inline void mat2_itruediv_mat2(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = target[i][0] / source[i][0]
cdef inline void mat2_itruediv_float(float* target[4], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(4): target[i][0] = target[i][0] * inverse_value
cdef inline void mat2_truediv_mat2(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = valueA[i][0] / valueB[i][0]
cdef inline void mat2_truediv_float(float* target[4], float* valueA[4], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(4): target[i][0] = valueA[i][0] * inverse_value
cdef inline void float_truediv_mat2(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = valueA / valueB[i][0]

cdef inline void mat2_ifloordiv_mat2(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = floorf(target[i][0] / source[i][0])
cdef inline void mat2_ifloordiv_float(float* target[4], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(4): target[i][0] = floorf(target[i][0] * inverse_value)
cdef inline void mat2_floordiv_mat2(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = floorf(valueA[i][0] / valueB[i][0])
cdef inline void mat2_floordiv_float(float* target[4], float* valueA[4], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(4): target[i][0] = floorf(valueA[i][0] * inverse_value)
cdef inline void float_floordiv_mat2(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = floorf(valueA / valueB[i][0])

cdef inline void mat2_imod_mat2(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = fmodf(target[i][0], source[i][0])
cdef inline void mat2_imod_float(float* target[4], float value):
	for i in range(4): target[i][0] = fmodf(target[i][0], value)
cdef inline void mat2_mod_mat2(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = fmodf(valueA[i][0], valueB[i][0])
cdef inline void mat2_mod_float(float* target[4], float* valueA[4], float valueB):
	for i in range(4): target[i][0] = fmodf(valueA[i][0], valueB)
cdef inline void float_mod_mat2(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = fmodf(valueA, valueB[i][0])

cdef inline void mat2_imul_mat2(float* target[4], float* value[4]):
	for i in range(4): target[i][0] *= value[i][0]
cdef inline void mat2_imul_vec2(float* target_matrix[4], float* vector[2]):
	cdef int i
	cdef int j = -1
	for i in range(4):
		if(i)%2 == 0: j += 1
		target_matrix[i][0] *= vector[j][0]
cdef inline void mat2_imul_float(float* target[4], float value):
	for i in range(4): target[i][0] *= value
cdef inline void mat2_mul_mat2(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = valueA[i][0] * valueB[i][0]
cdef inline void mat2_mul_vec2(float* target_matrix[4], float* matrix[4], float* vector[2]):
	cdef int i
	cdef int j = 2
	for i in range(4):
		if(i)%2 == 0: j -= 1
		target_matrix[i][0] = matrix[i][0] * vector[j][0]
cdef inline void mat2_mul_float(float* target[4], float* valueA[4], float valueB):
	for i in range(4): target[i][0] = valueA[i][0] * valueB

cdef inline void mat2_imatmul_mat2(float* target[4], float* source[4]):
	cdef float[4] result
	result[0] = target[0][0] * source[0][0] + target[1][0] * source[2][0]
	result[1] = target[0][0] * source[1][0] + target[1][0] * source[3][0]
	result[2] = target[2][0] * source[0][0] + target[3][0] * source[2][0]
	result[3] = target[2][0] * source[1][0] + target[3][0] * source[3][0]
	for i in range(4): target[i][0] = result[i]
cdef inline void mat2_matmul_mat2(float* target[4], float* valueA[4], float* valueB[4]):
	target[0][0] = valueA[0][0] * valueB[0][0] + valueA[1][0] * valueB[2][0]
	target[1][0] = valueA[0][0] * valueB[1][0] + valueA[1][0] * valueB[3][0]
	target[2][0] = valueA[2][0] * valueB[0][0] + valueA[3][0] * valueB[2][0]
	target[3][0] = valueA[2][0] * valueB[1][0] + valueA[3][0] * valueB[3][0]
cdef inline void mat2_matmul_vec2(float* target_vector[2], float* matrix[4], float* vector[2]):
	cdef int i = 0
	cdef int j = 0
	cdef float[2] result
	for i in range(2): result[i] = c_zero_float
	for i in range(2):
		for j in range(2): result[i] += matrix[i * 2 + j][0] * vector[j][0]
	for i in range(2): target_vector[i][0] = result[i]









cdef class vec3:

	cdef float[3] _global_data
	cdef float _global_magnitude
	cdef float _global_sqrMagnitude

	cdef float* _global_data_ptr[3]
	cdef float* _global_magnitude_ptr
	cdef float* _global_sqrMagnitude_ptr

	def __repr__(self) -> str:
		return f"vec3({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f})"

	def __len__(self) -> int:
		return 3

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		self._global_data_ptr[0][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		self._global_data_ptr[1][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def z(self) -> float:
		return self._global_data_ptr[2][0]
	@z.setter
	def z(self, float value) -> None:
		self._global_data_ptr[2][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		for i in range(3): self._global_data_ptr[i] = &self._global_data[i]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y, float z) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def SetVector(self, vec3 value) -> None:
		vec3_set_vec3(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	@property
	def magnitude(self) -> float:
		return vec3_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec3_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._global_data_ptr, self._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def NormalizeFrom(self, vec3 value) -> None:
		vec3_normalize_from(self._global_data_ptr, self._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@staticmethod
	def GetNormalized(vec3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec3 valueA, vec3 valueB) -> float:
		return vec3_dot_product_vec3(valueA._global_data_ptr, valueB._global_data_ptr)

	def CrossProduct(self, vec3 value) -> None:
		vec3_cross_product_in_place(self._global_data_ptr, value._global_data_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def CrossProductFrom(self, vec3 valueA, vec3 valueB) -> None:
		vec3_cross_product_from(self._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@staticmethod
	def GetCrossProduct(vec3 valueA, vec3 valueB) -> vec3:
		cdef vec3 result = vec3()
		vec3_cross_product_from(result._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return vec3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_lt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_le_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_eq_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ne_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_gt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ge_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_set_vec3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_iadd_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __add__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_add_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_add_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_isub_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __sub__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_sub_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_sub_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_ipow_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ipow_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __pow__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_pow_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_pow_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_itruediv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __truediv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_truediv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_truediv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_ifloordiv_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ifloordiv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __floordiv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_floordiv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_floordiv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_imod_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imod_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __mod__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mod_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_mod_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imul_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __mul__(self, value: 'allowed_types_vec3_mul') -> Union[vec3, mat3]:
		if isinstance(value, vec3):
			result = vec3()
			vec3_mul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result
		elif isinstance(value, mat3):
			result = mat3()
			vec3_mul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			vec3_mul_float((<vec3>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> vec3:
		vec3_imatmul_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __matmul__(self, mat3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_matmul_mat3(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result


allowed_types_vec3 = Union[vec3, float]
allowed_types_vec3_mul = Union[vec3, 'mat3', float]


cdef inline void vec3_set_vec3(float* target[3], float* source[3]):
	for i in range(3): target[i][0] = source[i][0]

cdef inline float vec3_magnitude(float* vector[3], float* magnitude):
	if magnitude[0] == c_neg_one_float:
		magnitude[0] = c_zero_float
		for i in range(3): magnitude[0] += vector[i][0] * vector[i][0]
		magnitude[0] = sqrtf(magnitude[0])
	return magnitude[0]
cdef inline float vec3_sqrMagnitude(float* vector[3], float* sqrMagnitude):
	if sqrMagnitude[0] == c_neg_one_float:
		sqrMagnitude[0] = c_zero_float
		for i in range(3): sqrMagnitude[0] += vector[i][0] * vector[i][0]
	return sqrMagnitude[0]

cdef inline void vec3_normalize_in_place(float* vector[3], float* magnitude):
	cdef float mag = vec3_magnitude(vector, magnitude)
	if mag == c_zero_float: return
	cdef float inverse_magnitude = c_one_float / mag
	for i in range(3): vector[i][0] *= inverse_magnitude
	magnitude[0] = c_one_float
cdef inline void vec3_normalize_from(float* target_vector[3], float* target_magnitude, float* source_vector[3], float* source_magnitude):
	cdef float mag = vec3_magnitude(source_vector, source_magnitude)
	if mag == c_zero_float: return
	cdef float inverse_magnitude = c_one_float / mag
	for i in range(3): target_vector[i][0] = source_vector[i][0] * inverse_magnitude
	target_magnitude[0] = c_one_float

cdef inline float vec3_dot_product_vec3(float* valueA[3], float* valueB[3]):
	cdef float result = c_zero_float
	for i in range(3): result += valueA[i][0] * valueB[i][0]
	return result

cdef inline void vec3_cross_product_in_place(float* target[3], float* value[3]):
	cdef float[3] result
	result[0] = target[1][0] * value[2][0] - target[2][0] * value[1][0]
	result[1] = target[2][0] * value[0][0] - target[0][0] * value[2][0]
	result[2] = target[0][0] * value[1][0] - target[1][0] * value[0][0]
	for i in range(3): target[i][0] = result[i]

cdef inline void vec3_cross_product_from(float* target[3], float* valueA[3], float* valueB[3]):
	target[0][0] = valueA[1][0] * valueB[2][0] - valueA[2][0] * valueB[1][0]
	target[1][0] = valueA[2][0] * valueB[0][0] - valueA[0][0] * valueB[2][0]
	target[2][0] = valueA[0][0] * valueB[1][0] - valueA[1][0] * valueB[0][0]


cdef inline bint vec3_contains_float(float* target[3], float value):
	for i in range(3):
		if target[i][0] == value: return c_true_bool
	return c_false_bool

cdef inline bint vec3_lt_vec3(float* valueA[3], float* valueB[3]):
	for i in range(3):
		if valueA[i][0] >= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec3_lt_float(float* valueA[3], float valueB):
	for i in range(3):
		if valueA[i][0] >= valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec3_le_vec3(float* valueA[3], float* valueB[3]):
	for i in range(3):
		if valueA[i][0] > valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec3_le_float(float* valueA[3], float valueB):
	for i in range(3):
		if valueA[i][0] > valueB: return c_false_bool
	return c_true_bool

cdef inline bint vec3_eq_vec3(float* valueA[3], float* valueB[3]):
	for i in range(3):
		if valueA[i][0] != valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec3_eq_float(float* valueA[3], float valueB):
	for i in range(3):
		if valueA[i][0] != valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec3_ne_vec3(float* valueA[3], float* valueB[3]):
	for i in range(3):
		if valueA[i][0] != valueB[i][0]: return c_true_bool
	return c_false_bool
cdef inline bint vec3_ne_float(float* valueA[3], float valueB):
	for i in range(3):
		if valueA[i][0] != valueB: return c_true_bool
	return c_false_bool

cdef inline bint vec3_gt_vec3(float* valueA[3], float* valueB[3]):
	for i in range(3):
		if valueA[i][0] <= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec3_gt_float(float* valueA[3], float valueB):
	for i in range(3):
		if valueA[i][0] <= valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec3_ge_vec3(float* valueA[3], float* valueB[3]):
	for i in range(3):
		if valueA[i][0] < valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec3_ge_float(float* valueA[3], float valueB):
	for i in range(3):
		if valueA[i][0] < valueB: return c_false_bool
	return c_true_bool

cdef inline void vec3_neg_from(float* target[3], float* source[3]):
	for i in range(3): target[i][0] = -source[i][0]
cdef inline void vec3_abs_from(float* target[3], float* source[3]):
	for i in range(3): target[i][0] = fabsf(source[i][0])

cdef inline void vec3_iadd_vec3(float* target[3], float* value[3]):
	for i in range(3): target[i][0] += value[i][0]
cdef inline void vec3_iadd_float(float* target[3], float value):
	for i in range(3): target[i][0] += value
cdef inline void vec3_add_vec3(float* target[3], float* valueA[3], float* valueB[3]):
	for i in range(3): target[i][0] = valueA[i][0] + valueB[i][0]
cdef inline void vec3_add_float(float* target[3], float* valueA[3], float valueB):
	for i in range(3): target[i][0] = valueA[i][0] + valueB
cdef inline void float_add_vec3(float* target[3], float valueA, float* valueB[3]):
	for i in range(3): target[i][0] = valueA + valueB[i][0]

cdef inline void vec3_isub_vec3(float* target[3], float* value[3]):
	for i in range(3): target[i][0] -= value[i][0]
cdef inline void vec3_isub_float(float* target[3], float value):
	for i in range(3): target[i][0] -= value
cdef inline void vec3_sub_vec3(float* target[3], float* valueA[3], float* valueB[3]):
	for i in range(3): target[i][0] = valueA[i][0] - valueB[i][0]
cdef inline void vec3_sub_float(float* target[3], float* valueA[3], float valueB):
	for i in range(3): target[i][0] = valueA[i][0] - valueB
cdef inline void float_sub_vec3(float* target[3], float valueA, float* valueB[3]):
	for i in range(3): target[i][0] = valueA - valueB[i][0]

cdef inline void vec3_ipow_vec3(float* target[3], float* value[3]):
	for i in range(3): target[i][0] = powf(target[i][0], value[i][0])
cdef inline void vec3_ipow_float(float* target[3], float value):
	for i in range(3): target[i][0] = powf(target[i][0], value)
cdef inline void vec3_pow_vec3(float* target[3], float* valueA[3], float* valueB[3]):
	for i in range(3): target[i][0] = powf(valueA[i][0], valueB[i][0])
cdef inline void vec3_pow_float(float* target[3], float* valueA[3], float valueB):
	for i in range(3): target[i][0] = powf(valueA[i][0], valueB)
cdef inline void float_pow_vec3(float* target[3], float valueA, float* valueB[3]):
	for i in range(3): target[i][0] = powf(valueA, valueB[i][0])

cdef inline void vec3_itruediv_vec3(float* target[3], float* value[3]):
	for i in range(3): target[i][0] /= value[i][0]
cdef inline void vec3_itruediv_float(float* target[3], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(3): target[i][0] *= inverse_value
cdef inline void vec3_truediv_vec3(float* target[3], float* valueA[3], float* valueB[3]):
	for i in range(3): target[i][0] = valueA[i][0] / valueB[i][0]
cdef inline void vec3_truediv_float(float* target[3], float* valueA[3], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(3): target[i][0] = valueA[i][0] * inverse_value
cdef inline void float_truediv_vec3(float* target[3], float valueA, float* valueB[3]):
	for i in range(3): target[i][0] = valueA / valueB[i][0]

cdef inline void vec3_ifloordiv_vec3(float* target[3], float* value[3]):
	for i in range(3): target[i][0] = floorf(target[i][0] / value[i][0])
cdef inline void vec3_ifloordiv_float(float* target[3], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(3): target[i][0] = floorf(target[i][0] * inverse_value)
cdef inline void vec3_floordiv_vec3(float* target[3], float* valueA[3], float* valueB[3]):
	for i in range(3): target[i][0] = floorf(valueA[i][0] / valueB[i][0])
cdef inline void vec3_floordiv_float(float* target[3], float* valueA[3], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(3): target[i][0] = floorf(valueA[i][0] * inverse_value)
cdef inline void float_floordiv_vec3(float* target[3], float valueA, float* valueB[3]):
	for i in range(3): target[i][0] = floorf(valueA / valueB[i][0])

cdef inline void vec3_imod_vec3(float* target[3], float* value[3]):
	for i in range(3): target[i][0] = fmodf(target[i][0], value[i][0])
cdef inline void vec3_imod_float(float* target[3], float value):
	for i in range(3): target[i][0] = fmodf(target[i][0], value)
cdef inline void vec3_mod_vec3(float* target[3], float* valueA[3], float* valueB[3]):
	for i in range(3): target[i][0] = fmodf(valueA[i][0], valueB[i][0])
cdef inline void vec3_mod_float(float* target[3], float* valueA[3], float valueB):
	for i in range(3): target[i][0] = fmodf(valueA[i][0], valueB)
cdef inline void float_mod_vec3(float* target[3], float valueA, float* valueB[3]):
	for i in range(3): target[i][0] = fmodf(valueA, valueB[i][0])

cdef inline void vec3_imul_vec3(float* target[3], float* value[3]):
	for i in range(3): target[i][0] *= value[i][0]
cdef inline void vec3_imul_float(float* target[3], float value):
	for i in range(3): target[i][0] *= value
cdef inline void vec3_mul_vec3(float* target[3], float* valueA[3], float* valueB[3]):
	for i in range(3): target[i][0] = valueA[i][0] * valueB[i][0]
cdef inline void vec3_mul_mat3(float* target_matrix[9], float* vector[3], float* matrix[9]):
	cdef int i
	cdef int j = -1
	for i in range(9):
		if(i)%3 == 0: j += 1
		target_matrix[i][0] = vector[j][0] * matrix[i][0]
cdef inline void vec3_mul_float(float* target[3], float* valueA[3], float valueB):
	for i in range(3): target[i][0] = valueA[i][0] * valueB

cdef inline void vec3_imatmul_mat3(float* target_vector[3], float* matrix[9]):
	cdef int i = 0
	cdef int j = 0
	cdef float[3] result
	for i in range(3): result[i] = c_zero_float
	for i in range(3):
		for j in range(3): result[i] += target_vector[j][0] * matrix[j * 3 + i][0]
	for i in range(3): target_vector[i][0] = result[i]
cdef inline void vec3_matmul_mat3(float* target_vector[3], float* vector[3], float* matrix[9]):
	cdef int i = 0
	cdef int j = 0
	cdef float[3] result
	for i in range(3): result[i] = c_zero_float
	for i in range(3):
		for j in range(3): result[i] += vector[j][0] * matrix[j * 3 + i][0]
	for i in range(3): target_vector[i][0] = result[i]



cdef class mat3:

	cdef float[9] _global_data
	cdef float _global_determinant

	cdef float* _global_data_ptr[9]
	cdef float* _global_determinant_ptr

	def __repr__(self) -> str:
		return f"mat3(\n{self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f}\n{self._global_data_ptr[3][0]:.2f}, {self._global_data_ptr[4][0]:.2f}, {self._global_data_ptr[5][0]:.2f}\n{self._global_data_ptr[6][0]:.2f}, {self._global_data_ptr[7][0]:.2f}, {self._global_data_ptr[8][0]:.2f}\n)"

	def __len__(self) -> int:
		return 9

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_determinant_ptr[0] = c_neg_one_float


	def __init__(self, 
		float m11 = c_one_float, float m12 = c_zero_float, float m13 = c_zero_float, 
		float m21 = c_zero_float, float m22 = c_one_float, float m23 = c_zero_float, 
		float m31 = c_zero_float, float m32 = c_zero_float, float m33 = c_one_float) -> None:

		self._global_data[0] = m11
		self._global_data[1] = m12
		self._global_data[2] = m13
		self._global_data[3] = m21
		self._global_data[4] = m22
		self._global_data[5] = m23
		self._global_data[6] = m31
		self._global_data[7] = m32
		self._global_data[8] = m33
		self._global_determinant = c_neg_one_float

		for i in range(9): self._global_data_ptr[i] = &self._global_data[i]
		self._global_determinant_ptr = &self._global_determinant


	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[3][0])
	def CreateCTypeBasisK(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[6][0])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>9).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self,
		float m11, float m12, float m13, 
		float m21, float m22, float m23, 
		float m31, float m32, float m33) -> None:

		self._global_data_ptr[0][0] = m11
		self._global_data_ptr[1][0] = m12
		self._global_data_ptr[2][0] = m13
		self._global_data_ptr[3][0] = m21
		self._global_data_ptr[4][0] = m22
		self._global_data_ptr[5][0] = m23
		self._global_data_ptr[6][0] = m31
		self._global_data_ptr[7][0] = m32
		self._global_data_ptr[8][0] = m33
		self._global_determinant_ptr[0] = c_neg_one_float

	def SetMatrix(self, mat3 value) -> None:
		mat3_set_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float

	def SetIdentity(self) -> None:
		self._global_data_ptr[0][0] = c_one_float
		self._global_data_ptr[1][0] = c_zero_float
		self._global_data_ptr[2][0] = c_zero_float
		self._global_data_ptr[3][0] = c_zero_float
		self._global_data_ptr[4][0] = c_one_float
		self._global_data_ptr[5][0] = c_zero_float
		self._global_data_ptr[6][0] = c_zero_float
		self._global_data_ptr[7][0] = c_zero_float
		self._global_data_ptr[8][0] = c_one_float
		self._global_determinant_ptr[0] = c_neg_one_float


	@property
	def determinant(self) -> float:
		return mat3_determinant(self._global_data_ptr, self._global_determinant_ptr)
	
	def Inverse(self) -> None:
		mat3_inverse_in_place(self._global_data_ptr, self._global_determinant_ptr)
	def InverseFrom(self, mat3 value) -> None:
		mat3_inverse_from(self._global_data_ptr, self._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
	@staticmethod
	def GetInverse(mat3 value) -> mat3:
		cdef mat3 result = mat3()
		mat3_inverse_from(result._global_data_ptr, result._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		return result

	def Transpose(self) -> None:
		mat3_transpose_in_place(self._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
	def TransposeFrom(self, mat3 value) -> None:
		mat3_transpose_from(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
	@staticmethod
	def GetTransposed(mat3 value) -> mat3:
		cdef mat3 result = mat3()
		mat3_transpose_from(result._global_data_ptr, value._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return mat3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_lt_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_le_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_le_float(self._global_data_ptr, value)
	
	def __eq__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_eq_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_ne_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_gt_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_ge_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> mat3:
		cdef mat3 result = mat3()
		mat3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> mat3:
		cdef mat3 result = mat3()
		mat3_set_mat3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> mat3:
		cdef mat3 result = mat3()
		mat3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_iadd_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_iadd_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __add__(self, value: 'allowed_types_mat3') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_add_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		float_add_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __isub__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_isub_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_isub_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __sub__(self, value: 'allowed_types_mat3') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_sub_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		float_sub_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ipow__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_ipow_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_ipow_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __pow__(self, value: 'allowed_types_mat3') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_pow_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		float_pow_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __itruediv__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_itruediv_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_itruediv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __truediv__(self, value: 'allowed_types_mat3') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_truediv_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		float_truediv_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_ifloordiv_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_ifloordiv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __floordiv__(self, value: 'allowed_types_mat3') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_floordiv_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		float_floordiv_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_imod_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_imod_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __mod__(self, value: 'allowed_types_mat3') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_mod_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		float_mod_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_mat3_mul') -> mat3:
		if isinstance(value, mat3):
			mat3_imul_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		elif isinstance(value, vec3):
			mat3_imul_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			mat3_imul_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __mul__(self, value: 'allowed_types_mat3_mul') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_mul_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		elif isinstance(value, vec3):
			mat3_mul_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			mat3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmul__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		mat3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> mat3:
		mat3_imatmul_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self	
	def __matmul__(self, value: 'allowed_types_mat3_matmul') -> Union[mat3, vec3]:
		if isinstance(value, mat3):
			result = mat3()
			mat3_matmul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			mat3_matmul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result

allowed_types_mat3 = Union[mat3, float]
allowed_types_mat3_mul = Union[mat3, vec3, float]
allowed_types_mat3_matmul = Union[mat3, vec3]


cdef inline void mat3_set_mat3(float* target[9], float* value[9]):
	for i in range(9): target[i][0] = value[i][0]


cdef inline float mat3_determinant(float* matrix[9], float* determinant):
	if determinant[0] == c_neg_one_float:
		determinant[0] = (
			matrix[0][0] * (matrix[4][0] * matrix[8][0] - matrix[5][0] * matrix[7][0]) -
			matrix[1][0] * (matrix[3][0] * matrix[8][0] - matrix[5][0] * matrix[6][0]) +
			matrix[2][0] * (matrix[3][0] * matrix[7][0] - matrix[4][0] * matrix[6][0])
		)
	return determinant[0]

cdef inline void mat3_inverse_in_place(float* matrix[9], float* determinant):
	cdef float det = mat3_determinant(matrix, determinant)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	cdef float[9] result

	result[0] = (matrix[4][0] * matrix[8][0] - matrix[5][0] * matrix[7][0]) * inv_det
	result[1] = (matrix[2][0] * matrix[7][0] - matrix[1][0] * matrix[8][0]) * inv_det
	result[2] = (matrix[1][0] * matrix[5][0] - matrix[2][0] * matrix[4][0]) * inv_det
	result[3] = (matrix[5][0] * matrix[6][0] - matrix[3][0] * matrix[8][0]) * inv_det
	result[4] = (matrix[0][0] * matrix[8][0] - matrix[2][0] * matrix[6][0]) * inv_det
	result[5] = (matrix[2][0] * matrix[3][0] - matrix[0][0] * matrix[5][0]) * inv_det
	result[6] = (matrix[3][0] * matrix[7][0] - matrix[4][0] * matrix[6][0]) * inv_det
	result[7] = (matrix[1][0] * matrix[6][0] - matrix[0][0] * matrix[7][0]) * inv_det
	result[8] = (matrix[0][0] * matrix[4][0] - matrix[1][0] * matrix[3][0]) * inv_det

	for i in range(9): matrix[i][0] = result[i]

	determinant[0] = inv_det

cdef inline void mat3_inverse_from(float* target_matrix[9], float* target_determinant, float* source_matrix[9], float* source_determinant):
	cdef float det = mat3_determinant(source_matrix, source_determinant)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	target_matrix[0][0] = (source_matrix[4][0] * source_matrix[8][0] - source_matrix[5][0] * source_matrix[7][0]) * inv_det
	target_matrix[1][0] = (source_matrix[2][0] * source_matrix[7][0] - source_matrix[1][0] * source_matrix[8][0]) * inv_det
	target_matrix[2][0] = (source_matrix[1][0] * source_matrix[5][0] - source_matrix[2][0] * source_matrix[4][0]) * inv_det
	target_matrix[3][0] = (source_matrix[5][0] * source_matrix[6][0] - source_matrix[3][0] * source_matrix[8][0]) * inv_det
	target_matrix[4][0] = (source_matrix[0][0] * source_matrix[8][0] - source_matrix[2][0] * source_matrix[6][0]) * inv_det
	target_matrix[5][0] = (source_matrix[2][0] * source_matrix[3][0] - source_matrix[0][0] * source_matrix[5][0]) * inv_det
	target_matrix[6][0] = (source_matrix[3][0] * source_matrix[7][0] - source_matrix[4][0] * source_matrix[6][0]) * inv_det
	target_matrix[7][0] = (source_matrix[1][0] * source_matrix[6][0] - source_matrix[0][0] * source_matrix[7][0]) * inv_det
	target_matrix[8][0] = (source_matrix[0][0] * source_matrix[4][0] - source_matrix[1][0] * source_matrix[3][0]) * inv_det

	target_determinant[0] = inv_det

cdef inline void mat3_transpose_in_place(float* matrix[9]):
	cdef int i, j
	for i in range(3):
		for j in range(i+1, 3):
			matrix[i*3 + j][0], matrix[j*3 + i][0] = matrix[j*3 + i][0], matrix[i*3 + j][0]

cdef inline void mat3_transpose_from(float* target_matrix[9], float* source_matrix[9]):
	cdef int i, j
	for i in range(3):
		for j in range(i+1, 3):
			target_matrix[i*3 + j][0], target_matrix[j*3 + i][0] = source_matrix[j*3 + i][0], source_matrix[i*3 + j][0]

cdef inline bint mat3_contains_float(float* target[9], float value):
	for i in range(9):
		if target[i][0] == value: return c_true_bool
	return c_false_bool

cdef inline bint mat3_lt_mat3(float* valueA[9], float* valueB[9]):
	for i in range(9):
		if valueA[i][0] >= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat3_lt_float(float* valueA[9], float valueB):
	for i in range(9):
		if valueA[i][0] >= valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat3_le_mat3(float* valueA[9], float* valueB[9]):
	for i in range(9):
		if valueA[i][0] > valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat3_le_float(float* valueA[9], float valueB):
	for i in range(9):
		if valueA[i][0] > valueB: return c_false_bool
	return c_true_bool

cdef inline bint mat3_eq_mat3(float* valueA[9], float* valueB[9]):
	for i in range(9):
		if valueA[i][0] != valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat3_eq_float(float* valueA[9], float valueB):
	for i in range(9):
		if valueA[i][0] != valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat3_ne_mat3(float* valueA[9], float* valueB[9]):
	for i in range(9):
		if valueA[i][0] != valueB[i][0]: return c_true_bool
	return c_false_bool
cdef inline bint mat3_ne_float(float* valueA[9], float valueB):
	for i in range(9):
		if valueA[i][0] != valueB: return c_true_bool
	return c_false_bool

cdef inline bint mat3_gt_mat3(float* valueA[9], float* valueB[9]):
	for i in range(9):
		if valueA[i][0] <= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat3_gt_float(float* valueA[9], float valueB):
	for i in range(9):
		if valueA[i][0] <= valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat3_ge_mat3(float* valueA[9], float* valueB[9]):
	for i in range(9):
		if valueA[i][0] < valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat3_ge_float(float* valueA[9], float valueB):
	for i in range(9):
		if valueA[i][0] < valueB: return c_false_bool
	return c_true_bool


cdef inline void mat3_neg_from(float* target[9], float* source[9]):
	for i in range(9): target[i][0] = -source[i][0]

cdef inline void mat3_abs_from(float* target[9], float* source[9]):
	for i in range(9): target[i][0] = fabsf(source[i][0])


cdef inline void mat3_iadd_mat3(float* target[9], float* source[9]):
	for i in range(9): target[i][0] += source[i][0]
cdef inline void mat3_iadd_float(float* target[9], float value):
	for i in range(9): target[i][0] += value
cdef inline void mat3_add_mat3(float* target[9], float* sourceA[9], float* sourceB[9]):
	for i in range(9): target[i][0] = sourceA[i][0] + sourceB[i][0]
cdef inline void mat3_add_float(float* target[9], float* sourceA[9], float value):
	for i in range(9): target[i][0] = sourceA[i][0] + value
cdef inline void float_add_mat3(float* target[9], float value, float* sourceA[9]):
	for i in range(9): target[i][0] = value + sourceA[i][0]

cdef inline void mat3_isub_mat3(float* target[9], float* source[9]):
	for i in range(9): target[i][0] -= source[i][0]
cdef inline void mat3_isub_float(float* target[9], float value):
	for i in range(9): target[i][0] -= value
cdef inline void mat3_sub_mat3(float* target[9], float* sourceA[9], float* sourceB[9]):
	for i in range(9): target[i][0] = sourceA[i][0] - sourceB[i][0]
cdef inline void mat3_sub_float(float* target[9], float* sourceA[9], float value):
	for i in range(9): target[i][0] = sourceA[i][0] - value
cdef inline void float_sub_mat3(float* target[9], float value, float* sourceA[9]):
	for i in range(9): target[i][0] = value - sourceA[i][0]

cdef inline void mat3_ipow_mat3(float* target[9], float* source[9]):
	for i in range(9): target[i][0] = powf(target[i][0], source[i][0])
cdef inline void mat3_ipow_float(float* target[9], float value):
	for i in range(9): target[i][0] = powf(target[i][0], value)
cdef inline void mat3_pow_mat3(float* target[9], float* sourceA[9], float* sourceB[9]):
	for i in range(9): target[i][0] = powf(sourceA[i][0], sourceB[i][0])
cdef inline void mat3_pow_float(float* target[9], float* sourceA[9], float value):
	for i in range(9): target[i][0] = powf(sourceA[i][0], value)
cdef inline void float_pow_mat3(float* target[9], float value, float* sourceA[9]):
	for i in range(9): target[i][0] = powf(value, sourceA[i][0])

cdef inline void mat3_itruediv_mat3(float* target[9], float* source[9]):
	for i in range(9): target[i][0] = target[i][0] / source[i][0]
cdef inline void mat3_itruediv_float(float* target[9], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(9): target[i][0] = target[i][0] * inverse_value
cdef inline void mat3_truediv_mat3(float* target[9], float* valueA[9], float* valueB[9]):
	for i in range(9): target[i][0] = valueA[i][0] / valueB[i][0]
cdef inline void mat3_truediv_float(float* target[9], float* valueA[9], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(9): target[i][0] = valueA[i][0] * inverse_value
cdef inline void float_truediv_mat3(float* target[9], float valueA, float* valueB[9]):
	for i in range(9): target[i][0] = valueA / valueB[i][0]

cdef inline void mat3_ifloordiv_mat3(float* target[9], float* source[9]):
	for i in range(9): target[i][0] = floorf(target[i][0] / source[i][0])
cdef inline void mat3_ifloordiv_float(float* target[9], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(9): target[i][0] = floorf(target[i][0] * inverse_value)
cdef inline void mat3_floordiv_mat3(float* target[9], float* valueA[9], float* valueB[9]):
	for i in range(9): target[i][0] = floorf(valueA[i][0] / valueB[i][0])
cdef inline void mat3_floordiv_float(float* target[9], float* valueA[9], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(9): target[i][0] = floorf(valueA[i][0] * inverse_value)
cdef inline void float_floordiv_mat3(float* target[9], float valueA, float* valueB[9]):
	for i in range(9): target[i][0] = floorf(valueA / valueB[i][0])

cdef inline void mat3_imod_mat3(float* target[9], float* source[9]):
	for i in range(9): target[i][0] = fmodf(target[i][0], source[i][0])
cdef inline void mat3_imod_float(float* target[9], float value):
	for i in range(9): target[i][0] = fmodf(target[i][0], value)
cdef inline void mat3_mod_mat3(float* target[9], float* valueA[9], float* valueB[9]):
	for i in range(9): target[i][0] = fmodf(valueA[i][0], valueB[i][0])
cdef inline void mat3_mod_float(float* target[9], float* valueA[9], float valueB):
	for i in range(9): target[i][0] = fmodf(valueA[i][0], valueB)
cdef inline void float_mod_mat3(float* target[9], float valueA, float* valueB[9]):
	for i in range(9): target[i][0] = fmodf(valueA, valueB[i][0])

cdef inline void mat3_imul_mat3(float* target[9], float* value[9]):
	for i in range(9): target[i][0] *= value[i][0]
cdef inline void mat3_imul_vec3(float* target_matrix[9], float* vector[3]):
	cdef int i
	cdef int j = -1
	for i in range(9):
		if(i)%3 == 0: j += 1
		target_matrix[i][0] *= vector[j][0]
cdef inline void mat3_imul_float(float* target[9], float value):
	for i in range(9): target[i][0] *= value
cdef inline void mat3_mul_mat3(float* target[9], float* valueA[9], float* valueB[9]):
	for i in range(9): target[i][0] = valueA[i][0] * valueB[i][0]
cdef inline void mat3_mul_vec3(float* target_matrix[9], float* matrix[9], float* vector[3]):
	cdef int i
	cdef int j = 3
	for i in range(9):
		if(i)%3 == 0: j -= 1
		target_matrix[i][0] = matrix[i][0] * vector[j][0]
cdef inline void mat3_mul_float(float* target[9], float* valueA[9], float valueB):
	for i in range(9): target[i][0] = valueA[i][0] * valueB

cdef inline void mat3_imatmul_mat3(float* target[9], float* source[9]):
	cdef float[9] result
	result[0] = target[0][0] * source[0][0] + target[1][0] * source[3][0] + target[2][0] * source[6][0]
	result[1] = target[0][0] * source[1][0] + target[1][0] * source[4][0] + target[2][0] * source[7][0]
	result[2] = target[0][0] * source[2][0] + target[1][0] * source[5][0] + target[2][0] * source[8][0]
	result[3] = target[3][0] * source[0][0] + target[4][0] * source[3][0] + target[5][0] * source[6][0]
	result[4] = target[3][0] * source[1][0] + target[4][0] * source[4][0] + target[5][0] * source[7][0]
	result[5] = target[3][0] * source[2][0] + target[4][0] * source[5][0] + target[5][0] * source[8][0]
	result[6] = target[6][0] * source[0][0] + target[7][0] * source[3][0] + target[8][0] * source[6][0]
	result[7] = target[6][0] * source[1][0] + target[7][0] * source[4][0] + target[8][0] * source[7][0]
	result[8] = target[6][0] * source[2][0] + target[7][0] * source[5][0] + target[8][0] * source[8][0]
	for i in range(9): target[i][0] = result[i]
cdef inline void mat3_matmul_mat3(float* target[9], float* valueA[9], float* valueB[9]):
	target[0][0] = valueA[0][0] * valueB[0][0] + valueA[1][0] * valueB[3][0] + valueA[2][0] * valueB[6][0]
	target[1][0] = valueA[0][0] * valueB[1][0] + valueA[1][0] * valueB[4][0] + valueA[2][0] * valueB[7][0]
	target[2][0] = valueA[0][0] * valueB[2][0] + valueA[1][0] * valueB[5][0] + valueA[2][0] * valueB[8][0]
	target[3][0] = valueA[3][0] * valueB[0][0] + valueA[4][0] * valueB[3][0] + valueA[5][0] * valueB[6][0]
	target[4][0] = valueA[3][0] * valueB[1][0] + valueA[4][0] * valueB[4][0] + valueA[5][0] * valueB[7][0]
	target[5][0] = valueA[3][0] * valueB[2][0] + valueA[4][0] * valueB[5][0] + valueA[5][0] * valueB[8][0]
	target[6][0] = valueA[6][0] * valueB[0][0] + valueA[7][0] * valueB[3][0] + valueA[8][0] * valueB[6][0]
	target[7][0] = valueA[6][0] * valueB[1][0] + valueA[7][0] * valueB[4][0] + valueA[8][0] * valueB[7][0]
	target[8][0] = valueA[6][0] * valueB[2][0] + valueA[7][0] * valueB[5][0] + valueA[8][0] * valueB[8][0]
cdef inline void mat3_matmul_vec3(float* target_vector[3], float* matrix[9], float* vector[3]):
	cdef int i = 0
	cdef int j = 0
	cdef float[3] result
	for i in range(3): result[i] = c_zero_float
	for i in range(3):
		for j in range(3): result[i] += matrix[i * 3 + j][0] * vector[j][0]
	for i in range(3): target_vector[i][0] = result[i]



cdef class Rotation(mat3):

	#cdef float[9] _global_data
	#cdef float _global_determinant

	#cdef float* _global_data_ptr[9]
	#cdef float* _global_determinant_ptr

	def __repr__(self) -> str:
		return f"Rotation(\n{self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f}\n{self._global_data_ptr[3][0]:.2f}, {self._global_data_ptr[4][0]:.2f}, {self._global_data_ptr[5][0]:.2f}\n{self._global_data_ptr[6][0]:.2f}, {self._global_data_ptr[7][0]:.2f}, {self._global_data_ptr[8][0]:.2f}\n)"

	def __len__(self) -> int:
		return 9

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_determinant_ptr[0] = c_neg_one_float


	def Rotate(self, float angle, float x, float y, float z) -> Rotation:
		mat3_rotate(self._global_data_ptr, angle, x, y, z)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self

	def Gx(self, float angle) -> Rotation:
		mat3_rotate(self._global_data_ptr, angle, c_one_float, c_zero_float, c_zero_float)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self

	def Gy(self, float angle) -> Rotation:
		mat3_rotate(self._global_data_ptr, angle, c_zero_float, c_one_float, c_zero_float)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self

	def Gz(self, float angle) -> Rotation:
		mat3_rotate(self._global_data_ptr, angle, c_zero_float, c_zero_float, c_one_float)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	
	def Lx(self, float angle) -> Rotation:
		mat3_rotate(self._global_data_ptr, angle, self._global_data_ptr[0][0], self._global_data_ptr[1][0], self._global_data_ptr[2][0])
		self._global_determinant_ptr[0] = c_neg_one_float
		return self

	def Ly(self, float angle) -> Rotation:
		mat3_rotate(self._global_data_ptr, angle, self._global_data_ptr[3][0], self._global_data_ptr[4][0], self._global_data_ptr[5][0])
		self._global_determinant_ptr[0] = c_neg_one_float
		return self

	def Lz(self, float angle) -> Rotation:
		mat3_rotate(self._global_data_ptr, angle, self._global_data_ptr[6][0], self._global_data_ptr[7][0], self._global_data_ptr[8][0])
		self._global_determinant_ptr[0] = c_neg_one_float
		return self


	def __init__(self, 
		float m11 = c_one_float, float m12 = c_zero_float, float m13 = c_zero_float, 
		float m21 = c_zero_float, float m22 = c_one_float, float m23 = c_zero_float, 
		float m31 = c_zero_float, float m32 = c_zero_float, float m33 = c_one_float) -> None:

		self._global_data[0] = m11
		self._global_data[1] = m12
		self._global_data[2] = m13
		self._global_data[3] = m21
		self._global_data[4] = m22
		self._global_data[5] = m23
		self._global_data[6] = m31
		self._global_data[7] = m32
		self._global_data[8] = m33
		self._global_determinant = c_neg_one_float

		for i in range(9): self._global_data_ptr[i] = &self._global_data[i]
		self._global_determinant_ptr = &self._global_determinant


	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[3][0])
	def CreateCTypeBasisK(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[6][0])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>9).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self,
		float m11, float m12, float m13, 
		float m21, float m22, float m23, 
		float m31, float m32, float m33) -> None:

		self._global_data_ptr[0][0] = m11
		self._global_data_ptr[1][0] = m12
		self._global_data_ptr[2][0] = m13
		self._global_data_ptr[3][0] = m21
		self._global_data_ptr[4][0] = m22
		self._global_data_ptr[5][0] = m23
		self._global_data_ptr[6][0] = m31
		self._global_data_ptr[7][0] = m32
		self._global_data_ptr[8][0] = m33
		self._global_determinant_ptr[0] = c_neg_one_float

	def SetMatrix(self, mat3 value) -> None:
		mat3_set_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float

	def SetIdentity(self) -> None:
		self._global_data_ptr[0][0] = c_one_float
		self._global_data_ptr[1][0] = c_zero_float
		self._global_data_ptr[2][0] = c_zero_float
		self._global_data_ptr[3][0] = c_zero_float
		self._global_data_ptr[4][0] = c_one_float
		self._global_data_ptr[5][0] = c_zero_float
		self._global_data_ptr[6][0] = c_zero_float
		self._global_data_ptr[7][0] = c_zero_float
		self._global_data_ptr[8][0] = c_one_float
		self._global_determinant_ptr[0] = c_neg_one_float


	@property
	def determinant(self) -> float:
		return mat3_determinant(self._global_data_ptr, self._global_determinant_ptr)
	
	def Inverse(self) -> None:
		mat3_inverse_in_place(self._global_data_ptr, self._global_determinant_ptr)
	def InverseFrom(self, mat3 value) -> None:
		mat3_inverse_from(self._global_data_ptr, self._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
	@staticmethod
	def GetInverse(mat3 value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_inverse_from(result._global_data_ptr, result._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		return result

	def Transpose(self) -> None:
		mat3_transpose_in_place(self._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
	def TransposeFrom(self, mat3 value) -> None:
		mat3_transpose_from(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
	@staticmethod
	def GetTransposed(mat3 value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_transpose_from(result._global_data_ptr, value._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return mat3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_lt_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_le_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_le_float(self._global_data_ptr, value)
	
	def __eq__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_eq_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_ne_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_gt_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_ge_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_set_mat3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_iadd_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_iadd_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __add__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_add_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_add_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __isub__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_isub_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_isub_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __sub__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_sub_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_sub_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ipow__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_ipow_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_ipow_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __pow__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_pow_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_pow_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __itruediv__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_itruediv_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_itruediv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __truediv__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_truediv_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_truediv_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_ifloordiv_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_ifloordiv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __floordiv__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_floordiv_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_floordiv_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_imod_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_imod_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __mod__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_mod_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_mod_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_mat3_mul') -> Rotation:
		if isinstance(value, mat3):
			mat3_imul_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		elif isinstance(value, vec3):
			mat3_imul_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			mat3_imul_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __mul__(self, value: 'allowed_types_mat3_mul') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_mul_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		elif isinstance(value, vec3):
			mat3_mul_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			mat3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmul__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> Rotation:
		mat3_imatmul_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self	
	def __matmul__(self, value: 'allowed_types_mat3_matmul') -> Union[Rotation, vec3]:
		if isinstance(value, mat3):
			result = Rotation()
			mat3_matmul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			mat3_matmul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result



cdef inline void mat3_rotate(float* target[9], float angle, float x, float y, float z):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = c_one_float - c
	cdef float tx = t * x
	cdef float ty = t * y

	cdef float matrix[9]

	matrix[0] = tx * x + c
	matrix[1] = tx * y - s * z
	matrix[2] = tx * z + s * y
	matrix[3] = tx * y + s * z
	matrix[4] = ty * y + c
	matrix[5] = ty * z - s * x
	matrix[6] = tx * z - s * y
	matrix[7] = ty * z + s * x
	matrix[8] = t * z * z + c

	cdef float[9] result
	result[0] = target[0][0] * matrix[0] + target[1][0] * matrix[3] + target[2][0] * matrix[6]
	result[1] = target[0][0] * matrix[1] + target[1][0] * matrix[4] + target[2][0] * matrix[7]
	result[2] = target[0][0] * matrix[2] + target[1][0] * matrix[5] + target[2][0] * matrix[8]
	result[3] = target[3][0] * matrix[0] + target[4][0] * matrix[3] + target[5][0] * matrix[6]
	result[4] = target[3][0] * matrix[1] + target[4][0] * matrix[4] + target[5][0] * matrix[7]
	result[5] = target[3][0] * matrix[2] + target[4][0] * matrix[5] + target[5][0] * matrix[8]
	result[6] = target[6][0] * matrix[0] + target[7][0] * matrix[3] + target[8][0] * matrix[6]
	result[7] = target[6][0] * matrix[1] + target[7][0] * matrix[4] + target[8][0] * matrix[7]
	result[8] = target[6][0] * matrix[2] + target[7][0] * matrix[5] + target[8][0] * matrix[8]

	cdef float n1 = sqrtf(result[0]*result[0] + result[1]*result[1] + result[2]*result[2])
	if(n1 != c_zero_float):
		n1 = c_one_float / n1
		result[0] *= n1
		result[1] *= n1
		result[2] *= n1

	cdef float n2 = sqrtf(result[3]*result[3] + result[4]*result[4] + result[5]*result[5])
	if(n2 != c_zero_float):
		n2 = c_one_float / n2
		result[3] *= n2
		result[4] *= n2
		result[5] *= n2

	cdef float n3 = sqrtf(result[6]*result[6] + result[7]*result[7] + result[8]*result[8])
	if(n3 != c_zero_float):
		n3 = c_one_float / n3
		result[6] *= n3
		result[7] *= n3
		result[8] *= n3

	for i in range(9): target[i][0] = result[i]





cdef class vec4:

	cdef float[4] _global_data
	cdef float _global_magnitude
	cdef float _global_sqrMagnitude

	cdef float* _global_data_ptr[4]
	cdef float* _global_magnitude_ptr
	cdef float* _global_sqrMagnitude_ptr

	def __repr__(self) -> str:
		return f"vec4({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f}, {self._global_data_ptr[3][0]:.2f})"

	def __len__(self) -> int:
		return 4

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		self._global_data_ptr[0][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		self._global_data_ptr[1][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def z(self) -> float:
		return self._global_data_ptr[2][0]
	@z.setter
	def z(self, float value) -> None:
		self._global_data_ptr[2][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def w(self) -> float:
		return self._global_data_ptr[3][0]
	@w.setter
	def w(self, float value) -> None:
		self._global_data_ptr[3][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	def __init__(self,
		float x = c_zero_float,
		float y = c_zero_float,
		float z = c_zero_float,
		float w = c_zero_float
	) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_data[3] = w
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		for i in range(4): self._global_data_ptr[i] = &self._global_data[i]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y, float z, float w) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_data[3] = w
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def SetVector(self, vec4 value) -> None:
		vec4_set_vec4(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	@property
	def magnitude(self) -> float:
		return vec4_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec4_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		vec4_normalize_in_place(self._global_data_ptr, self._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def NormalizeFrom(self, vec4 value) -> None:
		vec4_normalize_from(self._global_data_ptr, self._global_magnitude_ptr, value._global_data_ptr, (<vec4>value)._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@staticmethod
	def GetNormalized(vec4 value) -> vec4:
		cdef vec4 result = vec4()
		vec4_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec4>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec4 valueA, vec4 valueB) -> float:
		return vec4_dot_product_vec4(valueA._global_data_ptr, valueB._global_data_ptr)


	def __contains__(self, float value) -> bool:
		return vec4_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return vec4_lt_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		return vec4_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return vec4_le_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		return vec4_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return vec4_eq_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		return vec4_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return vec4_ne_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		return vec4_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return vec4_gt_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		return vec4_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return vec4_ge_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		return vec4_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec4:
		cdef vec4 result = vec4()
		vec4_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec4:
		cdef vec4 result = vec4()
		vec4_set_vec4(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec4:
		cdef vec4 result = vec4()
		vec4_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_iadd_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_iadd_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __add__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_add_vec4(result._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		float_add_vec4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_isub_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_isub_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __sub__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_sub_vec4(result._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		float_sub_vec4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_ipow_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_ipow_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __pow__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_pow_vec4(result._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		float_pow_vec4(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_itruediv_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_itruediv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __truediv__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_truediv_vec4(result._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		float_truediv_vec4(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_ifloordiv_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_ifloordiv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __floordiv__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_floordiv_vec4(result._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		float_floordiv_vec4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_imod_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_imod_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __mod__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_mod_vec4(result._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		float_mod_vec4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_imul_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			vec4_imul_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __mul__(self, value: 'allowed_types_vec4_mul') -> Union[vec4, mat4]:
		if isinstance(value, vec4):
			result = vec4()
			vec4_mul_vec4((<vec4>result)._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
			return result
		elif isinstance(value, mat4):
			result = mat4()
			vec4_mul_mat4((<mat4>result)._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
			return result
		else:
			result = vec4()
			vec4_mul_float((<vec4>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		vec4_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat4 value) -> vec4:
		vec4_imatmul_mat4(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __matmul__(self, mat4 value) -> vec4:
		cdef vec4 result = vec4()
		vec4_matmul_mat4(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result


allowed_types_vec4 = Union[vec4, float]
allowed_types_vec4_mul = Union[vec4, 'mat4', float]


cdef inline void vec4_set_vec4(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = source[i][0]

cdef inline float vec4_magnitude(float* vector[4], float* magnitude):
	if magnitude[0] == c_neg_one_float:
		magnitude[0] = c_zero_float
		for i in range(4): magnitude[0] += vector[i][0] * vector[i][0]
		magnitude[0] = sqrtf(magnitude[0])
	return magnitude[0]
cdef inline float vec4_sqrMagnitude(float* vector[4], float* sqrMagnitude):
	if sqrMagnitude[0] == c_neg_one_float:
		sqrMagnitude[0] = c_zero_float
		for i in range(4): sqrMagnitude[0] += vector[i][0] * vector[i][0]
	return sqrMagnitude[0]

cdef inline void vec4_normalize_in_place(float* vector[4], float* magnitude):
	cdef float mag = vec4_magnitude(vector, magnitude)
	if mag == c_zero_float: return
	cdef float inverse_magnitude = c_one_float / mag
	for i in range(4): vector[i][0] *= inverse_magnitude
	magnitude[0] = c_one_float
cdef inline void vec4_normalize_from(float* target_vector[4], float* target_magnitude, float* source_vector[4], float* source_magnitude):
	cdef float mag = vec4_magnitude(source_vector, source_magnitude)
	if mag == c_zero_float: return
	cdef float inverse_magnitude = c_one_float / mag
	for i in range(4): target_vector[i][0] = source_vector[i][0] * inverse_magnitude
	target_magnitude[0] = c_one_float

cdef inline float vec4_dot_product_vec4(float* valueA[4], float* valueB[4]):
	cdef float result = c_zero_float
	for i in range(4): result += valueA[i][0] * valueB[i][0]
	return result


cdef inline bint vec4_contains_float(float* target[4], float value):
	for i in range(4):
		if target[i][0] == value: return c_true_bool
	return c_false_bool

cdef inline bint vec4_lt_vec4(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] >= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec4_lt_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] >= valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec4_le_vec4(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] > valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec4_le_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] > valueB: return c_false_bool
	return c_true_bool

cdef inline bint vec4_eq_vec4(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] != valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec4_eq_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] != valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec4_ne_vec4(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] != valueB[i][0]: return c_true_bool
	return c_false_bool
cdef inline bint vec4_ne_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] != valueB: return c_true_bool
	return c_false_bool

cdef inline bint vec4_gt_vec4(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] <= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec4_gt_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] <= valueB: return c_false_bool
	return c_true_bool
cdef inline bint vec4_ge_vec4(float* valueA[4], float* valueB[4]):
	for i in range(4):
		if valueA[i][0] < valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint vec4_ge_float(float* valueA[4], float valueB):
	for i in range(4):
		if valueA[i][0] < valueB: return c_false_bool
	return c_true_bool

cdef inline void vec4_neg_from(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = -source[i][0]
cdef inline void vec4_abs_from(float* target[4], float* source[4]):
	for i in range(4): target[i][0] = fabsf(source[i][0])

cdef inline void vec4_iadd_vec4(float* target[4], float* value[4]):
	for i in range(4): target[i][0] += value[i][0]
cdef inline void vec4_iadd_float(float* target[4], float value):
	for i in range(4): target[i][0] += value
cdef inline void vec4_add_vec4(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = valueA[i][0] + valueB[i][0]
cdef inline void vec4_add_float(float* target[4], float* valueA[4], float valueB):
	for i in range(4): target[i][0] = valueA[i][0] + valueB
cdef inline void float_add_vec4(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = valueA + valueB[i][0]

cdef inline void vec4_isub_vec4(float* target[4], float* value[4]):
	for i in range(4): target[i][0] -= value[i][0]
cdef inline void vec4_isub_float(float* target[4], float value):
	for i in range(4): target[i][0] -= value
cdef inline void vec4_sub_vec4(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = valueA[i][0] - valueB[i][0]
cdef inline void vec4_sub_float(float* target[4], float* valueA[4], float valueB):
	for i in range(4): target[i][0] = valueA[i][0] - valueB
cdef inline void float_sub_vec4(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = valueA - valueB[i][0]

cdef inline void vec4_ipow_vec4(float* target[4], float* value[4]):
	for i in range(4): target[i][0] = powf(target[i][0], value[i][0])
cdef inline void vec4_ipow_float(float* target[4], float value):
	for i in range(4): target[i][0] = powf(target[i][0], value)
cdef inline void vec4_pow_vec4(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = powf(valueA[i][0], valueB[i][0])
cdef inline void vec4_pow_float(float* target[4], float* valueA[4], float valueB):
	for i in range(4): target[i][0] = powf(valueA[i][0], valueB)
cdef inline void float_pow_vec4(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = powf(valueA, valueB[i][0])

cdef inline void vec4_itruediv_vec4(float* target[4], float* value[4]):
	for i in range(4): target[i][0] /= value[i][0]
cdef inline void vec4_itruediv_float(float* target[4], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(4): target[i][0] *= inverse_value
cdef inline void vec4_truediv_vec4(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = valueA[i][0] / valueB[i][0]
cdef inline void vec4_truediv_float(float* target[4], float* valueA[4], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(4): target[i][0] = valueA[i][0] * inverse_value
cdef inline void float_truediv_vec4(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = valueA / valueB[i][0]

cdef inline void vec4_ifloordiv_vec4(float* target[4], float* value[4]):
	for i in range(4): target[i][0] = floorf(target[i][0] / value[i][0])
cdef inline void vec4_ifloordiv_float(float* target[4], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(4): target[i][0] = floorf(target[i][0] * inverse_value)
cdef inline void vec4_floordiv_vec4(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = floorf(valueA[i][0] / valueB[i][0])
cdef inline void vec4_floordiv_float(float* target[4], float* valueA[4], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(4): target[i][0] = floorf(valueA[i][0] * inverse_value)
cdef inline void float_floordiv_vec4(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = floorf(valueA / valueB[i][0])

cdef inline void vec4_imod_vec4(float* target[4], float* value[4]):
	for i in range(4): target[i][0] = fmodf(target[i][0], value[i][0])
cdef inline void vec4_imod_float(float* target[4], float value):
	for i in range(4): target[i][0] = fmodf(target[i][0], value)
cdef inline void vec4_mod_vec4(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = fmodf(valueA[i][0], valueB[i][0])
cdef inline void vec4_mod_float(float* target[4], float* valueA[4], float valueB):
	for i in range(4): target[i][0] = fmodf(valueA[i][0], valueB)
cdef inline void float_mod_vec4(float* target[4], float valueA, float* valueB[4]):
	for i in range(4): target[i][0] = fmodf(valueA, valueB[i][0])

cdef inline void vec4_imul_vec4(float* target[4], float* value[4]):
	for i in range(4): target[i][0] *= value[i][0]
cdef inline void vec4_imul_float(float* target[4], float value):
	for i in range(4): target[i][0] *= value
cdef inline void vec4_mul_vec4(float* target[4], float* valueA[4], float* valueB[4]):
	for i in range(4): target[i][0] = valueA[i][0] * valueB[i][0]
cdef inline void vec4_mul_mat4(float* target_matrix[16], float* vector[4], float* matrix[16]):
	cdef int i
	cdef int j = 4
	for i in range(9):
		if(i)%4 == 0: j -= 1
		target_matrix[i][0] = vector[j][0] * matrix[i][0]
cdef inline void vec4_mul_float(float* target[4], float* valueA[4], float valueB):
	for i in range(4): target[i][0] = valueA[i][0] * valueB

cdef inline void vec4_imatmul_mat4(float* target_vector[4], float* matrix[16]):
	cdef int i = 0
	cdef int j = 0
	cdef float[4] result
	for i in range(4): result[i] = c_zero_float
	for i in range(4):
		for j in range(4): result[i] += target_vector[j][0] * matrix[j * 4 + i][0]
	for i in range(4): target_vector[i][0] = result[i]
cdef inline void vec4_matmul_mat4(float* target_vector[4], float* vector[4], float* matrix[16]):
	cdef int i = 0
	cdef int j = 0
	cdef float[4] result
	for i in range(4): result[i] = c_zero_float
	for i in range(4):
		for j in range(4): result[i] += vector[j][0] * matrix[j * 4 + i][0]
	for i in range(4): target_vector[i][0] = result[i]



cdef class mat4:

	cdef float[16] _global_data
	cdef float _global_determinant

	cdef float* _global_data_ptr[16]
	cdef float* _global_determinant_ptr

	def __repr__(self) -> str:
		return f"mat4(\n{self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f}, {self._global_data_ptr[3][0]:.2f}\n{self._global_data_ptr[4][0]:.2f}, {self._global_data_ptr[5][0]:.2f}, {self._global_data_ptr[6][0]:.2f}, {self._global_data_ptr[7][0]:.2f}\n{self._global_data_ptr[8][0]:.2f}, {self._global_data_ptr[9][0]:.2f}, {self._global_data_ptr[10][0]:.2f}, {self._global_data_ptr[11][0]:.2f}\n{self._global_data_ptr[12][0]:.2f}, {self._global_data_ptr[13][0]:.2f}, {self._global_data_ptr[14][0]:.2f}, {self._global_data_ptr[15][0]:.2f}\n)"

	def __len__(self) -> int:
		return 16

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_determinant_ptr[0] = c_neg_one_float


	def __init__(self, 
		float m11 = c_one_float, float m12 = c_zero_float, float m13 = c_zero_float, float m14 = c_zero_float, 
		float m21 = c_zero_float, float m22 = c_one_float, float m23 = c_zero_float, float m24 = c_zero_float, 
		float m31 = c_zero_float, float m32 = c_zero_float, float m33 = c_one_float, float m34 = c_zero_float,
		float m41 = c_zero_float, float m42 = c_zero_float, float m43 = c_zero_float, float m44 = c_one_float) -> None:

		self._global_data[0] = m11
		self._global_data[1] = m12
		self._global_data[2] = m13
		self._global_data[3] = m14
		self._global_data[4] = m21
		self._global_data[5] = m22
		self._global_data[6] = m23
		self._global_data[7] = m24
		self._global_data[8] = m31
		self._global_data[9] = m32
		self._global_data[10] = m33
		self._global_data[11] = m34
		self._global_data[12] = m41
		self._global_data[13] = m42
		self._global_data[14] = m43
		self._global_data[15] = m44
		self._global_determinant = c_neg_one_float

		for i in range(16): self._global_data_ptr[i] = &self._global_data[i]
		self._global_determinant_ptr = &self._global_determinant


	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[0][0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[4][0])
	def CreateCTypeBasisK(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[8][0])
	def CreateCTypeBasisW(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[12][0])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>16).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self,
		float m11, float m12, float m13, float m14, 
		float m21, float m22, float m23, float m24, 
		float m31, float m32, float m33, float m34,
		float m41, float m42, float m43, float m44) -> None:

		self._global_data_ptr[0][0] = m11
		self._global_data_ptr[1][0] = m12
		self._global_data_ptr[2][0] = m13
		self._global_data_ptr[3][0] = m14
		self._global_data_ptr[4][0] = m21
		self._global_data_ptr[5][0] = m22
		self._global_data_ptr[6][0] = m23
		self._global_data_ptr[7][0] = m24
		self._global_data_ptr[8][0] = m31
		self._global_data_ptr[9][0] = m32
		self._global_data_ptr[10][0] = m33
		self._global_data_ptr[11][0] = m34
		self._global_data_ptr[12][0] = m41
		self._global_data_ptr[13][0] = m42
		self._global_data_ptr[14][0] = m43
		self._global_data_ptr[15][0] = m44
		self._global_determinant_ptr[0] = c_neg_one_float

	def SetMatrix(self, mat4 value) -> None:
		mat4_set_mat4(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float

	def SetIdentity(self) -> None:
		self._global_data_ptr[0][0] = c_one_float
		self._global_data_ptr[1][0] = c_zero_float
		self._global_data_ptr[2][0] = c_zero_float
		self._global_data_ptr[3][0] = c_zero_float
		self._global_data_ptr[4][0] = c_zero_float
		self._global_data_ptr[5][0] = c_one_float
		self._global_data_ptr[6][0] = c_zero_float
		self._global_data_ptr[7][0] = c_zero_float
		self._global_data_ptr[8][0] = c_zero_float
		self._global_data_ptr[9][0] = c_zero_float
		self._global_data_ptr[10][0] = c_one_float
		self._global_data_ptr[11][0] = c_zero_float
		self._global_data_ptr[12][0] = c_zero_float
		self._global_data_ptr[13][0] = c_zero_float
		self._global_data_ptr[14][0] = c_zero_float
		self._global_data_ptr[15][0] = c_one_float
		self._global_determinant_ptr[0] = c_neg_one_float


	@property
	def determinant(self) -> float:
		return mat4_determinant(self._global_data_ptr, self._global_determinant_ptr)
	
	def Inverse(self) -> None:
		mat4_inverse_in_place(self._global_data_ptr, self._global_determinant_ptr)
	def InverseFrom(self, mat4 value) -> None:
		mat4_inverse_from(self._global_data_ptr, self._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
	@staticmethod
	def GetInverse(mat4 value) -> mat4:
		cdef mat4 result = mat4()
		mat4_inverse_from(result._global_data_ptr, result._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		return result

	def Transpose(self) -> None:
		mat4_transpose_in_place(self._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
	def TransposeFrom(self, mat4 value) -> None:
		mat4_transpose_from(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
	@staticmethod
	def GetTransposed(mat4 value) -> mat4:
		cdef mat4 result = mat4()
		mat4_transpose_from(result._global_data_ptr, value._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return mat4_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_lt_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_le_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_le_float(self._global_data_ptr, value)
	
	def __eq__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_eq_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_ne_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_gt_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_ge_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_set_mat4(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_iadd_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_iadd_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __add__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_add_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_add_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __isub__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_isub_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_isub_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __sub__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_sub_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_sub_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ipow__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_ipow_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_ipow_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __pow__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_pow_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_pow_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __itruediv__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_itruediv_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_itruediv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __truediv__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_truediv_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_truediv_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_ifloordiv_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_ifloordiv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __floordiv__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_floordiv_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_floordiv_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_imod_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_imod_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __mod__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_mod_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_mod_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_mat4_mul') -> mat4:
		if isinstance(value, mat4):
			mat4_imul_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		elif isinstance(value, vec4):
			mat4_imul_vec4(self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			mat4_imul_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self
	def __mul__(self, value: 'allowed_types_mat4_mul') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_mul_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		elif isinstance(value, vec4):
			mat4_mul_vec4(result._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			mat4_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmul__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		mat4_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat4 value) -> mat4:
		mat4_imatmul_mat4(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
		return self	
	def __matmul__(self, value: 'allowed_types_mat4_matmul') -> Union[mat4, vec4]:
		if isinstance(value, mat4):
			result = mat4()
			mat4_matmul_mat4((<mat4>result)._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
			return result
		else:
			result = vec4()
			mat4_matmul_vec4((<vec4>result)._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
			return result


allowed_types_mat4 = Union[mat4, float]
allowed_types_mat4_mul = Union[mat4, vec4, float]
allowed_types_mat4_matmul = Union[mat4, vec4]


cdef inline void mat4_set_mat4(float* target[16], float* value[16]):
	for i in range(16): target[i][0] = value[i][0]


cdef inline float mat4_determinant(float* matrix[16], float* determinant):
	if determinant[0] == c_neg_one_float:
		determinant[0] = (matrix[0][0] * (matrix[5][0] * (matrix[10][0] * matrix[15][0] - matrix[11][0] * matrix[14][0]) -
						matrix[6][0] * (matrix[9][0] * matrix[15][0] - matrix[11][0] * matrix[13][0]) +
						matrix[7][0] * (matrix[9][0] * matrix[14][0] - matrix[10][0] * matrix[13][0])) -
		matrix[1][0] * (matrix[4][0] * (matrix[10][0] * matrix[15][0] - matrix[11][0] * matrix[14][0]) -
						matrix[6][0] * (matrix[8][0] * matrix[15][0] - matrix[11][0] * matrix[12][0]) +
						matrix[7][0] * (matrix[8][0] * matrix[14][0] - matrix[10][0] * matrix[12][0])) +
		matrix[2][0] * (matrix[4][0] * (matrix[9][0] * matrix[15][0] - matrix[11][0] * matrix[13][0]) -
						matrix[5][0] * (matrix[8][0] * matrix[15][0] - matrix[11][0] * matrix[12][0]) +
						matrix[7][0] * (matrix[8][0] * matrix[13][0] - matrix[9][0] * matrix[12][0])) -
		matrix[3][0] * (matrix[4][0] * (matrix[9][0] * matrix[14][0] - matrix[10][0] * matrix[13][0]) -
						matrix[5][0] * (matrix[8][0] * matrix[14][0] - matrix[10][0] * matrix[12][0]) +
						matrix[6][0] * (matrix[8][0] * matrix[13][0] - matrix[9][0] * matrix[12][0])))
	return determinant[0]

cdef inline void mat4_inverse_in_place(float* matrix[16], float* determinant):
	cdef float det = mat4_determinant(matrix, determinant)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	cdef float[16] result

	result[0] = (matrix[5][0] * (matrix[10][0] * matrix[15][0] - matrix[11][0] * matrix[14][0]) -
						matrix[6][0] * (matrix[9][0] * matrix[15][0] - matrix[11][0] * matrix[13][0]) +
						matrix[7][0] * (matrix[9][0] * matrix[14][0] - matrix[10][0] * matrix[13][0])) * inv_det
	result[1] = -(matrix[1][0] * (matrix[10][0] * matrix[15][0] - matrix[11][0] * matrix[14][0]) -
						matrix[2][0] * (matrix[9][0] * matrix[15][0] - matrix[11][0] * matrix[13][0]) +
						matrix[3][0] * (matrix[9][0] * matrix[14][0] - matrix[10][0] * matrix[13][0])) * inv_det
	result[2] = (matrix[1][0] * (matrix[6][0] * matrix[15][0] - matrix[7][0] * matrix[14][0]) -
						matrix[2][0] * (matrix[5][0] * matrix[15][0] - matrix[7][0] * matrix[13][0]) +
						matrix[3][0] * (matrix[5][0] * matrix[14][0] - matrix[6][0] * matrix[13][0])) * inv_det
	result[3] = -(matrix[1][0] * (matrix[6][0] * matrix[11][0] - matrix[7][0] * matrix[10][0]) -
						matrix[2][0] * (matrix[5][0] * matrix[11][0] - matrix[7][0] * matrix[9][0]) +
						matrix[3][0] * (matrix[5][0] * matrix[10][0] - matrix[6][0] * matrix[9][0])) * inv_det
	result[4] = -(matrix[4][0] * (matrix[10][0] * matrix[15][0] - matrix[11][0] * matrix[14][0]) -
						matrix[6][0] * (matrix[8][0] * matrix[15][0] - matrix[11][0] * matrix[12][0]) +
						matrix[7][0] * (matrix[8][0] * matrix[14][0] - matrix[10][0] * matrix[12][0])) * inv_det
	result[5] = (matrix[0][0] * (matrix[10][0] * matrix[15][0] - matrix[11][0] * matrix[14][0]) -
						matrix[2][0] * (matrix[8][0] * matrix[15][0] - matrix[11][0] * matrix[12][0]) +
						matrix[3][0] * (matrix[8][0] * matrix[14][0] - matrix[10][0] * matrix[12][0])) * inv_det
	result[6] = -(matrix[0][0] * (matrix[6][0] * matrix[15][0] - matrix[7][0] * matrix[14][0]) -
						matrix[2][0] * (matrix[4][0] * matrix[15][0] - matrix[7][0] * matrix[12][0]) +
						matrix[3][0] * (matrix[4][0] * matrix[14][0] - matrix[6][0] * matrix[12][0])) * inv_det
	result[7] = (matrix[0][0] * (matrix[6][0] * matrix[11][0] - matrix[7][0] * matrix[10][0]) -
						matrix[2][0] * (matrix[4][0] * matrix[11][0] - matrix[7][0] * matrix[8][0]) +
						matrix[3][0] * (matrix[4][0] * matrix[10][0] - matrix[6][0] * matrix[8][0])) * inv_det
	result[8] = (matrix[4][0] * (matrix[9][0] * matrix[15][0] - matrix[11][0] * matrix[13][0]) -
						matrix[5][0] * (matrix[8][0] * matrix[15][0] - matrix[11][0] * matrix[12][0]) +
						matrix[7][0] * (matrix[8][0] * matrix[13][0] - matrix[9][0] * matrix[12][0])) * inv_det
	result[9] = -(matrix[0][0] * (matrix[9][0] * matrix[15][0] - matrix[11][0] * matrix[13][0]) -
						matrix[1][0] * (matrix[8][0] * matrix[15][0] - matrix[11][0] * matrix[12][0]) +
						matrix[3][0] * (matrix[8][0] * matrix[13][0] - matrix[9][0] * matrix[12][0])) * inv_det
	result[10] = (matrix[0][0] * (matrix[5][0] * matrix[15][0] - matrix[7][0] * matrix[13][0]) -
						matrix[1][0] * (matrix[4][0] * matrix[15][0] - matrix[7][0] * matrix[12][0]) +
						matrix[3][0] * (matrix[4][0] * matrix[13][0] - matrix[5][0] * matrix[12][0])) * inv_det
	result[11] = -(matrix[0][0] * (matrix[5][0] * matrix[11][0] - matrix[7][0] * matrix[9][0]) -
						matrix[1][0] * (matrix[4][0] * matrix[11][0] - matrix[7][0] * matrix[8][0]) +
						matrix[3][0] * (matrix[4][0] * matrix[9][0] - matrix[5][0] * matrix[8][0])) * inv_det
	result[12] = -(matrix[4][0] * (matrix[9][0] * matrix[14][0] - matrix[10][0] * matrix[13][0]) -
						matrix[5][0] * (matrix[8][0] * matrix[14][0] - matrix[10][0] * matrix[12][0]) +
						matrix[6][0] * (matrix[8][0] * matrix[13][0] - matrix[9][0] * matrix[12][0])) * inv_det
	result[13] = (matrix[0][0] * (matrix[9][0] * matrix[14][0] - matrix[10][0] * matrix[13][0]) -
						matrix[1][0] * (matrix[8][0] * matrix[14][0] - matrix[10][0] * matrix[12][0]) +
						matrix[2][0] * (matrix[8][0] * matrix[13][0] - matrix[9][0] * matrix[12][0])) * inv_det
	result[14] = -(matrix[0][0] * (matrix[5][0] * matrix[14][0] - matrix[6][0] * matrix[13][0]) -
						matrix[1][0] * (matrix[4][0] * matrix[14][0] - matrix[6][0] * matrix[12][0]) +
						matrix[2][0] * (matrix[4][0] * matrix[13][0] - matrix[5][0] * matrix[12][0])) * inv_det
	result[15] = (matrix[0][0] * (matrix[5][0] * matrix[10][0] - matrix[6][0] * matrix[9][0]) -
						matrix[1][0] * (matrix[4][0] * matrix[10][0] - matrix[6][0] * matrix[8][0]) +
						matrix[2][0] * (matrix[4][0] * matrix[9][0] - matrix[5][0] * matrix[8][0])) * inv_det


	for i in range(16): matrix[i][0] = result[i]

	determinant[0] = inv_det

cdef inline void mat4_inverse_from(float* target_matrix[16], float* target_determinant, float* source_matrix[16], float* source_determinant):
	cdef float det = mat4_determinant(source_matrix, source_determinant)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	target_matrix[0][0] = (source_matrix[5][0] * (source_matrix[10][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[14][0]) -
						source_matrix[6][0] * (source_matrix[9][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[13][0]) +
						source_matrix[7][0] * (source_matrix[9][0] * source_matrix[14][0] - source_matrix[10][0] * source_matrix[13][0])) * inv_det

	target_matrix[1][0] = -(source_matrix[1][0] * (source_matrix[10][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[14][0]) -
						source_matrix[2][0] * (source_matrix[9][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[13][0]) +
						source_matrix[3][0] * (source_matrix[9][0] * source_matrix[14][0] - source_matrix[10][0] * source_matrix[13][0])) * inv_det

	target_matrix[2][0] = (source_matrix[1][0] * (source_matrix[6][0] * source_matrix[15][0] - source_matrix[7][0] * source_matrix[14][0]) -
						source_matrix[2][0] * (source_matrix[5][0] * source_matrix[15][0] - source_matrix[7][0] * source_matrix[13][0]) +
						source_matrix[3][0] * (source_matrix[5][0] * source_matrix[14][0] - source_matrix[6][0] * source_matrix[13][0])) * inv_det

	target_matrix[3][0] = -(source_matrix[1][0] * (source_matrix[6][0] * source_matrix[11][0] - source_matrix[7][0] * source_matrix[10][0]) -
						source_matrix[2][0] * (source_matrix[5][0] * source_matrix[11][0] - source_matrix[7][0] * source_matrix[9][0]) +
						source_matrix[3][0] * (source_matrix[5][0] * source_matrix[10][0] - source_matrix[6][0] * source_matrix[9][0])) * inv_det

	target_matrix[4][0] = -(source_matrix[4][0] * (source_matrix[10][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[14][0]) -
						source_matrix[6][0] * (source_matrix[8][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[12][0]) +
						source_matrix[7][0] * (source_matrix[8][0] * source_matrix[14][0] - source_matrix[10][0] * source_matrix[12][0])) * inv_det

	target_matrix[5][0] = (source_matrix[0][0] * (source_matrix[10][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[14][0]) -
						source_matrix[2][0] * (source_matrix[8][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[12][0]) +
						source_matrix[3][0] * (source_matrix[8][0] * source_matrix[14][0] - source_matrix[10][0] * source_matrix[12][0])) * inv_det

	target_matrix[6][0] = -(source_matrix[0][0] * (source_matrix[6][0] * source_matrix[15][0] - source_matrix[7][0] * source_matrix[14][0]) -
						source_matrix[2][0] * (source_matrix[4][0] * source_matrix[15][0] - source_matrix[7][0] * source_matrix[12][0]) +
						source_matrix[3][0] * (source_matrix[4][0] * source_matrix[14][0] - source_matrix[6][0] * source_matrix[12][0])) * inv_det

	target_matrix[7][0] = (source_matrix[0][0] * (source_matrix[6][0] * source_matrix[11][0] - source_matrix[7][0] * source_matrix[10][0]) -
						source_matrix[2][0] * (source_matrix[4][0] * source_matrix[11][0] - source_matrix[7][0] * source_matrix[8][0]) +
						source_matrix[3][0] * (source_matrix[4][0] * source_matrix[10][0] - source_matrix[6][0] * source_matrix[8][0])) * inv_det

	target_matrix[8][0] = (source_matrix[4][0] * (source_matrix[9][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[13][0]) -
						source_matrix[5][0] * (source_matrix[8][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[12][0]) +
						source_matrix[7][0] * (source_matrix[8][0] * source_matrix[13][0] - source_matrix[9][0] * source_matrix[12][0])) * inv_det

	target_matrix[9][0] = -(source_matrix[0][0] * (source_matrix[9][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[13][0]) -
						source_matrix[1][0] * (source_matrix[8][0] * source_matrix[15][0] - source_matrix[11][0] * source_matrix[12][0]) +
						source_matrix[3][0] * (source_matrix[8][0] * source_matrix[13][0] - source_matrix[9][0] * source_matrix[12][0])) * inv_det

	target_matrix[10][0] = (source_matrix[0][0] * (source_matrix[5][0] * source_matrix[15][0] - source_matrix[7][0] * source_matrix[13][0]) -
						source_matrix[1][0] * (source_matrix[4][0] * source_matrix[15][0] - source_matrix[7][0] * source_matrix[12][0]) +
						source_matrix[3][0] * (source_matrix[4][0] * source_matrix[13][0] - source_matrix[5][0] * source_matrix[12][0])) * inv_det

	target_matrix[11][0] = -(source_matrix[0][0] * (source_matrix[5][0] * source_matrix[11][0] - source_matrix[7][0] * source_matrix[9][0]) -
						source_matrix[1][0] * (source_matrix[4][0] * source_matrix[11][0] - source_matrix[7][0] * source_matrix[8][0]) +
						source_matrix[3][0] * (source_matrix[4][0] * source_matrix[9][0] - source_matrix[5][0] * source_matrix[8][0])) * inv_det

	target_matrix[12][0] = -(source_matrix[4][0] * (source_matrix[9][0] * source_matrix[14][0] - source_matrix[10][0] * source_matrix[13][0]) -
						source_matrix[5][0] * (source_matrix[8][0] * source_matrix[14][0] - source_matrix[10][0] * source_matrix[12][0]) +
						source_matrix[6][0] * (source_matrix[8][0] * source_matrix[13][0] - source_matrix[9][0] * source_matrix[12][0])) * inv_det

	target_matrix[13][0] = (source_matrix[0][0] * (source_matrix[9][0] * source_matrix[14][0] - source_matrix[10][0] * source_matrix[13][0]) -
						source_matrix[1][0] * (source_matrix[8][0] * source_matrix[14][0] - source_matrix[10][0] * source_matrix[12][0]) +
						source_matrix[2][0] * (source_matrix[8][0] * source_matrix[13][0] - source_matrix[9][0] * source_matrix[12][0])) * inv_det

	target_matrix[14][0] = -(source_matrix[0][0] * (source_matrix[5][0] * source_matrix[14][0] - source_matrix[6][0] * source_matrix[13][0]) -
						source_matrix[1][0] * (source_matrix[4][0] * source_matrix[14][0] - source_matrix[6][0] * source_matrix[12][0]) +
						source_matrix[2][0] * (source_matrix[4][0] * source_matrix[13][0] - source_matrix[5][0] * source_matrix[12][0])) * inv_det

	target_matrix[15][0] = (source_matrix[0][0] * (source_matrix[5][0] * source_matrix[10][0] - source_matrix[6][0] * source_matrix[9][0]) -
						source_matrix[1][0] * (source_matrix[4][0] * source_matrix[10][0] - source_matrix[6][0] * source_matrix[8][0]) +
						source_matrix[2][0] * (source_matrix[4][0] * source_matrix[9][0] - source_matrix[5][0] * source_matrix[8][0])) * inv_det


	target_determinant[0] = inv_det

cdef inline void mat4_transpose_in_place(float* matrix[16]):
	cdef int i, j
	for i in range(4):
		for j in range(i + 1, 4):
			matrix[i * 4 + j][0], matrix[j * 4 + i][0] = matrix[j * 4 + i][0], matrix[i * 4 + j][0]

cdef inline void mat4_transpose_from(float* target_matrix[16], float* source_matrix[16]):
	cdef int i, j
	for i in range(4):
		for j in range(i + 1, 4):
			target_matrix[i * 4 + j][0], target_matrix[j * 4 + i][0] = source_matrix[j * 4 + i][0], source_matrix[i * 4 + j][0]

cdef inline bint mat4_contains_float(float* target[16], float value):
	for i in range(16):
		if target[i][0] == value: return c_true_bool
	return c_false_bool

cdef inline bint mat4_lt_mat4(float* valueA[16], float* valueB[16]):
	for i in range(16):
		if valueA[i][0] >= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat4_lt_float(float* valueA[16], float valueB):
	for i in range(16):
		if valueA[i][0] >= valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat4_le_mat4(float* valueA[16], float* valueB[16]):
	for i in range(16):
		if valueA[i][0] > valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat4_le_float(float* valueA[16], float valueB):
	for i in range(16):
		if valueA[i][0] > valueB: return c_false_bool
	return c_true_bool

cdef inline bint mat4_eq_mat4(float* valueA[16], float* valueB[16]):
	for i in range(16):
		if valueA[i][0] != valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat4_eq_float(float* valueA[16], float valueB):
	for i in range(16):
		if valueA[i][0] != valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat4_ne_mat4(float* valueA[16], float* valueB[16]):
	for i in range(16):
		if valueA[i][0] != valueB[i][0]: return c_true_bool
	return c_false_bool
cdef inline bint mat4_ne_float(float* valueA[16], float valueB):
	for i in range(16):
		if valueA[i][0] != valueB: return c_true_bool
	return c_false_bool

cdef inline bint mat4_gt_mat4(float* valueA[16], float* valueB[16]):
	for i in range(16):
		if valueA[i][0] <= valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat4_gt_float(float* valueA[16], float valueB):
	for i in range(16):
		if valueA[i][0] <= valueB: return c_false_bool
	return c_true_bool
cdef inline bint mat4_ge_mat4(float* valueA[16], float* valueB[16]):
	for i in range(16):
		if valueA[i][0] < valueB[i][0]: return c_false_bool
	return c_true_bool
cdef inline bint mat4_ge_float(float* valueA[16], float valueB):
	for i in range(16):
		if valueA[i][0] < valueB: return c_false_bool
	return c_true_bool


cdef inline void mat4_neg_from(float* target[16], float* source[16]):
	for i in range(16): target[i][0] = -source[i][0]

cdef inline void mat4_abs_from(float* target[16], float* source[16]):
	for i in range(16): target[i][0] = fabsf(source[i][0])

cdef inline void mat4_iadd_mat4(float* target[16], float* source[16]):
	for i in range(16): target[i][0] += source[i][0]
cdef inline void mat4_iadd_float(float* target[16], float value):
	for i in range(16): target[i][0] += value
cdef inline void mat4_add_mat4(float* target[16], float* sourceA[16], float* sourceB[16]):
	for i in range(16): target[i][0] = sourceA[i][0] + sourceB[i][0]
cdef inline void mat4_add_float(float* target[16], float* sourceA[16], float value):
	for i in range(16): target[i][0] = sourceA[i][0] + value
cdef inline void float_add_mat4(float* target[16], float value, float* sourceA[16]):
	for i in range(16): target[i][0] = value + sourceA[i][0]

cdef inline void mat4_isub_mat4(float* target[16], float* source[16]):
	for i in range(16): target[i][0] -= source[i][0]
cdef inline void mat4_isub_float(float* target[16], float value):
	for i in range(16): target[i][0] -= value
cdef inline void mat4_sub_mat4(float* target[16], float* sourceA[16], float* sourceB[16]):
	for i in range(16): target[i][0] = sourceA[i][0] - sourceB[i][0]
cdef inline void mat4_sub_float(float* target[16], float* sourceA[16], float value):
	for i in range(16): target[i][0] = sourceA[i][0] - value
cdef inline void float_sub_mat4(float* target[16], float value, float* sourceA[16]):
	for i in range(16): target[i][0] = value - sourceA[i][0]

cdef inline void mat4_ipow_mat4(float* target[16], float* source[16]):
	for i in range(16): target[i][0] = powf(target[i][0], source[i][0])
cdef inline void mat4_ipow_float(float* target[16], float value):
	for i in range(16): target[i][0] = powf(target[i][0], value)
cdef inline void mat4_pow_mat4(float* target[16], float* sourceA[16], float* sourceB[16]):
	for i in range(16): target[i][0] = powf(sourceA[i][0], sourceB[i][0])
cdef inline void mat4_pow_float(float* target[16], float* sourceA[16], float value):
	for i in range(16): target[i][0] = powf(sourceA[i][0], value)
cdef inline void float_pow_mat4(float* target[16], float value, float* sourceA[16]):
	for i in range(16): target[i][0] = powf(value, sourceA[i][0])

cdef inline void mat4_itruediv_mat4(float* target[16], float* source[16]):
	for i in range(16): target[i][0] = target[i][0] / source[i][0]
cdef inline void mat4_itruediv_float(float* target[16], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(16): target[i][0] = target[i][0] * inverse_value
cdef inline void mat4_truediv_mat4(float* target[16], float* valueA[16], float* valueB[16]):
	for i in range(16): target[i][0] = valueA[i][0] / valueB[i][0]
cdef inline void mat4_truediv_float(float* target[16], float* valueA[16], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(16): target[i][0] = valueA[i][0] * inverse_value
cdef inline void float_truediv_mat4(float* target[16], float valueA, float* valueB[16]):
	for i in range(16): target[i][0] = valueA / valueB[i][0]

cdef inline void mat4_ifloordiv_mat4(float* target[16], float* source[16]):
	for i in range(16): target[i][0] = floorf(target[i][0] / source[i][0])
cdef inline void mat4_ifloordiv_float(float* target[16], float value):
	cdef float inverse_value = c_one_float / value
	for i in range(16): target[i][0] = floorf(target[i][0] * inverse_value)
cdef inline void mat4_floordiv_mat4(float* target[16], float* valueA[16], float* valueB[16]):
	for i in range(16): target[i][0] = floorf(valueA[i][0] / valueB[i][0])
cdef inline void mat4_floordiv_float(float* target[16], float* valueA[16], float valueB):
	cdef float inverse_value = c_one_float / valueB
	for i in range(16): target[i][0] = floorf(valueA[i][0] * inverse_value)
cdef inline void float_floordiv_mat4(float* target[16], float valueA, float* valueB[16]):
	for i in range(16): target[i][0] = floorf(valueA / valueB[i][0])

cdef inline void mat4_imod_mat4(float* target[16], float* source[16]):
	for i in range(16): target[i][0] = fmodf(target[i][0], source[i][0])
cdef inline void mat4_imod_float(float* target[16], float value):
	for i in range(16): target[i][0] = fmodf(target[i][0], value)
cdef inline void mat4_mod_mat4(float* target[16], float* valueA[16], float* valueB[16]):
	for i in range(16): target[i][0] = fmodf(valueA[i][0], valueB[i][0])
cdef inline void mat4_mod_float(float* target[16], float* valueA[16], float valueB):
	for i in range(16): target[i][0] = fmodf(valueA[i][0], valueB)
cdef inline void float_mod_mat4(float* target[16], float valueA, float* valueB[16]):
	for i in range(16): target[i][0] = fmodf(valueA, valueB[i][0])

cdef inline void mat4_imul_mat4(float* target[16], float* value[16]):
	for i in range(16): target[i][0] *= value[i][0]
cdef inline void mat4_imul_vec4(float* target_matrix[16], float* vector[4]):
	cdef int i
	cdef int j = -1
	for i in range(16):
		if(i)%4 == 0: j += 1
		target_matrix[i][0] *= vector[j][0]
cdef inline void mat4_imul_float(float* target[16], float value):
	for i in range(16): target[i][0] *= value
cdef inline void mat4_mul_mat4(float* target[16], float* valueA[16], float* valueB[16]):
	for i in range(16): target[i][0] = valueA[i][0] * valueB[i][0]
cdef inline void mat4_mul_vec4(float* target_matrix[16], float* matrix[16], float* vector[4]):
	cdef int i
	cdef int j = -1
	for i in range(16):
		if(i)%4 == 0: j += 1
		target_matrix[i][0] = matrix[i][0] * vector[j][0]
cdef inline void mat4_mul_float(float* target[16], float* valueA[16], float valueB):
	for i in range(16): target[i][0] = valueA[i][0] * valueB

cdef inline void mat4_imatmul_mat4(float* target[16], float* source[16]):
	cdef float[16] result
	result[0] = target[0][0] * source[0][0] + target[1][0] * source[4][0] + target[2][0] * source[8][0] + target[3][0] * source[12][0]
	result[1] = target[0][0] * source[1][0] + target[1][0] * source[5][0] + target[2][0] * source[9][0] + target[3][0] * source[13][0]
	result[2] = target[0][0] * source[2][0] + target[1][0] * source[6][0] + target[2][0] * source[10][0] + target[3][0] * source[14][0]
	result[3] = target[0][0] * source[3][0] + target[1][0] * source[7][0] + target[2][0] * source[11][0] + target[3][0] * source[15][0]
	result[4] = target[4][0] * source[0][0] + target[5][0] * source[4][0] + target[6][0] * source[8][0] + target[7][0] * source[12][0]
	result[5] = target[4][0] * source[1][0] + target[5][0] * source[5][0] + target[6][0] * source[9][0] + target[7][0] * source[13][0]
	result[6] = target[4][0] * source[2][0] + target[5][0] * source[6][0] + target[6][0] * source[10][0] + target[7][0] * source[14][0]
	result[7] = target[4][0] * source[3][0] + target[5][0] * source[7][0] + target[6][0] * source[11][0] + target[7][0] * source[15][0]
	result[8] = target[8][0] * source[0][0] + target[9][0] * source[4][0] + target[10][0] * source[8][0] + target[11][0] * source[12][0]
	result[9] = target[8][0] * source[1][0] + target[9][0] * source[5][0] + target[10][0] * source[9][0] + target[11][0] * source[13][0]
	result[10] = target[8][0] * source[2][0] + target[9][0] * source[6][0] + target[10][0] * source[10][0] + target[11][0] * source[14][0]
	result[11] = target[8][0] * source[3][0] + target[9][0] * source[7][0] + target[10][0] * source[11][0] + target[11][0] * source[15][0]
	result[12] = target[12][0] * source[0][0] + target[13][0] * source[4][0] + target[14][0] * source[8][0] + target[15][0] * source[12][0]
	result[13] = target[12][0] * source[1][0] + target[13][0] * source[5][0] + target[14][0] * source[9][0] + target[15][0] * source[13][0]
	result[14] = target[12][0] * source[2][0] + target[13][0] * source[6][0] + target[14][0] * source[10][0] + target[15][0] * source[14][0]
	result[15] = target[12][0] * source[3][0] + target[13][0] * source[7][0] + target[14][0] * source[11][0] + target[15][0] * source[15][0]
	for i in range(16): target[i][0] = result[i]
cdef inline void mat4_matmul_mat4(float* target[16], float* valueA[16], float* valueB[16]):
	target[0][0] = valueA[0][0] * valueB[0][0] + valueA[1][0] * valueB[4][0] + valueA[2][0] * valueB[8][0] + valueA[3][0] * valueB[12][0]
	target[1][0] = valueA[0][0] * valueB[1][0] + valueA[1][0] * valueB[5][0] + valueA[2][0] * valueB[9][0] + valueA[3][0] * valueB[13][0]
	target[2][0] = valueA[0][0] * valueB[2][0] + valueA[1][0] * valueB[6][0] + valueA[2][0] * valueB[10][0] + valueA[3][0] * valueB[14][0]
	target[3][0] = valueA[0][0] * valueB[3][0] + valueA[1][0] * valueB[7][0] + valueA[2][0] * valueB[11][0] + valueA[3][0] * valueB[15][0]
	target[4][0] = valueA[4][0] * valueB[0][0] + valueA[5][0] * valueB[4][0] + valueA[6][0] * valueB[8][0] + valueA[7][0] * valueB[12][0]
	target[5][0] = valueA[4][0] * valueB[1][0] + valueA[5][0] * valueB[5][0] + valueA[6][0] * valueB[9][0] + valueA[7][0] * valueB[13][0]
	target[6][0] = valueA[4][0] * valueB[2][0] + valueA[5][0] * valueB[6][0] + valueA[6][0] * valueB[10][0] + valueA[7][0] * valueB[14][0]
	target[7][0] = valueA[4][0] * valueB[3][0] + valueA[5][0] * valueB[7][0] + valueA[6][0] * valueB[11][0] + valueA[7][0] * valueB[15][0]
	target[8][0] = valueA[8][0] * valueB[0][0] + valueA[9][0] * valueB[4][0] + valueA[10][0] * valueB[8][0] + valueA[11][0] * valueB[12][0]
	target[9][0] = valueA[8][0] * valueB[1][0] + valueA[9][0] * valueB[5][0] + valueA[10][0] * valueB[9][0] + valueA[11][0] * valueB[13][0]
	target[10][0] = valueA[8][0] * valueB[2][0] + valueA[9][0] * valueB[6][0] + valueA[10][0] * valueB[10][0] + valueA[11][0] * valueB[14][0]
	target[11][0] = valueA[8][0] * valueB[3][0] + valueA[9][0] * valueB[7][0] + valueA[10][0] * valueB[11][0] + valueA[11][0] * valueB[15][0]
	target[12][0] = valueA[12][0] * valueB[0][0] + valueA[13][0] * valueB[4][0] + valueA[14][0] * valueB[8][0] + valueA[15][0] * valueB[12][0]
	target[13][0] = valueA[12][0] * valueB[1][0] + valueA[13][0] * valueB[5][0] + valueA[14][0] * valueB[9][0] + valueA[15][0] * valueB[13][0]
	target[14][0] = valueA[12][0] * valueB[2][0] + valueA[13][0] * valueB[6][0] + valueA[14][0] * valueB[10][0] + valueA[15][0] * valueB[14][0]
	target[15][0] = valueA[12][0] * valueB[3][0] + valueA[13][0] * valueB[7][0] + valueA[14][0] * valueB[11][0] + valueA[15][0] * valueB[15][0]
cdef inline void mat4_matmul_vec4(float* target_vector[4], float* matrix[16], float* vector[4]):
	cdef int i = 0
	cdef int j = 0
	cdef float[4] result
	for i in range(4): result[i] = c_zero_float
	for i in range(4):
		for j in range(4): result[i] += matrix[i * 4 + j][0] * vector[j][0]
	for i in range(4): target_vector[i][0] = result[i]









cdef class vec3_ptr(vec3):

	#cdef float[3] _global_data
	#cdef float _global_magnitude
	#cdef float _global_sqrMagnitude

	#cdef float* _global_data_ptr[3]
	#cdef float* _global_magnitude_ptr
	#cdef float* _global_sqrMagnitude_ptr

	def LinkVector(self, vec3 vector) -> None:
		for i in range(3): self._global_data_ptr[i] = vector._global_data_ptr[i]
		self._global_magnitude_ptr = vector._global_magnitude_ptr
		self._global_sqrMagnitude_ptr = vector._global_sqrMagnitude_ptr

	def LinkMatrix(self, mat3 matrix, int basis) -> None:
		for i in range(3): self._global_data_ptr[i] = matrix._global_data_ptr[basis * 3 + i]
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def Unlink(self) -> None:
		for i in range(3): self._global_data_ptr[i] = &self._global_data[i]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def __repr__(self) -> str:
		return f"vec3({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f})"

	def __len__(self) -> int:
		return 3

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		self._global_data_ptr[0][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		self._global_data_ptr[1][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@property
	def z(self) -> float:
		return self._global_data_ptr[2][0]
	@z.setter
	def z(self, float value) -> None:
		self._global_data_ptr[2][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		for i in range(3): self._global_data_ptr[i] = &self._global_data[i]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y, float z) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def SetVector(self, vec3 value) -> None:
		vec3_set_vec3(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	@property
	def magnitude(self) -> float:
		return vec3_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec3_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._global_data_ptr, self._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def NormalizeFrom(self, vec3 value) -> None:
		vec3_normalize_from(self._global_data_ptr, self._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@staticmethod
	def GetNormalized(vec3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec3 valueA, vec3 valueB) -> float:
		return vec3_dot_product_vec3(valueA._global_data_ptr, valueB._global_data_ptr)

	def CrossProduct(self, vec3 value) -> None:
		vec3_cross_product_in_place(self._global_data_ptr, value._global_data_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def CrossProductFrom(self, vec3 valueA, vec3 valueB) -> None:
		vec3_cross_product_from(self._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	@staticmethod
	def GetCrossProduct(vec3 valueA, vec3 valueB) -> vec3:
		cdef vec3 result = vec3()
		vec3_cross_product_from(result._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return vec3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_lt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_le_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_eq_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ne_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_gt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ge_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_set_vec3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec3') -> vec3_ptr:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_iadd_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __add__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_add_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_add_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec3') -> vec3_ptr:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_isub_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __sub__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_sub_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_sub_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec3') -> vec3_ptr:
		if isinstance(value, vec3):
			vec3_ipow_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ipow_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __pow__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_pow_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_pow_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> vec3_ptr:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_itruediv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __truediv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_truediv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_truediv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec3') -> vec3_ptr:
		if isinstance(value, vec3):
			vec3_ifloordiv_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ifloordiv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __floordiv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_floordiv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_floordiv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec3') -> vec3_ptr:
		if isinstance(value, vec3):
			vec3_imod_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imod_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __mod__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mod_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_mod_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec3') -> vec3_ptr:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imul_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __mul__(self, value: 'allowed_types_vec3_mul') -> Union[vec3, mat3]:
		if isinstance(value, vec3):
			result = vec3()
			vec3_mul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result
		elif isinstance(value, mat3):
			result = mat3()
			vec3_mul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			vec3_mul_float((<vec3>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> vec3_ptr:
		vec3_imatmul_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		return self
	def __matmul__(self, mat3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_matmul_mat3(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result



cdef class vec3_ptr_static(vec3):

	#cdef float[3] _global_data
	#cdef float _global_magnitude
	#cdef float _global_sqrMagnitude

	#cdef float* _global_data_ptr[3]
	#cdef float* _global_magnitude_ptr
	#cdef float* _global_sqrMagnitude_ptr

	def LinkVector(self, vec3 vector) -> None:
		for i in range(3): self._global_data_ptr[i] = vector._global_data_ptr[i]
		self._global_magnitude_ptr = vector._global_magnitude_ptr
		self._global_sqrMagnitude_ptr = vector._global_sqrMagnitude_ptr

	def LinkMatrix(self, mat3 matrix, int basis) -> None:
		for i in range(3): self._global_data_ptr[i] = matrix._global_data_ptr[basis * 3 + i]
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def Unlink(self) -> None:
		for i in range(3): self._global_data_ptr[i] = &self._global_data[i]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float

	def __repr__(self) -> str:
		return f"vec3({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f})"

	def __len__(self) -> int:
		return 3

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		print("Not allowed")

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		print("Not allowed")

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		print("Not allowed")

	@property
	def z(self) -> float:
		return self._global_data_ptr[2][0]
	@z.setter
	def z(self, float value) -> None:
		print("Not allowed")


	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		for i in range(3): self._global_data_ptr[i] = &self._global_data[i]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y, float z) -> None:
		print("Not allowed")

	def SetVector(self, vec3 value) -> None:
		print("Not allowed")


	@property
	def magnitude(self) -> float:
		return vec3_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec3_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		print("Not allowed")

	def NormalizeFrom(self, vec3 value) -> None:
		print("Not allowed")

	@staticmethod
	def GetNormalized(vec3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec3 valueA, vec3 valueB) -> float:
		return vec3_dot_product_vec3(valueA._global_data_ptr, valueB._global_data_ptr)

	def CrossProduct(self, vec3 value) -> None:
		print("Not allowed")

	def CrossProductFrom(self, vec3 valueA, vec3 valueB) -> None:
		print("Not allowed")

	@staticmethod
	def GetCrossProduct(vec3 valueA, vec3 valueB) -> vec3:
		cdef vec3 result = vec3()
		vec3_cross_product_from(result._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return vec3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_lt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_le_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_eq_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ne_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_gt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ge_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_set_vec3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec3') -> vec3_ptr_static:
		print("Not allowed")
		return self
	def __add__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_add_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_add_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec3') -> vec3_ptr_static:
		print("Not allowed")
		return self
	def __sub__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_sub_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_sub_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec3') -> vec3_ptr_static:
		print("Not allowed")
		return self
	def __pow__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_pow_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_pow_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> vec3_ptr_static:
		print("Not allowed")
		return self
	def __truediv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_truediv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_truediv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec3') -> vec3_ptr_static:
		print("Not allowed")
		return self
	def __floordiv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_floordiv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_floordiv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec3') -> vec3_ptr_static:
		print("Not allowed")
		return self
	def __mod__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mod_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_mod_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec3') -> vec3_ptr_static:
		print("Not allowed")
		return self
	def __mul__(self, value: 'allowed_types_vec3_mul') -> Union[vec3, mat3]:
		if isinstance(value, vec3):
			result = vec3()
			vec3_mul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result
		elif isinstance(value, mat3):
			result = mat3()
			vec3_mul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			vec3_mul_float((<vec3>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> vec3_ptr_static:
		print("Not allowed")
		return self
	def __matmul__(self, mat3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_matmul_mat3(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result












cdef class GlobalTransformPosition(vec3):
	cdef Transform _transform

	cdef float* _local_data_ptr[3]
	cdef float* _local_magnitude_ptr
	cdef float* _local_sqrMagnitude_ptr

	#cdef float[3] _global_data
	#cdef float _global_magnitude
	#cdef float _global_sqrMagnitude

	#cdef float* _global_data_ptr[3]
	#cdef float* _global_magnitude_ptr
	#cdef float* _global_sqrMagnitude_ptr

	def __repr__(self) -> str:
		return f"position({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f})"

	def __len__(self) -> int:
		return 3

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._local_data_ptr[index][0] = value
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		self._local_data_ptr[0][0] = value
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		self._local_data_ptr[1][0] = value
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@property
	def z(self) -> float:
		return self._global_data_ptr[2][0]
	@z.setter
	def z(self, float value) -> None:
		self._local_data_ptr[2][0] = value
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)


	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		self._global_data_ptr[0] = &self._global_data[0]
		self._global_data_ptr[1] = &self._global_data[1]
		self._global_data_ptr[2] = &self._global_data[2]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y, float z) -> None:
		self._local_data_ptr[0][0] = x
		self._local_data_ptr[1][0] = y
		self._local_data_ptr[2][0] = z
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	def SetVector(self, vec3 value) -> None:
		vec3_set_vec3(self._local_data_ptr, value._global_data_ptr)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)


	@property
	def magnitude(self) -> float:
		return vec3_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec3_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._local_data_ptr, self._local_magnitude_ptr)
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	def NormalizeFrom(self, vec3 value) -> None:
		vec3_normalize_from(self._local_data_ptr, self._local_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@staticmethod
	def GetNormalized(vec3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec3 valueA, vec3 valueB) -> float:
		return vec3_dot_product_vec3(valueA._global_data_ptr, valueB._global_data_ptr)

	def CrossProduct(self, vec3 value) -> None:
		vec3_cross_product_in_place(self._local_data_ptr, value._global_data_ptr)
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	def CrossProductFrom(self, vec3 valueA, vec3 valueB) -> None:
		vec3_cross_product_from(self._local_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@staticmethod
	def GetCrossProduct(vec3 valueA, vec3 valueB) -> vec3:
		cdef vec3 result = vec3()
		vec3_cross_product_from(result._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return vec3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_lt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_le_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_eq_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ne_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_gt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ge_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_set_vec3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec3') -> GlobalTransformPosition:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_iadd_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __add__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_add_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_add_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec3') -> GlobalTransformPosition:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_isub_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __sub__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_sub_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_sub_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec3') -> GlobalTransformPosition:
		if isinstance(value, vec3):
			vec3_ipow_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ipow_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __pow__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_pow_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_pow_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> GlobalTransformPosition:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_itruediv_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __truediv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_truediv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_truediv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec3') -> GlobalTransformPosition:
		if isinstance(value, vec3):
			vec3_ifloordiv_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ifloordiv_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __floordiv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_floordiv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_floordiv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec3') -> GlobalTransformPosition:
		if isinstance(value, vec3):
			vec3_imod_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imod_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __mod__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mod_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_mod_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec3') -> GlobalTransformPosition:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imul_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __mul__(self, value: 'allowed_types_vec3_mul') -> Union[vec3, mat3]:
		if isinstance(value, vec3):
			result = vec3()
			vec3_mul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result
		elif isinstance(value, mat3):
			result = mat3()
			vec3_mul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			vec3_mul_float((<vec3>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> GlobalTransformPosition:
		vec3_imatmul_mat3(self._local_data_ptr, value._global_data_ptr)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __matmul__(self, mat3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_matmul_mat3(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result


cdef class GlobalTransformScale(vec3):
	cdef Transform _transform

	cdef float* _local_data_ptr[3]
	cdef float* _local_magnitude_ptr
	cdef float* _local_sqrMagnitude_ptr

	#cdef float[3] _global_data
	#cdef float _global_magnitude
	#cdef float _global_sqrMagnitude

	#cdef float* _global_data_ptr[3]
	#cdef float* _global_magnitude_ptr
	#cdef float* _global_sqrMagnitude_ptr

	def __repr__(self) -> str:
		return f"scale({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f})"

	def __len__(self) -> int:
		return 3

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._local_data_ptr[index][0] = value
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		self._local_data_ptr[0][0] = value
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		self._local_data_ptr[1][0] = value
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@property
	def z(self) -> float:
		return self._global_data_ptr[2][0]
	@z.setter
	def z(self, float value) -> None:
		self._local_data_ptr[2][0] = value
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)


	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		self._global_data_ptr[0] = &self._global_data[0]
		self._global_data_ptr[1] = &self._global_data[1]
		self._global_data_ptr[2] = &self._global_data[2]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y, float z) -> None:
		self._local_data_ptr[0][0] = x
		self._local_data_ptr[1][0] = y
		self._local_data_ptr[2][0] = z
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def SetVector(self, vec3 value) -> None:
		vec3_set_vec3(self._local_data_ptr, value._global_data_ptr)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)


	@property
	def magnitude(self) -> float:
		return vec3_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec3_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._local_data_ptr, self._local_magnitude_ptr)
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def NormalizeFrom(self, vec3 value) -> None:
		vec3_normalize_from(self._local_data_ptr, self._local_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@staticmethod
	def GetNormalized(vec3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec3 valueA, vec3 valueB) -> float:
		return vec3_dot_product_vec3(valueA._global_data_ptr, valueB._global_data_ptr)

	def CrossProduct(self, vec3 value) -> None:
		vec3_cross_product_in_place(self._local_data_ptr, value._global_data_ptr)
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def CrossProductFrom(self, vec3 valueA, vec3 valueB) -> None:
		vec3_cross_product_from(self._local_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@staticmethod
	def GetCrossProduct(vec3 valueA, vec3 valueB) -> vec3:
		cdef vec3 result = vec3()
		vec3_cross_product_from(result._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return vec3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_lt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_le_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_eq_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ne_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_gt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ge_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_set_vec3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec3') -> GlobalTransformScale:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_iadd_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __add__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_add_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_add_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec3') -> GlobalTransformScale:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_isub_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __sub__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_sub_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_sub_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec3') -> GlobalTransformScale:
		if isinstance(value, vec3):
			vec3_ipow_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ipow_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __pow__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_pow_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_pow_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> GlobalTransformScale:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_itruediv_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __truediv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_truediv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_truediv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec3') -> GlobalTransformScale:
		if isinstance(value, vec3):
			vec3_ifloordiv_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ifloordiv_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __floordiv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_floordiv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_floordiv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec3') -> GlobalTransformScale:
		if isinstance(value, vec3):
			vec3_imod_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imod_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __mod__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mod_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_mod_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec3') -> GlobalTransformScale:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imul_float(self._local_data_ptr, value)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __mul__(self, value: 'allowed_types_vec3_mul') -> Union[vec3, mat3]:
		if isinstance(value, vec3):
			result = vec3()
			vec3_mul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result
		elif isinstance(value, mat3):
			result = mat3()
			vec3_mul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			vec3_mul_float((<vec3>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> GlobalTransformScale:
		vec3_imatmul_mat3(self._local_data_ptr, value._global_data_ptr)
		self._local_magnitude_ptr[0] = c_neg_one_float
		self._local_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __matmul__(self, mat3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_matmul_mat3(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result


cdef class GlobalTransformRotation(Rotation):
	cdef Transform _transform

	cdef float* _local_data_ptr[9]
	cdef float* _local_determinant_ptr

	#cdef float[9] _global_data
	#cdef float _global_determinant

	#cdef float* _global_data_ptr[9]
	#cdef float* _global_determinant_ptr

	def __repr__(self) -> str:
		return f"Rotation(\n{self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f}\n{self._global_data_ptr[3][0]:.2f}, {self._global_data_ptr[4][0]:.2f}, {self._global_data_ptr[5][0]:.2f}\n{self._global_data_ptr[6][0]:.2f}, {self._global_data_ptr[7][0]:.2f}, {self._global_data_ptr[8][0]:.2f}\n)"

	def __len__(self) -> int:
		return 9

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._local_data_ptr[index][0] = value
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)


	def Rotate(self, float angle, float x, float y, float z) -> GlobalTransformRotation:
		mat3_rotate(self._local_data_ptr, angle, x, y, z)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Gx(self, float angle) -> GlobalTransformRotation:
		mat3_rotate(self._local_data_ptr, angle, c_one_float, c_zero_float, c_zero_float)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Gy(self, float angle) -> GlobalTransformRotation:
		mat3_rotate(self._local_data_ptr, angle, c_zero_float, c_one_float, c_zero_float)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Gz(self, float angle) -> GlobalTransformRotation:
		mat3_rotate(self._local_data_ptr, angle, c_zero_float, c_zero_float, c_one_float)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	
	def Lx(self, float angle) -> GlobalTransformRotation:
		mat3_rotate(self._local_data_ptr, angle, self._global_data_ptr[0][0], self._global_data_ptr[1][0], self._global_data_ptr[2][0])
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Ly(self, float angle) -> GlobalTransformRotation:
		mat3_rotate(self._local_data_ptr, angle, self._global_data_ptr[3][0], self._global_data_ptr[4][0], self._global_data_ptr[5][0])
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Lz(self, float angle) -> GlobalTransformRotation:
		mat3_rotate(self._local_data_ptr, angle, self._global_data_ptr[6][0], self._global_data_ptr[7][0], self._global_data_ptr[8][0])
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self


	def __init__(self, 
		float m11 = c_one_float, float m12 = c_zero_float, float m13 = c_zero_float, 
		float m21 = c_zero_float, float m22 = c_one_float, float m23 = c_zero_float, 
		float m31 = c_zero_float, float m32 = c_zero_float, float m33 = c_one_float) -> None:

		self._global_data[0] = m11
		self._global_data[1] = m12
		self._global_data[2] = m13
		self._global_data[3] = m21
		self._global_data[4] = m22
		self._global_data[5] = m23
		self._global_data[6] = m31
		self._global_data[7] = m32
		self._global_data[8] = m33
		self._global_determinant = c_neg_one_float

		for i in range(9): self._global_data_ptr[i] = &self._global_data[i]
		self._global_determinant_ptr = &self._global_determinant


	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[3][0])
	def CreateCTypeBasisK(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[6][0])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>9).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self,
		float m11, float m12, float m13, 
		float m21, float m22, float m23, 
		float m31, float m32, float m33) -> None:

		self._local_data_ptr[0][0] = m11
		self._local_data_ptr[1][0] = m12
		self._local_data_ptr[2][0] = m13
		self._local_data_ptr[3][0] = m21
		self._local_data_ptr[4][0] = m22
		self._local_data_ptr[5][0] = m23
		self._local_data_ptr[6][0] = m31
		self._local_data_ptr[7][0] = m32
		self._local_data_ptr[8][0] = m33
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def SetMatrix(self, mat3 value) -> None:
		mat3_set_mat3(self._local_data_ptr, value._global_data_ptr)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def SetIdentity(self) -> None:
		self._local_data_ptr[0][0] = c_one_float
		self._local_data_ptr[1][0] = c_zero_float
		self._local_data_ptr[2][0] = c_zero_float
		self._local_data_ptr[3][0] = c_zero_float
		self._local_data_ptr[4][0] = c_one_float
		self._local_data_ptr[5][0] = c_zero_float
		self._local_data_ptr[6][0] = c_zero_float
		self._local_data_ptr[7][0] = c_zero_float
		self._local_data_ptr[8][0] = c_one_float
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)


	@property
	def determinant(self) -> float:
		return mat3_determinant(self._global_data_ptr, self._global_determinant_ptr)
	
	def Inverse(self) -> None:
		mat3_inverse_in_place(self._local_data_ptr, self._local_determinant_ptr)
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
	def InverseFrom(self, mat3 value) -> None:
		mat3_inverse_from(self._local_data_ptr, self._local_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
	@staticmethod
	def GetInverse(mat3 value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_inverse_from(result._global_data_ptr, result._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		return result

	def Transpose(self) -> None:
		mat3_transpose_in_place(self._local_data_ptr)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
	def TransposeFrom(self, mat3 value) -> None:
		mat3_transpose_from(self._local_data_ptr, value._global_data_ptr)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
	@staticmethod
	def GetTransposed(mat3 value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_transpose_from(result._global_data_ptr, value._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return mat3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_lt_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_le_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_le_float(self._global_data_ptr, value)
	
	def __eq__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_eq_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_ne_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_gt_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_ge_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_set_mat3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_mat3') -> GlobalTransformRotation:
		if isinstance(value, mat3):
			mat3_iadd_mat3(self._local_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_iadd_float(self._local_data_ptr, value)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __add__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_add_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_add_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __isub__(self, value: 'allowed_types_mat3') -> GlobalTransformRotation:
		if isinstance(value, mat3):
			mat3_isub_mat3(self._local_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_isub_float(self._local_data_ptr, value)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __sub__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_sub_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_sub_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ipow__(self, value: 'allowed_types_mat3') -> GlobalTransformRotation:
		if isinstance(value, mat3):
			mat3_ipow_mat3(self._local_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_ipow_float(self._local_data_ptr, value)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __pow__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_pow_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_pow_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __itruediv__(self, value: 'allowed_types_mat3') -> GlobalTransformRotation:
		if isinstance(value, mat3):
			mat3_itruediv_mat3(self._local_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_itruediv_float(self._local_data_ptr, value)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __truediv__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_truediv_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_truediv_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_mat3') -> GlobalTransformRotation:
		if isinstance(value, mat3):
			mat3_ifloordiv_mat3(self._local_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_ifloordiv_float(self._local_data_ptr, value)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __floordiv__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_floordiv_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_floordiv_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_mat3') -> GlobalTransformRotation:
		if isinstance(value, mat3):
			mat3_imod_mat3(self._local_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_imod_float(self._local_data_ptr, value)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __mod__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_mod_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_mod_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_mat3_mul') -> GlobalTransformRotation:
		if isinstance(value, mat3):
			mat3_imul_mat3(self._local_data_ptr, (<mat3>value)._global_data_ptr)
		elif isinstance(value, vec3):
			mat3_imul_vec3(self._local_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			mat3_imul_float(self._local_data_ptr, value)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __mul__(self, value: 'allowed_types_mat3_mul') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_mul_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		elif isinstance(value, vec3):
			mat3_mul_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			mat3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmul__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> GlobalTransformRotation:
		mat3_imatmul_mat3(self._local_data_ptr, value._global_data_ptr)
		self._local_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self	
	def __matmul__(self, value: 'allowed_types_mat3_matmul') -> Union[Rotation, vec3]:
		if isinstance(value, mat3):
			result = Rotation()
			mat3_matmul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			mat3_matmul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result



cdef class LocalTransformPosition(vec3):
	cdef Transform _transform

	#cdef float[3] _global_data
	#cdef float _global_magnitude
	#cdef float _global_sqrMagnitude

	#cdef float* _global_data_ptr[3]
	#cdef float* _global_magnitude_ptr
	#cdef float* _global_sqrMagnitude_ptr

	def __repr__(self) -> str:
		return f"position({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f})"

	def __len__(self) -> int:
		return 3

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		self._global_data_ptr[0][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		self._global_data_ptr[1][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@property
	def z(self) -> float:
		return self._global_data_ptr[2][0]
	@z.setter
	def z(self, float value) -> None:
		self._global_data_ptr[2][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		self._global_data_ptr[0] = &self._global_data[0]
		self._global_data_ptr[1] = &self._global_data[1]
		self._global_data_ptr[2] = &self._global_data[2]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y, float z) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	def SetVector(self, vec3 value) -> None:
		vec3_set_vec3(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)


	@property
	def magnitude(self) -> float:
		return vec3_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec3_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._global_data_ptr, self._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	def NormalizeFrom(self, vec3 value) -> None:
		vec3_normalize_from(self._global_data_ptr, self._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@staticmethod
	def GetNormalized(vec3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec3 valueA, vec3 valueB) -> float:
		return vec3_dot_product_vec3(valueA._global_data_ptr, valueB._global_data_ptr)

	def CrossProduct(self, vec3 value) -> None:
		vec3_cross_product_in_place(self._global_data_ptr, value._global_data_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	def CrossProductFrom(self, vec3 valueA, vec3 valueB) -> None:
		vec3_cross_product_from(self._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)

	@staticmethod
	def GetCrossProduct(vec3 valueA, vec3 valueB) -> vec3:
		cdef vec3 result = vec3()
		vec3_cross_product_from(result._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return vec3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_lt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_le_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_eq_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ne_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_gt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ge_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_set_vec3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_iadd_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __add__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_add_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_add_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_isub_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __sub__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_sub_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_sub_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_ipow_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ipow_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __pow__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_pow_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_pow_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_itruediv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __truediv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_truediv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_truediv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_ifloordiv_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ifloordiv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __floordiv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_floordiv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_floordiv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_imod_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imod_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __mod__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mod_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_mod_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imul_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __mul__(self, value: 'allowed_types_vec3_mul') -> Union[vec3, mat3]:
		if isinstance(value, vec3):
			result = vec3()
			vec3_mul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result
		elif isinstance(value, mat3):
			result = mat3()
			vec3_mul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			vec3_mul_float((<vec3>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> LocalTransformPosition:
		vec3_imatmul_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_false_bool)
		return self
	def __matmul__(self, mat3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_matmul_mat3(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result


cdef class LocalTransformScale(vec3):
	cdef Transform _transform

	#cdef float[3] _global_data
	#cdef float _global_magnitude
	#cdef float _global_sqrMagnitude

	#cdef float* _global_data_ptr[3]
	#cdef float* _global_magnitude_ptr
	#cdef float* _global_sqrMagnitude_ptr

	def __repr__(self) -> str:
		return f"scale({self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f})"

	def __len__(self) -> int:
		return 3

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@property
	def x(self) -> float:
		return self._global_data_ptr[0][0]
	@x.setter
	def x(self, float value) -> None:
		self._global_data_ptr[0][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@property
	def y(self) -> float:
		return self._global_data_ptr[1][0]
	@y.setter
	def y(self, float value) -> None:
		self._global_data_ptr[1][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@property
	def z(self) -> float:
		return self._global_data_ptr[2][0]
	@z.setter
	def z(self, float value) -> None:
		self._global_data_ptr[2][0] = value
		self._global_magnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float


	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

		self._global_data_ptr[0] = &self._global_data[0]
		self._global_data_ptr[1] = &self._global_data[1]
		self._global_data_ptr[2] = &self._global_data[2]
		self._global_magnitude_ptr = &self._global_magnitude
		self._global_sqrMagnitude_ptr = &self._global_sqrMagnitude


	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self, float x, float y, float z) -> None:
		self._global_data[0] = x
		self._global_data[1] = y
		self._global_data[2] = z
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def SetVector(self, vec3 value) -> None:
		vec3_set_vec3(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)


	@property
	def magnitude(self) -> float:
		return vec3_magnitude(self._global_data_ptr, self._global_magnitude_ptr)

	@property
	def sqrMagnitude(self) -> float:
		return vec3_sqrMagnitude(self._global_data_ptr, self._global_sqrMagnitude_ptr)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._global_data_ptr, self._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def NormalizeFrom(self, vec3 value) -> None:
		vec3_normalize_from(self._global_data_ptr, self._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@staticmethod
	def GetNormalized(vec3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_normalize_from(result._global_data_ptr, result._global_magnitude_ptr, value._global_data_ptr, (<vec3>value)._global_magnitude_ptr)
		return result

	@staticmethod
	def GetDotProduct(vec3 valueA, vec3 valueB) -> float:
		return vec3_dot_product_vec3(valueA._global_data_ptr, valueB._global_data_ptr)

	def CrossProduct(self, vec3 value) -> None:
		vec3_cross_product_in_place(self._global_data_ptr, value._global_data_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def CrossProductFrom(self, vec3 valueA, vec3 valueB) -> None:
		vec3_cross_product_from(self._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	@staticmethod
	def GetCrossProduct(vec3 valueA, vec3 valueB) -> vec3:
		cdef vec3 result = vec3()
		vec3_cross_product_from(result._global_data_ptr, valueA._global_data_ptr, valueB._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return vec3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_lt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_le_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_le_float(self._global_data_ptr, value)

	def __eq__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_eq_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ne_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_gt_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return vec3_ge_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		return vec3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_set_vec3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_iadd_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __add__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_add_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_add_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __isub__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_isub_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __sub__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_sub_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_sub_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __ipow__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_ipow_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ipow_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __pow__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_pow_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_pow_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_itruediv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __truediv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_truediv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_truediv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_ifloordiv_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_ifloordiv_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __floordiv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_floordiv_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_floordiv_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_imod_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imod_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __mod__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mod_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		float_mod_vec3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			vec3_imul_float(self._global_data_ptr, value)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __mul__(self, value: 'allowed_types_vec3_mul') -> Union[vec3, mat3]:
		if isinstance(value, vec3):
			result = vec3()
			vec3_mul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result
		elif isinstance(value, mat3):
			result = mat3()
			vec3_mul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			vec3_mul_float((<vec3>result)._global_data_ptr, self._global_data_ptr, value)
			return result
	def __rmul__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> LocalTransformScale:
		vec3_imatmul_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_magnitude_ptr[0] = c_neg_one_float
		self._global_sqrMagnitude_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __matmul__(self, mat3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_matmul_mat3(result._global_data_ptr, self._global_data_ptr, value._global_data_ptr)
		return result


cdef class LocalTransformRotation(Rotation):
	cdef Transform _transform

	#cdef float[9] _global_data
	#cdef float _global_determinant

	#cdef float* _global_data_ptr[9]
	#cdef float* _global_determinant_ptr

	def __repr__(self) -> str:
		return f"Rotation(\n{self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f}\n{self._global_data_ptr[3][0]:.2f}, {self._global_data_ptr[4][0]:.2f}, {self._global_data_ptr[5][0]:.2f}\n{self._global_data_ptr[6][0]:.2f}, {self._global_data_ptr[7][0]:.2f}, {self._global_data_ptr[8][0]:.2f}\n)"

	def __len__(self) -> int:
		return 9

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		self._global_data_ptr[index][0] = value
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)


	def Rotate(self, float angle, float x, float y, float z) -> LocalTransformRotation:
		mat3_rotate(self._global_data_ptr, angle, x, y, z)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Gx(self, float angle) -> LocalTransformRotation:
		mat3_rotate(self._global_data_ptr, angle, c_one_float, c_zero_float, c_zero_float)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Gy(self, float angle) -> LocalTransformRotation:
		mat3_rotate(self._global_data_ptr, angle, c_zero_float, c_one_float, c_zero_float)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Gz(self, float angle) -> LocalTransformRotation:
		mat3_rotate(self._global_data_ptr, angle, c_zero_float, c_zero_float, c_one_float)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	
	def Lx(self, float angle) -> LocalTransformRotation:
		mat3_rotate(self._global_data_ptr, angle, self._global_data_ptr[0][0], self._global_data_ptr[1][0], self._global_data_ptr[2][0])
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Ly(self, float angle) -> LocalTransformRotation:
		mat3_rotate(self._global_data_ptr, angle, self._global_data_ptr[3][0], self._global_data_ptr[4][0], self._global_data_ptr[5][0])
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self

	def Lz(self, float angle) -> LocalTransformRotation:
		mat3_rotate(self._global_data_ptr, angle, self._global_data_ptr[6][0], self._global_data_ptr[7][0], self._global_data_ptr[8][0])
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self


	def __init__(self, 
		float m11 = c_one_float, float m12 = c_zero_float, float m13 = c_zero_float, 
		float m21 = c_zero_float, float m22 = c_one_float, float m23 = c_zero_float, 
		float m31 = c_zero_float, float m32 = c_zero_float, float m33 = c_one_float) -> None:

		self._global_data[0] = m11
		self._global_data[1] = m12
		self._global_data[2] = m13
		self._global_data[3] = m21
		self._global_data[4] = m22
		self._global_data[5] = m23
		self._global_data[6] = m31
		self._global_data[7] = m32
		self._global_data[8] = m33
		self._global_determinant = c_neg_one_float

		for i in range(9): self._global_data_ptr[i] = &self._global_data[i]
		self._global_determinant_ptr = &self._global_determinant


	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[0][0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[3][0])
	def CreateCTypeBasisK(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data_ptr[6][0])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>9).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self,
		float m11, float m12, float m13, 
		float m21, float m22, float m23, 
		float m31, float m32, float m33) -> None:

		self._global_data_ptr[0][0] = m11
		self._global_data_ptr[1][0] = m12
		self._global_data_ptr[2][0] = m13
		self._global_data_ptr[3][0] = m21
		self._global_data_ptr[4][0] = m22
		self._global_data_ptr[5][0] = m23
		self._global_data_ptr[6][0] = m31
		self._global_data_ptr[7][0] = m32
		self._global_data_ptr[8][0] = m33
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def SetMatrix(self, mat3 value) -> None:
		mat3_set_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)

	def SetIdentity(self) -> None:
		self._global_data_ptr[0][0] = c_one_float
		self._global_data_ptr[1][0] = c_zero_float
		self._global_data_ptr[2][0] = c_zero_float
		self._global_data_ptr[3][0] = c_zero_float
		self._global_data_ptr[4][0] = c_one_float
		self._global_data_ptr[5][0] = c_zero_float
		self._global_data_ptr[6][0] = c_zero_float
		self._global_data_ptr[7][0] = c_zero_float
		self._global_data_ptr[8][0] = c_one_float
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)


	@property
	def determinant(self) -> float:
		return mat3_determinant(self._global_data_ptr, self._global_determinant_ptr)
	
	def Inverse(self) -> None:
		mat3_inverse_in_place(self._global_data_ptr, self._global_determinant_ptr)
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
	def InverseFrom(self, mat3 value) -> None:
		mat3_inverse_from(self._global_data_ptr, self._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
	@staticmethod
	def GetInverse(mat3 value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_inverse_from(result._global_data_ptr, result._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		return result

	def Transpose(self) -> None:
		mat3_transpose_in_place(self._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
	def TransposeFrom(self, mat3 value) -> None:
		mat3_transpose_from(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
	@staticmethod
	def GetTransposed(mat3 value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_transpose_from(result._global_data_ptr, value._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return mat3_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_lt_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_le_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_le_float(self._global_data_ptr, value)
	
	def __eq__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_eq_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_ne_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_gt_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_mat3') -> bool:
		if isinstance(value, mat3):
			return mat3_ge_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		return mat3_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_set_mat3(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_mat3') -> LocalTransformRotation:
		if isinstance(value, mat3):
			mat3_iadd_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_iadd_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __add__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_add_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_add_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __isub__(self, value: 'allowed_types_mat3') -> LocalTransformRotation:
		if isinstance(value, mat3):
			mat3_isub_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_isub_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __sub__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_sub_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_sub_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ipow__(self, value: 'allowed_types_mat3') -> LocalTransformRotation:
		if isinstance(value, mat3):
			mat3_ipow_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_ipow_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __pow__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_pow_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_pow_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __itruediv__(self, value: 'allowed_types_mat3') -> LocalTransformRotation:
		if isinstance(value, mat3):
			mat3_itruediv_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_itruediv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __truediv__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_truediv_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_truediv_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_mat3') -> LocalTransformRotation:
		if isinstance(value, mat3):
			mat3_ifloordiv_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_ifloordiv_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __floordiv__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_floordiv_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_floordiv_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_mat3') -> LocalTransformRotation:
		if isinstance(value, mat3):
			mat3_imod_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_imod_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __mod__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_mod_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		else:
			mat3_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		float_mod_mat3(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_mat3_mul') -> LocalTransformRotation:
		if isinstance(value, mat3):
			mat3_imul_mat3(self._global_data_ptr, (<mat3>value)._global_data_ptr)
		elif isinstance(value, vec3):
			mat3_imul_vec3(self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			mat3_imul_float(self._global_data_ptr, value)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self
	def __mul__(self, value: 'allowed_types_mat3_mul') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_mul_mat3(result._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
		elif isinstance(value, vec3):
			mat3_mul_vec3(result._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
		else:
			mat3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmul__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat3 value) -> LocalTransformRotation:
		mat3_imatmul_mat3(self._global_data_ptr, value._global_data_ptr)
		self._global_determinant_ptr[0] = c_neg_one_float
		TransformUpdateLocalMatrixSRT(self._transform, c_true_bool)
		return self	
	def __matmul__(self, value: 'allowed_types_mat3_matmul') -> Union[Rotation, vec3]:
		if isinstance(value, mat3):
			result = Rotation()
			mat3_matmul_mat3((<mat3>result)._global_data_ptr, self._global_data_ptr, (<mat3>value)._global_data_ptr)
			return result
		else:
			result = vec3()
			mat3_matmul_vec3((<vec3>result)._global_data_ptr, self._global_data_ptr, (<vec3>value)._global_data_ptr)
			return result


cdef class TransformMatrix(mat4):

	#cdef float[16] _global_data
	#cdef float _global_determinant

	#cdef float* _global_data_ptr[16]
	#cdef float* _global_determinant_ptr

	def __repr__(self) -> str:
		return f"mat4(\n{self._global_data_ptr[0][0]:.2f}, {self._global_data_ptr[1][0]:.2f}, {self._global_data_ptr[2][0]:.2f}, {self._global_data_ptr[3][0]:.2f}\n{self._global_data_ptr[4][0]:.2f}, {self._global_data_ptr[5][0]:.2f}, {self._global_data_ptr[6][0]:.2f}, {self._global_data_ptr[7][0]:.2f}\n{self._global_data_ptr[8][0]:.2f}, {self._global_data_ptr[9][0]:.2f}, {self._global_data_ptr[10][0]:.2f}, {self._global_data_ptr[11][0]:.2f}\n{self._global_data_ptr[12][0]:.2f}, {self._global_data_ptr[13][0]:.2f}, {self._global_data_ptr[14][0]:.2f}, {self._global_data_ptr[15][0]:.2f}\n)"

	def __len__(self) -> int:
		return 16

	def __getitem__(self, int index) -> float:
		return self._global_data_ptr[index][0]
	def __setitem__(self, int index, float value) -> None:
		print("Not allowed")


	def __init__(self, 
		float m11 = c_one_float, float m12 = c_zero_float, float m13 = c_zero_float, float m14 = c_zero_float, 
		float m21 = c_zero_float, float m22 = c_one_float, float m23 = c_zero_float, float m24 = c_zero_float, 
		float m31 = c_zero_float, float m32 = c_zero_float, float m33 = c_one_float, float m34 = c_zero_float,
		float m41 = c_zero_float, float m42 = c_zero_float, float m43 = c_zero_float, float m44 = c_one_float) -> None:

		self._global_data[0] = m11
		self._global_data[1] = m12
		self._global_data[2] = m13
		self._global_data[3] = m14
		self._global_data[4] = m21
		self._global_data[5] = m22
		self._global_data[6] = m23
		self._global_data[7] = m24
		self._global_data[8] = m31
		self._global_data[9] = m32
		self._global_data[10] = m33
		self._global_data[11] = m34
		self._global_data[12] = m41
		self._global_data[13] = m42
		self._global_data[14] = m43
		self._global_data[15] = m44
		self._global_determinant = c_neg_one_float

		for i in range(16): self._global_data_ptr[i] = &self._global_data[i]
		self._global_determinant_ptr = &self._global_determinant


	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[0][0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[4][0])
	def CreateCTypeBasisK(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data_ptr[8][0])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * <size_t>16).from_address(<size_t>&self._global_data_ptr[0][0])


	def SetValues(self,
		float m11, float m12, float m13, float m14, 
		float m21, float m22, float m23, float m24, 
		float m31, float m32, float m33, float m34,
		float m41, float m42, float m43, float m44) -> None:
		print("Not allowed")

	def SetMatrix(self, mat4 value) -> None:
		print("Not allowed")

	def SetIdentity(self) -> None:
		print("Not allowed")


	@property
	def determinant(self) -> float:
		return mat4_determinant(self._global_data_ptr, self._global_determinant_ptr)
	
	def Inverse(self) -> None:
		print("Not allowed")
	def InverseFrom(self, mat4 value) -> None:
		print("Not allowed")
	@staticmethod
	def GetInverse(mat4 value) -> mat4:
		cdef mat4 result = mat4()
		mat4_inverse_from(result._global_data_ptr, result._global_determinant_ptr, value._global_data_ptr, value._global_determinant_ptr)
		return result

	def Transpose(self) -> None:
		print("Not allowed")
	def TransposeFrom(self, mat4 value) -> None:
		print("Not allowed")
	@staticmethod
	def GetTransposed(mat4 value) -> mat4:
		cdef mat4 result = mat4()
		mat4_transpose_from(result._global_data_ptr, value._global_data_ptr)
		return result


	def __contains__(self, float value) -> bool:
		return mat4_contains_float(self._global_data_ptr, value)

	def __lt__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_lt_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_lt_float(self._global_data_ptr, value)
	def __le__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_le_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_le_float(self._global_data_ptr, value)
	
	def __eq__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_eq_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_eq_float(self._global_data_ptr, value)
	def __ne__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_ne_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_ne_float(self._global_data_ptr, value)

	def __gt__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_gt_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_gt_float(self._global_data_ptr, value)
	def __ge__(self, value: 'allowed_types_mat4') -> bool:
		if isinstance(value, mat4):
			return mat4_ge_mat4(self._global_data_ptr, (<mat4>value)._global_data_ptr)
		return mat4_ge_float(self._global_data_ptr, value)


	def __neg__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_neg_from(result._global_data_ptr, self._global_data_ptr)
		return result
	def __pos__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_set_mat4(result._global_data_ptr, self._global_data_ptr)
		return result
	def __abs__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_abs_from(result._global_data_ptr, self._global_data_ptr)
		return result

	def __iadd__(self, value: 'allowed_types_mat4') -> mat4:
		print("Not allowed")
		return self
	def __add__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_add_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_add_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __radd__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_add_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __isub__(self, value: 'allowed_types_mat4') -> mat4:
		print("Not allowed")
		return self
	def __sub__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_sub_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_sub_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rsub__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_sub_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ipow__(self, value: 'allowed_types_mat4') -> mat4:
		print("Not allowed")
		return self
	def __pow__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_pow_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_pow_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rpow__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_pow_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __itruediv__(self, value: 'allowed_types_mat4') -> mat4:
		print("Not allowed")
		return self
	def __truediv__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_truediv_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_truediv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rtruediv__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_truediv_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result
	
	def __ifloordiv__(self, value: 'allowed_types_mat4') -> mat4:
		print("Not allowed")
		return self
	def __floordiv__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_floordiv_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_floordiv_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rfloordiv__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_floordiv_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imod__(self, value: 'allowed_types_mat4') -> mat4:
		print("Not allowed")
		return self
	def __mod__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_mod_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		else:
			mat4_mod_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmod__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		float_mod_mat4(result._global_data_ptr, value, self._global_data_ptr)
		return result

	def __imul__(self, value: 'allowed_types_mat4_mul') -> mat4:
		print("Not allowed")
		return self
	def __mul__(self, value: 'allowed_types_mat4_mul') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_mul_mat4(result._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
		elif isinstance(value, vec4):
			mat4_mul_vec4(result._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
		else:
			mat4_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result
	def __rmul__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		mat4_mul_float(result._global_data_ptr, self._global_data_ptr, value)
		return result

	def __imatmul__(self, mat4 value) -> mat4:
		print("Not allowed")
		return self	
	def __matmul__(self, value: 'allowed_types_mat4_matmul') -> Union[mat4, vec4]:
		if isinstance(value, mat4):
			result = mat4()
			mat4_matmul_mat4((<mat4>result)._global_data_ptr, self._global_data_ptr, (<mat4>value)._global_data_ptr)
			return result
		else:
			result = vec4()
			mat4_matmul_vec4((<vec4>result)._global_data_ptr, self._global_data_ptr, (<vec4>value)._global_data_ptr)
			return result




cdef class Transform:

	_parent: Optional[Transform]
	_children: List[Transform]

	cdef LocalTransformPosition _local_position
	cdef LocalTransformScale _local_scale
	cdef LocalTransformRotation _local_rotation
	cdef vec3_ptr_static _local_forward
	cdef vec3_ptr_static _local_right
	cdef vec3_ptr_static _local_up

	cdef GlobalTransformPosition _global_position
	cdef GlobalTransformScale _global_scale
	cdef GlobalTransformRotation _global_rotation
	cdef vec3_ptr_static _global_forward
	cdef vec3_ptr_static _global_right
	cdef vec3_ptr_static _global_up


	cdef TransformMatrix _local_srt
	cdef float* _local_matrix_scale_rot_srt_ptr[9]

	cdef TransformMatrix _local_trs
	cdef bint _local_obslate_trs
	cdef float* _local_matrix_scale_rot_trs_ptr[16]
	cdef float* _local_matrix_transpose_trs_ptr[16]


	cdef TransformMatrix _global_srt
	cdef float* _global_matrix_scale_rot_srt_ptr[9]

	cdef TransformMatrix _global_trs
	cdef bint _global_obslate_trs
	cdef float* _global_matrix_scale_rot_trs_ptr[16]
	cdef float* _global_matrix_transpose_trs_ptr[16]




	@property
	def local_matrix_srt(self) -> mat4:
		return self._local_srt
	@property
	def matrix_srt(self) -> mat4:
		if(self._parent is not None):
			return self._global_srt
		return self._local_srt


	def GetParent(self) -> Optional[Transform]:
		return self._parent
	def SetParent(self, parent: Optional[Transform]) -> None:
		if(self._parent is not None):
			self._parent._children.remove(self)
		if(parent is not None):
			if(parent._parent is self):
				return
		self._parent = parent
		if(self._parent is not None):
			if(self not in self._parent._children):
				self._parent._children.append(self)
				TransformUpdateGlobalMatrixSRT(self)


	@property
	def local_position(self) -> vec3:
		return self._local_position
	@property
	def position(self) -> vec3:
		if(self._parent is not None):
			return self._global_position
		return self._local_position
	@position.setter
	def position(self, vec3 value) -> None:
		vec3_set_vec3(self._local_position._global_data_ptr, value._global_data_ptr)
		TransformUpdateLocalMatrixSRT(self, c_false_bool)

	@property
	def local_scale(self) -> vec3:
		return self._local_scale
	@property
	def scale(self) -> vec3:
		if(self._parent is not None):
			return self._global_scale
		return self._local_scale
	@scale.setter
	def scale(self, vec3 value) -> None:
		vec3_set_vec3(self._local_scale._global_data_ptr, value._global_data_ptr)
		TransformUpdateLocalMatrixSRT(self, c_true_bool)

	@property
	def local_rotation(self) -> Rotation:
		return self._local_rotation
	@property
	def rotation(self) -> Rotation:
		if(self._parent is not None):
			return self._global_rotation
		return self._local_rotation
	@rotation.setter
	def rotation(self, Rotation value) -> None:
		mat3_set_mat3(self._local_rotation._global_data_ptr, value._global_data_ptr)
		TransformUpdateLocalMatrixSRT(self, c_true_bool)


	@property
	def local_forward(self) -> vec3:
		return self._local_forward
	@property
	def local_right(self) -> vec3:
		return self._local_right
	@property
	def local_up(self) -> vec3:
		return self._local_up


	@property
	def forward(self) -> vec3:
		if(self._parent is not None):
			return self._global_forward
		return self._local_forward
	@property
	def right(self) -> vec3:
		if(self._parent is not None):
			return self._global_right
		return self._local_right
	@property
	def up(self) -> vec3:
		if(self._parent is not None):
			return self._global_up
		return self._local_up


	def __init__(self, vec3 position, vec3 scale, Rotation rotation):
		self._parent = None
		self._children = []

		self._local_position = LocalTransformPosition()
		self._local_position._transform = self
		vec3_set_vec3(self._local_position._global_data_ptr, position._global_data_ptr)

		self._local_scale = LocalTransformScale()
		self._local_scale._transform = self
		vec3_set_vec3(self._local_scale._global_data_ptr, scale._global_data_ptr)

		self._local_rotation = LocalTransformRotation()
		self._local_rotation._transform = self
		mat3_set_mat3(self._local_rotation._global_data_ptr, rotation._global_data_ptr)

		self._local_forward = vec3_ptr_static()
		self._local_forward._global_data_ptr[0] = self._local_rotation._global_data_ptr[6]
		self._local_forward._global_data_ptr[1] = self._local_rotation._global_data_ptr[7]
		self._local_forward._global_data_ptr[2] = self._local_rotation._global_data_ptr[8]
		self._local_right = vec3_ptr_static()
		self._local_right._global_data_ptr[0] = self._local_rotation._global_data_ptr[0]
		self._local_right._global_data_ptr[1] = self._local_rotation._global_data_ptr[1]
		self._local_right._global_data_ptr[2] = self._local_rotation._global_data_ptr[2]
		self._local_up = vec3_ptr_static()
		self._local_up._global_data_ptr[0] = self._local_rotation._global_data_ptr[3]
		self._local_up._global_data_ptr[1] = self._local_rotation._global_data_ptr[4]
		self._local_up._global_data_ptr[2] = self._local_rotation._global_data_ptr[5]


		self._local_srt = TransformMatrix()

		self._local_srt._global_data_ptr[12] = self._local_position._global_data_ptr[0]
		self._local_srt._global_data_ptr[13] = self._local_position._global_data_ptr[1]
		self._local_srt._global_data_ptr[14] = self._local_position._global_data_ptr[2]

		self._local_matrix_scale_rot_srt_ptr[0] = self._local_srt._global_data_ptr[0]
		self._local_matrix_scale_rot_srt_ptr[1] = self._local_srt._global_data_ptr[1]
		self._local_matrix_scale_rot_srt_ptr[2] = self._local_srt._global_data_ptr[2]
		self._local_matrix_scale_rot_srt_ptr[3] = self._local_srt._global_data_ptr[4]
		self._local_matrix_scale_rot_srt_ptr[4] = self._local_srt._global_data_ptr[5]
		self._local_matrix_scale_rot_srt_ptr[5] = self._local_srt._global_data_ptr[6]
		self._local_matrix_scale_rot_srt_ptr[6] = self._local_srt._global_data_ptr[8]
		self._local_matrix_scale_rot_srt_ptr[7] = self._local_srt._global_data_ptr[9]
		self._local_matrix_scale_rot_srt_ptr[8] = self._local_srt._global_data_ptr[10]


		self._local_trs = TransformMatrix()
		self._local_obslate_trs = c_true_bool
		for i in range(16): self._local_matrix_scale_rot_trs_ptr[i] = &c_zero_float
		self._local_matrix_scale_rot_trs_ptr[0] = self._local_matrix_scale_rot_srt_ptr[0]
		self._local_matrix_scale_rot_trs_ptr[1] = self._local_matrix_scale_rot_srt_ptr[1]
		self._local_matrix_scale_rot_trs_ptr[2] = self._local_matrix_scale_rot_srt_ptr[2]
		self._local_matrix_scale_rot_trs_ptr[4] = self._local_matrix_scale_rot_srt_ptr[3]
		self._local_matrix_scale_rot_trs_ptr[5] = self._local_matrix_scale_rot_srt_ptr[4]
		self._local_matrix_scale_rot_trs_ptr[6] = self._local_matrix_scale_rot_srt_ptr[5]
		self._local_matrix_scale_rot_trs_ptr[8] = self._local_matrix_scale_rot_srt_ptr[6]
		self._local_matrix_scale_rot_trs_ptr[9] = self._local_matrix_scale_rot_srt_ptr[7]
		self._local_matrix_scale_rot_trs_ptr[10] = self._local_matrix_scale_rot_srt_ptr[8]
		self._local_matrix_scale_rot_trs_ptr[15] = &c_one_float
		for i in range(16): self._local_matrix_transpose_trs_ptr[i] = &c_zero_float
		self._local_matrix_transpose_trs_ptr[0] = &c_one_float
		self._local_matrix_transpose_trs_ptr[5] = &c_one_float
		self._local_matrix_transpose_trs_ptr[10] = &c_one_float
		self._local_matrix_transpose_trs_ptr[12] = self._local_position._global_data_ptr[0]
		self._local_matrix_transpose_trs_ptr[13] = self._local_position._global_data_ptr[1]
		self._local_matrix_transpose_trs_ptr[14] = self._local_position._global_data_ptr[2]
		self._local_matrix_transpose_trs_ptr[15] = &c_one_float





		self._global_position = GlobalTransformPosition()
		self._global_position._transform = self
		for i in range(3): self._global_position._local_data_ptr[i] = self._local_position._global_data_ptr[i]
		self._global_position._local_magnitude_ptr = self._local_position._global_magnitude_ptr
		self._global_position._local_sqrMagnitude_ptr = self._local_position._global_sqrMagnitude_ptr

		self._global_scale = GlobalTransformScale()
		self._global_scale._transform = self
		for i in range(3): self._global_scale._local_data_ptr[i] = self._local_scale._global_data_ptr[i]
		self._global_scale._local_magnitude_ptr = self._local_scale._global_magnitude_ptr
		self._global_scale._local_sqrMagnitude_ptr = self._local_scale._global_sqrMagnitude_ptr

		self._global_rotation = GlobalTransformRotation()
		self._global_rotation._transform = self
		for i in range(9): self._global_rotation._local_data_ptr[i] = self._local_rotation._global_data_ptr[i]
		self._global_rotation._local_determinant_ptr = self._local_rotation._global_determinant_ptr

		self._global_forward = vec3_ptr_static()
		self._global_forward._global_data_ptr[0] = self._global_rotation._global_data_ptr[6]
		self._global_forward._global_data_ptr[1] = self._global_rotation._global_data_ptr[7]
		self._global_forward._global_data_ptr[2] = self._global_rotation._global_data_ptr[8]
		self._global_right = vec3_ptr_static()
		self._global_right._global_data_ptr[0] = self._global_rotation._global_data_ptr[0]
		self._global_right._global_data_ptr[1] = self._global_rotation._global_data_ptr[1]
		self._global_right._global_data_ptr[2] = self._global_rotation._global_data_ptr[2]
		self._global_up = vec3_ptr_static()
		self._global_up._global_data_ptr[0] = self._global_rotation._global_data_ptr[3]
		self._global_up._global_data_ptr[1] = self._global_rotation._global_data_ptr[4]
		self._global_up._global_data_ptr[2] = self._global_rotation._global_data_ptr[5]


		self._global_srt = TransformMatrix()

		self._global_srt._global_data_ptr[12] = self._global_position._global_data_ptr[0]
		self._global_srt._global_data_ptr[13] = self._global_position._global_data_ptr[1]
		self._global_srt._global_data_ptr[14] = self._global_position._global_data_ptr[2]

		self._global_matrix_scale_rot_srt_ptr[0] = self._global_srt._global_data_ptr[0]
		self._global_matrix_scale_rot_srt_ptr[1] = self._global_srt._global_data_ptr[1]
		self._global_matrix_scale_rot_srt_ptr[2] = self._global_srt._global_data_ptr[2]
		self._global_matrix_scale_rot_srt_ptr[3] = self._global_srt._global_data_ptr[4]
		self._global_matrix_scale_rot_srt_ptr[4] = self._global_srt._global_data_ptr[5]
		self._global_matrix_scale_rot_srt_ptr[5] = self._global_srt._global_data_ptr[6]
		self._global_matrix_scale_rot_srt_ptr[6] = self._global_srt._global_data_ptr[8]
		self._global_matrix_scale_rot_srt_ptr[7] = self._global_srt._global_data_ptr[9]
		self._global_matrix_scale_rot_srt_ptr[8] = self._global_srt._global_data_ptr[10]


		self._global_trs = TransformMatrix()
		self._global_obslate_trs = c_true_bool
		for i in range(16): self._global_matrix_scale_rot_trs_ptr[i] = &c_zero_float
		self._global_matrix_scale_rot_trs_ptr[0] = self._global_matrix_scale_rot_srt_ptr[0]
		self._global_matrix_scale_rot_trs_ptr[1] = self._global_matrix_scale_rot_srt_ptr[1]
		self._global_matrix_scale_rot_trs_ptr[2] = self._global_matrix_scale_rot_srt_ptr[2]
		self._global_matrix_scale_rot_trs_ptr[4] = self._global_matrix_scale_rot_srt_ptr[3]
		self._global_matrix_scale_rot_trs_ptr[5] = self._global_matrix_scale_rot_srt_ptr[4]
		self._global_matrix_scale_rot_trs_ptr[6] = self._global_matrix_scale_rot_srt_ptr[5]
		self._global_matrix_scale_rot_trs_ptr[8] = self._global_matrix_scale_rot_srt_ptr[6]
		self._global_matrix_scale_rot_trs_ptr[9] = self._global_matrix_scale_rot_srt_ptr[7]
		self._global_matrix_scale_rot_trs_ptr[10] = self._global_matrix_scale_rot_srt_ptr[8]
		self._global_matrix_scale_rot_trs_ptr[15] = &c_one_float
		for i in range(16): self._global_matrix_transpose_trs_ptr[i] = &c_zero_float
		self._global_matrix_transpose_trs_ptr[0] = &c_one_float
		self._global_matrix_transpose_trs_ptr[5] = &c_one_float
		self._global_matrix_transpose_trs_ptr[10] = &c_one_float
		self._global_matrix_transpose_trs_ptr[12] = self._global_position._global_data_ptr[0]
		self._global_matrix_transpose_trs_ptr[13] = self._global_position._global_data_ptr[1]
		self._global_matrix_transpose_trs_ptr[14] = self._global_position._global_data_ptr[2]
		self._global_matrix_transpose_trs_ptr[15] = &c_one_float


		TransformUpdateLocalMatrixSRT(self, c_true_bool)


	@property
	def local_matrix_trs(self) -> mat4:
		TransformUpdateLocalMatrixTRS(self)
		return self._local_trs
	@property
	def matrix_trs(self) -> mat4:
		if(self._parent is not None):
			TransformUpdateGlobalMatrixTRS(self)
			return self._global_trs
		TransformUpdateLocalMatrixTRS(self)
		return self._local_trs


cdef inline void TransformUpdateLocalMatrixTRS(Transform transform):
	if(transform._local_obslate_trs):
		mat4_matmul_mat4(
			transform._local_trs._global_data_ptr,
			transform._local_matrix_transpose_trs_ptr,
			transform._local_matrix_scale_rot_trs_ptr
		)
		transform._local_trs._global_determinant_ptr[0] = c_neg_one_float
		transform._local_obslate_trs = c_false_bool

cdef inline void TransformUpdateGlobalMatrixTRS(Transform transform):
	if(transform._global_obslate_trs):
		mat4_matmul_mat4(
			transform._global_trs._global_data_ptr,
			transform._global_matrix_transpose_trs_ptr,
			transform._global_matrix_scale_rot_trs_ptr
		)
		transform._global_trs._global_determinant_ptr[0] = c_neg_one_float
		transform._global_obslate_trs = c_false_bool


cdef inline void TransformUpdateLocalMatrixSRT(Transform transform, bint is_not_pos):

	if(is_not_pos):
		vec3_mul_mat3(
			transform._local_matrix_scale_rot_srt_ptr,
			transform._local_scale._global_data_ptr,
			transform._local_rotation._global_data_ptr
		)
		transform._local_srt._global_determinant_ptr[0] = c_neg_one_float
		transform._local_forward._global_magnitude_ptr[0] = c_neg_one_float
		transform._local_forward._global_sqrMagnitude_ptr[0] = c_neg_one_float
		transform._local_right._global_magnitude_ptr[0] = c_neg_one_float
		transform._local_right._global_sqrMagnitude_ptr[0] = c_neg_one_float
		transform._local_up._global_magnitude_ptr[0] = c_neg_one_float
		transform._local_up._global_sqrMagnitude_ptr[0] = c_neg_one_float
	transform._local_obslate_trs = c_true_bool

	if(transform._parent is not None):
		TransformUpdateGlobalMatrixSRT(<Transform>transform)
	else:
		for child_transform in transform._children:
			TransformUpdateGlobalMatrixSRT(<Transform>child_transform)

cdef inline void TransformUpdateGlobalMatrixSRT(Transform transform):

	mat4_matmul_mat4(
		transform._global_srt._global_data_ptr,
		transform._local_srt._global_data_ptr,
		(<mat4>transform._parent.matrix_srt)._global_data_ptr
	)
	transform._global_srt._global_determinant_ptr[0] = c_neg_one_float
	transform._global_obslate_trs = c_true_bool

	cdef float[3] magnitude
	cdef int i, j, k

	for i in range(3): magnitude[i] = c_zero_float
	for j in range(3):
		for i in range(3):
			k = j*3+i
			magnitude[j] += (
				transform._global_matrix_scale_rot_srt_ptr[k][0]*transform._global_matrix_scale_rot_srt_ptr[k][0]
			)

	for i in range(3):
		transform._global_scale._global_data_ptr[i][0] = magnitude[i]
		if(magnitude[i] != c_zero_float): magnitude[i] = c_one_float / magnitude[i]

	for j in range(3):
		for i in range(3):
			k = j*3+i
			transform._global_rotation._global_data_ptr[k][0] = (
				transform._global_matrix_scale_rot_srt_ptr[k][0]*magnitude[j]
			)

	transform._global_forward._global_magnitude_ptr[0] = c_neg_one_float
	transform._global_forward._global_sqrMagnitude_ptr[0] = c_neg_one_float
	transform._global_right._global_magnitude_ptr[0] = c_neg_one_float
	transform._global_right._global_sqrMagnitude_ptr[0] = c_neg_one_float
	transform._global_up._global_magnitude_ptr[0] = c_neg_one_float
	transform._global_up._global_sqrMagnitude_ptr[0] = c_neg_one_float

	for child_transform in transform._children:
		TransformUpdateGlobalMatrixSRT(<Transform>child_transform)