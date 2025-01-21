# cython: language_level=3, boundscheck=False, wraparound=False, cdivision=True, nonecheck=False
from cpython.float cimport PyFloat_Check
from libc.stdlib cimport malloc, free
from libc.string cimport memset
from libc.math cimport isnan, fabsf, sqrtf, acosf, cosf, sinf, tanf, powf, copysignf
from numpy import radians
from ctypes import c_float, Array
from typing import Optional, Union, List

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

cdef class vec3:
	cdef int _size
	cdef float[3] _global_data
	cdef float _global_magnitude
	cdef float _global_sqrMagnitude

	@property	
	def x(self) -> float:
		return self._global_data[0]
	@x.setter	
	def x(self, float value) -> None:
		self._global_data[0] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	@property
	def y(self) -> float:
		return self._global_data[1]
	@y.setter
	def y(self, float value) -> None:
		self._global_data[1] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	@property
	def z(self) -> float:
		return self._global_data[2]
	@z.setter
	def z(self, float value) -> None:
		self._global_data[2] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float) -> None:
		self._size = 3
		vec3_set(self._global_data, x, y, z)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	def __repr__(self) -> str:
		return f"vec3({self._global_data[0]:.2f}, {self._global_data[1]:.2f}, {self._global_data[2]:.2f})"


	def __len__(self) -> int:
		return self._size
	def __getitem__(self, int index) -> float:
		if index < 0 or index >= self._size: return c_zero_float
		return self._global_data[index]
	def __setitem__(self, int index, float value) -> None:
		if index < 0 or index >= self._size: return
		self._global_data[index] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
	def __contains__(self, float value) -> bool:
		return bool(vec3_contains(self._global_data, value))

	def __neg__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_neg(result._global_data, self._global_data)
		return result
	def __pos__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_copy(result._global_data, self._global_data)
		return result
	def __abs__(self) -> vec3:
		cdef vec3 result = vec3()
		vec3_abs(result._global_data, self._global_data)
		return result

	def __lt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return bool(vec3_lt_vec3(self._global_data, (<vec3>value)._global_data))
		else:
			return bool(vec3_lt_float(self._global_data, <float>value))
	def __le__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return bool(vec3_le_vec3(self._global_data, (<vec3>value)._global_data))
		else:
			return bool(vec3_le_float(self._global_data, <float>value))
	def __eq__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return bool(vec3_eq_vec3(self._global_data, (<vec3>value)._global_data))
		else:
			return bool(vec3_eq_float(self._global_data, <float>value))
	def __ne__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return not vec3_eq_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			return not vec3_eq_float(self._global_data, <float>value)
	def __ge__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return bool(vec3_ge_vec3(self._global_data, (<vec3>value)._global_data))
		else:
			return bool(vec3_ge_float(self._global_data, <float>value))
	def __gt__(self, value: 'allowed_types_vec3') -> bool:
		if isinstance(value, vec3):
			return bool(vec3_gt_vec3(self._global_data, (<vec3>value)._global_data))
		else:
			return bool(vec3_gt_float(self._global_data, <float>value))

	def SetValues(self, float x, float y, float z) -> None:
		vec3_set(self._global_data, x, y, z)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
	def SetVector(self, vec3 value) -> None:
		vec3_copy(self._global_data, value._global_data)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	def CreateCType(self) -> Array[c_float]:
		return (c_float * self._size).from_address(<size_t>&self._global_data[0])

	@property
	def magnitude(self) -> float:
		return vec3_magnitude(self._global_magnitude, self._global_data)
	@property
	def sqrMagnitude(self) -> float:
		return vec3_sqrMagnitude(self._global_sqrMagnitude, self._global_data)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._global_magnitude, self._global_data)
		self._global_sqrMagnitude = c_neg_one_float
	def Normalize_from(self, vec3 value) -> None:
		vec3_normalize_from(self._global_magnitude, self._global_data, value._global_magnitude, value._global_data)
		self._global_sqrMagnitude = c_neg_one_float
	@classmethod
	def GetNormalized(cls, vec3 value) -> vec3:
		cdef vec3 result = vec3()
		vec3_normalize_from(result._global_magnitude, result._global_data, value._global_magnitude, value._global_data)
		result._global_sqrMagnitude = c_neg_one_float
		return result

	def __iadd__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_iadd_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		return self

	def __add__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_add_vec3(result._global_data, self._global_data, (<vec3>value)._global_data)
		else:
			vec3_add_float(result._global_data, self._global_data, <float>value)
		return result

	def __radd__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_radd_float(result._global_data, <float>value, self._global_data)
		return result

	def __isub__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_isub_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		return self

	def __sub__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_sub_vec3(result._global_data, self._global_data, (<vec3>value)._global_data)
		else:
			vec3_sub_float(result._global_data, self._global_data, <float>value)
		return result

	def __rsub__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_rsub_float(result._global_data, <float>value, self._global_data)
		return result

	def __imul__(self, value: 'allowed_types_vec3_mat3') -> vec3:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._global_data, (<vec3>value)._global_data)
		elif isinstance(value, mat3):
			vec3_imul_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			vec3_imul_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		return self

	def __mul__(self, value: 'allowed_types_vec3_mat3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mul_vec3(result._global_data, self._global_data, (<vec3>value)._global_data)
		elif isinstance(value, mat3):
			vec3_mul_mat3(result._global_data, self._global_data, (<mat3>value)._global_data)
		else:
			vec3_mul_float(result._global_data, self._global_data, <float>value)
		return result

	def __rmul__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_mul_vec3(result._global_data, self._global_data, (<vec3>value)._global_data)
		else:
			vec3_mul_float(result._global_data, self._global_data, <float>value)
		return result	
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> vec3:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_itruediv_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		return self
	
	def __truediv__(self, value: 'allowed_types_vec3') -> vec3:
		cdef vec3 result = vec3()
		if isinstance(value, vec3):
			vec3_truediv_vec3(result._global_data, self._global_data, (<vec3>value)._global_data)
		else:
			vec3_truediv_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __rtruediv__(self, float value) -> vec3:
		cdef vec3 result = vec3()
		vec3_rtruediv_float(result._global_data, <float>value, self._global_data)
		return result

allowed_types_vec3 = Union[vec3, float]
allowed_types_vec3_mat3 = Union[vec3, 'mat3', float]


cdef inline bint vec3_contains(float[3] target, float value):
	return (
		target[0] == value or 
		target[1] == value or 
		target[2] == value)

cdef inline void vec3_neg(float[3] target, float[3] value):
	target[0] = -value[0]
	target[1] = -value[1]
	target[2] = -value[2]

cdef inline void vec3_copy(float[3] target, float[3] value):
	target[0] = value[0]
	target[1] = value[1]
	target[2] = value[2]

cdef inline void vec3_abs(float[3] target, float[3] value):
	target[0] = fabsf(value[0])
	target[1] = fabsf(value[1])
	target[2] = fabsf(value[2])

cdef inline bint vec3_lt_vec3(float[3] target, float[3] value):
	return target[0] < value[0] and target[1] < value[1] and target[2] < value[2]
cdef inline bint vec3_lt_float(float[3] target, float value):
	return target[0] < value and target[1] < value and target[2] < value

cdef inline bint vec3_le_vec3(float[3] target, float[3] value):
	return target[0] <= value[0] and target[1] <= value[1] and target[2] <= value[2]
cdef inline bint vec3_le_float(float[3] target, float value):
	return target[0] <= value and target[1] <= value and target[2] <= value

cdef inline bint vec3_eq_vec3(float[3] target, float[3] value):
	return target[0] == value[0] and target[1] == value[1] and target[2] == value[2]
cdef inline bint vec3_eq_float(float[3] target, float value):
	return target[0] == value and target[1] == value and target[2] == value

cdef inline bint vec3_ge_vec3(float[3] target, float[3] value):
	return target[0] >= value[0] and target[1] >= value[1] and target[2] >= value[2]
cdef inline bint vec3_ge_float(float[3] target, float value):
	return target[0] >= value and target[1] >= value and target[2] >= value

cdef inline bint vec3_gt_vec3(float[3] target, float[3] value):
	return target[0] > value[0] and target[1] > value[1] and target[2] > value[2]
cdef inline bint vec3_gt_float(float[3] target, float value):
	return target[0] > value and target[1] > value and target[2] > value

cdef inline void vec3_set(float[3] target, float x, float y, float z):
	target[0] = x
	target[1] = y
	target[2] = z

cdef inline float vec3_magnitude(float magnitude, float[3] vector):
	if(magnitude == c_neg_one_float):
		magnitude = sqrtf(
			vector[0] * vector[0] + 
			vector[1] * vector[1] + 
			vector[2] * vector[2])
	return magnitude

cdef inline float vec3_sqrMagnitude(float sqrMagnitude, float[3] vector):
	if(sqrMagnitude == c_neg_one_float):
		sqrMagnitude = (
			vector[0] * vector[0] + 
			vector[1] * vector[1] + 
			vector[2] * vector[2])
	return sqrMagnitude

cdef inline void vec3_normalize_in_place(float magnitude, float[3] vector):
	cdef float magnitude_value = vec3_magnitude(magnitude, vector)
	if(magnitude_value == c_zero_float): return
	cdef float inv_magnitude_value = c_one_float / magnitude_value
	vector[0] *= inv_magnitude_value
	vector[1] *= inv_magnitude_value
	vector[2] *= inv_magnitude_value
	magnitude = c_one_float

cdef inline void vec3_normalize_from(float target_magnitude, float[3] target_vector, float value_magnitude, float[3] value_vector):
	cdef float magnitude_value = vec3_magnitude(value_magnitude, value_vector)
	if(magnitude_value == c_zero_float): return
	cdef float inv_magnitude_value = c_one_float / magnitude_value
	target_vector[0] = value_vector[0] * inv_magnitude_value
	target_vector[1] = value_vector[1] * inv_magnitude_value
	target_vector[2] = value_vector[2] * inv_magnitude_value
	target_magnitude = c_one_float

cdef inline void vec3_iadd_float(float[3] target, float value):
	target[0] += value
	target[1] += value
	target[2] += value

cdef inline void vec3_iadd_vec3(float[3] target, float[3] value):
	target[0] += value[0]
	target[1] += value[1]
	target[2] += value[2]

cdef inline void vec3_add_float(float[3] target, float[3] valueA, float valueB):
	target[0] = valueA[0] + valueB
	target[1] = valueA[1] + valueB
	target[2] = valueA[2] + valueB

cdef inline void vec3_add_vec3(float[3] target, float[3] valueA, float[3] valueB):
	target[0] = valueA[0] + valueB[0]
	target[1] = valueA[1] + valueB[1]
	target[2] = valueA[2] + valueB[2]

cdef inline void vec3_radd_float(float[3] target, float valueA, float[3] valueB):
	target[0] = valueA + valueB[0]
	target[1] = valueA + valueB[1]
	target[2] = valueA + valueB[2]



cdef inline void vec3_isub_float(float[3] target, float value):
	target[0] -= value
	target[1] -= value
	target[2] -= value

cdef inline void vec3_isub_vec3(float[3] target, float[3] value):
	target[0] -= value[0]
	target[1] -= value[1]
	target[2] -= value[2]

cdef inline void vec3_sub_float(float[3] target, float[3] valueA, float valueB):
	target[0] = valueA[0] - valueB
	target[1] = valueA[1] - valueB
	target[2] = valueA[2] - valueB

cdef inline void vec3_sub_vec3(float[3] target, float[3] valueA, float[3] valueB):
	target[0] = valueA[0] - valueB[0]
	target[1] = valueA[1] - valueB[1]
	target[2] = valueA[2] - valueB[2]

cdef inline void vec3_rsub_float(float[3] target, float valueA, float[3] valueB):
	target[0] = valueA - valueB[0]
	target[1] = valueA - valueB[1]
	target[2] = valueA - valueB[2]



cdef inline void vec3_imul_float(float[3] target, float value):
	target[0] *= value
	target[1] *= value
	target[2] *= value

cdef inline void vec3_imul_vec3(float[3] target, float[3] value):
	target[0] *= value[0]
	target[1] *= value[1]
	target[2] *= value[2]

cdef inline void vec3_mul_float(float[3] target, float[3] valueA, float valueB):
	target[0] = valueA[0] * valueB
	target[1] = valueA[1] * valueB
	target[2] = valueA[2] * valueB

cdef inline void vec3_mul_vec3(float[3] target, float[3] valueA, float[3] valueB):
	target[0] = valueA[0] * valueB[0]
	target[1] = valueA[1] * valueB[1]
	target[2] = valueA[2] * valueB[2]



cdef inline void vec3_itruediv_float(float[3] target, float value):
	if value == c_zero_float: return
	cdef float inv_value = c_one_float / value
	target[0] *= inv_value
	target[1] *= inv_value
	target[2] *= inv_value

cdef inline void vec3_itruediv_vec3(float[3] target, float[3] value):
	if(value[0] != c_zero_float): target[0] /= value[0]
	if(value[1] != c_zero_float): target[1] /= value[1]
	if(value[2] != c_zero_float): target[2] /= value[2]

cdef inline void vec3_truediv_float(float[3] target, float[3] valueA, float valueB):
	if valueB == c_zero_float: return
	cdef float inv_value = c_one_float / valueB
	target[0] = valueA[0] * inv_value
	target[1] = valueA[1] * inv_value
	target[2] = valueA[2] * inv_value

cdef inline void vec3_truediv_vec3(float[3] target, float[3] valueA, float[3] valueB):
	if(valueB[0] != c_zero_float): target[0] = valueA[0] / valueB[0]
	if(valueB[1] != c_zero_float): target[1] = valueA[1] / valueB[1]
	if(valueB[2] != c_zero_float): target[2] = valueA[2] / valueB[2]

cdef inline void vec3_rtruediv_float(float[3] target, float valueA, float[3] valueB):
	if(valueB[0] != c_zero_float): target[0] = valueA / valueB[0]
	if(valueB[1] != c_zero_float): target[1] = valueA / valueB[1]
	if(valueB[2] != c_zero_float): target[2] = valueA / valueB[2]



cdef class mat3:
	cdef int _size
	cdef float[9] _global_data
	cdef float _global_determinant

	def __init__(self,
		float m11 = c_one_float, float m12 = c_zero_float, float m13 = c_zero_float,
		float m21 = c_zero_float, float m22 = c_one_float, float m23 = c_zero_float,
		float m31 = c_zero_float, float m32 = c_zero_float, float m33 = c_one_float
	) -> None:
		self._size = 9
		mat3_set(self._global_data, m11, m12, m13, m21, m22, m23, m31, m32, m33)
		self._global_determinant = c_neg_one_float

	def __repr__(self) -> str:
		return f"""
{self._global_data[0]:.2f} , {self._global_data[1]:.2f} , {self._global_data[2]:.2f}
{self._global_data[3]:.2f} , {self._global_data[4]:.2f} , {self._global_data[5]:.2f}
{self._global_data[6]:.2f} , {self._global_data[7]:.2f} , {self._global_data[8]:.2f}
"""


	def __len__(self) -> int:
		return self._size
	def __getitem__(self, int index) -> float:
		if index < 0 or index >= self._size: return c_zero_float
		return self._global_data[index]
	def __setitem__(self, int index, float value) -> None:
		if index < 0 or index >= self._size: return
		self._global_data[index] = value
		self._global_determinant = c_neg_one_float
	def __contains__(self, float value) -> bool:
		return bool(mat3_contains(self._global_data, value))

	def __neg__(self) -> mat3:
		cdef mat3 result = mat3()
		mat3_neg(result._global_data, self._global_data)
		return result
	def __pos__(self) -> mat3:
		cdef mat3 result = mat3()
		mat3_copy(result._global_data, self._global_data)
		return result
	def __abs__(self) -> mat3:
		cdef mat3 result = mat3()
		mat3_abs(result._global_data, self._global_data)
		return result

	def __lt__(self, float value) -> bool:
		return bool(mat3_lt_float(self._global_data, value))
	def __le__(self, float value) -> bool:
		return bool(mat3_le_float(self._global_data, value))
	def __eq__(self, mat3 value) -> bool:
		return bool(mat3_eq_mat3(self._global_data, value._global_data))
	def __ne__(self, mat3 value) -> bool:
		return not mat3_eq_mat3(self._global_data, value._global_data)
	def __ge__(self, float value) -> bool:
		return bool(mat3_ge_float(self._global_data, value))
	def __gt__(self, float value) -> bool:
		return bool(mat3_gt_float(self._global_data, value))

	def SetValues(self, float m11, float m12, float m13, float m21, float m22, float m23, float m31, float m32, float m33) -> None:
		mat3_set(self._global_data, m11, m12, m13, m21, m22, m23, m31, m32, m33)
		self._global_determinant = c_neg_one_float
	def SetMatrix(self, mat3 value) -> None:
		mat3_copy(self._global_data, value._global_data)
		self._global_determinant = c_neg_one_float

	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data[0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data[3])
	def CreateCTypeBasisK(self) -> Array[c_float]:
		return (c_float * <size_t>3).from_address(<size_t>&self._global_data[6])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * self._size).from_address(<size_t>&self._global_data[0])
	
	@property
	def determinant(self) -> float:
		return mat3_determinant(self._global_determinant, self._global_data)
	
	def Inverse(self) -> mat3:
		mat3_inverse_in_place(self._global_determinant, self._global_data)
		return self
	
	def InverseFrom(self, mat3 value) -> mat3:
		mat3_inverse_from(self._global_determinant, self._global_data, value._global_determinant, value._global_data)
		return self
	
	@classmethod
	def GetInverse(cls, mat3 value) -> mat3:
		cdef mat3 result = mat3()
		mat3_inverse_from(result._global_determinant, result._global_data, value._global_determinant, value._global_data)
		return result

	def __iadd__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_iadd_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_iadd_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self

	def __add__(self, value: 'allowed_types_mat3') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_add_mat3(result._global_data, self._global_data, (<mat3>value)._global_data)
		else:
			mat3_add_float(result._global_data, self._global_data, <float>value)
		return result

	def __radd__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		mat3_add_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __isub__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_isub_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_isub_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self

	def __sub__(self, value: 'allowed_types_mat3') -> mat3:
		cdef mat3 result = mat3()
		if isinstance(value, mat3):
			mat3_sub_mat3(result._global_data, self._global_data, (<mat3>value)._global_data)
		else:
			mat3_sub_float(result._global_data, self._global_data, <float>value)
		return result

	def __rsub__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		mat3_sub_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __imul__(self, value: 'allowed_types_mat3') -> mat3:
		if isinstance(value, mat3):
			mat3_imul_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_imul_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self
	
	def __mul__(self, value: 'allowed_types_mat3_vec3') -> Union[mat3, vec3]:
		if isinstance(value, mat3):
			result = mat3()
			mat3_mul_mat3((<mat3>result)._global_data, self._global_data, (<mat3>value)._global_data)
			return result
		elif isinstance(value, vec3):
			result_vec3 = vec3()
			mat3_mul_vec3((<vec3>result_vec3)._global_data, self._global_data, (<vec3>value)._global_data)
			return result_vec3
		else:
			result = mat3()
			mat3_mul_float((<mat3>result)._global_data, self._global_data, <float>value)
			return result

	def __rmul__(self, float value) -> mat3:
		cdef mat3 result = mat3()
		mat3_mul_float(result._global_data, self._global_data, <float>value)
		return result

allowed_types_mat3 = Union[mat3, float]
allowed_types_mat3_vec3 = Union[mat3, vec3, float]


cdef inline void mat3_set(float[9] target, float m11, float m12, float m13, float m21, float m22, float m23, float m31, float m32, float m33):
	target[0] = m11
	target[1] = m12
	target[2] = m13
	target[3] = m21
	target[4] = m22
	target[5] = m23
	target[6] = m31
	target[7] = m32
	target[8] = m33

cdef inline bint mat3_contains(float[9] target, float value):
	return (
		target[0] == value or 
		target[1] == value or 
		target[2] == value or 
		target[3] == value or 
		target[4] == value or 
		target[5] == value or 
		target[6] == value or 
		target[7] == value or 
		target[8] == value)

cdef inline void mat3_neg(float[9] target, float[9] value):
	target[0] = -value[0]
	target[1] = -value[1]
	target[2] = -value[2]
	target[3] = -value[3]
	target[4] = -value[4]
	target[5] = -value[5]
	target[6] = -value[6]
	target[7] = -value[7]
	target[8] = -value[8]

cdef inline void mat3_copy(float[9] target, float[9] value):
	target[0] = value[0]
	target[1] = value[1]
	target[2] = value[2]
	target[3] = value[3]
	target[4] = value[4]
	target[5] = value[5]
	target[6] = value[6]
	target[7] = value[7]
	target[8] = value[8]

cdef inline void mat3_abs(float[9] target, float[9] value):
	target[0] = fabsf(value[0])
	target[1] = fabsf(value[1])
	target[2] = fabsf(value[2])
	target[3] = fabsf(value[3])
	target[4] = fabsf(value[4])
	target[5] = fabsf(value[5])
	target[6] = fabsf(value[6])
	target[7] = fabsf(value[7])
	target[8] = fabsf(value[8])

cdef inline bint mat3_lt_float(float[9] target, float value):
	return (
		target[0] < value and 
		target[1] < value and 
		target[2] < value and 
		target[3] < value and 
		target[4] < value and 
		target[5] < value and 
		target[6] < value and 
		target[7] < value and 
		target[8] < value)

cdef inline bint mat3_le_float(float[9] target, float value):
	return (
		target[0] <= value and 
		target[1] <= value and 
		target[2] <= value and 
		target[3] <= value and 
		target[4] <= value and 
		target[5] <= value and 
		target[6] <= value and 
		target[7] <= value and 
		target[8] <= value)

cdef inline bint mat3_eq_mat3(float[9] target, float[9] value):
	return (
		target[0] == value[0] and 
		target[1] == value[1] and 
		target[2] == value[2] and 
		target[3] == value[3] and 
		target[4] == value[4] and 
		target[5] == value[5] and 
		target[6] == value[6] and 
		target[7] == value[7] and 
		target[8] == value[8])

cdef inline bint mat3_ge_float(float[9] target, float value):
	return (
		target[0] >= value and 
		target[1] >= value and 
		target[2] >= value and 
		target[3] >= value and 
		target[4] >= value and 
		target[5] >= value and 
		target[6] >= value and 
		target[7] >= value and 
		target[8] >= value)

cdef inline bint mat3_gt_float(float[9] target, float value):
	return (
		target[0] > value and 
		target[1] > value and 
		target[2] > value and 
		target[3] > value and 
		target[4] > value and 
		target[5] > value and 
		target[6] > value and 
		target[7] > value and 
		target[8] > value)



cdef inline void mat3_iadd_float(float[9] target, float value):
	target[0] += value
	target[1] += value
	target[2] += value
	target[3] += value
	target[4] += value
	target[5] += value
	target[6] += value
	target[7] += value
	target[8] += value

cdef inline void mat3_iadd_mat3(float[9] target, float[9] value):
	target[0] += value[0]
	target[1] += value[1]
	target[2] += value[2]
	target[3] += value[3]
	target[4] += value[4]
	target[5] += value[5]
	target[6] += value[6]
	target[7] += value[7]
	target[8] += value[8]

cdef inline void mat3_add_float(float[9] target, float[9] valueA, float valueB):
	target[0] = valueA[0] + valueB
	target[1] = valueA[1] + valueB
	target[2] = valueA[2] + valueB
	target[3] = valueA[3] + valueB
	target[4] = valueA[4] + valueB
	target[5] = valueA[5] + valueB
	target[6] = valueA[6] + valueB
	target[7] = valueA[7] + valueB
	target[8] = valueA[8] + valueB

cdef inline void mat3_add_mat3(float[9] target, float[9] valueA, float[9] valueB):
	target[0] = valueA[0] + valueB[0]
	target[1] = valueA[1] + valueB[1]
	target[2] = valueA[2] + valueB[2]
	target[3] = valueA[3] + valueB[3]
	target[4] = valueA[4] + valueB[4]
	target[5] = valueA[5] + valueB[5]
	target[6] = valueA[6] + valueB[6]
	target[7] = valueA[7] + valueB[7]
	target[8] = valueA[8] + valueB[8]

cdef inline void mat3_radd_float(float[9] target, float valueA, float[9] valueB):
	target[0] = valueA + valueB[0]
	target[1] = valueA + valueB[1]
	target[2] = valueA + valueB[2]
	target[3] = valueA + valueB[3]
	target[4] = valueA + valueB[4]
	target[5] = valueA + valueB[5]
	target[6] = valueA + valueB[6]
	target[7] = valueA + valueB[7]
	target[8] = valueA + valueB[8]



cdef inline void mat3_isub_float(float[9] target, float value):
	target[0] -= value
	target[1] -= value
	target[2] -= value
	target[3] -= value
	target[4] -= value
	target[5] -= value
	target[6] -= value
	target[7] -= value
	target[8] -= value

cdef inline void mat3_isub_mat3(float[9] target, float[9] value):
	target[0] -= value[0]
	target[1] -= value[1]
	target[2] -= value[2]
	target[3] -= value[3]
	target[4] -= value[4]
	target[5] -= value[5]
	target[6] -= value[6]
	target[7] -= value[7]
	target[8] -= value[8]

cdef inline void mat3_sub_float(float[9] target, float[9] valueA, float valueB):
	target[0] = valueA[0] - valueB
	target[1] = valueA[1] - valueB
	target[2] = valueA[2] - valueB
	target[3] = valueA[3] - valueB
	target[4] = valueA[4] - valueB
	target[5] = valueA[5] - valueB
	target[6] = valueA[6] - valueB
	target[7] = valueA[7] - valueB
	target[8] = valueA[8] - valueB

cdef inline void mat3_sub_mat3(float[9] target, float[9] valueA, float[9] valueB):
	target[0] = valueA[0] - valueB[0]
	target[1] = valueA[1] - valueB[1]
	target[2] = valueA[2] - valueB[2]
	target[3] = valueA[3] - valueB[3]
	target[4] = valueA[4] - valueB[4]
	target[5] = valueA[5] - valueB[5]
	target[6] = valueA[6] - valueB[6]
	target[7] = valueA[7] - valueB[7]
	target[8] = valueA[8] - valueB[8]

cdef inline void mat3_rsub_float(float[9] target, float valueA, float[9] valueB):
	target[0] = valueA - valueB[0]
	target[1] = valueA - valueB[1]
	target[2] = valueA - valueB[2]
	target[3] = valueA - valueB[3]
	target[4] = valueA - valueB[4]
	target[5] = valueA - valueB[5]
	target[6] = valueA - valueB[6]
	target[7] = valueA - valueB[7]
	target[8] = valueA - valueB[8]



cdef inline void mat3_imul_float(float[9] target, float value):
	target[0] *= value
	target[1] *= value
	target[2] *= value
	target[3] *= value
	target[4] *= value
	target[5] *= value
	target[6] *= value
	target[7] *= value
	target[8] *= value

cdef inline void mat3_imul_mat3(float[9] target, float[9] value):
	cdef float m11 = target[0] * value[0] + target[1] * value[3] + target[2] * value[6]
	cdef float m12 = target[0] * value[1] + target[1] * value[4] + target[2] * value[7]
	cdef float m13 = target[0] * value[2] + target[1] * value[5] + target[2] * value[8]
	cdef float m21 = target[3] * value[0] + target[4] * value[3] + target[5] * value[6]
	cdef float m22 = target[3] * value[1] + target[4] * value[4] + target[5] * value[7]
	cdef float m23 = target[3] * value[2] + target[4] * value[5] + target[5] * value[8]
	cdef float m31 = target[6] * value[0] + target[7] * value[3] + target[8] * value[6]
	cdef float m32 = target[6] * value[1] + target[7] * value[4] + target[8] * value[7]
	cdef float m33 = target[6] * value[2] + target[7] * value[5] + target[8] * value[8]
	target[0] = m11
	target[1] = m12
	target[2] = m13
	target[3] = m21
	target[4] = m22
	target[5] = m23
	target[6] = m31
	target[7] = m32
	target[8] = m33

cdef inline void mat3_mul_float(float[9] target, float[9] valueA, float valueB):
	target[0] = valueA[0] * valueB
	target[1] = valueA[1] * valueB
	target[2] = valueA[2] * valueB
	target[3] = valueA[3] * valueB
	target[4] = valueA[4] * valueB
	target[5] = valueA[5] * valueB
	target[6] = valueA[6] * valueB
	target[7] = valueA[7] * valueB
	target[8] = valueA[8] * valueB

cdef inline void mat3_mul_mat3(float[9] target, float[9] valueA, float[9] valueB):
	target[0] = valueA[0] * valueB[0] + valueA[1] * valueB[3] + valueA[2] * valueB[6]
	target[1] = valueA[0] * valueB[1] + valueA[1] * valueB[4] + valueA[2] * valueB[7]
	target[2] = valueA[0] * valueB[2] + valueA[1] * valueB[5] + valueA[2] * valueB[8]
	target[3] = valueA[3] * valueB[0] + valueA[4] * valueB[3] + valueA[5] * valueB[6]
	target[4] = valueA[3] * valueB[1] + valueA[4] * valueB[4] + valueA[5] * valueB[7]
	target[5] = valueA[3] * valueB[2] + valueA[4] * valueB[5] + valueA[5] * valueB[8]
	target[6] = valueA[6] * valueB[0] + valueA[7] * valueB[3] + valueA[8] * valueB[6]
	target[7] = valueA[6] * valueB[1] + valueA[7] * valueB[4] + valueA[8] * valueB[7]
	target[8] = valueA[6] * valueB[2] + valueA[7] * valueB[5] + valueA[8] * valueB[8]

cdef inline void vec3_imul_mat3(float[3] target, float[9] value):
	cdef float x = target[0] * value[0] + target[1] * value[3] + target[2] * value[6]
	cdef float y = target[0] * value[1] + target[1] * value[4] + target[2] * value[7]
	cdef float z = target[0] * value[2] + target[1] * value[5] + target[2] * value[8]
	target[0] = x
	target[1] = y
	target[2] = z

cdef inline void vec3_mul_mat3(float[3] target, float[3] valueA, float[9] valueB):
	target[0] = valueA[0] * valueB[0] + valueA[1] * valueB[3] + valueA[2] * valueB[6]
	target[1] = valueA[0] * valueB[1] + valueA[1] * valueB[4] + valueA[2] * valueB[7]
	target[2] = valueA[0] * valueB[2] + valueA[1] * valueB[5] + valueA[2] * valueB[8]

cdef inline void mat3_mul_vec3(float[3] target, float[9] valueA, float[3] valueB):
	target[0] = valueA[0] * valueB[0] + valueA[1] * valueB[1] + valueA[2] * valueB[2]
	target[1] = valueA[3] * valueB[0] + valueA[4] * valueB[1] + valueA[5] * valueB[2]
	target[2] = valueA[6] * valueB[0] + valueA[7] * valueB[1] + valueA[8] * valueB[2]


cdef inline float mat3_determinant(float determinant, float[9] matrix):
	if determinant == c_neg_one_float:
		determinant = (
			matrix[0] * (matrix[4] * matrix[8] - matrix[5] * matrix[7]) -
			matrix[1] * (matrix[3] * matrix[8] - matrix[5] * matrix[6]) +
			matrix[2] * (matrix[3] * matrix[7] - matrix[4] * matrix[6])
		)
	return determinant

cdef inline void mat3_inverse_in_place(float determinant, float[9] matrix):
	cdef float det = mat3_determinant(determinant, matrix)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	cdef float m11 = (matrix[4] * matrix[8] - matrix[5] * matrix[7]) * inv_det
	cdef float m12 = (matrix[2] * matrix[7] - matrix[1] * matrix[8]) * inv_det
	cdef float m13 = (matrix[1] * matrix[5] - matrix[2] * matrix[4]) * inv_det
	cdef float m21 = (matrix[5] * matrix[6] - matrix[3] * matrix[8]) * inv_det
	cdef float m22 = (matrix[0] * matrix[8] - matrix[2] * matrix[6]) * inv_det
	cdef float m23 = (matrix[2] * matrix[3] - matrix[0] * matrix[5]) * inv_det
	cdef float m31 = (matrix[3] * matrix[7] - matrix[4] * matrix[6]) * inv_det
	cdef float m32 = (matrix[1] * matrix[6] - matrix[0] * matrix[7]) * inv_det
	cdef float m33 = (matrix[0] * matrix[4] - matrix[1] * matrix[3]) * inv_det

	matrix[0] = m11
	matrix[1] = m12
	matrix[2] = m13
	matrix[3] = m21
	matrix[4] = m22
	matrix[5] = m23
	matrix[6] = m31
	matrix[7] = m32
	matrix[8] = m33

	determinant = inv_det

cdef inline void mat3_inverse_from(float target_determinant, float[9] target_matrix, float source_determinant, float[9] source_matrix):
	cdef float det = mat3_determinant(source_determinant, source_matrix)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	target_matrix[0] = (source_matrix[4] * source_matrix[8] - source_matrix[5] * source_matrix[7]) * inv_det
	target_matrix[1] = (source_matrix[2] * source_matrix[7] - source_matrix[1] * source_matrix[8]) * inv_det
	target_matrix[2] = (source_matrix[1] * source_matrix[5] - source_matrix[2] * source_matrix[4]) * inv_det
	target_matrix[3] = (source_matrix[5] * source_matrix[6] - source_matrix[3] * source_matrix[8]) * inv_det
	target_matrix[4] = (source_matrix[0] * source_matrix[8] - source_matrix[2] * source_matrix[6]) * inv_det
	target_matrix[5] = (source_matrix[2] * source_matrix[3] - source_matrix[0] * source_matrix[5]) * inv_det
	target_matrix[6] = (source_matrix[3] * source_matrix[7] - source_matrix[4] * source_matrix[6]) * inv_det
	target_matrix[7] = (source_matrix[1] * source_matrix[6] - source_matrix[0] * source_matrix[7]) * inv_det
	target_matrix[8] = (source_matrix[0] * source_matrix[4] - source_matrix[1] * source_matrix[3]) * inv_det

	target_determinant = inv_det



cdef class Rotation(mat3):

	def Rotate(self, float angle, float x, float y, float z) -> Rotation:
		mat3_rotate(self._global_data, angle, x, y, z)
		self._global_determinant = c_neg_one_float
		return self

	def Gx(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, c_one_float, c_zero_float, c_zero_float)
		self._global_determinant = c_neg_one_float
		return self

	def Gy(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, c_zero_float, c_one_float, c_zero_float)
		self._global_determinant = c_neg_one_float
		return self

	def Gz(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, c_zero_float, c_zero_float, c_one_float)
		self._global_determinant = c_neg_one_float
		return self
	
	def Lx(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, self._global_data[0], self._global_data[1], self._global_data[2])
		self._global_determinant = c_neg_one_float
		return self

	def Ly(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, self._global_data[3], self._global_data[4], self._global_data[5])
		self._global_determinant = c_neg_one_float
		return self

	def Lz(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, self._global_data[6], self._global_data[7], self._global_data[8])
		self._global_determinant = c_neg_one_float
		return self

	def __neg__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_neg(result._global_data, self._global_data)
		return result
	def __pos__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_copy(result._global_data, self._global_data)
		return result
	def __abs__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_abs(result._global_data, self._global_data)
		return result

	def Inverse(self) -> Rotation:
		mat3_inverse_in_place(self._global_determinant, self._global_data)
		return self
	def InverseFrom(self, mat3 value) -> Rotation:
		mat3_inverse_from(self._global_determinant, self._global_data, value._global_determinant, value._global_data)
		return self
	@classmethod
	def GetInverse(cls, mat3 value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_inverse_from(result._global_determinant, result._global_data, value._global_determinant, value._global_data)
		return result

	def __iadd__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_iadd_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_iadd_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self

	def __add__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_add_mat3(result._global_data, self._global_data, (<mat3>value)._global_data)
		else:
			mat3_add_float(result._global_data, self._global_data, <float>value)
		return result

	def __radd__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_add_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __isub__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_isub_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_isub_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self

	def __sub__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_sub_mat3(result._global_data, self._global_data, (<mat3>value)._global_data)
		else:
			mat3_sub_float(result._global_data, self._global_data, <float>value)
		return result

	def __rsub__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_sub_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __imul__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_imul_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_imul_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self
	
	def __mul__(self, value: 'allowed_types_mat3_vec3') -> Union[Rotation, vec3]:
		if isinstance(value, mat3):
			result = Rotation()
			mat3_mul_mat3((<Rotation>result)._global_data, self._global_data, (<mat3>value)._global_data)
			return result
		elif isinstance(value, vec3):
			result_vec3 = vec3()
			mat3_mul_vec3((<vec3>result_vec3)._global_data, self._global_data, (<vec3>value)._global_data)
			return result_vec3
		else:
			result = mat3()
			mat3_mul_float((<mat3>result)._global_data, self._global_data, <float>value)
			return result

	def __rmul__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_mul_float(result._global_data, self._global_data, <float>value)
		return result

cdef inline void mat3_rotate(float[9] target, float angle, float x, float y, float z):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = c_one_float - c
	cdef float tx = t * x
	cdef float ty = t * y

	cdef float m11 = tx * x + c
	cdef float m12 = tx * y - s * z
	cdef float m13 = tx * z + s * y
	cdef float m21 = tx * y + s * z
	cdef float m22 = ty * y + c
	cdef float m23 = ty * z - s * x
	cdef float m31 = tx * z - s * y
	cdef float m32 = ty * z + s * x
	cdef float m33 = t * z * z + c

	cdef float m1 = target[0] * m11 + target[1] * m21 + target[2] * m31
	cdef float m2 = target[0] * m12 + target[1] * m22 + target[2] * m32
	cdef float m3 = target[0] * m13 + target[1] * m23 + target[2] * m33
	cdef float m4 = target[3] * m11 + target[4] * m21 + target[5] * m31
	cdef float m5 = target[3] * m12 + target[4] * m22 + target[5] * m32
	cdef float m6 = target[3] * m13 + target[4] * m23 + target[5] * m33
	cdef float m7 = target[6] * m11 + target[7] * m21 + target[8] * m31
	cdef float m8 = target[6] * m12 + target[7] * m22 + target[8] * m32
	cdef float m9 = target[6] * m13 + target[7] * m23 + target[8] * m33

	cdef float n1 = sqrtf(m1*m1 + m2*m2 + m3*m3)
	if(n1 != c_zero_float):
		n1 = c_one_float / n1
		m1 *= n1
		m2 *= n1
		m3 *= n1

	cdef float n2 = sqrtf(m4*m4 + m5*m5 + m6*m6)
	if(n2 != c_zero_float):
		n2 = c_one_float / n2
		m4 *= n2
		m5 *= n2
		m6 *= n2

	cdef float n3 = sqrtf(m7*m7 + m8*m8 + m9*m9)
	if(n3 != c_zero_float):
		n3 = c_one_float / n3
		m7 *= n3
		m8 *= n3
		m9 *= n3

	target[0] = m1
	target[1] = m2
	target[2] = m3
	target[3] = m4
	target[4] = m5
	target[5] = m6
	target[6] = m7
	target[7] = m8
	target[8] = m9


cdef class vec4:
	cdef int _size
	cdef float[4] _global_data
	cdef float _global_magnitude
	cdef float _global_sqrMagnitude

	@property	
	def x(self) -> float:
		return self._global_data[0]
	@x.setter	
	def x(self, float value) -> None:
		self._global_data[0] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	@property
	def y(self) -> float:
		return self._global_data[1]
	@y.setter
	def y(self, float value) -> None:
		self._global_data[1] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	@property
	def z(self) -> float:
		return self._global_data[2]
	@z.setter
	def z(self, float value) -> None:
		self._global_data[2] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	@property
	def w(self) -> float:
		return self._global_data[3]
	@w.setter
	def w(self, float value) -> None:
		self._global_data[3] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	def __init__(self, float x = c_zero_float, float y = c_zero_float, float z = c_zero_float, float w = c_zero_float) -> None:
		self._size = 4
		vec4_set(self._global_data, x, y, z, w)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	def __repr__(self) -> str:
		return f"vec4({self._global_data[0]:.2f}, {self._global_data[1]:.2f}, {self._global_data[2]:.2f}, {self._global_data[3]:.2f})"


	def __len__(self) -> int:
		return self._size
	def __getitem__(self, int index) -> float:
		if index < 0 or index >= self._size: return c_zero_float
		return self._global_data[index]
	def __setitem__(self, int index, float value) -> None:
		if index < 0 or index >= self._size: return
		self._global_data[index] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
	def __contains__(self, float value) -> bool:
		return bool(vec4_contains(self._global_data, value))

	def __neg__(self) -> vec4:
		cdef vec4 result = vec4()
		vec4_neg(result._global_data, self._global_data)
		return result
	def __pos__(self) -> vec4:
		cdef vec4 result = vec4()
		vec4_copy(result._global_data, self._global_data)
		return result
	def __abs__(self) -> vec4:
		cdef vec4 result = vec4()
		vec4_abs(result._global_data, self._global_data)
		return result

	def __lt__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return bool(vec4_lt_vec4(self._global_data, (<vec4>value)._global_data))
		else:
			return bool(vec4_lt_float(self._global_data, <float>value))
	def __le__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return bool(vec4_le_vec4(self._global_data, (<vec4>value)._global_data))
		else:
			return bool(vec4_le_float(self._global_data, <float>value))
	def __eq__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return bool(vec4_eq_vec4(self._global_data, (<vec4>value)._global_data))
		else:
			return bool(vec4_eq_float(self._global_data, <float>value))
	def __ne__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return not vec4_eq_vec4(self._global_data, (<vec4>value)._global_data)
		else:
			return not vec4_eq_float(self._global_data, <float>value)
	def __ge__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return bool(vec4_ge_vec4(self._global_data, (<vec4>value)._global_data))
		else:
			return bool(vec4_ge_float(self._global_data, <float>value))
	def __gt__(self, value: 'allowed_types_vec4') -> bool:
		if isinstance(value, vec4):
			return bool(vec4_gt_vec4(self._global_data, (<vec4>value)._global_data))
		else:
			return bool(vec4_gt_float(self._global_data, <float>value))

	def SetValues(self, float x, float y, float z, float w) -> None:
		vec4_set(self._global_data, x, y, z, w)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
	def SetVector(self, vec4 value) -> None:
		vec4_copy(self._global_data, value._global_data)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float

	def CreateCType(self) -> Array[c_float]:
		return (c_float * self._size).from_address(<size_t>&self._global_data[0])

	@property
	def magnitude(self) -> float:
		return vec4_magnitude(self._global_magnitude, self._global_data)
	@property
	def sqrMagnitude(self) -> float:
		return vec4_sqrMagnitude(self._global_sqrMagnitude, self._global_data)

	def Normalize(self) -> None:
		vec4_normalize_in_place(self._global_magnitude, self._global_data)
		self._global_sqrMagnitude = c_neg_one_float
	def Normalize_from(self, vec4 value) -> None:
		vec4_normalize_from(self._global_magnitude, self._global_data, value._global_magnitude, value._global_data)
		self._global_sqrMagnitude = c_neg_one_float
	@classmethod
	def GetNormalized(cls, vec4 value) -> vec4:
		cdef vec4 result = vec4()
		vec4_normalize_from(result._global_magnitude, result._global_data, value._global_magnitude, value._global_data)
		result._global_sqrMagnitude = c_neg_one_float
		return result

	def __iadd__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_iadd_vec4(self._global_data, (<vec4>value)._global_data)
		else:
			vec4_iadd_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		return self

	def __add__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_add_vec4(result._global_data, self._global_data, (<vec4>value)._global_data)
		else:
			vec4_add_float(result._global_data, self._global_data, <float>value)
		return result

	def __radd__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		vec4_radd_float(result._global_data, <float>value, self._global_data)
		return result

	def __isub__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_isub_vec4(self._global_data, (<vec4>value)._global_data)
		else:
			vec4_isub_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		return self

	def __sub__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_sub_vec4(result._global_data, self._global_data, (<vec4>value)._global_data)
		else:
			vec4_sub_float(result._global_data, self._global_data, <float>value)
		return result

	def __rsub__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		vec4_rsub_float(result._global_data, <float>value, self._global_data)
		return result

	def __imul__(self, value: 'allowed_types_vec4_mat4') -> vec4:
		if isinstance(value, vec4):
			vec4_imul_vec4(self._global_data, (<vec4>value)._global_data)
		elif isinstance(value, mat4):
			vec4_imul_mat4(self._global_data, (<mat4>value)._global_data)
		else:
			vec4_imul_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		return self

	def __mul__(self, value: 'allowed_types_vec4_mat4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_mul_vec4(result._global_data, self._global_data, (<vec4>value)._global_data)
		elif isinstance(value, mat4):
			vec4_mul_mat4(result._global_data, self._global_data, (<mat4>value)._global_data)
		else:
			vec4_mul_float(result._global_data, self._global_data, <float>value)
		return result

	def __rmul__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_mul_vec4(result._global_data, self._global_data, (<vec4>value)._global_data)
		else:
			vec4_mul_float(result._global_data, self._global_data, <float>value)
		return result	
	
	def __itruediv__(self, value: 'allowed_types_vec4') -> vec4:
		if isinstance(value, vec4):
			vec4_itruediv_vec4(self._global_data, (<vec4>value)._global_data)
		else:
			vec4_itruediv_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		return self
	
	def __truediv__(self, value: 'allowed_types_vec4') -> vec4:
		cdef vec4 result = vec4()
		if isinstance(value, vec4):
			vec4_truediv_vec4(result._global_data, self._global_data, (<vec4>value)._global_data)
		else:
			vec4_truediv_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __rtruediv__(self, float value) -> vec4:
		cdef vec4 result = vec4()
		vec4_rtruediv_float(result._global_data, <float>value, self._global_data)
		return result

allowed_types_vec4 = Union[vec4, float]
allowed_types_vec4_mat4 = Union[vec4, 'mat4', float]


cdef inline bint vec4_contains(float[4] target, float value):
	return (
		target[0] == value or 
		target[1] == value or 
		target[2] == value or 
		target[3] == value)

cdef inline void vec4_neg(float[4] target, float[4] value):
	target[0] = -value[0]
	target[1] = -value[1]
	target[2] = -value[2]
	target[3] = -value[3]

cdef inline void vec4_copy(float[4] target, float[4] value):
	target[0] = value[0]
	target[1] = value[1]
	target[2] = value[2]
	target[3] = value[3]

cdef inline void vec4_abs(float[4] target, float[4] value):
	target[0] = fabsf(value[0])
	target[1] = fabsf(value[1])
	target[2] = fabsf(value[2])
	target[3] = fabsf(value[3])

cdef inline bint vec4_lt_vec4(float[4] target, float[4] value):
	return target[0] < value[0] and target[1] < value[1] and target[2] < value[2] and target[3] < value[3]
cdef inline bint vec4_lt_float(float[4] target, float value):
	return target[0] < value and target[1] < value and target[2] < value and target[3] < value

cdef inline bint vec4_le_vec4(float[4] target, float[4] value):
	return target[0] <= value[0] and target[1] <= value[1] and target[2] <= value[2] and target[3] <= value[3]
cdef inline bint vec4_le_float(float[4] target, float value):
	return target[0] <= value and target[1] <= value and target[2] <= value and target[3] <= value

cdef inline bint vec4_eq_vec4(float[4] target, float[4] value):
	return target[0] == value[0] and target[1] == value[1] and target[2] == value[2] and target[3] == value[3]
cdef inline bint vec4_eq_float(float[4] target, float value):
	return target[0] == value and target[1] == value and target[2] == value and target[3] == value

cdef inline bint vec4_ge_vec4(float[4] target, float[4] value):
	return target[0] >= value[0] and target[1] >= value[1] and target[2] >= value[2] and target[3] >= value[3]
cdef inline bint vec4_ge_float(float[4] target, float value):
	return target[0] >= value and target[1] >= value and target[2] >= value and target[3] >= value

cdef inline bint vec4_gt_vec4(float[4] target, float[4] value):
	return target[0] > value[0] and target[1] > value[1] and target[2] > value[2] and target[3] > value[3]
cdef inline bint vec4_gt_float(float[4] target, float value):
	return target[0] > value and target[1] > value and target[2] > value and target[3] > value

cdef inline void vec4_set(float[4] target, float x, float y, float z, float w):
	target[0] = x
	target[1] = y
	target[2] = z
	target[3] = w
cdef inline float vec4_magnitude(float magnitude, float[4] vector):
	if(magnitude == c_neg_one_float):
		magnitude = sqrtf(
			vector[0] * vector[0] + 
			vector[1] * vector[1] + 
			vector[2] * vector[2] + 
			vector[3] * vector[3])
	return magnitude

cdef inline float vec4_sqrMagnitude(float sqrMagnitude, float[4] vector):
	if(sqrMagnitude == c_neg_one_float):
		sqrMagnitude = (
			vector[0] * vector[0] + 
			vector[1] * vector[1] + 
			vector[2] * vector[2] + 
			vector[3] * vector[3])
	return sqrMagnitude

cdef inline void vec4_normalize_in_place(float magnitude, float[4] vector):
	cdef float magnitude_value = vec4_magnitude(magnitude, vector)
	if(magnitude_value == c_zero_float): return
	cdef float inv_magnitude_value = c_one_float / magnitude_value
	vector[0] *= inv_magnitude_value
	vector[1] *= inv_magnitude_value
	vector[2] *= inv_magnitude_value
	vector[3] *= inv_magnitude_value
	magnitude = c_one_float

cdef inline void vec4_normalize_from(float target_magnitude, float[4] target_vector, float value_magnitude, float[4] value_vector):
	cdef float magnitude_value = vec4_magnitude(value_magnitude, value_vector)
	if(magnitude_value == c_zero_float): return
	cdef float inv_magnitude_value = c_one_float / magnitude_value
	target_vector[0] = value_vector[0] * inv_magnitude_value
	target_vector[1] = value_vector[1] * inv_magnitude_value
	target_vector[2] = value_vector[2] * inv_magnitude_value
	target_vector[3] = value_vector[3] * inv_magnitude_value
	target_magnitude = c_one_float

cdef inline void vec4_iadd_float(float[4] target, float value):
	target[0] += value
	target[1] += value
	target[2] += value
	target[3] += value

cdef inline void vec4_iadd_vec4(float[4] target, float[4] value):
	target[0] += value[0]
	target[1] += value[1]
	target[2] += value[2]
	target[3] += value[3]


cdef inline void vec4_add_float(float[4] target, float[4] valueA, float valueB):
	target[0] = valueA[0] + valueB
	target[1] = valueA[1] + valueB
	target[2] = valueA[2] + valueB
	target[3] = valueA[3] + valueB

cdef inline void vec4_add_vec4(float[4] target, float[4] valueA, float[4] valueB):
	target[0] = valueA[0] + valueB[0]
	target[1] = valueA[1] + valueB[1]
	target[2] = valueA[2] + valueB[2]
	target[3] = valueA[3] + valueB[3]

cdef inline void vec4_radd_float(float[4] target, float valueA, float[4] valueB):
	target[0] = valueA + valueB[0]
	target[1] = valueA + valueB[1]
	target[2] = valueA + valueB[2]
	target[3] = valueA + valueB[3]



cdef inline void vec4_isub_float(float[4] target, float value):
	target[0] -= value
	target[1] -= value
	target[2] -= value
	target[3] -= value

cdef inline void vec4_isub_vec4(float[4] target, float[4] value):
	target[0] -= value[0]
	target[1] -= value[1]
	target[2] -= value[2]
	target[3] -= value[3]

cdef inline void vec4_sub_float(float[4] target, float[4] valueA, float valueB):
	target[0] = valueA[0] - valueB
	target[1] = valueA[1] - valueB
	target[2] = valueA[2] - valueB
	target[3] = valueA[3] - valueB

cdef inline void vec4_sub_vec4(float[4] target, float[4] valueA, float[4] valueB):
	target[0] = valueA[0] - valueB[0]
	target[1] = valueA[1] - valueB[1]
	target[2] = valueA[2] - valueB[2]
	target[3] = valueA[3] - valueB[3]

cdef inline void vec4_rsub_float(float[4] target, float valueA, float[4] valueB):
	target[0] = valueA - valueB[0]
	target[1] = valueA - valueB[1]
	target[2] = valueA - valueB[2]
	target[3] = valueA - valueB[3]



cdef inline void vec4_imul_float(float[4] target, float value):
	target[0] *= value
	target[1] *= value
	target[2] *= value
	target[3] *= value

cdef inline void vec4_imul_vec4(float[4] target, float[4] value):
	target[0] *= value[0]
	target[1] *= value[1]
	target[2] *= value[2]
	target[3] *= value[3]

cdef inline void vec4_mul_float(float[4] target, float[4] valueA, float valueB):
	target[0] = valueA[0] * valueB
	target[1] = valueA[1] * valueB
	target[2] = valueA[2] * valueB
	target[3] = valueA[3] * valueB


cdef inline void vec4_mul_vec4(float[4] target, float[4] valueA, float[4] valueB):
	target[0] = valueA[0] * valueB[0]
	target[1] = valueA[1] * valueB[1]
	target[2] = valueA[2] * valueB[2]
	target[3] = valueA[3] * valueB[3]


cdef inline void vec4_itruediv_float(float[4] target, float value):
	if value == c_zero_float: return
	cdef float inv_value = c_one_float / value
	target[0] *= inv_value
	target[1] *= inv_value
	target[2] *= inv_value
	target[3] *= inv_value

cdef inline void vec4_itruediv_vec4(float[4] target, float[4] value):
	if(value[0] != c_zero_float): target[0] /= value[0]
	if(value[1] != c_zero_float): target[1] /= value[1]
	if(value[2] != c_zero_float): target[2] /= value[2]
	if(value[3] != c_zero_float): target[3] /= value[3]

cdef inline void vec4_truediv_float(float[4] target, float[4] valueA, float valueB):
	if valueB == c_zero_float: return
	cdef float inv_value = c_one_float / valueB
	target[0] = valueA[0] * inv_value
	target[1] = valueA[1] * inv_value
	target[2] = valueA[2] * inv_value
	target[3] = valueA[3] * inv_value

cdef inline void vec4_truediv_vec4(float[4] target, float[4] valueA, float[4] valueB):
	if(valueB[0] != c_zero_float): target[0] = valueA[0] / valueB[0]
	if(valueB[1] != c_zero_float): target[1] = valueA[1] / valueB[1]
	if(valueB[2] != c_zero_float): target[2] = valueA[2] / valueB[2]
	if(valueB[3] != c_zero_float): target[3] = valueA[3] / valueB[3]

cdef inline void vec4_rtruediv_float(float[4] target, float valueA, float[4] valueB):
	if(valueB[0] != c_zero_float): target[0] = valueA / valueB[0]
	if(valueB[1] != c_zero_float): target[1] = valueA / valueB[1]
	if(valueB[2] != c_zero_float): target[2] = valueA / valueB[2]
	if(valueB[3] != c_zero_float): target[3] = valueA / valueB[3]





cdef class mat4:
	cdef int _size
	cdef float[16] _global_data
	cdef float _global_determinant

	def __init__(self,
		float m11 = c_one_float, float m12 = c_zero_float, float m13 = c_zero_float, float m14 = c_zero_float,
		float m21 = c_zero_float, float m22 = c_one_float, float m23 = c_zero_float, float m24 = c_zero_float,
		float m31 = c_zero_float, float m32 = c_zero_float, float m33 = c_one_float, float m34 = c_zero_float,
		float m41 = c_zero_float, float m42 = c_zero_float, float m43 = c_zero_float, float m44 = c_one_float
	) -> None:
		self._size = 16	
		mat4_set(self._global_data, m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44)
		self._global_determinant = c_neg_one_float

	def __repr__(self) -> str:
		return f"""
{self._global_data[0]:.2f} , {self._global_data[1]:.2f} , {self._global_data[2]:.2f} , {self._global_data[3]:.2f}
{self._global_data[4]:.2f} , {self._global_data[5]:.2f} , {self._global_data[6]:.2f} , {self._global_data[7]:.2f}
{self._global_data[8]:.2f} , {self._global_data[9]:.2f} , {self._global_data[10]:.2f} , {self._global_data[11]:.2f}
{self._global_data[12]:.2f} , {self._global_data[13]:.2f} , {self._global_data[14]:.2f} , {self._global_data[15]:.2f}
"""


	def __len__(self) -> int:
		return self._size
	def __getitem__(self, int index) -> float:
		if index < 0 or index >= self._size: return c_zero_float
		return self._global_data[index]
	def __setitem__(self, int index, float value) -> None:
		if index < 0 or index >= self._size: return
		self._global_data[index] = value
		self._global_determinant = c_neg_one_float
	def __contains__(self, float value) -> bool:
		return bool(mat4_contains(self._global_data, value))

	def __neg__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_neg(result._global_data, self._global_data)
		return result
	def __pos__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_copy(result._global_data, self._global_data)
		return result
	def __abs__(self) -> mat4:
		cdef mat4 result = mat4()
		mat4_abs(result._global_data, self._global_data)
		return result

	def __lt__(self, float value) -> bool:
		return bool(mat4_lt_float(self._global_data, value))
	def __le__(self, float value) -> bool:
		return bool(mat4_le_float(self._global_data, value))
	def __eq__(self, mat4 value) -> bool:
		return bool(mat4_eq_mat4(self._global_data, value._global_data))
	def __ne__(self, mat4 value) -> bool:
		return not mat4_eq_mat4(self._global_data, value._global_data)
	def __ge__(self, float value) -> bool:
		return bool(mat4_ge_float(self._global_data, value))
	def __gt__(self, float value) -> bool:
		return bool(mat4_gt_float(self._global_data, value))

	def SetValues(self, float m11, float m12, float m13, float m14, float m21, float m22, float m23, float m24, float m31, float m32, float m33, float m34, float m41, float m42, float m43, float m44) -> None:
		mat4_set(self._global_data, m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44)
		self._global_determinant = c_neg_one_float
	def SetMatrix(self, mat4 value) -> None:
		mat4_copy(self._global_data, value._global_data)
		self._global_determinant = c_neg_one_float

	def CreateCTypeBasisI(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data[0])
	def CreateCTypeBasisJ(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data[4])
	def CreateCTypeBasisK(self) -> Array[c_float]:
		return (c_float * <size_t>4).from_address(<size_t>&self._global_data[8])
	def CreateCType(self) -> Array[c_float]:
		return (c_float * self._size).from_address(<size_t>&self._global_data[0])
	
	@property
	def determinant(self) -> float:
		return mat4_determinant(self._global_determinant, self._global_data)
	
	def Inverse(self) -> mat4:
		mat4_inverse_in_place(self._global_determinant, self._global_data)
		return self
	
	def InverseFrom(self, mat4 value) -> mat4:
		mat4_inverse_from(self._global_determinant, self._global_data, value._global_determinant, value._global_data)
		return self
	
	@classmethod
	def GetInverse(cls, mat4 value) -> mat4:
		cdef mat4 result = mat4()
		mat4_inverse_from(result._global_determinant, result._global_data, value._global_determinant, value._global_data)
		return result

	def __iadd__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_iadd_mat4(self._global_data, (<mat4>value)._global_data)
		else:
			mat4_iadd_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self

	def __add__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_add_mat4(result._global_data, self._global_data, (<mat4>value)._global_data)
		else:
			mat4_add_float(result._global_data, self._global_data, <float>value)
		return result

	def __radd__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		mat4_add_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __isub__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_isub_mat4(self._global_data, (<mat4>value)._global_data)
		else:
			mat4_isub_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self

	def __sub__(self, value: 'allowed_types_mat4') -> mat4:
		cdef mat4 result = mat4()
		if isinstance(value, mat4):
			mat4_sub_mat4(result._global_data, self._global_data, (<mat4>value)._global_data)
		else:
			mat4_sub_float(result._global_data, self._global_data, <float>value)
		return result

	def __rsub__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		mat4_sub_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __imul__(self, value: 'allowed_types_mat4') -> mat4:
		if isinstance(value, mat4):
			mat4_imul_mat4(self._global_data, (<mat4>value)._global_data)
		else:
			mat4_imul_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		return self
	
	def __mul__(self, value: 'allowed_types_mat4_vec4') -> Union[mat4, vec4]:
		if isinstance(value, mat4):
			result = mat4()
			mat4_mul_mat4((<mat4>result)._global_data, self._global_data, (<mat4>value)._global_data)
			return result
		elif isinstance(value, vec4):
			result_vec4 = vec4()
			mat4_mul_vec4((<vec4>result_vec4)._global_data, self._global_data, (<vec4>value)._global_data)
			return result_vec4
		else:
			result = mat4()
			mat4_mul_float((<mat4>result)._global_data, self._global_data, <float>value)
			return result

	def __rmul__(self, float value) -> mat4:
		cdef mat4 result = mat4()
		mat4_mul_float(result._global_data, self._global_data, <float>value)
		return result

allowed_types_mat4 = Union[mat4, float]
allowed_types_mat4_vec4 = Union[mat4, vec4, float]


cdef inline void mat4_set(float[16] target, float m11, float m12, float m13, float m14, float m21, float m22, float m23, float m24, float m31, float m32, float m33, float m34, float m41, float m42, float m43, float m44):
	target[0] = m11
	target[1] = m12
	target[2] = m13
	target[3] = m14
	target[4] = m21
	target[5] = m22
	target[6] = m23
	target[7] = m24
	target[8] = m31
	target[9] = m32
	target[10] = m33
	target[11] = m34
	target[12] = m41
	target[13] = m42
	target[14] = m43
	target[15] = m44

cdef inline bint mat4_contains(float[16] target, float value):
	return (
		target[0] == value or 
		target[1] == value or 
		target[2] == value or 
		target[3] == value or 
		target[4] == value or 
		target[5] == value or 
		target[6] == value or 
		target[7] == value or 
		target[8] == value or 
		target[9] == value or 
		target[10] == value or 
		target[11] == value or 
		target[12] == value or 
		target[13] == value or 
		target[14] == value or 
		target[15] == value)

cdef inline void mat4_neg(float[16] target, float[16] value):
	target[0] = -value[0]
	target[1] = -value[1]
	target[2] = -value[2]
	target[3] = -value[3]
	target[4] = -value[4]
	target[5] = -value[5]
	target[6] = -value[6]
	target[7] = -value[7]
	target[8] = -value[8]
	target[9] = -value[9]
	target[10] = -value[10]
	target[11] = -value[11]
	target[12] = -value[12]
	target[13] = -value[13]
	target[14] = -value[14]
	target[15] = -value[15]


cdef inline void mat4_copy(float[16] target, float[16] value):
	target[0] = value[0]
	target[1] = value[1]
	target[2] = value[2]
	target[3] = value[3]
	target[4] = value[4]
	target[5] = value[5]
	target[6] = value[6]
	target[7] = value[7]
	target[8] = value[8]
	target[9] = value[9]
	target[10] = value[10]
	target[11] = value[11]
	target[12] = value[12]
	target[13] = value[13]
	target[14] = value[14]
	target[15] = value[15]


cdef inline void mat4_abs(float[16] target, float[16] value):
	target[0] = fabsf(value[0])
	target[1] = fabsf(value[1])
	target[2] = fabsf(value[2])
	target[3] = fabsf(value[3])
	target[4] = fabsf(value[4])
	target[5] = fabsf(value[5])
	target[6] = fabsf(value[6])
	target[7] = fabsf(value[7])
	target[8] = fabsf(value[8])
	target[9] = fabsf(value[9])
	target[10] = fabsf(value[10])
	target[11] = fabsf(value[11])
	target[12] = fabsf(value[12])
	target[13] = fabsf(value[13])
	target[14] = fabsf(value[14])
	target[15] = fabsf(value[15])


cdef inline bint mat4_lt_float(float[16] target, float value):
	return (
		target[0] < value and 
		target[1] < value and 
		target[2] < value and 
		target[3] < value and 
		target[4] < value and 
		target[5] < value and 
		target[6] < value and 
		target[7] < value and 
		target[8] < value and 
		target[9] < value and 
		target[10] < value and 
		target[11] < value and 
		target[12] < value and 
		target[13] < value and 
		target[14] < value and 
		target[15] < value)

cdef inline bint mat4_le_float(float[16] target, float value):
	return (
		target[0] <= value and 
		target[1] <= value and 
		target[2] <= value and 
		target[3] <= value and 
		target[4] <= value and 
		target[5] <= value and 
		target[6] <= value and 
		target[7] <= value and 
		target[8] <= value and 
		target[9] <= value and 
		target[10] <= value and 
		target[11] <= value and 
		target[12] <= value and 
		target[13] <= value and 
		target[14] <= value and 
		target[15] <= value)

cdef inline bint mat4_eq_mat4(float[16] target, float[16] value):
	return (
		target[0] == value[0] and 
		target[1] == value[1] and 
		target[2] == value[2] and 
		target[3] == value[3] and 
		target[4] == value[4] and 
		target[5] == value[5] and 
		target[6] == value[6] and 
		target[7] == value[7] and 
		target[8] == value[8] and 
		target[9] == value[9] and 
		target[10] == value[10] and 
		target[11] == value[11] and 
		target[12] == value[12] and 
		target[13] == value[13] and 
		target[14] == value[14] and 
		target[15] == value[15])

cdef inline bint mat4_ge_float(float[16] target, float value):
	return (
		target[0] >= value and 
		target[1] >= value and 
		target[2] >= value and 
		target[3] >= value and 
		target[4] >= value and 
		target[5] >= value and 
		target[6] >= value and 
		target[7] >= value and 
		target[8] >= value and 
		target[9] >= value and 
		target[10] >= value and 
		target[11] >= value and 
		target[12] >= value and 
		target[13] >= value and 
		target[14] >= value and 
		target[15] >= value)

cdef inline bint mat4_gt_float(float[16] target, float value):
	return (
		target[0] > value and 
		target[1] > value and 
		target[2] > value and 
		target[3] > value and 
		target[4] > value and 
		target[5] > value and 
		target[6] > value and 
		target[7] > value and 
		target[8] > value and 
		target[9] > value and 
		target[10] > value and 
		target[11] > value and 
		target[12] > value and 
		target[13] > value and 
		target[14] > value and 
		target[15] > value)



cdef inline void mat4_iadd_float(float[16] target, float value):
	target[0] += value
	target[1] += value
	target[2] += value
	target[3] += value
	target[4] += value
	target[5] += value
	target[6] += value
	target[7] += value
	target[8] += value
	target[9] += value
	target[10] += value
	target[11] += value
	target[12] += value
	target[13] += value
	target[14] += value
	target[15] += value


cdef inline void mat4_iadd_mat4(float[16] target, float[16] value):
	target[0] += value[0]
	target[1] += value[1]
	target[2] += value[2]
	target[3] += value[3]
	target[4] += value[4]
	target[5] += value[5]
	target[6] += value[6]
	target[7] += value[7]
	target[8] += value[8]
	target[9] += value[9]
	target[10] += value[10]
	target[11] += value[11]
	target[12] += value[12]
	target[13] += value[13]
	target[14] += value[14]
	target[15] += value[15]


cdef inline void mat4_add_float(float[16] target, float[16] valueA, float valueB):
	target[0] = valueA[0] + valueB
	target[1] = valueA[1] + valueB
	target[2] = valueA[2] + valueB
	target[3] = valueA[3] + valueB
	target[4] = valueA[4] + valueB
	target[5] = valueA[5] + valueB
	target[6] = valueA[6] + valueB
	target[7] = valueA[7] + valueB
	target[8] = valueA[8] + valueB
	target[9] = valueA[9] + valueB
	target[10] = valueA[10] + valueB
	target[11] = valueA[11] + valueB
	target[12] = valueA[12] + valueB
	target[13] = valueA[13] + valueB
	target[14] = valueA[14] + valueB
	target[15] = valueA[15] + valueB


cdef inline void mat4_add_mat4(float[16] target, float[16] valueA, float[16] valueB):
	target[0] = valueA[0] + valueB[0]
	target[1] = valueA[1] + valueB[1]
	target[2] = valueA[2] + valueB[2]
	target[3] = valueA[3] + valueB[3]
	target[4] = valueA[4] + valueB[4]
	target[5] = valueA[5] + valueB[5]
	target[6] = valueA[6] + valueB[6]
	target[7] = valueA[7] + valueB[7]
	target[8] = valueA[8] + valueB[8]
	target[9] = valueA[9] + valueB[9]
	target[10] = valueA[10] + valueB[10]
	target[11] = valueA[11] + valueB[11]
	target[12] = valueA[12] + valueB[12]
	target[13] = valueA[13] + valueB[13]
	target[14] = valueA[14] + valueB[14]
	target[15] = valueA[15] + valueB[15]


cdef inline void mat4_radd_float(float[16] target, float valueA, float[16] valueB):
	target[0] = valueA + valueB[0]
	target[1] = valueA + valueB[1]
	target[2] = valueA + valueB[2]
	target[3] = valueA + valueB[3]
	target[4] = valueA + valueB[4]
	target[5] = valueA + valueB[5]
	target[6] = valueA + valueB[6]
	target[7] = valueA + valueB[7]
	target[8] = valueA + valueB[8]
	target[9] = valueA + valueB[9]
	target[10] = valueA + valueB[10]
	target[11] = valueA + valueB[11]
	target[12] = valueA + valueB[12]
	target[13] = valueA + valueB[13]
	target[14] = valueA + valueB[14]
	target[15] = valueA + valueB[15]


cdef inline void mat4_isub_float(float[16] target, float value):
	target[0] -= value
	target[1] -= value
	target[2] -= value
	target[3] -= value
	target[4] -= value
	target[5] -= value
	target[6] -= value
	target[7] -= value
	target[8] -= value
	target[9] -= value
	target[10] -= value
	target[11] -= value
	target[12] -= value
	target[13] -= value
	target[14] -= value
	target[15] -= value


cdef inline void mat4_isub_mat4(float[16] target, float[16] value):
	target[0] -= value[0]
	target[1] -= value[1]
	target[2] -= value[2]
	target[3] -= value[3]
	target[4] -= value[4]
	target[5] -= value[5]
	target[6] -= value[6]
	target[7] -= value[7]
	target[8] -= value[8]
	target[9] -= value[9]
	target[10] -= value[10]
	target[11] -= value[11]
	target[12] -= value[12]
	target[13] -= value[13]
	target[14] -= value[14]
	target[15] -= value[15]


cdef inline void mat4_sub_float(float[16] target, float[16] valueA, float valueB):
	target[0] = valueA[0] - valueB
	target[1] = valueA[1] - valueB
	target[2] = valueA[2] - valueB
	target[3] = valueA[3] - valueB
	target[4] = valueA[4] - valueB
	target[5] = valueA[5] - valueB
	target[6] = valueA[6] - valueB
	target[7] = valueA[7] - valueB
	target[8] = valueA[8] - valueB
	target[9] = valueA[9] - valueB
	target[10] = valueA[10] - valueB
	target[11] = valueA[11] - valueB
	target[12] = valueA[12] - valueB
	target[13] = valueA[13] - valueB
	target[14] = valueA[14] - valueB
	target[15] = valueA[15] - valueB


cdef inline void mat4_sub_mat4(float[16] target, float[16] valueA, float[16] valueB):
	target[0] = valueA[0] - valueB[0]
	target[1] = valueA[1] - valueB[1]
	target[2] = valueA[2] - valueB[2]
	target[3] = valueA[3] - valueB[3]
	target[4] = valueA[4] - valueB[4]
	target[5] = valueA[5] - valueB[5]
	target[6] = valueA[6] - valueB[6]
	target[7] = valueA[7] - valueB[7]
	target[8] = valueA[8] - valueB[8]
	target[9] = valueA[9] - valueB[9]
	target[10] = valueA[10] - valueB[10]
	target[11] = valueA[11] - valueB[11]
	target[12] = valueA[12] - valueB[12]
	target[13] = valueA[13] - valueB[13]
	target[14] = valueA[14] - valueB[14]
	target[15] = valueA[15] - valueB[15]


cdef inline void mat4_rsub_float(float[16] target, float valueA, float[16] valueB):
	target[0] = valueA - valueB[0]
	target[1] = valueA - valueB[1]
	target[2] = valueA - valueB[2]
	target[3] = valueA - valueB[3]
	target[4] = valueA - valueB[4]
	target[5] = valueA - valueB[5]
	target[6] = valueA - valueB[6]
	target[7] = valueA - valueB[7]
	target[8] = valueA - valueB[8]
	target[9] = valueA - valueB[9]
	target[10] = valueA - valueB[10]
	target[11] = valueA - valueB[11]
	target[12] = valueA - valueB[12]
	target[13] = valueA - valueB[13]
	target[14] = valueA - valueB[14]
	target[15] = valueA - valueB[15]



cdef inline void mat4_imul_float(float[16] target, float value):
	target[0] *= value
	target[1] *= value
	target[2] *= value
	target[3] *= value
	target[4] *= value
	target[5] *= value
	target[6] *= value
	target[7] *= value
	target[8] *= value
	target[9] *= value
	target[10] *= value
	target[11] *= value
	target[12] *= value
	target[13] *= value
	target[14] *= value
	target[15] *= value


cdef inline void mat4_imul_mat4(float[16] target, float[16] value):
	cdef float m11 = target[0] * value[0] + target[1] * value[4] + target[2] * value[8] + target[3] * value[12]
	cdef float m12 = target[0] * value[1] + target[1] * value[5] + target[2] * value[9] + target[3] * value[13]
	cdef float m13 = target[0] * value[2] + target[1] * value[6] + target[2] * value[10] + target[3] * value[14]
	cdef float m14 = target[0] * value[3] + target[1] * value[7] + target[2] * value[11] + target[3] * value[15]

	cdef float m21 = target[4] * value[0] + target[5] * value[4] + target[6] * value[8] + target[7] * value[12]
	cdef float m22 = target[4] * value[1] + target[5] * value[5] + target[6] * value[9] + target[7] * value[13]
	cdef float m23 = target[4] * value[2] + target[5] * value[6] + target[6] * value[10] + target[7] * value[14]
	cdef float m24 = target[4] * value[3] + target[5] * value[7] + target[6] * value[11] + target[7] * value[15]

	cdef float m31 = target[8] * value[0] + target[9] * value[4] + target[10] * value[8] + target[11] * value[12]
	cdef float m32 = target[8] * value[1] + target[9] * value[5] + target[10] * value[9] + target[11] * value[13]
	cdef float m33 = target[8] * value[2] + target[9] * value[6] + target[10] * value[10] + target[11] * value[14]
	cdef float m34 = target[8] * value[3] + target[9] * value[7] + target[10] * value[11] + target[11] * value[15]

	cdef float m41 = target[12] * value[0] + target[13] * value[4] + target[14] * value[8] + target[15] * value[12]
	cdef float m42 = target[12] * value[1] + target[13] * value[5] + target[14] * value[9] + target[15] * value[13]
	cdef float m43 = target[12] * value[2] + target[13] * value[6] + target[14] * value[10] + target[15] * value[14]
	cdef float m44 = target[12] * value[3] + target[13] * value[7] + target[14] * value[11] + target[15] * value[15]

	target[0] = m11
	target[1] = m12
	target[2] = m13
	target[3] = m14
	target[4] = m21
	target[5] = m22
	target[6] = m23
	target[7] = m24
	target[8] = m31
	target[9] = m32
	target[10] = m33
	target[11] = m34
	target[12] = m41
	target[13] = m42
	target[14] = m43
	target[15] = m44

cdef inline void mat4_mul_float(float[16] target, float[16] valueA, float valueB):
	target[0] = valueA[0] * valueB
	target[1] = valueA[1] * valueB
	target[2] = valueA[2] * valueB
	target[3] = valueA[3] * valueB
	target[4] = valueA[4] * valueB
	target[5] = valueA[5] * valueB
	target[6] = valueA[6] * valueB
	target[7] = valueA[7] * valueB
	target[8] = valueA[8] * valueB
	target[9] = valueA[9] * valueB
	target[10] = valueA[10] * valueB
	target[11] = valueA[11] * valueB
	target[12] = valueA[12] * valueB
	target[13] = valueA[13] * valueB
	target[14] = valueA[14] * valueB
	target[15] = valueA[15] * valueB

cdef inline void mat4_mul_mat4(float[16] target, float[16] valueA, float[16] valueB):
	target[0] = valueA[0] * valueB[0] + valueA[1] * valueB[4] + valueA[2] * valueB[8] + valueA[3] * valueB[12]
	target[1] = valueA[0] * valueB[1] + valueA[1] * valueB[5] + valueA[2] * valueB[9] + valueA[3] * valueB[13]
	target[2] = valueA[0] * valueB[2] + valueA[1] * valueB[6] + valueA[2] * valueB[10] + valueA[3] * valueB[14]
	target[3] = valueA[0] * valueB[3] + valueA[1] * valueB[7] + valueA[2] * valueB[11] + valueA[3] * valueB[15]

	target[4] = valueA[4] * valueB[0] + valueA[5] * valueB[4] + valueA[6] * valueB[8] + valueA[7] * valueB[12]
	target[5] = valueA[4] * valueB[1] + valueA[5] * valueB[5] + valueA[6] * valueB[9] + valueA[7] * valueB[13]
	target[6] = valueA[4] * valueB[2] + valueA[5] * valueB[6] + valueA[6] * valueB[10] + valueA[7] * valueB[14]
	target[7] = valueA[4] * valueB[3] + valueA[5] * valueB[7] + valueA[6] * valueB[11] + valueA[7] * valueB[15]

	target[8] = valueA[8] * valueB[0] + valueA[9] * valueB[4] + valueA[10] * valueB[8] + valueA[11] * valueB[12]
	target[9] = valueA[8] * valueB[1] + valueA[9] * valueB[5] + valueA[10] * valueB[9] + valueA[11] * valueB[13]
	target[10] = valueA[8] * valueB[2] + valueA[9] * valueB[6] + valueA[10] * valueB[10] + valueA[11] * valueB[14]
	target[11] = valueA[8] * valueB[3] + valueA[9] * valueB[7] + valueA[10] * valueB[11] + valueA[11] * valueB[15]

	target[12] = valueA[12] * valueB[0] + valueA[13] * valueB[4] + valueA[14] * valueB[8] + valueA[15] * valueB[12]
	target[13] = valueA[12] * valueB[1] + valueA[13] * valueB[5] + valueA[14] * valueB[9] + valueA[15] * valueB[13]
	target[14] = valueA[12] * valueB[2] + valueA[13] * valueB[6] + valueA[14] * valueB[10] + valueA[15] * valueB[14]
	target[15] = valueA[12] * valueB[3] + valueA[13] * valueB[7] + valueA[14] * valueB[11] + valueA[15] * valueB[15]

cdef inline void vec4_imul_mat4(float[4] target, float[16] value):
	cdef float x = target[0] * value[0] + target[1] * value[4] + target[2] * value[8] + target[3] * value[12]
	cdef float y = target[0] * value[1] + target[1] * value[5] + target[2] * value[9] + target[3] * value[13]
	cdef float z = target[0] * value[2] + target[1] * value[6] + target[2] * value[10] + target[3] * value[14]
	cdef float w = target[0] * value[3] + target[1] * value[7] + target[2] * value[11] + target[3] * value[15]
	target[0] = x
	target[1] = y
	target[2] = z
	target[3] = w

cdef inline void vec4_mul_mat4(float[4] target, float[4] valueA, float[16] valueB):
	target[0] = valueA[0] * valueB[0] + valueA[1] * valueB[4] + valueA[2] * valueB[8] + valueA[3] * valueB[12]
	target[1] = valueA[0] * valueB[1] + valueA[1] * valueB[5] + valueA[2] * valueB[9] + valueA[3] * valueB[13]
	target[2] = valueA[0] * valueB[2] + valueA[1] * valueB[6] + valueA[2] * valueB[10] + valueA[3] * valueB[14]
	target[3] = valueA[0] * valueB[3] + valueA[1] * valueB[7] + valueA[2] * valueB[11] + valueA[3] * valueB[15]

cdef inline void mat4_mul_vec4(float[4] target, float[16] valueA, float[4] valueB):
	target[0] = valueA[0] * valueB[0] + valueA[1] * valueB[1] + valueA[2] * valueB[2] + valueA[3] * valueB[3]
	target[1] = valueA[4] * valueB[0] + valueA[5] * valueB[1] + valueA[6] * valueB[2] + valueA[7] * valueB[3]
	target[2] = valueA[8] * valueB[0] + valueA[9] * valueB[1] + valueA[10] * valueB[2] + valueA[11] * valueB[3]
	target[3] = valueA[12] * valueB[0] + valueA[13] * valueB[1] + valueA[14] * valueB[2] + valueA[15] * valueB[3]

cdef inline float mat4_determinant(float determinant, float[16] matrix):
	if determinant == c_neg_one_float:
		determinant = (matrix[0] * (matrix[5] * (matrix[10] * matrix[15] - matrix[11] * matrix[14]) -
						matrix[6] * (matrix[9] * matrix[15] - matrix[11] * matrix[13]) +
						matrix[7] * (matrix[9] * matrix[14] - matrix[10] * matrix[13])) -
		matrix[1] * (matrix[4] * (matrix[10] * matrix[15] - matrix[11] * matrix[14]) -
						matrix[6] * (matrix[8] * matrix[15] - matrix[11] * matrix[12]) +
						matrix[7] * (matrix[8] * matrix[14] - matrix[10] * matrix[12])) +
		matrix[2] * (matrix[4] * (matrix[9] * matrix[15] - matrix[11] * matrix[13]) -
						matrix[5] * (matrix[8] * matrix[15] - matrix[11] * matrix[12]) +
						matrix[7] * (matrix[8] * matrix[13] - matrix[9] * matrix[12])) -
		matrix[3] * (matrix[4] * (matrix[9] * matrix[14] - matrix[10] * matrix[13]) -
						matrix[5] * (matrix[8] * matrix[14] - matrix[10] * matrix[12]) +
						matrix[6] * (matrix[8] * matrix[13] - matrix[9] * matrix[12])))
	return determinant

cdef inline void mat4_inverse_in_place(float determinant, float[16] matrix):
	cdef float det = mat4_determinant(determinant, matrix)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	cdef float m11 = (matrix[5] * (matrix[10] * matrix[15] - matrix[11] * matrix[14]) -
						matrix[6] * (matrix[9] * matrix[15] - matrix[11] * matrix[13]) +
						matrix[7] * (matrix[9] * matrix[14] - matrix[10] * matrix[13])) * inv_det

	cdef float m12 = -(matrix[1] * (matrix[10] * matrix[15] - matrix[11] * matrix[14]) -
						matrix[2] * (matrix[9] * matrix[15] - matrix[11] * matrix[13]) +
						matrix[3] * (matrix[9] * matrix[14] - matrix[10] * matrix[13])) * inv_det

	cdef float m13 = (matrix[1] * (matrix[6] * matrix[15] - matrix[7] * matrix[14]) -
						matrix[2] * (matrix[5] * matrix[15] - matrix[7] * matrix[13]) +
						matrix[3] * (matrix[5] * matrix[14] - matrix[6] * matrix[13])) * inv_det

	cdef float m14 = -(matrix[1] * (matrix[6] * matrix[11] - matrix[7] * matrix[10]) -
						matrix[2] * (matrix[5] * matrix[11] - matrix[7] * matrix[9]) +
						matrix[3] * (matrix[5] * matrix[10] - matrix[6] * matrix[9])) * inv_det

	cdef float m21 = -(matrix[4] * (matrix[10] * matrix[15] - matrix[11] * matrix[14]) -
						matrix[6] * (matrix[8] * matrix[15] - matrix[11] * matrix[12]) +
						matrix[7] * (matrix[8] * matrix[14] - matrix[10] * matrix[12])) * inv_det

	cdef float m22 = (matrix[0] * (matrix[10] * matrix[15] - matrix[11] * matrix[14]) -
						matrix[2] * (matrix[8] * matrix[15] - matrix[11] * matrix[12]) +
						matrix[3] * (matrix[8] * matrix[14] - matrix[10] * matrix[12])) * inv_det

	cdef float m23 = -(matrix[0] * (matrix[6] * matrix[15] - matrix[7] * matrix[14]) -
						matrix[2] * (matrix[4] * matrix[15] - matrix[7] * matrix[12]) +
						matrix[3] * (matrix[4] * matrix[14] - matrix[6] * matrix[12])) * inv_det

	cdef float m24 = (matrix[0] * (matrix[6] * matrix[11] - matrix[7] * matrix[10]) -
						matrix[2] * (matrix[4] * matrix[11] - matrix[7] * matrix[8]) +
						matrix[3] * (matrix[4] * matrix[10] - matrix[6] * matrix[8])) * inv_det

	cdef float m31 = (matrix[4] * (matrix[9] * matrix[15] - matrix[11] * matrix[13]) -
						matrix[5] * (matrix[8] * matrix[15] - matrix[11] * matrix[12]) +
						matrix[7] * (matrix[8] * matrix[13] - matrix[9] * matrix[12])) * inv_det

	cdef float m32 = -(matrix[0] * (matrix[9] * matrix[15] - matrix[11] * matrix[13]) -
						matrix[1] * (matrix[8] * matrix[15] - matrix[11] * matrix[12]) +
						matrix[3] * (matrix[8] * matrix[13] - matrix[9] * matrix[12])) * inv_det

	cdef float m33 = (matrix[0] * (matrix[5] * matrix[15] - matrix[7] * matrix[13]) -
						matrix[1] * (matrix[4] * matrix[15] - matrix[7] * matrix[12]) +
						matrix[3] * (matrix[4] * matrix[13] - matrix[5] * matrix[12])) * inv_det

	cdef float m34 = -(matrix[0] * (matrix[5] * matrix[11] - matrix[7] * matrix[9]) -
						matrix[1] * (matrix[4] * matrix[11] - matrix[7] * matrix[8]) +
						matrix[3] * (matrix[4] * matrix[9] - matrix[5] * matrix[8])) * inv_det

	cdef float m41 = -(matrix[4] * (matrix[9] * matrix[14] - matrix[10] * matrix[13]) -
						matrix[5] * (matrix[8] * matrix[14] - matrix[10] * matrix[12]) +
						matrix[6] * (matrix[8] * matrix[13] - matrix[9] * matrix[12])) * inv_det

	cdef float m42 = (matrix[0] * (matrix[9] * matrix[14] - matrix[10] * matrix[13]) -
						matrix[1] * (matrix[8] * matrix[14] - matrix[10] * matrix[12]) +
						matrix[2] * (matrix[8] * matrix[13] - matrix[9] * matrix[12])) * inv_det

	cdef float m43 = -(matrix[0] * (matrix[5] * matrix[14] - matrix[6] * matrix[13]) -
						matrix[1] * (matrix[4] * matrix[14] - matrix[6] * matrix[12]) +
						matrix[2] * (matrix[4] * matrix[13] - matrix[5] * matrix[12])) * inv_det

	cdef float m44 = (matrix[0] * (matrix[5] * matrix[10] - matrix[6] * matrix[9]) -
						matrix[1] * (matrix[4] * matrix[10] - matrix[6] * matrix[8]) +
						matrix[2] * (matrix[4] * matrix[9] - matrix[5] * matrix[8])) * inv_det

	matrix[0] = m11
	matrix[1] = m12
	matrix[2] = m13
	matrix[3] = m14
	matrix[4] = m21
	matrix[5] = m22
	matrix[6] = m23
	matrix[7] = m24
	matrix[8] = m31
	matrix[9] = m32
	matrix[10] = m33
	matrix[11] = m34
	matrix[12] = m41
	matrix[13] = m42
	matrix[14] = m43
	matrix[15] = m44

	determinant = inv_det

cdef inline void mat4_inverse_from(float target_determinant, float[16] target_matrix, float source_determinant, float[16] source_matrix):
	cdef float det = mat4_determinant(source_determinant, source_matrix)
	if det == c_zero_float: return

	cdef float inv_det = c_one_float / det

	target_matrix[0] = (source_matrix[5] * (source_matrix[10] * source_matrix[15] - source_matrix[11] * source_matrix[14]) -
						source_matrix[6] * (source_matrix[9] * source_matrix[15] - source_matrix[11] * source_matrix[13]) +
						source_matrix[7] * (source_matrix[9] * source_matrix[14] - source_matrix[10] * source_matrix[13])) * inv_det

	target_matrix[1] = -(source_matrix[1] * (source_matrix[10] * source_matrix[15] - source_matrix[11] * source_matrix[14]) -
						source_matrix[2] * (source_matrix[9] * source_matrix[15] - source_matrix[11] * source_matrix[13]) +
						source_matrix[3] * (source_matrix[9] * source_matrix[14] - source_matrix[10] * source_matrix[13])) * inv_det

	target_matrix[2] = (source_matrix[1] * (source_matrix[6] * source_matrix[15] - source_matrix[7] * source_matrix[14]) -
						source_matrix[2] * (source_matrix[5] * source_matrix[15] - source_matrix[7] * source_matrix[13]) +
						source_matrix[3] * (source_matrix[5] * source_matrix[14] - source_matrix[6] * source_matrix[13])) * inv_det

	target_matrix[3] = -(source_matrix[1] * (source_matrix[6] * source_matrix[11] - source_matrix[7] * source_matrix[10]) -
						source_matrix[2] * (source_matrix[5] * source_matrix[11] - source_matrix[7] * source_matrix[9]) +
						source_matrix[3] * (source_matrix[5] * source_matrix[10] - source_matrix[6] * source_matrix[9])) * inv_det

	target_matrix[4] = -(source_matrix[4] * (source_matrix[10] * source_matrix[15] - source_matrix[11] * source_matrix[14]) -
						source_matrix[6] * (source_matrix[8] * source_matrix[15] - source_matrix[11] * source_matrix[12]) +
						source_matrix[7] * (source_matrix[8] * source_matrix[14] - source_matrix[10] * source_matrix[12])) * inv_det

	target_matrix[5] = (source_matrix[0] * (source_matrix[10] * source_matrix[15] - source_matrix[11] * source_matrix[14]) -
						source_matrix[2] * (source_matrix[8] * source_matrix[15] - source_matrix[11] * source_matrix[12]) +
						source_matrix[3] * (source_matrix[8] * source_matrix[14] - source_matrix[10] * source_matrix[12])) * inv_det

	target_matrix[6] = -(source_matrix[0] * (source_matrix[6] * source_matrix[15] - source_matrix[7] * source_matrix[14]) -
						source_matrix[2] * (source_matrix[4] * source_matrix[15] - source_matrix[7] * source_matrix[12]) +
						source_matrix[3] * (source_matrix[4] * source_matrix[14] - source_matrix[6] * source_matrix[12])) * inv_det

	target_matrix[7] = (source_matrix[0] * (source_matrix[6] * source_matrix[11] - source_matrix[7] * source_matrix[10]) -
						source_matrix[2] * (source_matrix[4] * source_matrix[11] - source_matrix[7] * source_matrix[8]) +
						source_matrix[3] * (source_matrix[4] * source_matrix[10] - source_matrix[6] * source_matrix[8])) * inv_det

	target_matrix[8] = (source_matrix[4] * (source_matrix[9] * source_matrix[15] - source_matrix[11] * source_matrix[13]) -
						source_matrix[5] * (source_matrix[8] * source_matrix[15] - source_matrix[11] * source_matrix[12]) +
						source_matrix[7] * (source_matrix[8] * source_matrix[13] - source_matrix[9] * source_matrix[12])) * inv_det

	target_matrix[9] = -(source_matrix[0] * (source_matrix[9] * source_matrix[15] - source_matrix[11] * source_matrix[13]) -
						source_matrix[1] * (source_matrix[8] * source_matrix[15] - source_matrix[11] * source_matrix[12]) +
						source_matrix[3] * (source_matrix[8] * source_matrix[13] - source_matrix[9] * source_matrix[12])) * inv_det

	target_matrix[10] = (source_matrix[0] * (source_matrix[5] * source_matrix[15] - source_matrix[7] * source_matrix[13]) -
						source_matrix[1] * (source_matrix[4] * source_matrix[15] - source_matrix[7] * source_matrix[12]) +
						source_matrix[3] * (source_matrix[4] * source_matrix[13] - source_matrix[5] * source_matrix[12])) * inv_det

	target_matrix[11] = -(source_matrix[0] * (source_matrix[5] * source_matrix[11] - source_matrix[7] * source_matrix[9]) -
						source_matrix[1] * (source_matrix[4] * source_matrix[11] - source_matrix[7] * source_matrix[8]) +
						source_matrix[3] * (source_matrix[4] * source_matrix[9] - source_matrix[5] * source_matrix[8])) * inv_det

	target_matrix[12] = -(source_matrix[4] * (source_matrix[9] * source_matrix[14] - source_matrix[10] * source_matrix[13]) -
						source_matrix[5] * (source_matrix[8] * source_matrix[14] - source_matrix[10] * source_matrix[12]) +
						source_matrix[6] * (source_matrix[8] * source_matrix[13] - source_matrix[9] * source_matrix[12])) * inv_det

	target_matrix[13] = (source_matrix[0] * (source_matrix[9] * source_matrix[14] - source_matrix[10] * source_matrix[13]) -
						source_matrix[1] * (source_matrix[8] * source_matrix[14] - source_matrix[10] * source_matrix[12]) +
						source_matrix[2] * (source_matrix[8] * source_matrix[13] - source_matrix[9] * source_matrix[12])) * inv_det

	target_matrix[14] = -(source_matrix[0] * (source_matrix[5] * source_matrix[14] - source_matrix[6] * source_matrix[13]) -
						source_matrix[1] * (source_matrix[4] * source_matrix[14] - source_matrix[6] * source_matrix[12]) +
						source_matrix[2] * (source_matrix[4] * source_matrix[13] - source_matrix[5] * source_matrix[12])) * inv_det

	target_matrix[15] = (source_matrix[0] * (source_matrix[5] * source_matrix[10] - source_matrix[6] * source_matrix[9]) -
						source_matrix[1] * (source_matrix[4] * source_matrix[10] - source_matrix[6] * source_matrix[8]) +
						source_matrix[2] * (source_matrix[4] * source_matrix[9] - source_matrix[5] * source_matrix[8])) * inv_det


	target_determinant = inv_det




cdef class LocalTransformPosition(vec3):
	cdef Transform _transform
	#cdef int _size
	#cdef float[3] _global_data
	#cdef float _global_magnitude
	#cdef float _global_sqrMagnitude

	@property	
	def x(self) -> float:
		return self._global_data[0]
	@x.setter	
	def x(self, float value) -> None:
		self._global_data[0] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)

	@property
	def y(self) -> float:
		return self._global_data[1]
	@y.setter
	def y(self, float value) -> None:
		self._global_data[1] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)

	@property
	def z(self) -> float:
		return self._global_data[2]
	@z.setter
	def z(self, float value) -> None:
		self._global_data[2] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)

	def __repr__(self) -> str:
		return f"position({self._global_data[0]:.2f}, {self._global_data[1]:.2f}, {self._global_data[2]:.2f})"
	def __setitem__(self, int index, float value) -> None:
		if index < 0 or index >= self._size: return
		self._global_data[index] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)

	def SetValues(self, float x, float y, float z) -> None:
		vec3_set(self._global_data, x, y, z)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)
	def SetVector(self, vec3 value) -> None:
		vec3_copy(self._global_data, value._global_data)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._global_magnitude, self._global_data)
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)
	def Normalize_from(self, vec3 value) -> None:
		vec3_normalize_from(self._global_magnitude, self._global_data, value._global_magnitude, value._global_data)
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)

	def __iadd__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_iadd_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)
		return self

	def __isub__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_isub_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)
		return self

	def __imul__(self, value: 'allowed_types_vec3_mat3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._global_data, (<vec3>value)._global_data)
		elif isinstance(value, mat3):
			vec3_imul_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			vec3_imul_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)
		return self	
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> LocalTransformPosition:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_itruediv_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_true_bool)
		return self


cdef class LocalTransformScale(vec3):
	cdef Transform _transform
	#cdef int _size
	#cdef float[3] _global_data
	#cdef float _global_magnitude
	#cdef float _global_sqrMagnitude

	@property	
	def x(self) -> float:
		return self._global_data[0]
	@x.setter	
	def x(self, float value) -> None:
		self._global_data[0] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)

	@property
	def y(self) -> float:
		return self._global_data[1]
	@y.setter
	def y(self, float value) -> None:
		self._global_data[1] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)

	@property
	def z(self) -> float:
		return self._global_data[2]
	@z.setter
	def z(self, float value) -> None:
		self._global_data[2] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)

	def __repr__(self) -> str:
		return f"scale({self._global_data[0]:.2f}, {self._global_data[1]:.2f}, {self._global_data[2]:.2f})"
	def __setitem__(self, int index, float value) -> None:
		if index < 0 or index >= self._size: return
		self._global_data[index] = value
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)

	def SetValues(self, float x, float y, float z) -> None:
		vec3_set(self._global_data, x, y, z)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
	def SetVector(self, vec3 value) -> None:
		vec3_copy(self._global_data, value._global_data)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)

	def Normalize(self) -> None:
		vec3_normalize_in_place(self._global_magnitude, self._global_data)
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
	def Normalize_from(self, vec3 value) -> None:
		vec3_normalize_from(self._global_magnitude, self._global_data, value._global_magnitude, value._global_data)
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)

	def __iadd__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_iadd_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_iadd_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def __isub__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_isub_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_isub_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def __imul__(self, value: 'allowed_types_vec3_mat3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_imul_vec3(self._global_data, (<vec3>value)._global_data)
		elif isinstance(value, mat3):
			vec3_imul_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			vec3_imul_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self	
	
	def __itruediv__(self, value: 'allowed_types_vec3') -> LocalTransformScale:
		if isinstance(value, vec3):
			vec3_itruediv_vec3(self._global_data, (<vec3>value)._global_data)
		else:
			vec3_itruediv_float(self._global_data, <float>value)
		self._global_magnitude = c_neg_one_float
		self._global_sqrMagnitude = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self


cdef class LocalTransformRotation(Rotation):
	cdef Transform _transform

	def Rotate(self, float angle, float x, float y, float z) -> Rotation:
		mat3_rotate(self._global_data, angle, x, y, z)
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def Gx(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, c_one_float, c_zero_float, c_zero_float)
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def Gy(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, c_zero_float, c_one_float, c_zero_float)
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def Gz(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, c_zero_float, c_zero_float, c_one_float)
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self
	
	def Lx(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, self._global_data[0], self._global_data[1], self._global_data[2])
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def Ly(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, self._global_data[3], self._global_data[4], self._global_data[5])
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def Lz(self, float angle) -> Rotation:
		mat3_rotate(self._global_data, angle, self._global_data[6], self._global_data[7], self._global_data[8])
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def __neg__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_neg(result._global_data, self._global_data)
		return result
	def __pos__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_copy(result._global_data, self._global_data)
		return result
	def __abs__(self) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_abs(result._global_data, self._global_data)
		return result

	def Inverse(self) -> Rotation:
		mat3_inverse_in_place(self._global_determinant, self._global_data)
		transform_update_local_srt(self._transform, c_false_bool)
		return self
	def InverseFrom(self, mat3 value) -> Rotation:
		mat3_inverse_from(self._global_determinant, self._global_data, value._global_determinant, value._global_data)
		transform_update_local_srt(self._transform, c_false_bool)
		return self
	@classmethod
	def GetInverse(cls, mat3 value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_inverse_from(result._global_determinant, result._global_data, value._global_determinant, value._global_data)
		return result

	def __iadd__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_iadd_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_iadd_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def __add__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_add_mat3(result._global_data, self._global_data, (<mat3>value)._global_data)
		else:
			mat3_add_float(result._global_data, self._global_data, <float>value)
		return result

	def __radd__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_add_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __isub__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_isub_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_isub_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self

	def __sub__(self, value: 'allowed_types_mat3') -> Rotation:
		cdef Rotation result = Rotation()
		if isinstance(value, mat3):
			mat3_sub_mat3(result._global_data, self._global_data, (<mat3>value)._global_data)
		else:
			mat3_sub_float(result._global_data, self._global_data, <float>value)
		return result

	def __rsub__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_sub_float(result._global_data, self._global_data, <float>value)
		return result
	
	def __imul__(self, value: 'allowed_types_mat3') -> Rotation:
		if isinstance(value, mat3):
			mat3_imul_mat3(self._global_data, (<mat3>value)._global_data)
		else:
			mat3_imul_float(self._global_data, <float>value)
		self._global_determinant = c_neg_one_float
		transform_update_local_srt(self._transform, c_false_bool)
		return self
	
	def __mul__(self, value: 'allowed_types_mat3_vec3') -> Union[Rotation, vec3]:
		if isinstance(value, mat3):
			result = Rotation()
			mat3_mul_mat3((<Rotation>result)._global_data, self._global_data, (<mat3>value)._global_data)
			return result
		elif isinstance(value, vec3):
			result_vec3 = vec3()
			mat3_mul_vec3((<vec3>result_vec3)._global_data, self._global_data, (<vec3>value)._global_data)
			return result_vec3
		else:
			result = mat3()
			mat3_mul_float((<mat3>result)._global_data, self._global_data, <float>value)
			return result

	def __rmul__(self, float value) -> Rotation:
		cdef Rotation result = Rotation()
		mat3_mul_float(result._global_data, self._global_data, <float>value)
		return result




cdef class LocalMatrixSRT(mat4):
	def __setitem__(self, int index, float value) -> None:
		print("not allowed")
		return

	def SetValues(self, float m11, float m12, float m13, float m14, float m21, float m22, float m23, float m24, float m31, float m32, float m33, float m34, float m41, float m42, float m43, float m44) -> None:
		print("not allowed")
	def SetMatrix(self, mat4 value) -> None:
		print("not allowed")
	
	def Inverse(self) -> mat4:
		print("not allowed")
		return self
	
	def InverseFrom(self, mat4 value) -> mat4:
		print("not allowed")
		return self

	def __iadd__(self, value: 'allowed_types_mat4') -> mat4:
		print("not allowed")
		return self
	
	def __isub__(self, value: 'allowed_types_mat4') -> mat4:
		print("not allowed")
		return self
	
	def __imul__(self, value: 'allowed_types_mat4') -> mat4:
		print("not allowed")
		return self



cdef class Transform:

	cdef LocalTransformPosition _local_position
	cdef LocalTransformScale _local_scale
	cdef LocalTransformRotation _local_rotation

	cdef mat4 _local_matrix_SRT

	cdef float* _matrix_position[16]
	cdef float* _matrix_scale[16]
	cdef float* _matrix_rotation[16]

	def __init__(self, vec3 position, vec3 scale, Rotation rotation) -> None:
		self._local_position = LocalTransformPosition()
		self._local_scale = LocalTransformScale()
		self._local_rotation = LocalTransformRotation()

		self._local_position._transform = self
		self._local_scale._transform = self
		self._local_rotation._transform = self

		self._local_matrix_SRT = mat4()

		cdef float[3] position_data = position._global_data
		cdef float[3] scale_data = scale._global_data
		cdef float[9] rotation_data = rotation._global_data

		vec3_set(self._local_position._global_data, position_data[0], position_data[1], position_data[2])
		vec3_set(self._local_scale._global_data, scale_data[0], scale_data[1], scale_data[2])
		mat3_set(self._local_rotation._global_data, 
			rotation_data[0], rotation_data[1], rotation_data[2],
			rotation_data[3], rotation_data[4], rotation_data[5],
			rotation_data[6], rotation_data[7], rotation_data[8]
		)

		# Заполнение массива
		self._matrix_position[0] = &c_one_float
		self._matrix_position[1] = &c_zero_float
		self._matrix_position[2] = &c_zero_float
		self._matrix_position[3] = &c_zero_float
		self._matrix_position[4] = &c_zero_float
		self._matrix_position[5] = &c_one_float
		self._matrix_position[6] = &c_zero_float
		self._matrix_position[7] = &c_zero_float
		self._matrix_position[8] = &c_zero_float
		self._matrix_position[9] = &c_zero_float
		self._matrix_position[10] = &c_one_float
		self._matrix_position[11] = &c_zero_float
		self._matrix_position[12] = &self._local_position._global_data[0]
		self._matrix_position[13] = &self._local_position._global_data[1]
		self._matrix_position[14] = &self._local_position._global_data[2]
		self._matrix_position[15] = &c_one_float

		self._matrix_scale[0] = &self._local_scale._global_data[0]
		self._matrix_scale[1] = &c_zero_float
		self._matrix_scale[2] = &c_zero_float
		self._matrix_scale[3] = &c_zero_float
		self._matrix_scale[4] = &c_zero_float
		self._matrix_scale[5] = &self._local_scale._global_data[1]
		self._matrix_scale[6] = &c_zero_float
		self._matrix_scale[7] = &c_zero_float
		self._matrix_scale[8] = &c_zero_float
		self._matrix_scale[9] = &c_zero_float
		self._matrix_scale[10] = &self._local_scale._global_data[2]
		self._matrix_scale[11] = &c_zero_float
		self._matrix_scale[12] = &c_zero_float
		self._matrix_scale[13] = &c_zero_float
		self._matrix_scale[14] = &c_zero_float
		self._matrix_scale[15] = &c_one_float

		self._matrix_rotation[0] = &self._local_rotation._global_data[0]
		self._matrix_rotation[1] = &self._local_rotation._global_data[1]
		self._matrix_rotation[2] = &self._local_rotation._global_data[2]
		self._matrix_rotation[3] = &c_zero_float
		self._matrix_rotation[4] = &self._local_rotation._global_data[3]
		self._matrix_rotation[5] = &self._local_rotation._global_data[4]
		self._matrix_rotation[6] = &self._local_rotation._global_data[5]
		self._matrix_rotation[7] = &c_zero_float
		self._matrix_rotation[8] = &self._local_rotation._global_data[6]
		self._matrix_rotation[9] = &self._local_rotation._global_data[7]
		self._matrix_rotation[10] = &self._local_rotation._global_data[8]
		self._matrix_rotation[11] = &c_zero_float
		self._matrix_rotation[12] = &c_zero_float
		self._matrix_rotation[13] = &c_zero_float
		self._matrix_rotation[14] = &c_zero_float
		self._matrix_rotation[15] = &c_one_float

		transform_update_local_srt(self, c_true_bool)
		transform_update_local_srt(self, c_false_bool)

	
	def GetMatrixSRT(self) -> mat4:
		return self._local_matrix_SRT

	@property
	def position(self) -> vec3:
		return self._local_position
	@position.setter
	def position(self, vec3 value) -> None:
		vec3_copy(self._local_position._global_data, value._global_data)
		transform_update_local_srt(self, c_true_bool)

	@property
	def scale(self) -> vec3:
		return self._local_scale
	@scale.setter
	def scale(self, vec3 value) -> None:
		vec3_copy(self._local_scale._global_data, value._global_data)
		transform_update_local_srt(self, c_false_bool)
	

	@property
	def rotation(self) -> Rotation:
		return self._local_rotation
	@rotation.setter
	def rotation(self, Rotation value) -> None:
		mat3_copy(self._local_rotation._global_data, value._global_data)
		transform_update_local_srt(self, c_false_bool)


cdef inline void transform_update_local_srt(Transform target, bint is_position):

	if(is_position):
		target._local_matrix_SRT._global_data[12] = target._local_position._global_data[0]
		target._local_matrix_SRT._global_data[13] = target._local_position._global_data[1]
		target._local_matrix_SRT._global_data[14] = target._local_position._global_data[2]
	else:
		target._local_matrix_SRT._global_data[0] = target._local_scale._global_data[0] * target._local_rotation._global_data[0]
		target._local_matrix_SRT._global_data[1] = target._local_scale._global_data[0] * target._local_rotation._global_data[1]
		target._local_matrix_SRT._global_data[2] = target._local_scale._global_data[0] * target._local_rotation._global_data[2]
		target._local_matrix_SRT._global_data[4] = target._local_scale._global_data[1] * target._local_rotation._global_data[3]
		target._local_matrix_SRT._global_data[5] = target._local_scale._global_data[1] * target._local_rotation._global_data[4]
		target._local_matrix_SRT._global_data[6] = target._local_scale._global_data[1] * target._local_rotation._global_data[5]
		target._local_matrix_SRT._global_data[8] = target._local_scale._global_data[2] * target._local_rotation._global_data[6]
		target._local_matrix_SRT._global_data[9] = target._local_scale._global_data[2] * target._local_rotation._global_data[7]
		target._local_matrix_SRT._global_data[10] = target._local_scale._global_data[2] * target._local_rotation._global_data[8]

	#pmat4_mul_pmat4(target._local_matrix_SRT._global_data, 
	#	target._matrix_scale, 
	#	target._matrix_rotation)
	#mat4_imul_pmat4(target._local_matrix_SRT._global_data, 
	#	target._matrix_position)


cdef inline void mat4_imul_pmat4(float[16] target, float* value[16]):
	cdef float m11 = target[0] * value[0][0] + target[1] * value[4][0] + target[2] * value[8][0] + target[3] * value[12][0]
	cdef float m12 = target[0] * value[1][0] + target[1] * value[5][0] + target[2] * value[9][0] + target[3] * value[13][0]
	cdef float m13 = target[0] * value[2][0] + target[1] * value[6][0] + target[2] * value[10][0] + target[3] * value[14][0]
	cdef float m14 = target[0] * value[3][0] + target[1] * value[7][0] + target[2] * value[11][0] + target[3] * value[15][0]

	cdef float m21 = target[4] * value[0][0] + target[5] * value[4][0] + target[6] * value[8][0] + target[7] * value[12][0]
	cdef float m22 = target[4] * value[1][0] + target[5] * value[5][0] + target[6] * value[9][0] + target[7] * value[13][0]
	cdef float m23 = target[4] * value[2][0] + target[5] * value[6][0] + target[6] * value[10][0] + target[7] * value[14][0]
	cdef float m24 = target[4] * value[3][0] + target[5] * value[7][0] + target[6] * value[11][0] + target[7] * value[15][0]

	cdef float m31 = target[8] * value[0][0] + target[9] * value[4][0] + target[10] * value[8][0] + target[11] * value[12][0]
	cdef float m32 = target[8] * value[1][0] + target[9] * value[5][0] + target[10] * value[9][0] + target[11] * value[13][0]
	cdef float m33 = target[8] * value[2][0] + target[9] * value[6][0] + target[10] * value[10][0] + target[11] * value[14][0]
	cdef float m34 = target[8] * value[3][0] + target[9] * value[7][0] + target[10] * value[11][0] + target[11] * value[15][0]

	cdef float m41 = target[12] * value[0][0] + target[13] * value[4][0] + target[14] * value[8][0] + target[15] * value[12][0]
	cdef float m42 = target[12] * value[1][0] + target[13] * value[5][0] + target[14] * value[9][0] + target[15] * value[13][0]
	cdef float m43 = target[12] * value[2][0] + target[13] * value[6][0] + target[14] * value[10][0] + target[15] * value[14][0]
	cdef float m44 = target[12] * value[3][0] + target[13] * value[7][0] + target[14] * value[11][0] + target[15] * value[15][0]

	target[0] = m11
	target[1] = m12
	target[2] = m13
	target[3] = m14
	target[4] = m21
	target[5] = m22
	target[6] = m23
	target[7] = m24
	target[8] = m31
	target[9] = m32
	target[10] = m33
	target[11] = m34
	target[12] = m41
	target[13] = m42
	target[14] = m43
	target[15] = m44

cdef inline void pmat4_mul_pmat4(float[16] target, float* valueA[16], float* valueB[16]):
	target[0] = valueA[0][0] * valueB[0][0] + valueA[1][0] * valueB[4][0] + valueA[2][0] * valueB[8][0] + valueA[3][0] * valueB[12][0]
	target[1] = valueA[0][0] * valueB[1][0] + valueA[1][0] * valueB[5][0] + valueA[2][0] * valueB[9][0] + valueA[3][0] * valueB[13][0]
	target[2] = valueA[0][0] * valueB[2][0] + valueA[1][0] * valueB[6][0] + valueA[2][0] * valueB[10][0] + valueA[3][0] * valueB[14][0]
	target[3] = valueA[0][0] * valueB[3][0] + valueA[1][0] * valueB[7][0] + valueA[2][0] * valueB[11][0] + valueA[3][0] * valueB[15][0]

	target[4] = valueA[4][0] * valueB[0][0] + valueA[5][0] * valueB[4][0] + valueA[6][0] * valueB[8][0] + valueA[7][0] * valueB[12][0]
	target[5] = valueA[4][0] * valueB[1][0] + valueA[5][0] * valueB[5][0] + valueA[6][0] * valueB[9][0] + valueA[7][0] * valueB[13][0]
	target[6] = valueA[4][0] * valueB[2][0] + valueA[5][0] * valueB[6][0] + valueA[6][0] * valueB[10][0] + valueA[7][0] * valueB[14][0]
	target[7] = valueA[4][0] * valueB[3][0] + valueA[5][0] * valueB[7][0] + valueA[6][0] * valueB[11][0] + valueA[7][0] * valueB[15][0]

	target[8] = valueA[8][0] * valueB[0][0] + valueA[9][0] * valueB[4][0] + valueA[10][0] * valueB[8][0] + valueA[11][0] * valueB[12][0]
	target[9] = valueA[8][0] * valueB[1][0] + valueA[9][0] * valueB[5][0] + valueA[10][0] * valueB[9][0] + valueA[11][0] * valueB[13][0]
	target[10] = valueA[8][0] * valueB[2][0] + valueA[9][0] * valueB[6][0] + valueA[10][0] * valueB[10][0] + valueA[11][0] * valueB[14][0]
	target[11] = valueA[8][0] * valueB[3][0] + valueA[9][0] * valueB[7][0] + valueA[10][0] * valueB[11][0] + valueA[11][0] * valueB[15][0]

	target[12] = valueA[12][0] * valueB[0][0] + valueA[13][0] * valueB[4][0] + valueA[14][0] * valueB[8][0] + valueA[15][0] * valueB[12][0]
	target[13] = valueA[12][0] * valueB[1][0] + valueA[13][0] * valueB[5][0] + valueA[14][0] * valueB[9][0] + valueA[15][0] * valueB[13][0]
	target[14] = valueA[12][0] * valueB[2][0] + valueA[13][0] * valueB[6][0] + valueA[14][0] * valueB[10][0] + valueA[15][0] * valueB[14][0]
	target[15] = valueA[12][0] * valueB[3][0] + valueA[13][0] * valueB[7][0] + valueA[14][0] * valueB[11][0] + valueA[15][0] * valueB[15][0]


