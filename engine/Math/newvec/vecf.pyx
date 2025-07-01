# cython: language_level=3
from libc.stdlib cimport malloc, free
from libc.math cimport NAN, isnan, sqrtf, acosf, cosf, sinf, tanf, powf, copysignf
from numpy import radians, deg2rad
from typing import Union, Tuple, Generator, List

cdef float zerfloat = 0.0
cdef float onefloat = 1.0
cdef float negfloat = -1.0


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


cdef class vec2:
	cdef float _x, _y

	def __init__(self, float x, float y = NAN) -> None:
		self._x = x
		self._y = x if(isnan(<double>y)) else y

	def __str__(self) -> str:
		return (
			f'\n┌───────────────────────┐\n'
			f'│   {self._x:^6.1f}  ○   {self._y:^6.1f}  │\n'
			f'└───────────────────────┘'
		)


	@property
	def x(self) -> float: return self._x
	@x.setter
	def x(self, float value) -> None: self._x = value

	@property
	def y(self) -> float: return self._y
	@y.setter
	def y(self, float value) -> None: self._y = value

	def GetArray(self) -> Tuple[float, float]: return self._x, self._y
	def SetArray(self, float x, float y = NAN) -> vec2:
		self._x = x
		self._y = x if(isnan(<double>y)) else y
		return self
	def SetValue(self, vec2 value) -> vec2:
		self._x = value.x
		self._y = value.y
		return self


	@staticmethod
	def DotProduct(vec2 a, vec2 b) -> float:
		return vec2_dot(a,b)
	@staticmethod
	def CrossProduct(vec2 a, vec2 b) -> float:
		return vec2_cross(a,b)
	@staticmethod
	def Magnitude(vec2 a) -> float:
		return vec2_magnitude(a)
	@staticmethod
	def Normalize(vec2 a) -> vec2:
		return vec2_normalize(a)
	@property
	def normalize(self) -> vec2:
		i_vec2_normalize(self)
		return self
	@staticmethod
	def Projection(vec2 a, vec2 b) -> vec2:
		return vec2_projection(a, b)
	def project(self, vec2 b) -> vec2:
		i_vec2_projection(self, b)
		return self
	@staticmethod
	def Angle(vec2 a, vec2 b) -> float:
		return vec2_angle(a, b)



	def __neg__(self) -> vec2: return vec2(-self._x,-self._y)
	def __pos__(self) -> vec2: return vec2(self._x,self._y)
	def __abs__(self) -> vec2: return vec2(abs(self._x),abs(self._y))



	def __lt__(self, value: Union[vec2, float]) -> bool:
		if(isinstance(value, vec2)): return bool(vec2_lt_vec2(self,value))
		return bool(vec2_lt_num(self,value))
	def __le__(self, value: Union[vec2, float]) -> bool:
		if(isinstance(value, vec2)): return bool(vec2_le_vec2(self,value))
		return bool(vec2_le_num(self,value))
	def __eq__(self, value: Union[vec2, float]) -> bool:
		if(isinstance(value, vec2)): return bool(vec2_eq_vec2(self,value))
		return bool(vec2_eq_num(self,value))
	def __ne__(self, value: Union[vec2, float]) -> bool:
		if(isinstance(value, vec2)): return bool(vec2_ne_vec2(self,value))
		return bool(vec2_ne_num(self,value))
	def __ge__(self, value: Union[vec2, float]) -> bool:
		if(isinstance(value, vec2)): return bool(vec2_ge_vec2(self,value))
		return bool(vec2_ge_num(self,value))
	def __gt__(self, value: Union[vec2, float]) -> bool:
		if(isinstance(value, vec2)): return bool(vec2_gt_vec2(self,value))
		return bool(vec2_gt_num(self,value))



	def __add__(self, value: Union[vec2, float]) -> vec2:
		if(isinstance(value, vec2)): return vec2_add_vec2(self,value)
		return vec2_add_num(self,value)
	def __radd__(self, float value) -> vec2:
		return num_add_vec2(value,self)
	def __iadd__(self, value: Union[vec2, float]) -> vec2:
		if(isinstance(value, vec2)): i_vec2_add_vec2(self,value)
		else: i_vec2_add_num(self,value)
		return self



	def __sub__(self, value: Union[vec2, float]) -> vec2:
		if(isinstance(value, vec2)): return vec2_sub_vec2(self,value)
		return vec2_sub_num(self,value)
	def __rsub__(self, float value) -> vec2:
		return num_sub_vec2(value,self)
	def __isub__(self, value: Union[vec2, float]) -> vec2:
		if(isinstance(value, vec2)): i_vec2_sub_vec2(self,value)
		else: i_vec2_sub_num(self,value)
		return self



	def __mul__(self, value: Union[mat2, vec2, float]) -> vec2:
		if(isinstance(value, mat2)): return vec2_mul_mat2(self,value)
		if(isinstance(value, vec2)): return vec2_mul_vec2(self,value)
		return vec2_mul_num(self,value)
	def __rmul__(self, float value) -> vec2:
		return num_mul_vec2(value,self)
	def __imul__(self, value: Union[mat2, vec2, float]) -> vec2:
		if(isinstance(value, mat2)): i_vec2_mul_mat2(self,value)
		elif(isinstance(value, vec2)): i_vec2_mul_vec2(self,value)
		else: i_vec2_mul_num(self,value)
		return self



	def __pow__(self, value: Union[vec2, float]) -> vec2:
		if(isinstance(value, vec2)): return vec2_pow_vec2(self,value)
		return vec2_pow_num(self,value)
	def __rpow__(self, float value) -> vec2:
		return num_pow_vec2(value,self)
	def __ipow__(self, value: Union[vec2, float]) -> vec2:
		if(isinstance(value, vec2)): i_vec2_pow_vec2(self,value)
		else: i_vec2_pow_num(self,value)
		return self



	def __truediv__(self, value: Union[vec2, float]) -> vec2:
		if(isinstance(value, vec2)): return vec2_truediv_vec2(self,value)
		return vec2_truediv_num(self,value)
	def __rtruediv__(self, float value) -> vec2:
		return num_truediv_vec2(value,self)
	def __itruediv__(self, value: Union[vec2, float]) -> vec2:
		if(isinstance(value, vec2)): i_vec2_truediv_vec2(self,value)
		else: i_vec2_truediv_num(self,value)
		return self




cdef inline float vec2_dot(vec2 a, vec2 b):
	return a.x*b.x + a.y*b.y
cdef inline float vec2_cross(vec2 a, vec2 b):
	return a.x*b.y - a.y*b.x
cdef inline float vec2_magnitude(vec2 a):
	return sqrtf(a.x*a.x + a.y*a.y)
cdef inline vec2 vec2_normalize(vec2 a):
	return vec2_truediv_num(a, sqrtf(a.x*a.x + a.y*a.y) )
cdef inline vec2 vec2_projection(vec2 a, vec2 b):
	cdef float d = b.x*b.x + b.y*b.y
	cdef float p = (a.x*b.x + a.y*b.y) / (onefloat if(d==zerfloat) else d)
	return vec2(p * b.x, p * b.y)
cdef inline float vec2_angle(vec2 a, vec2 b):
	cdef float magnitude = sqrtf(a.x*a.x + a.y*a.y) * sqrtf(b.x*b.x + b.y*b.y)
	return acosf(max(min((a.x*b.x + a.y*b.y) / (onefloat if(magnitude == zerfloat) else magnitude), onefloat), negfloat))



cdef inline bint vec2_lt_vec2(vec2 a, vec2 b):
	return <bint>(a.x < b.x and a.y < b.y)
cdef inline bint vec2_lt_num(vec2 a, float b):
	return <bint>(a.x < b and a.y < b)

cdef inline bint vec2_le_vec2(vec2 a, vec2 b):
	return <bint>(a.x <= b.x and a.y <= b.y)
cdef inline bint vec2_le_num(vec2 a, float b):
	return <bint>(a.x <= b and a.y <= b)

cdef inline bint vec2_eq_vec2(vec2 a, vec2 b):
	return <bint>(a.x == b.x and a.y == b.y)
cdef inline bint vec2_eq_num(vec2 a, float b):
	return <bint>(a.x == b and a.y == b)

cdef inline bint vec2_ne_vec2(vec2 a, vec2 b):
	return <bint>(a.x != b.x or a.y != b.y)
cdef inline bint vec2_ne_num(vec2 a, float b):
	return <bint>(a.x != b or a.y != b)

cdef inline bint vec2_ge_vec2(vec2 a, vec2 b):
	return <bint>(a.x >= b.x or a.y >= b.y)
cdef inline bint vec2_ge_num(vec2 a, float b):
	return <bint>(a.x >= b or a.y >= b)

cdef inline bint vec2_gt_vec2(vec2 a, vec2 b):
	return <bint>(a.x > b.x or a.y > b.y)
cdef inline bint vec2_gt_num(vec2 a, float b):
	return <bint>(a.x > b or a.y > b)



cdef inline vec2 vec2_add_vec2(vec2 a, vec2 b):
	return vec2(a.x + b.x , a.y + b.y)
cdef inline vec2 vec2_add_num(vec2 a, float b):
	return vec2(a.x + b , a.y + b)
cdef inline vec2 num_add_vec2(float a, vec2 b):
	return vec2(a + b.x , a + b.y)

cdef inline vec2 vec2_sub_vec2(vec2 a, vec2 b):
	return vec2(a.x - b.x , a.y - b.y)
cdef inline vec2 vec2_sub_num(vec2 a, float b):
	return vec2(a.x - b , a.y - b)
cdef inline vec2 num_sub_vec2(float a, vec2 b):
	return vec2(a - b.x , a - b.y)

cdef inline vec2 vec2_mul_vec2(vec2 a, vec2 b):
	return vec2(a.x * b.x , a.y * b.y)
cdef inline vec2 vec2_mul_num(vec2 a, float b):
	return vec2(a.x * b , a.y * b)
cdef inline vec2 num_mul_vec2(float a, vec2 b):
	return vec2(a * b.x , a * b.y)
cdef inline vec2 vec2_mul_mat2(vec2 a, mat2 b):
	return vec2(
		a.x*b.m11 + a.y*b.m12,
		a.x*b.m21 + a.y*b.m22)

cdef inline vec2 vec2_pow_vec2(vec2 a, vec2 b):
	return vec2(powf(a.x, b.x) , powf(a.y, b.y))
cdef inline vec2 vec2_pow_num(vec2 a, float b):
	return vec2(powf(a.x, b) , powf(a.y, b))
cdef inline vec2 num_pow_vec2(float a, vec2 b):
	return vec2(powf(a, b.x) , powf(a, b.y))

cdef inline vec2 vec2_truediv_vec2(vec2 a, vec2 b):
	return vec2(
		a.x / (onefloat if(b.x==zerfloat) else b.x) ,
		a.y / (onefloat if(b.y==zerfloat) else b.y))
cdef inline vec2 vec2_truediv_num(vec2 a, float b):
	v = (onefloat if(b==zerfloat) else b)
	return vec2(a.x / v , a.y / v)
cdef inline vec2 num_truediv_vec2(float a, vec2 b):
	return vec2(
		a / (onefloat if(b.x==zerfloat) else b.x) ,
		a / (onefloat if(b.y==zerfloat) else b.y))


cdef inline void i_vec2_normalize(vec2 a):
	i_vec2_truediv_num(a, sqrtf(a._x*a._x + a._y*a._y) )

cdef inline void i_vec2_projection(vec2 a, vec2 b):
	cdef float d = b.x*b.x + b.y*b.y
	cdef float p = (a._x*b.x + a._y*b.y) / (onefloat if(d==zerfloat) else d)
	a._x = p * b.x
	a._y = p * b.y

cdef inline void i_vec2_add_vec2(vec2 a, vec2 b):
	a._x += b.x
	a._y += b.y
cdef inline void i_vec2_add_num(vec2 a, float b):
	a._x += b
	a._y += b

cdef inline void i_vec2_sub_vec2(vec2 a, vec2 b):
	a._x -= b.x
	a._y -= b.y
cdef inline void i_vec2_sub_num(vec2 a, float b):
	a._x -= b
	a._y -= b

cdef inline void i_vec2_mul_vec2(vec2 a, vec2 b):
	a._x *= b.x
	a._y *= b.y
cdef inline void i_vec2_mul_num(vec2 a, float b):
	a._x *= b
	a._y *= b
cdef inline void i_vec2_mul_mat2(vec2 a, mat2 b):
	cdef float x = a._x*b.m11 + a._y*b.m12
	cdef float y = a._x*b.m21 + a._y*b.m22
	a._x = x
	a._y = y

cdef inline void i_vec2_pow_vec2(vec2 a, vec2 b):
		a._x = powf(a._x, b.x)
		a._y = powf(a._y, b.y)
cdef inline void i_vec2_pow_num(vec2 a, float b):
	a._x = powf(a._x, b)
	a._y = powf(a._y, b)

cdef inline void i_vec2_truediv_vec2(vec2 a, vec2 b):
	a._x /= (onefloat if(b.x==zerfloat) else b.x)
	a._y /= (onefloat if(b.y==zerfloat) else b.y)
cdef inline void i_vec2_truediv_num(vec2 a, float b):
	v = (onefloat if(b==zerfloat) else b)
	a._x /= v
	a._y /= v

#############################################################################################################################################################################

cdef class mat2:
	cdef float _m11, _m12 , _m21, _m22

	def __init__(self,
		float m11 = onefloat, float m12 = zerfloat, 
		float m21 = zerfloat, float m22 = onefloat
	) -> None:
		self._m11 = m11
		self._m12 = m12
		self._m21 = m21
		self._m22 = m22

	def __str__(self) -> str:
		return (
			f'\n┌───────────────────────┐\n'
			f'│   {"":^6}      {"":^6}  │\n'
			f'│   {self._m11:^6.1f}      {self._m12:^6.1f}  │\n'
			f'│   {"":^6}  ○   {"":^6}  │\n'
			f'│   {self._m21:^6.1f}      {self._m22:^6.1f}  │\n'
			f'│   {"":^6}      {"":^6}  │\n'
			f'└───────────────────────┘'
		)

	@property
	def m11(self) -> float: return self._m11
	@m11.setter
	def m11(self, float value) -> None: self._m11 = value
	@property
	def m12(self) -> float: return self._m12
	@m12.setter
	def m12(self, float value) -> None: self._m12 = value
	@property
	def m21(self) -> float: return self._m21
	@m21.setter
	def m21(self, float value) -> None: self._m21 = value
	@property
	def m22(self) -> float: return self._m22
	@m22.setter
	def m22(self, float value) -> None: self._m22 = value



	def GetArray(self) -> Tuple[float, float, float, float]:
		return self._m11, self._m12, self._m21, self._m22

	def SetArray(self, 
		float m11 = onefloat, float m12 = zerfloat, 
		float m21 = zerfloat, float m22 = onefloat
	) -> mat2:
		self._m11 = m11
		self._m12 = m12
		self._m21 = m21
		self._m22 = m22
		return self

	def SetValue(self, mat2 value) -> mat2:
		self._m11 = value.m11
		self._m12 = value.m12
		self._m21 = value.m21
		self._m22 = value.m22
		return self


	@staticmethod
	def Inverse(mat2 a) -> mat2:
		return mat2_inverse(a)
	
	@property
	def inverse(self) -> mat2:
		i_mat2_inverse(self)
		return self

	def __mul__(self, value: Union[mat2, vec2, float]) -> Union[mat2, vec2]:
		if isinstance(value, mat2): return mat2_mul_mat2(self,value)
		if isinstance(value, vec2): return mat2_mul_vec2(self,value)
		return mat2_mul_num(self, value)
	def __rmul__(self, float value) -> mat2:
		return num_mul_mat2(value,self)
	def __imul__(self, value: Union[mat2, float]) -> mat2:
		if isinstance(value, mat2): i_mat2_mul_mat2(self,value)
		else: i_mat2_mul_num(self, value)
		return self



cdef inline mat2 mat2_mul_mat2(mat2 a, mat2 b):
	return mat2(
		a.m11 * b.m11  +  a.m12 * b.m21,
		a.m11 * b.m12  +  a.m12 * b.m22,
		a.m21 * b.m11  +  a.m22 * b.m21,
		a.m21 * b.m12  +  a.m22 * b.m22)
cdef inline vec2 mat2_mul_vec2(mat2 a, vec2 b):
	return vec2(
		a.m11*b.x + a.m21*b.y,
		a.m12*b.x + a.m22*b.y)
cdef inline mat2 mat2_mul_num(mat2 a, float b):
	return mat2(
		a.m11 * b,
		a.m12 * b,
		a.m21 * b,
		a.m22 * b)
cdef inline mat2 num_mul_mat2(float a, mat2 b):
	return mat2(
		a * b.m11,
		a * b.m12,
		a * b.m21,
		a * b.m22)

cdef inline mat2 mat2_inverse(mat2 a):
	cdef float det = a.m11 * a.m22 - a.m12 * a.m21
	det = onefloat / (onefloat if(det == zerfloat) else det)
	return mat2(
		a.m22 * det,
		-a.m12 * det,
		-a.m21 * det,
		a.m11 * det)


cdef inline void i_mat2_mul_mat2(mat2 a, mat2 b):
	cdef float m11 = a._m11 * b.m11  +  a._m12 * b.m21
	cdef float m12 = a._m11 * b.m12  +  a._m12 * b.m22
	cdef float m21 = a._m21 * b.m11  +  a._m22 * b.m21
	cdef float m22 = a._m21 * b.m12  +  a._m22 * b.m22
	a._m11 = m11
	a._m12 = m12
	a._m21 = m21
	a._m22 = m22
cdef inline void i_mat2_mul_num(mat2 a, float b):
	a._m11 *= b
	a._m12 *= b
	a._m21 *= b
	a._m22 *= b

cdef inline void i_mat2_inverse(mat2 a):
	cdef float det = a._m11 * a._m22 - a._m12 * a._m21
	det = onefloat / (onefloat if(det == zerfloat) else det)
	a._m22 *= det
	a._m12 *= -det
	a._m21 *= -det
	a._m11 *= det

#==============================================================================================================
#==============================================================================================================
#==============================================================================================================


cdef class vec3:
	cdef float _x, _y, _z

	def __init__(self, float x, float y = NAN, float z = NAN) -> None:
		self._x = x
		self._y = x if(isnan(<double>y)) else y
		self._z = x if(isnan(<double>z)) else z

	def __str__(self) -> str:
		return (
			f'\n┌───────────────────────────────────┐\n'
			f'│   {self._x:^6.1f}  ○   {self._y:^6.1f}  ○   {self._z:^6.1f}  │\n'
			f'└───────────────────────────────────┘'
		)


	@property
	def x(self) -> float: return self._x
	@x.setter
	def x(self, float value) -> None: self._x = value

	@property
	def y(self) -> float: return self._y
	@y.setter
	def y(self, float value) -> None: self._y = value

	@property
	def z(self) -> float: return self._z
	@z.setter
	def z(self, float value) -> None: self._z = value

	def GetArray(self) -> Tuple[float, float, float]: return self._x, self._y, self._z

	def SetArray(self, float x, float y = NAN, float z = NAN) -> vec3:
		self._x = x
		self._y = x if(isnan(<double>y)) else y
		self._z = x if(isnan(<double>z)) else z
		return self
	def SetValue(self, vec3 value) -> vec3:
		self._x = value.x
		self._y = value.y
		self._z = value.z
		return self


	@staticmethod
	def DotProduct(vec3 a, vec3 b) -> float:
		return vec3_dot(a,b)
	@staticmethod
	def CrossProduct(vec3 a, vec3 b) -> vec3:
		return vec3_cross(a,b)
	def crossBy(self, vec3 b) -> vec3:
		i_vec3_cross(self, b)
		return self
	@staticmethod
	def Magnitude(vec3 a) -> float:
		return vec3_magnitude(a)
	@staticmethod
	def Normalize(vec3 a) -> vec3:
		return vec3_normalize(a)
	@property
	def normalize(self) -> vec3:
		i_vec3_normalize(self)
		return self
	@staticmethod
	def Projection(vec3 a, vec3 b) -> vec3:
		return vec3_projection(a, b)
	def project(self, vec3 b) -> vec3:
		i_vec3_projection(self, b)
		return self
	@staticmethod
	def Angle(vec3 a, vec3 b) -> float:
		return vec3_angle(a, b)



	def __neg__(self) -> vec3: return vec3(-self._x,-self._y,-self._z)
	def __pos__(self) -> vec3: return vec3(self._x,self._y,self._z)
	def __abs__(self) -> vec3: return vec3(abs(self._x),abs(self._y),abs(self._z))



	def __lt__(self, value: Union[vec3, float]) -> bool:
		if(isinstance(value, vec3)): return bool(vec3_lt_vec3(self,value))
		return bool(vec3_lt_num(self,value))
	def __le__(self, value: Union[vec3, float]) -> bool:
		if(isinstance(value, vec3)): return bool(vec3_le_vec3(self,value))
		return bool(vec3_le_num(self,value))
	def __eq__(self, value: Union[vec3, float]) -> bool:
		if(isinstance(value, vec3)): return bool(vec3_eq_vec3(self,value))
		return bool(vec3_eq_num(self,value))
	def __ne__(self, value: Union[vec3, float]) -> bool:
		if(isinstance(value, vec3)): return bool(vec3_ne_vec3(self,value))
		return bool(vec3_ne_num(self,value))
	def __ge__(self, value: Union[vec3, float]) -> bool:
		if(isinstance(value, vec3)): return bool(vec3_ge_vec3(self,value))
		return bool(vec3_ge_num(self,value))
	def __gt__(self, value: Union[vec3, float]) -> bool:
		if(isinstance(value, vec3)): return bool(vec3_gt_vec3(self,value))
		return bool(vec3_gt_num(self,value))



	def __add__(self, value: Union[vec3, float]) -> vec3:
		if(isinstance(value, vec3)): return vec3_add_vec3(self,value)
		return vec3_add_num(self,value)
	def __radd__(self, float value) -> vec3:
		return num_add_vec3(value,self)
	def __iadd__(self, value: Union[vec3, float]) -> vec3:
		if(isinstance(value, vec3)): i_vec3_add_vec3(self,value)
		else: i_vec3_add_num(self,value)
		return self



	def __sub__(self, value: Union[vec3, float]) -> vec3:
		if(isinstance(value, vec3)): return vec3_sub_vec3(self,value)
		return vec3_sub_num(self,value)
	def __rsub__(self, float value) -> vec3:
		return num_sub_vec3(value,self)
	def __isub__(self, value: Union[vec3, float]) -> vec3:
		if(isinstance(value, vec3)): i_vec3_sub_vec3(self,value)
		else: i_vec3_sub_num(self,value)
		return self



	def __mul__(self, value: Union[mat3, vec3, float]) -> vec3:
		if(isinstance(value, mat3)): return vec3_mul_mat3(self,value)
		if(isinstance(value, vec3)): return vec3_mul_vec3(self,value)
		return vec3_mul_num(self,value)
	def __rmul__(self, float value) -> vec3:
		return num_mul_vec3(value,self)
	def __imul__(self, value: Union[mat3, vec3, float]) -> vec3:
		if(isinstance(value, mat3)): i_vec3_mul_mat3(self,value)
		elif(isinstance(value, vec3)): i_vec3_mul_vec3(self,value)
		else: i_vec3_mul_num(self,value)
		return self



	def __pow__(self, value: Union[vec3, float]) -> vec3:
		if(isinstance(value, vec3)): return vec3_pow_vec3(self,value)
		return vec3_pow_num(self,value)
	def __rpow__(self, float value) -> vec3:
		return num_pow_vec3(value,self)
	def __ipow__(self, value: Union[vec3, float]) -> vec3:
		if(isinstance(value, vec3)): i_vec3_pow_vec3(self,value)
		else: i_vec3_pow_num(self,value)
		return self



	def __truediv__(self, value: Union[vec3, float]) -> vec3:
		if(isinstance(value, vec3)): return vec3_truediv_vec3(self,value)
		return vec3_truediv_num(self,value)
	def __rtruediv__(self, float value) -> vec3:
		return num_truediv_vec3(value,self)
	def __itruediv__(self, value: Union[vec3, float]) -> vec3:
		if(isinstance(value, vec3)): i_vec3_truediv_vec3(self,value)
		else: i_vec3_truediv_num(self,value)
		return self




cdef inline float vec3_dot(vec3 a, vec3 b):
	return a.x*b.x + a.y*b.y + a.z*b.z

cdef inline vec3 vec3_cross(vec3 a, vec3 b):
	return vec3(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x)
cdef inline float vec3_magnitude(vec3 a):
	return sqrtf(a.x*a.x + a.y*a.y + a.z*a.z)

cdef inline vec3 vec3_normalize(vec3 a):
	return vec3_truediv_num(a, sqrtf(a.x*a.x + a.y*a.y + a.z*a.z) )

cdef inline vec3 vec3_projection(vec3 a, vec3 b):
	cdef float d = b.x * b.x + b.y * b.y + b.z * b.z
	cdef float p = (a.x * b.x + a.y * b.y + a.z * b.z) / (onefloat if (d == zerfloat) else d)
	return vec3(
		p * b.x,
		p * b.y,
		p * b.z)

cdef inline float vec3_angle(vec3 a, vec3 b):
	cdef float magnitude = sqrtf(a.x*a.x + a.y*a.y + a.z*a.z) * sqrtf(b.x*b.x + b.y*b.y + b.z*b.z)
	return acosf(max(min(((a.x*b.x + a.y*b.y + a.z*b.z) / (onefloat if(magnitude == zerfloat) else magnitude)), onefloat), negfloat))



cdef inline bint vec3_lt_vec3(vec3 a, vec3 b):
	return <bint>(a.x < b.x and a.y < b.y and a.z < b.z)
cdef inline bint vec3_lt_num(vec3 a, float b):
	return <bint>(a.x < b and a.y < b and a.z < b)
cdef inline bint vec3_le_vec3(vec3 a, vec3 b):
	return <bint>(a.x <= b.x and a.y <= b.y and a.z <= b.z)
cdef inline bint vec3_le_num(vec3 a, float b):
	return <bint>(a.x <= b and a.y <= b and a.z <= b)
cdef inline bint vec3_eq_vec3(vec3 a, vec3 b):
	return <bint>(a.x == b.x and a.y == b.y and a.z == b.z)
cdef inline bint vec3_eq_num(vec3 a, float b):
	return <bint>(a.x == b and a.y == b and a.z == b)
cdef inline bint vec3_ne_vec3(vec3 a, vec3 b):
	return <bint>(a.x != b.x or a.y != b.y or a.z != b.z)
cdef inline bint vec3_ne_num(vec3 a, float b):
	return <bint>(a.x != b or a.y != b or a.z != b)
cdef inline bint vec3_ge_vec3(vec3 a, vec3 b):
	return <bint>(a.x >= b.x and a.y >= b.y and a.z >= b.z)
cdef inline bint vec3_ge_num(vec3 a, float b):
	return <bint>(a.x >= b and a.y >= b and a.z >= b)
cdef inline bint vec3_gt_vec3(vec3 a, vec3 b):
	return <bint>(a.x > b.x and a.y > b.y and a.z > b.z)
cdef inline bint vec3_gt_num(vec3 a, float b):
	return <bint>(a.x > b and a.y > b and a.z > b)



cdef inline vec3 vec3_add_vec3(vec3 a, vec3 b):
	return vec3(a.x + b.x, a.y + b.y, a.z + b.z)
cdef inline vec3 num_add_vec3(float a, vec3 b):
	return vec3(a + b.x, a + b.y, a + b.z)

cdef inline vec3 vec3_sub_vec3(vec3 a, vec3 b):
	return vec3(a.x - b.x, a.y - b.y, a.z - b.z)
cdef inline vec3 num_sub_vec3(float a, vec3 b):
	return vec3(a - b.x, a - b.y, a - b.z)

cdef inline vec3 vec3_mul_vec3(vec3 a, vec3 b):
	return vec3(a.x * b.x, a.y * b.y, a.z * b.z)
cdef inline vec3 vec3_mul_num(vec3 a, float b):
	return vec3(a.x * b, a.y * b, a.z * b)
cdef inline vec3 num_mul_vec3(float a, vec3 b):
	return vec3(a * b.x, a * b.y, a * b.z)
cdef inline vec3 vec3_mul_mat3(vec3 a, mat3 b):
	return vec3(
		a.x*b.m11 + a.y*b.m12 + a.z*b.m13,
		a.x*b.m21 + a.y*b.m22 + a.z*b.m23,
		a.x*b.m31 + a.y*b.m32 + a.z*b.m33)

cdef inline vec3 vec3_pow_vec3(vec3 a, vec3 b):
	return vec3(powf(a.x, b.x), powf(a.y, b.y), powf(a.z, b.z))
cdef inline vec3 vec3_pow_num(vec3 a, float b):
	return vec3(powf(a.x, b), powf(a.y, b), powf(a.z, b))
cdef inline vec3 num_pow_vec3(float a, vec3 b):
	return vec3(powf(a, b.x), powf(a, b.y), powf(a, b.z))

cdef inline vec3 vec3_truediv_vec3(vec3 a, vec3 b):
	return vec3(
		a.x / (onefloat if(b.x==zerfloat) else b.x),
		a.y / (onefloat if(b.y==zerfloat) else b.y),
		a.z / (onefloat if(b.z==zerfloat) else b.z))
cdef inline vec3 vec3_truediv_num(vec3 a, float b):
	v = (onefloat if(b==zerfloat) else b)
	return vec3(a.x / v, a.y / v, a.z / v)
cdef inline vec3 num_truediv_vec3(float a, vec3 b):
	return vec3(
		a / (onefloat if(b.x==zerfloat) else b.x),
		a / (onefloat if(b.y==zerfloat) else b.y),
		a / (onefloat if(b.z==zerfloat) else b.z))


cdef inline vec3 i_vec3_cross(vec3 a, vec3 b):
	cdef float x = a._y * b.z - a._z * b.y
	cdef float y = a._z * b.x - a._x * b.z
	cdef float z = a._x * b.y - a._y * b.x
	a._x = x
	a._y = y
	a._z = z

cdef inline void i_vec3_normalize(vec3 a):
	i_vec3_truediv_num(a, sqrtf(a._x*a._x + a._y*a._y + a._z*a._z) )

cdef inline void i_vec3_projection(vec3 a, vec3 b):
	cdef float d = b.x * b.x + b.y * b.y + b.z * b.z
	cdef float p = (a._x * b.x + a._y * b.y + a._z * b.z) / (onefloat if (d == zerfloat) else d)
	a._x = p * b.x
	a._y = p * b.y
	a._z = p * b.z

cdef inline void i_vec3_add_vec3(vec3 a, vec3 b):
	a._x += b.x
	a._y += b.y
	a._z += b.z
cdef inline vec3 vec3_add_num(vec3 a, float b):
	return vec3(a._x + b, a._y + b, a._z + b)
cdef inline void i_vec3_add_num(vec3 a, float b):
	a._x += b
	a._y += b
	a._z += b

cdef inline void i_vec3_sub_vec3(vec3 a, vec3 b):
	a._x -= b.x
	a._y -= b.y
	a._z -= b.z
cdef inline vec3 vec3_sub_num(vec3 a, float b):
	return vec3(a._x - b, a._y - b, a._z - b)
cdef inline void i_vec3_sub_num(vec3 a, float b):
	a._x -= b
	a._y -= b
	a._z -= b

cdef inline void i_vec3_mul_vec3(vec3 a, vec3 b):
	a._x *= b.x
	a._y *= b.y
	a._z *= b.z
cdef inline void i_vec3_mul_num(vec3 a, float b):
	a._x *= b
	a._y *= b
	a._z *= b
cdef inline void i_vec3_mul_mat3(vec3 a, mat3 b):
	cdef float x = a._x*b.m11 + a._y*b.m12 + a._z*b.m13
	cdef float y = a._x*b.m21 + a._y*b.m22 + a._z*b.m23
	cdef float z = a._x*b.m31 + a._y*b.m32 + a._z*b.m33
	a._x = x
	a._y = y
	a._z = z

cdef inline void i_vec3_pow_vec3(vec3 a, vec3 b):
	a._x = powf(a._x, b.x)
	a._y = powf(a._y, b.y)
	a._z = powf(a._z, b.z)
cdef inline void i_vec3_pow_num(vec3 a, float b):
	a._x = powf(a._x, b)
	a._y = powf(a._y, b)
	a._z = powf(a._z, b)

cdef inline void i_vec3_truediv_vec3(vec3 a, vec3 b):
	a._x /= (onefloat if(b.x==zerfloat) else b.x)
	a._y /= (onefloat if(b.y==zerfloat) else b.y)
	a._z /= (onefloat if(b.z==zerfloat) else b.z)
cdef inline void i_vec3_truediv_num(vec3 a, float b):
	v = (onefloat if(b==zerfloat) else b)
	a._x /= v
	a._y /= v
	a._z /= v

#############################################################################################################################################################################

cdef class mat3:
	cdef float _m11, _m12, _m13 , _m21, _m22, _m23 , _m31, _m32, _m33

	def __init__(self,
		float m11 = onefloat, float m12 = zerfloat, float m13 = zerfloat,
		float m21 = zerfloat, float m22 = onefloat, float m23 = zerfloat,
		float m31 = zerfloat, float m32 = zerfloat, float m33 = onefloat,
	) -> None:
		self._m11 = m11
		self._m12 = m12
		self._m13 = m13
		self._m21 = m21
		self._m22 = m22
		self._m23 = m23
		self._m31 = m31
		self._m32 = m32
		self._m33 = m33

	def __str__(self) -> str:
		return (
			f'\n┌───────────────────────────────────┐\n'
			f'│   {"":^6}      {"":^6}      {"":^6}  │\n'
			f'│   {self._m11:^6.1f}      {self._m12:^6.1f}      {self._m13:^6.1f}  │\n'
			f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
			f'│   {self._m21:^6.1f}      {self._m22:^6.1f}      {self._m23:^6.1f}  │\n'
			f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
			f'│   {self._m31:^6.1f}      {self._m32:^6.1f}      {self._m33:^6.1f}  │\n'
			f'│   {"":^6}      {"":^6}      {"":^6}  │\n'
			f'└───────────────────────────────────┘'
		)



	def GetArray(self) -> Tuple[float, float, float, float, float, float, float, float, float]:
		return self._m11, self._m12, self._m13, self._m21, self._m22, self._m23, self._m31, self._m32, self._m33, 

	def SetArray(self,
		float m11 = onefloat, float m12 = zerfloat, float m13 = zerfloat,
		float m21 = zerfloat, float m22 = onefloat, float m23 = zerfloat,
		float m31 = zerfloat, float m32 = zerfloat, float m33 = onefloat,
	) -> mat3:
		self._m11 = m11
		self._m12 = m12
		self._m13 = m13
		self._m21 = m21
		self._m22 = m22
		self._m23 = m23
		self._m31 = m31
		self._m32 = m32
		self._m33 = m33
		return self

	def SetValue(self, mat3 value) -> mat3:
		self._m11 = value.m11
		self._m12 = value.m12
		self._m13 = value.m13
		self._m21 = value.m21
		self._m22 = value.m22
		self._m23 = value.m23
		self._m31 = value.m31
		self._m32 = value.m32
		self._m33 = value.m33
		return self



	@property
	def m11(self) -> float: return self._m11
	@m11.setter
	def m11(self, float value) -> None: self._m11 = value
	@property
	def m12(self) -> float: return self._m12
	@m12.setter
	def m12(self, float value) -> None: self._m12 = value
	@property
	def m13(self) -> float: return self._m13
	@m13.setter
	def m13(self, float value) -> None: self._m13 = value

	@property
	def m21(self) -> float: return self._m21
	@m21.setter
	def m21(self, float value) -> None: self._m21 = value
	@property
	def m22(self) -> float: return self._m22
	@m22.setter
	def m22(self, float value) -> None: self._m22 = value
	@property
	def m23(self) -> float: return self._m23
	@m23.setter
	def m23(self, float value) -> None: self._m23 = value

	@property
	def m31(self) -> float: return self._m31
	@m31.setter
	def m31(self, float value) -> None: self._m31 = value
	@property
	def m32(self) -> float: return self._m32
	@m32.setter
	def m32(self, float value) -> None: self._m32 = value
	@property
	def m33(self) -> float: return self._m33
	@m33.setter
	def m33(self, float value) -> None: self._m33 = value



	@staticmethod
	def Inverse(mat3 a) -> mat3:
		return mat3_inverse(a)

	@property
	def inverse(self) -> mat3:
		i_mat3_inverse(self)
		return self

	def __mul__(self, value: Union[mat3, vec3, float]) -> Union[mat3, vec3]:
		if isinstance(value, mat3): return mat3_mul_mat3(self,value)
		if isinstance(value, vec3): return mat3_mul_vec3(self,value)
		return mat3_mul_num(self, value)
	def __rmul__(self, float value) -> mat3:
		return num_mul_mat3(value,self)
	def __imul__(self, value: Union[mat3, float]) -> mat3:
		if isinstance(value, mat3): i_mat3_mul_mat3(self,value)
		else: i_mat3_mul_num(self, value)
		return self



cdef inline mat3 mat3_mul_mat3(mat3 a, mat3 b):
	return mat3(
		a.m11 * b.m11 + a.m12 * b.m21 + a.m13 * b.m31,
		a.m11 * b.m12 + a.m12 * b.m22 + a.m13 * b.m32,
		a.m11 * b.m13 + a.m12 * b.m23 + a.m13 * b.m33,
		a.m21 * b.m11 + a.m22 * b.m21 + a.m23 * b.m31,
		a.m21 * b.m12 + a.m22 * b.m22 + a.m23 * b.m32,
		a.m21 * b.m13 + a.m22 * b.m23 + a.m23 * b.m33,
		a.m31 * b.m11 + a.m32 * b.m21 + a.m33 * b.m31,
		a.m31 * b.m12 + a.m32 * b.m22 + a.m33 * b.m32,
		a.m31 * b.m13 + a.m32 * b.m23 + a.m33 * b.m33)
cdef inline vec3 mat3_mul_vec3(mat3 a, vec3 b):
	return vec3(
		a.m11*b.x + a.m21*b.y + a.m31*b.z,
		a.m12*b.x + a.m22*b.y + a.m32*b.z,
		a.m13*b.x + a.m23*b.y + a.m33*b.z)
cdef inline mat3 mat3_mul_num(mat3 a, float b):
	return mat3(
		a.m11 * b,
		a.m12 * b,
		a.m13 * b,
		a.m21 * b,
		a.m22 * b,
		a.m23 * b,
		a.m31 * b,
		a.m32 * b,
		a.m33 * b)
cdef inline mat3 num_mul_mat3(float a, mat3 b):
	return mat3(
		a * b.m11,
		a * b.m12,
		a * b.m13,
		a * b.m21,
		a * b.m22,
		a * b.m23,
		a * b.m31,
		a * b.m32,
		a * b.m33)

cdef inline mat3 mat3_inverse(mat3 a):
	cdef float det = (
		a.m11 * (a.m22 * a.m33 - a.m23 * a.m32) -
		a.m12 * (a.m21 * a.m33 - a.m23 * a.m31) +
		a.m13 * (a.m21 * a.m32 - a.m22 * a.m31))
	det = onefloat / (onefloat if(det == zerfloat) else det)

	return mat3(
		(a.m22 * a.m33 - a.m23 * a.m32) * det,
		(a.m13 * a.m32 - a.m12 * a.m33) * det,
		(a.m12 * a.m23 - a.m13 * a.m22) * det,

		(a.m23 * a.m31 - a.m21 * a.m33) * det,
		(a.m11 * a.m33 - a.m13 * a.m31) * det,
		(a.m13 * a.m21 - a.m11 * a.m23) * det,

		(a.m21 * a.m32 - a.m22 * a.m31) * det,
		(a.m12 * a.m31 - a.m11 * a.m32) * det,
		(a.m11 * a.m22 - a.m12 * a.m21) * det)


cdef inline void i_mat3_mul_mat3(mat3 a, mat3 b):
	cdef float m11 = a._m11 * b.m11 + a._m12 * b.m21 + a._m13 * b.m31
	cdef float m12 = a._m11 * b.m12 + a._m12 * b.m22 + a._m13 * b.m32
	cdef float m13 = a._m11 * b.m13 + a._m12 * b.m23 + a._m13 * b.m33
	cdef float m21 = a._m21 * b.m11 + a._m22 * b.m21 + a._m23 * b.m31
	cdef float m22 = a._m21 * b.m12 + a._m22 * b.m22 + a._m23 * b.m32
	cdef float m23 = a._m21 * b.m13 + a._m22 * b.m23 + a._m23 * b.m33
	cdef float m31 = a._m31 * b.m11 + a._m32 * b.m21 + a._m33 * b.m31
	cdef float m32 = a._m31 * b.m12 + a._m32 * b.m22 + a._m33 * b.m32
	cdef float m33 = a._m31 * b.m13 + a._m32 * b.m23 + a._m33 * b.m33
	a._m11 = m11
	a._m12 = m12
	a._m13 = m13
	a._m21 = m21
	a._m22 = m22
	a._m23 = m23
	a._m31 = m31
	a._m32 = m32
	a._m33 = m33
cdef inline void i_mat3_mul_num(mat3 a, float b):
	a._m11 *= b
	a._m12 *= b
	a._m13 *= b
	a._m21 *= b
	a._m22 *= b
	a._m23 *= b
	a._m31 *= b
	a._m32 *= b
	a._m33 *= b

cdef inline void i_mat3_inverse(mat3 a):
	cdef float det = (
		a._m11 * (a._m22 * a._m33 - a._m23 * a._m32) -
		a._m12 * (a._m21 * a._m33 - a._m23 * a._m31) +
		a._m13 * (a._m21 * a._m32 - a._m22 * a._m31)
	)
	det = onefloat / (onefloat if(det == zerfloat) else det)

	cdef float m11 = (a._m22 * a._m33 - a._m23 * a._m32) * det
	cdef float m12 = (a._m13 * a._m32 - a._m12 * a._m33) * det
	cdef float m13 = (a._m12 * a._m23 - a._m13 * a._m22) * det
	cdef float m21 = (a._m23 * a._m31 - a._m21 * a._m33) * det
	cdef float m22 = (a._m11 * a._m33 - a._m13 * a._m31) * det
	cdef float m23 = (a._m13 * a._m21 - a._m11 * a._m23) * det
	cdef float m31 = (a._m21 * a._m32 - a._m22 * a._m31) * det
	cdef float m32 = (a._m12 * a._m31 - a._m11 * a._m32) * det
	cdef float m33 = (a._m11 * a._m22 - a._m12 * a._m21) * det

	a._m11 = m11
	a._m12 = m12
	a._m13 = m13
	a._m21 = m21
	a._m22 = m22
	a._m23 = m23
	a._m31 = m31
	a._m32 = m32
	a._m33 = m33

#==============================================================================================================
#==============================================================================================================
#==============================================================================================================


cdef class vec4:
	cdef float _x, _y, _z, _w

	def __init__(self, float x, float y = NAN, float z = NAN, float w = NAN) -> None:
		self._x = x
		self._y = x if(isnan(<double>y)) else y
		self._z = x if(isnan(<double>z)) else z
		self._w = x if(isnan(<double>w)) else w

	def __str__(self) -> str:
		return (
			f'\n┌───────────────────────────────────────────────┐\n'
			f'│   {self._x:^6.1f}  ○   {self._y:^6.1f}  ○   {self._z:^6.1f}  ○   {self._w:^6.1f}  │\n'
			f'└───────────────────────────────────────────────┘'
		)


	@property
	def x(self) -> float: return self._x
	@x.setter
	def x(self, float value) -> None: self._x = value

	@property
	def y(self) -> float: return self._y
	@y.setter
	def y(self, float value) -> None: self._y = value

	@property
	def z(self) -> float: return self._z
	@z.setter
	def z(self, float value) -> None: self._z = value

	@property
	def w(self) -> float: return self._w
	@w.setter
	def w(self, float value) -> None: self._w = value

	def GetArray(self) -> Tuple[float, float, float, float]: return self._x, self._y, self._z, self._w

	def SetArray(self, float x, float y = NAN, float z = NAN, float w = NAN) -> vec4:
		self._x = x
		self._y = x if(isnan(<double>y)) else y
		self._z = x if(isnan(<double>z)) else z
		self._w = x if(isnan(<double>w)) else w
		return self
	def SetValue(self, vec4 value) -> vec4:
		self._x = value.x
		self._y = value.y
		self._z = value.z
		self._w = value.w
		return self


	@staticmethod
	def DotProduct(vec4 a, vec4 b) -> float:
		return vec4_dot(a,b)
	@staticmethod
	def Magnitude(vec4 a) -> float:
		return vec4_magnitude(a)
	@staticmethod
	def Normalize(vec4 a) -> vec4:
		return vec4_normalize(a)
	@property
	def normalize(self) -> vec4:
		i_vec4_normalize(self)
		return self
	@staticmethod
	def Projection(vec4 a, vec4 b) -> vec4:
		return vec4_projection(a, b)
	def project(self, vec4 b) -> vec4:
		i_vec4_projection(self, b)
		return self
	@staticmethod
	def Angle(vec4 a, vec4 b) -> float:
		return vec4_angle(a, b)



	def __neg__(self) -> vec4: return vec4(-self._x,-self._y,-self._z,-self._w)
	def __pos__(self) -> vec4: return vec4(self._x,self._y,self._z,self._w)
	def __abs__(self) -> vec4: return vec4(abs(self._x),abs(self._y),abs(self._z),abs(self._w))



	def __lt__(self, value: Union[vec4, float]) -> bool:
		if(isinstance(value, vec4)): return bool(vec4_lt_vec4(self,value))
		return bool(vec4_lt_num(self,value))
	def __le__(self, value: Union[vec4, float]) -> bool:
		if(isinstance(value, vec4)): return bool(vec4_le_vec4(self,value))
		return bool(vec4_le_num(self,value))
	def __eq__(self, value: Union[vec4, float]) -> bool:
		if(isinstance(value, vec4)): return bool(vec4_eq_vec4(self,value))
		return bool(vec4_eq_num(self,value))
	def __ne__(self, value: Union[vec4, float]) -> bool:
		if(isinstance(value, vec4)): return bool(vec4_ne_vec4(self,value))
		return bool(vec4_ne_num(self,value))
	def __ge__(self, value: Union[vec4, float]) -> bool:
		if(isinstance(value, vec4)): return bool(vec4_ge_vec4(self,value))
		return bool(vec4_ge_num(self,value))
	def __gt__(self, value: Union[vec4, float]) -> bool:
		if(isinstance(value, vec4)): return bool(vec4_gt_vec4(self,value))
		return bool(vec4_gt_num(self,value))



	def __add__(self, value: Union[vec4, float]) -> vec4:
		if(isinstance(value, vec4)): return vec4_add_vec4(self,value)
		return vec4_add_num(self,value)
	def __radd__(self, float value) -> vec4:
		return num_add_vec4(value,self)
	def __iadd__(self, value: Union[vec4, float]) -> vec4:
		if(isinstance(value, vec4)): i_vec4_add_vec4(self,value)
		else: i_vec4_add_num(self,value)
		return self



	def __sub__(self, value: Union[vec4, float]) -> vec4:
		if(isinstance(value, vec4)): return vec4_sub_vec4(self,value)
		return vec4_sub_num(self,value)
	def __rsub__(self, float value) -> vec4:
		return num_sub_vec4(value,self)
	def __isub__(self, value: Union[vec4, float]) -> vec4:
		if(isinstance(value, vec4)): i_vec4_sub_vec4(self,value)
		else: i_vec4_sub_num(self,value)
		return self



	def __mul__(self, value: Union[mat4, vec4, float]) -> vec4:
		if(isinstance(value, mat4)): return vec4_mul_mat4(self,value)
		if(isinstance(value, vec4)): return vec4_mul_vec4(self,value)
		return vec4_mul_num(self,value)
	def __rmul__(self, float value) -> vec4:
		return num_mul_vec4(value,self)
	def __imul__(self, value: Union[mat4, vec4, float]) -> vec4:
		if(isinstance(value, mat4)): i_vec4_mul_mat4(self,value)
		elif(isinstance(value, vec4)): i_vec4_mul_vec4(self,value)
		else: i_vec4_mul_num(self,value)
		return self



	def __pow__(self, value: Union[vec4, float]) -> vec4:
		if(isinstance(value, vec4)): return vec4_pow_vec4(self,value)
		return vec4_pow_num(self,value)
	def __rpow__(self, float value) -> vec4:
		return num_pow_vec4(value,self)
	def __ipow__(self, value: Union[vec4, float]) -> vec4:
		if(isinstance(value, vec4)): i_vec4_pow_vec4(self,value)
		else: i_vec4_pow_num(self,value)
		return self



	def __truediv__(self, value: Union[vec4, float]) -> vec4:
		if(isinstance(value, vec4)): return vec4_truediv_vec4(self,value)
		return vec4_truediv_num(self,value)
	def __rtruediv__(self, float value) -> vec4:
		return num_truediv_vec4(value,self)
	def __itruediv__(self, value: Union[vec4, float]) -> vec4:
		if(isinstance(value, vec4)): i_vec4_truediv_vec4(self,value)
		else: i_vec4_truediv_num(self,value)
		return self



cdef inline float vec4_dot(vec4 a, vec4 b):
	return a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w

cdef inline float vec4_magnitude(vec4 a):
	return sqrtf(a.x*a.x + a.y*a.y + a.z*a.z + a.w*a.w)

cdef inline vec4 vec4_normalize(vec4 a):
	return vec4_truediv_num(a, sqrtf(a.x*a.x + a.y*a.y + a.z*a.z + a.w*a.w) )

cdef inline vec4 vec4_projection(vec4 a, vec4 b):
	cdef float d = b.x * b.x + b.y * b.y + b.z * b.z + b.w * b.w
	cdef float p = (a.x * b.x + a.y * b.y + a.z * b.z + a.w*a.w) / (onefloat if (d == zerfloat) else d)
	return vec4(
		p * b.x,
		p * b.y,
		p * b.z,
		p * b.w)

cdef inline float vec4_angle(vec4 a, vec4 b):
	cdef float magnitude = sqrtf(a.x*a.x + a.y*a.y + a.z*a.z + a.w*a.w) * sqrtf(b.x*b.x + b.y*b.y + b.z*b.z + b.w*b.w)
	return acosf(max(min(((a.x*b.x + a.y*b.y + a.z*b.z + a.w*a.w) / (onefloat if(magnitude == zerfloat) else magnitude)), onefloat), negfloat))



cdef inline bint vec4_lt_vec4(vec4 a, vec4 b):
	return <bint>(a.x < b.x and a.y < b.y and a.z < b.z and a.w < b.w)
cdef inline bint vec4_lt_num(vec4 a, float b):
	return <bint>(a.x < b and a.y < b and a.z < b and a.w < b)
cdef inline bint vec4_le_vec4(vec4 a, vec4 b):
	return <bint>(a.x <= b.x and a.y <= b.y and a.z <= b.z and a.w <= b.w)
cdef inline bint vec4_le_num(vec4 a, float b):
	return <bint>(a.x <= b and a.y <= b and a.z <= b and a.w <= b)
cdef inline bint vec4_eq_vec4(vec4 a, vec4 b):
	return <bint>(a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w)
cdef inline bint vec4_eq_num(vec4 a, float b):
	return <bint>(a.x == b and a.y == b and a.z == b and a.w == b)
cdef inline bint vec4_ne_vec4(vec4 a, vec4 b):
	return <bint>(a.x != b.x or a.y != b.y or a.z != b.z or a.w != b.w)
cdef inline bint vec4_ne_num(vec4 a, float b):
	return <bint>(a.x != b or a.y != b or a.z != b or a.w != b)
cdef inline bint vec4_ge_vec4(vec4 a, vec4 b):
	return <bint>(a.x >= b.x and a.y >= b.y and a.z >= b.z and a.w >= b.w)
cdef inline bint vec4_ge_num(vec4 a, float b):
	return <bint>(a.x >= b and a.y >= b and a.z >= b and a.w >= b)
cdef inline bint vec4_gt_vec4(vec4 a, vec4 b):
	return <bint>(a.x > b.x and a.y > b.y and a.z > b.z and a.w > b.w)
cdef inline bint vec4_gt_num(vec4 a, float b):
	return <bint>(a.x > b and a.y > b and a.z > b and a.w > b)



cdef inline vec4 vec4_add_vec4(vec4 a, vec4 b):
	return vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
cdef inline vec4 vec4_add_num(vec4 a, float b):
	return vec4(a.x + b, a.y + b, a.z + b, a.w + b)
cdef inline vec4 num_add_vec4(float a, vec4 b):
	return vec4(a + b.x, a + b.y, a + b.z, a + b.w)

cdef inline vec4 vec4_sub_vec4(vec4 a, vec4 b):
	return vec4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
cdef inline vec4 vec4_sub_num(vec4 a, float b):
	return vec4(a.x - b, a.y - b, a.z - b, a.w - b)
cdef inline vec4 num_sub_vec4(float a, vec4 b):
	return vec4(a - b.x, a - b.y, a - b.z, a - b.w)

cdef inline vec4 vec4_mul_vec4(vec4 a, vec4 b):
	return vec4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)
cdef inline vec4 vec4_mul_num(vec4 a, float b):
	return vec4(a.x * b, a.y * b, a.z * b, a.w * b)
cdef inline vec4 num_mul_vec4(float a, vec4 b):
	return vec4(a * b.x, a * b.y, a * b.z, a * b.w)
cdef inline vec4 vec4_mul_mat4(vec4 a, mat4 b):
	return vec4(
		a.x*b.m11 + a.y*b.m12 + a.z*b.m13 + a.w*b.m14,
		a.x*b.m21 + a.y*b.m22 + a.z*b.m23 + a.w*b.m24,
		a.x*b.m31 + a.y*b.m32 + a.z*b.m33 + a.w*b.m34,
		a.x*b.m41 + a.y*b.m42 + a.z*b.m43 + a.w*b.m44)

cdef inline vec4 vec4_pow_vec4(vec4 a, vec4 b):
	return vec4(powf(a.x, b.x), powf(a.y, b.y), powf(a.z, b.z), powf(a.w, b.w))
cdef inline vec4 vec4_pow_num(vec4 a, float b):
	return vec4(powf(a.x, b), powf(a.y, b), powf(a.z, b), powf(a.w, b))
cdef inline vec4 num_pow_vec4(float a, vec4 b):
	return vec4(powf(a, b.x), powf(a, b.y), powf(a, b.z), powf(a, b.w))

cdef inline vec4 vec4_truediv_vec4(vec4 a, vec4 b):
	return vec4(
		a.x / (onefloat if(b.x==zerfloat) else b.x),
		a.y / (onefloat if(b.y==zerfloat) else b.y),
		a.z / (onefloat if(b.z==zerfloat) else b.z),
		a.w / (onefloat if(b.w==zerfloat) else b.w))
cdef inline vec4 vec4_truediv_num(vec4 a, float b):
	v = (onefloat if(b==zerfloat) else b)
	return vec4(a.x / v, a.y / v, a.z / v, a.w / v)
cdef inline vec4 num_truediv_vec4(float a, vec4 b):
	return vec4(
		a / (onefloat if(b.x==zerfloat) else b.x),
		a / (onefloat if(b.y==zerfloat) else b.y),
		a / (onefloat if(b.z==zerfloat) else b.z),
		a / (onefloat if(b.w==zerfloat) else b.w))


cdef inline void i_vec4_normalize(vec4 a):
	i_vec4_truediv_num(a, sqrtf(a._x*a._x + a._y*a._y + a._z*a._z + a._w*a._w) )

cdef inline void i_vec4_projection(vec4 a, vec4 b):
	cdef float d = b.x * b.x + b.y * b.y + b.z * b.z + b.w * b.w
	cdef float p = (a._x * b.x + a._y * b.y + a._z * b.z + a._w*a._w) / (onefloat if (d == zerfloat) else d)
	a._x = p * b.x
	a._y = p * b.y
	a._z = p * b.z
	a._w = p * b.w

cdef inline void i_vec4_add_vec4(vec4 a, vec4 b):
	a._x += b.x
	a._y += b.y
	a._z += b.z
	a._w += b.w
cdef inline void i_vec4_add_num(vec4 a, float b):
	a._x += b
	a._y += b
	a._z += b
	a._w += b

cdef inline void i_vec4_sub_vec4(vec4 a, vec4 b):
	a._x -= b.x
	a._y -= b.y
	a._z -= b.z
	a._w -= b.w
cdef inline void i_vec4_sub_num(vec4 a, float b):
	a._x -= b
	a._y -= b
	a._z -= b
	a._w -= b

cdef inline void i_vec4_mul_vec4(vec4 a, vec4 b):
	a._x *= b.x
	a._y *= b.y
	a._z *= b.z
	a._w *= b.w
cdef inline void i_vec4_mul_num(vec4 a, float b):
	a._x *= b
	a._y *= b
	a._z *= b
	a._w *= b
cdef inline void i_vec4_mul_mat4(vec4 a, mat4 b):
	cdef float x = a._x*b.m11 + a._y*b.m12 + a._z*b.m13 + a._w*b.m14
	cdef float y = a._x*b.m21 + a._y*b.m22 + a._z*b.m23 + a._w*b.m24
	cdef float z = a._x*b.m31 + a._y*b.m32 + a._z*b.m33 + a._w*b.m34
	cdef float w = a._x*b.m41 + a._y*b.m42 + a._z*b.m43 + a._w*b.m44
	a._x = x
	a._y = y
	a._z = z
	a._w = w

cdef inline void i_vec4_pow_vec4(vec4 a, vec4 b):
	a._x = powf(a._x, b.x)
	a._y = powf(a._y, b.y)
	a._z = powf(a._z, b.z)
	a._w = powf(a._w, b.w)
cdef inline void i_vec4_pow_num(vec4 a, float b):
	a._x = powf(a._x, b)
	a._y = powf(a._y, b)
	a._z = powf(a._z, b)
	a._w = powf(a._w, b)

cdef inline void i_vec4_truediv_vec4(vec4 a, vec4 b):
	a._x /= (onefloat if(b.x==zerfloat) else b.x)
	a._y /= (onefloat if(b.y==zerfloat) else b.y)
	a._z /= (onefloat if(b.z==zerfloat) else b.z)
	a._w /= (onefloat if(b.w==zerfloat) else b.w)
cdef inline void i_vec4_truediv_num(vec4 a, float b):
	v = (onefloat if(b==zerfloat) else b)
	a._x /= v
	a._y /= v
	a._z /= v
	a._w /= v

#############################################################################################################################################################################

cdef class mat4:
	cdef float _m11, _m12, _m13, _m14 , _m21, _m22, _m23, _m24 , _m31, _m32, _m33, _m34 , _m41, _m42, _m43, _m44

	def __init__(self,
		float m11 = onefloat, float m12 = zerfloat, float m13 = zerfloat, float m14 = zerfloat,
		float m21 = zerfloat, float m22 = onefloat, float m23 = zerfloat, float m24 = zerfloat,
		float m31 = zerfloat, float m32 = zerfloat, float m33 = onefloat, float m34 = zerfloat,
		float m41 = zerfloat, float m42 = zerfloat, float m43 = zerfloat, float m44 = onefloat,
	) -> None:
		self._m11, self._m12, self._m13, self._m14 = m11, m12, m13, m14
		self._m21, self._m22, self._m23, self._m24 = m21, m22, m23, m24
		self._m31, self._m32, self._m33, self._m34 = m31, m32, m33, m34
		self._m41, self._m42, self._m43, self._m44 = m41, m42, m43, m44

	def __str__(self) -> str:
		return (
			f'\n┌───────────────────────────────────────────────┐\n'
			f'│   {"":^6}      {"":^6}      {"":^6}      {"":^6}  │\n'
			f'│   {self._m11:^6.1f}      {self._m12:^6.1f}      {self._m13:^6.1f}      {self._m14:^6.1f}  │\n'
			f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
			f'│   {self._m21:^6.1f}      {self._m22:^6.1f}      {self._m23:^6.1f}      {self._m24:^6.1f}  │\n'
			f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
			f'│   {self._m31:^6.1f}      {self._m32:^6.1f}      {self._m33:^6.1f}      {self._m34:^6.1f}  │\n'
			f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
			f'│   {self._m41:^6.1f}      {self._m42:^6.1f}      {self._m43:^6.1f}      {self._m44:^6.1f}  │\n'
			f'│   {"":^6}      {"":^6}      {"":^6}      {"":^6}  │\n'
			f'└───────────────────────────────────────────────┘'
		)


	def GetArray(self) -> Tuple[float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float]:
		return self._m11, self._m12, self._m13, self._m14 , self._m21, self._m22, self._m23, self._m24 , self._m31, self._m32, self._m33, self._m34 , self._m41, self._m42, self._m43, self._m44

	def SetArray(self,
		float m11 = onefloat, float m12 = zerfloat, float m13 = zerfloat, float m14 = zerfloat,
		float m21 = zerfloat, float m22 = onefloat, float m23 = zerfloat, float m24 = zerfloat,
		float m31 = zerfloat, float m32 = zerfloat, float m33 = onefloat, float m34 = zerfloat,
		float m41 = zerfloat, float m42 = zerfloat, float m43 = zerfloat, float m44 = onefloat,
	) -> mat4:
		self._m11, self._m12, self._m13, self._m14 = m11, m12, m13, m14
		self._m21, self._m22, self._m23, self._m24 = m21, m22, m23, m24
		self._m31, self._m32, self._m33, self._m34 = m31, m32, m33, m34
		self._m41, self._m42, self._m43, self._m44 = m41, m42, m43, m44
		return self

	def SetValue(self, mat4 value) -> mat4:
		self._m11, self._m12, self._m13, self._m14 = value.m11, value.m12, value.m13, value.m14
		self._m21, self._m22, self._m23, self._m24 = value.m21, value.m22, value.m23, value.m24
		self._m31, self._m32, self._m33, self._m34 = value.m31, value.m32, value.m33, value.m34
		self._m41, self._m42, self._m43, self._m44 = value.m41, value.m42, value.m43, value.m44
		return self



	@property
	def m11(self) -> float: return self._m11
	@m11.setter
	def m11(self, float value) -> None: self._m11 = value
	@property
	def m12(self) -> float: return self._m12
	@m12.setter
	def m12(self, float value) -> None: self._m12 = value
	@property
	def m13(self) -> float: return self._m13
	@m13.setter
	def m13(self, float value) -> None: self._m13 = value
	@property
	def m14(self) -> float: return self._m14
	@m14.setter
	def m14(self, float value) -> None: self._m14 = value

	@property
	def m21(self) -> float: return self._m21
	@m21.setter
	def m21(self, float value) -> None: self._m21 = value
	@property
	def m22(self) -> float: return self._m22
	@m22.setter
	def m22(self, float value) -> None: self._m22 = value
	@property
	def m23(self) -> float: return self._m23
	@m23.setter
	def m23(self, float value) -> None: self._m23 = value
	@property
	def m24(self) -> float: return self._m24
	@m24.setter
	def m24(self, float value) -> None: self._m24 = value

	@property
	def m31(self) -> float: return self._m31
	@m31.setter
	def m31(self, float value) -> None: self._m31 = value
	@property
	def m32(self) -> float: return self._m32
	@m32.setter
	def m32(self, float value) -> None: self._m32 = value
	@property
	def m33(self) -> float: return self._m33
	@m33.setter
	def m33(self, float value) -> None: self._m33 = value
	@property
	def m34(self) -> float: return self._m34
	@m34.setter
	def m34(self, float value) -> None: self._m34 = value

	@property
	def m41(self) -> float: return self._m41
	@m41.setter
	def m41(self, float value) -> None: self._m41 = value
	@property
	def m42(self) -> float: return self._m42
	@m42.setter
	def m42(self, float value) -> None: self._m42 = value
	@property
	def m43(self) -> float: return self._m43
	@m43.setter
	def m43(self, float value) -> None: self._m43 = value
	@property
	def m44(self) -> float: return self._m44
	@m44.setter
	def m44(self, float value) -> None: self._m44 = value



	@staticmethod
	def Inverse(mat4 a) -> mat4:
		return mat4_inverse(a)
	
	@property
	def inverse(self) -> mat4:
		i_mat4_inverse(self)
		return self

	def __mul__(self, value: Union[mat4, vec4, vec3, float]) -> Union[mat4, vec4, vec3]:
		if isinstance(value, mat4): return mat4_mul_mat4(self,value)
		if isinstance(value, vec4): return mat4_mul_vec4(self,value)
		if isinstance(value, vec3): return mat4_mul_vec3(self,value)
		return mat4_mul_num(self, value)
	def __rmul__(self, float value) -> mat4:
		return num_mul_mat4(value,self)
	def __imul__(self, value: Union[mat4, float]) -> mat4:
		if isinstance(value, mat4): i_mat4_mul_mat4(self,value)
		else: i_mat4_mul_num(self, value)
		return self



cdef inline mat4 mat4_mul_mat4(mat4 a, mat4 b):
	return mat4(
		a.m11 * b.m11 + a.m12 * b.m21 + a.m13 * b.m31 + a.m14 * b.m41,
		a.m11 * b.m12 + a.m12 * b.m22 + a.m13 * b.m32 + a.m14 * b.m42,
		a.m11 * b.m13 + a.m12 * b.m23 + a.m13 * b.m33 + a.m14 * b.m43,
		a.m11 * b.m14 + a.m12 * b.m24 + a.m13 * b.m34 + a.m14 * b.m44,
		a.m21 * b.m11 + a.m22 * b.m21 + a.m23 * b.m31 + a.m24 * b.m41,
		a.m21 * b.m12 + a.m22 * b.m22 + a.m23 * b.m32 + a.m24 * b.m42,
		a.m21 * b.m13 + a.m22 * b.m23 + a.m23 * b.m33 + a.m24 * b.m43,
		a.m21 * b.m14 + a.m22 * b.m24 + a.m23 * b.m34 + a.m24 * b.m44,
		a.m31 * b.m11 + a.m32 * b.m21 + a.m33 * b.m31 + a.m34 * b.m41,
		a.m31 * b.m12 + a.m32 * b.m22 + a.m33 * b.m32 + a.m34 * b.m42,
		a.m31 * b.m13 + a.m32 * b.m23 + a.m33 * b.m33 + a.m34 * b.m43,
		a.m31 * b.m14 + a.m32 * b.m24 + a.m33 * b.m34 + a.m34 * b.m44,
		a.m41 * b.m11 + a.m42 * b.m21 + a.m43 * b.m31 + a.m44 * b.m41,
		a.m41 * b.m12 + a.m42 * b.m22 + a.m43 * b.m32 + a.m44 * b.m42,
		a.m41 * b.m13 + a.m42 * b.m23 + a.m43 * b.m33 + a.m44 * b.m43,
		a.m41 * b.m14 + a.m42 * b.m24 + a.m43 * b.m34 + a.m44 * b.m44
	)
cdef inline vec4 mat4_mul_vec4(mat4 a, vec4 b):
	return vec4(
		a.m11*b.x + a.m21*b.y + a.m31*b.z + a.m41*b.w,
		a.m12*b.x + a.m22*b.y + a.m32*b.z + a.m42*b.w,
		a.m13*b.x + a.m23*b.y + a.m33*b.z + a.m43*b.w,
		a.m14*b.x + a.m24*b.y + a.m34*b.z + a.m44*b.w
	)
cdef inline vec3 mat4_mul_vec3(mat4 a, vec3 b):
	return vec3(
		a.m11*b.x + a.m21*b.y + a.m31*b.z + a.m41*onefloat,
		a.m12*b.x + a.m22*b.y + a.m32*b.z + a.m42*onefloat,
		a.m13*b.x + a.m23*b.y + a.m33*b.z + a.m43*onefloat
	)
cdef inline mat4 mat4_mul_num(mat4 a, float b):
	return mat4(
		a.m11 * b,
		a.m12 * b,
		a.m13 * b,
		a.m14 * b,
		a.m21 * b,
		a.m22 * b,
		a.m23 * b,
		a.m24 * b,
		a.m31 * b,
		a.m32 * b,
		a.m33 * b,
		a.m34 * b,
		a.m41 * b,
		a.m42 * b,
		a.m43 * b,
		a.m44 * b,
	)
cdef inline mat4 num_mul_mat4(float a, mat4 b):
	return mat4(
		a * b.m11,
		a * b.m12,
		a * b.m13,
		a * b.m14,
		a * b.m21,
		a * b.m22,
		a * b.m23,
		a * b.m24,
		a * b.m31,
		a * b.m32,
		a * b.m33,
		a * b.m34,
		a * b.m41,
		a * b.m42,
		a * b.m43,
		a * b.m44,
	)

cdef inline mat4 mat4_inverse(mat4 a):
	cdef float s0 = a.m11 * a.m22 - a.m12 * a.m21
	cdef float s1 = a.m11 * a.m23 - a.m13 * a.m21
	cdef float s2 = a.m11 * a.m24 - a.m14 * a.m21
	cdef float s3 = a.m12 * a.m23 - a.m13 * a.m22
	cdef float s4 = a.m12 * a.m24 - a.m14 * a.m22
	cdef float s5 = a.m13 * a.m24 - a.m14 * a.m23
	cdef float c5 = a.m33 * a.m44 - a.m34 * a.m43
	cdef float c4 = a.m32 * a.m44 - a.m34 * a.m42
	cdef float c3 = a.m32 * a.m43 - a.m33 * a.m42
	cdef float c2 = a.m31 * a.m44 - a.m34 * a.m41
	cdef float c1 = a.m31 * a.m43 - a.m33 * a.m41
	cdef float c0 = a.m31 * a.m42 - a.m32 * a.m41

	cdef float det = (s0 * c5 - s1 * c4 + s2 * c3 + s3 * c2 - s4 * c1 + s5 * c0)
	det = onefloat / (onefloat if(det == zerfloat) else det)

	return mat4(
		(a.m22 * c5 - a.m23 * c4 + a.m24 * c3) * det,
		(-a.m12 * c5 + a.m13 * c4 - a.m14 * c3) * det,
		(a.m42 * s5 - a.m43 * s4 + a.m44 * s3) * det,
		(-a.m32 * s5 + a.m33 * s4 - a.m34 * s3) * det,
		(-a.m21 * c5 + a.m23 * c2 - a.m24 * c1) * det,
		(a.m11 * c5 - a.m13 * c2 + a.m14 * c1) * det,
		(-a.m41 * s5 + a.m43 * s2 - a.m44 * s1) * det,
		(a.m31 * s5 - a.m33 * s2 + a.m34 * s1) * det,
		(a.m21 * c4 - a.m22 * c2 + a.m24 * c0) * det,
		(-a.m11 * c4 + a.m12 * c2 - a.m14 * c0) * det,
		(a.m41 * s4 - a.m42 * s2 + a.m44 * s0) * det,
		(-a.m31 * s4 + a.m32 * s2 - a.m34 * s0) * det,
		(-a.m21 * c3 + a.m22 * c1 - a.m23 * c0) * det,
		(a.m11 * c3 - a.m12 * c1 + a.m13 * c0) * det,
		(-a.m41 * s3 + a.m42 * s1 - a.m43 * s0) * det,
		(a.m31 * s3 - a.m32 * s1 + a.m33 * s0) * det
	)


cdef inline void i_mat4_mul_mat4(mat4 a, mat4 b):
	cdef float m11 = a._m11 * b.m11 + a._m12 * b.m21 + a._m13 * b.m31 + a._m14 * b.m41
	cdef float m12 = a._m11 * b.m12 + a._m12 * b.m22 + a._m13 * b.m32 + a._m14 * b.m42
	cdef float m13 = a._m11 * b.m13 + a._m12 * b.m23 + a._m13 * b.m33 + a._m14 * b.m43
	cdef float m14 = a._m11 * b.m14 + a._m12 * b.m24 + a._m13 * b.m34 + a._m14 * b.m44
	cdef float m21 = a._m21 * b.m11 + a._m22 * b.m21 + a._m23 * b.m31 + a._m24 * b.m41
	cdef float m22 = a._m21 * b.m12 + a._m22 * b.m22 + a._m23 * b.m32 + a._m24 * b.m42
	cdef float m23 = a._m21 * b.m13 + a._m22 * b.m23 + a._m23 * b.m33 + a._m24 * b.m43
	cdef float m24 = a._m21 * b.m14 + a._m22 * b.m24 + a._m23 * b.m34 + a._m24 * b.m44
	cdef float m31 = a._m31 * b.m11 + a._m32 * b.m21 + a._m33 * b.m31 + a._m34 * b.m41
	cdef float m32 = a._m31 * b.m12 + a._m32 * b.m22 + a._m33 * b.m32 + a._m34 * b.m42
	cdef float m33 = a._m31 * b.m13 + a._m32 * b.m23 + a._m33 * b.m33 + a._m34 * b.m43
	cdef float m34 = a._m31 * b.m14 + a._m32 * b.m24 + a._m33 * b.m34 + a._m34 * b.m44
	cdef float m41 = a._m41 * b.m11 + a._m42 * b.m21 + a._m43 * b.m31 + a._m44 * b.m41
	cdef float m42 = a._m41 * b.m12 + a._m42 * b.m22 + a._m43 * b.m32 + a._m44 * b.m42
	cdef float m43 = a._m41 * b.m13 + a._m42 * b.m23 + a._m43 * b.m33 + a._m44 * b.m43
	cdef float m44 = a._m41 * b.m14 + a._m42 * b.m24 + a._m43 * b.m34 + a._m44 * b.m44
	a._m11 = m11
	a._m12 = m12
	a._m13 = m13
	a._m14 = m14
	a._m21 = m21
	a._m22 = m22
	a._m23 = m23
	a._m24 = m24
	a._m31 = m31
	a._m32 = m32
	a._m33 = m33
	a._m34 = m34
	a._m41 = m41
	a._m42 = m42
	a._m43 = m43
	a._m44 = m44
cdef inline void i_mat4_mul_num(mat4 a, float b):
	a._m11 *= b
	a._m12 *= b
	a._m13 *= b
	a._m14 *= b
	a._m21 *= b
	a._m22 *= b
	a._m23 *= b
	a._m24 *= b
	a._m31 *= b
	a._m32 *= b
	a._m33 *= b
	a._m34 *= b
	a._m41 *= b
	a._m42 *= b
	a._m43 *= b
	a._m44 *= b

cdef inline void i_mat4_inverse(mat4 a):
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

	cdef float m11 = (a._m22 * c5 - a._m23 * c4 + a._m24 * c3) * det
	cdef float m12 = (-a._m12 * c5 + a._m13 * c4 - a._m14 * c3) * det
	cdef float m13 = (a._m42 * s5 - a._m43 * s4 + a._m44 * s3) * det
	cdef float m14 = (-a._m32 * s5 + a._m33 * s4 - a._m34 * s3) * det
	cdef float m21 = (-a._m21 * c5 + a._m23 * c2 - a._m24 * c1) * det
	cdef float m22 = (a._m11 * c5 - a._m13 * c2 + a._m14 * c1) * det
	cdef float m23 = (-a._m41 * s5 + a._m43 * s2 - a._m44 * s1) * det
	cdef float m24 = (a._m31 * s5 - a._m33 * s2 + a._m34 * s1) * det
	cdef float m31 = (a._m21 * c4 - a._m22 * c2 + a._m24 * c0) * det
	cdef float m32 = (-a._m11 * c4 + a._m12 * c2 - a._m14 * c0) * det
	cdef float m33 = (a._m41 * s4 - a._m42 * s2 + a._m44 * s0) * det
	cdef float m34 = (-a._m31 * s4 + a._m32 * s2 - a._m34 * s0) * det
	cdef float m41 = (-a._m21 * c3 + a._m22 * c1 - a._m23 * c0) * det
	cdef float m42 = (a._m11 * c3 - a._m12 * c1 + a._m13 * c0) * det
	cdef float m43 = (-a._m41 * s3 + a._m42 * s1 - a._m43 * s0) * det
	cdef float m44 = (a._m31 * s3 - a._m32 * s1 + a._m33 * s0) * det

	a._m11 = m11
	a._m12 = m12
	a._m13 = m13
	a._m14 = m14
	a._m21 = m21
	a._m22 = m22
	a._m23 = m23
	a._m24 = m24
	a._m31 = m31
	a._m32 = m32
	a._m33 = m33
	a._m34 = m34
	a._m41 = m41
	a._m42 = m42
	a._m43 = m43
	a._m44 = m44

##############################################################################################################################################################################
##############################################################################################################################################################################
##############################################################################################################################################################################

cdef inline mat3 mat3_rotation_axis(vec3 axis, float angle):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = onefloat - c
	cdef float x = axis.x
	cdef float y = axis.y
	cdef float z = axis.z
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

	cdef float n1 = sqrtf(m11*m11 + m12*m12 + m13*m13)
	n1 = onefloat / (onefloat if(n1 == zerfloat) else n1)

	cdef float n2 = sqrtf(m21*m21 + m22*m22 + m23*m23)
	n2 = onefloat / (onefloat if(n2 == zerfloat) else n2)

	cdef float n3 = sqrtf(m31*m31 + m32*m32 + m33*m33)
	n3 = onefloat / (onefloat if(n3 == zerfloat) else n3)

	return mat3(
		m11*n1 , m12*n1 , m13*n1,
		m21*n2 , m22*n2 , m23*n2,
		m31*n3 , m32*n3 , m33*n3
	)

cdef inline void i_mat3_rotation_axis(mat3 m, vec3 axis, float angle):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = onefloat - c
	cdef float x = axis.x
	cdef float y = axis.y
	cdef float z = axis.z
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

	cdef float m1 = m._m11 * m11 + m._m12 * m21 + m._m13 * m31
	cdef float m2 = m._m11 * m12 + m._m12 * m22 + m._m13 * m32
	cdef float m3 = m._m11 * m13 + m._m12 * m23 + m._m13 * m33
	cdef float m4 = m._m21 * m11 + m._m22 * m21 + m._m23 * m31
	cdef float m5 = m._m21 * m12 + m._m22 * m22 + m._m23 * m32
	cdef float m6 = m._m21 * m13 + m._m22 * m23 + m._m23 * m33
	cdef float m7 = m._m31 * m11 + m._m32 * m21 + m._m33 * m31
	cdef float m8 = m._m31 * m12 + m._m32 * m22 + m._m33 * m32
	cdef float m9 = m._m31 * m13 + m._m32 * m23 + m._m33 * m33

	cdef float n1 = sqrtf(m1*m1 + m2*m2 + m3*m3)
	n1 = onefloat / (onefloat if(n1 == zerfloat) else n1)

	cdef float n2 = sqrtf(m4*m4 + m5*m5 + m6*m6)
	n2 = onefloat / (onefloat if(n2 == zerfloat) else n2)

	cdef float n3 = sqrtf(m7*m7 + m8*m8 + m9*m9)
	n3 = onefloat / (onefloat if(n3 == zerfloat) else n3)

	m._m11 = m1 * n1
	m._m12 = m2 * n1
	m._m13 = m3 * n1
	m._m21 = m4 * n2
	m._m22 = m5 * n2
	m._m23 = m6 * n2
	m._m31 = m7 * n3
	m._m32 = m8 * n3
	m._m33 = m9 * n3

cdef inline void i_mat3_rotation_axis_Gz(mat3 m, float angle):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = onefloat - c
	cdef float tx = t * zerfloat
	cdef float ty = t * zerfloat

	cdef float m11 = tx * zerfloat + c
	cdef float m12 = tx * zerfloat - s * onefloat
	cdef float m13 = tx * onefloat + s * zerfloat
	cdef float m21 = tx * zerfloat + s * onefloat
	cdef float m22 = ty * zerfloat + c
	cdef float m23 = ty * onefloat - s * zerfloat
	cdef float m31 = tx * onefloat - s * zerfloat
	cdef float m32 = ty * onefloat + s * zerfloat
	cdef float m33 = t * onefloat * onefloat + c

	cdef float m1 = m._m11 * m11 + m._m12 * m21 + m._m13 * m31
	cdef float m2 = m._m11 * m12 + m._m12 * m22 + m._m13 * m32
	cdef float m3 = m._m11 * m13 + m._m12 * m23 + m._m13 * m33
	cdef float m4 = m._m21 * m11 + m._m22 * m21 + m._m23 * m31
	cdef float m5 = m._m21 * m12 + m._m22 * m22 + m._m23 * m32
	cdef float m6 = m._m21 * m13 + m._m22 * m23 + m._m23 * m33
	cdef float m7 = m._m31 * m11 + m._m32 * m21 + m._m33 * m31
	cdef float m8 = m._m31 * m12 + m._m32 * m22 + m._m33 * m32
	cdef float m9 = m._m31 * m13 + m._m32 * m23 + m._m33 * m33

	cdef float n1 = sqrtf(m1*m1 + m2*m2 + m3*m3)
	n1 = onefloat / (onefloat if(n1 == zerfloat) else n1)

	cdef float n2 = sqrtf(m4*m4 + m5*m5 + m6*m6)
	n2 = onefloat / (onefloat if(n2 == zerfloat) else n2)

	cdef float n3 = sqrtf(m7*m7 + m8*m8 + m9*m9)
	n3 = onefloat / (onefloat if(n3 == zerfloat) else n3)

	m._m11 = m1 * n1
	m._m12 = m2 * n1
	m._m13 = m3 * n1
	m._m21 = m4 * n2
	m._m22 = m5 * n2
	m._m23 = m6 * n2
	m._m31 = m7 * n3
	m._m32 = m8 * n3
	m._m33 = m9 * n3

cdef inline void i_mat3_rotation_axis_Gy(mat3 m, float angle):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = onefloat - c
	cdef float tx = t * zerfloat
	cdef float ty = t * onefloat

	cdef float m11 = tx * zerfloat + c
	cdef float m12 = tx * onefloat - s * zerfloat
	cdef float m13 = tx * zerfloat + s * onefloat
	cdef float m21 = tx * onefloat + s * zerfloat
	cdef float m22 = ty * onefloat + c
	cdef float m23 = ty * zerfloat - s * zerfloat
	cdef float m31 = tx * zerfloat - s * onefloat
	cdef float m32 = ty * zerfloat + s * zerfloat
	cdef float m33 = t * zerfloat * zerfloat + c

	cdef float m1 = m._m11 * m11 + m._m12 * m21 + m._m13 * m31
	cdef float m2 = m._m11 * m12 + m._m12 * m22 + m._m13 * m32
	cdef float m3 = m._m11 * m13 + m._m12 * m23 + m._m13 * m33
	cdef float m4 = m._m21 * m11 + m._m22 * m21 + m._m23 * m31
	cdef float m5 = m._m21 * m12 + m._m22 * m22 + m._m23 * m32
	cdef float m6 = m._m21 * m13 + m._m22 * m23 + m._m23 * m33
	cdef float m7 = m._m31 * m11 + m._m32 * m21 + m._m33 * m31
	cdef float m8 = m._m31 * m12 + m._m32 * m22 + m._m33 * m32
	cdef float m9 = m._m31 * m13 + m._m32 * m23 + m._m33 * m33

	cdef float n1 = sqrtf(m1*m1 + m2*m2 + m3*m3)
	n1 = onefloat / (onefloat if(n1 == zerfloat) else n1)

	cdef float n2 = sqrtf(m4*m4 + m5*m5 + m6*m6)
	n2 = onefloat / (onefloat if(n2 == zerfloat) else n2)

	cdef float n3 = sqrtf(m7*m7 + m8*m8 + m9*m9)
	n3 = onefloat / (onefloat if(n3 == zerfloat) else n3)

	m._m11 = m1 * n1
	m._m12 = m2 * n1
	m._m13 = m3 * n1
	m._m21 = m4 * n2
	m._m22 = m5 * n2
	m._m23 = m6 * n2
	m._m31 = m7 * n3
	m._m32 = m8 * n3
	m._m33 = m9 * n3

cdef inline void i_mat3_rotation_axis_Gx(mat3 m, float angle):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = onefloat - c
	cdef float tx = t * onefloat
	cdef float ty = t * zerfloat

	cdef float m11 = tx * onefloat + c
	cdef float m12 = tx * zerfloat - s * zerfloat
	cdef float m13 = tx * zerfloat + s * zerfloat
	cdef float m21 = tx * zerfloat + s * zerfloat
	cdef float m22 = ty * zerfloat + c
	cdef float m23 = ty * zerfloat - s * onefloat
	cdef float m31 = tx * zerfloat - s * zerfloat
	cdef float m32 = ty * zerfloat + s * onefloat
	cdef float m33 = t * zerfloat * zerfloat + c

	cdef float m1 = m._m11 * m11 + m._m12 * m21 + m._m13 * m31
	cdef float m2 = m._m11 * m12 + m._m12 * m22 + m._m13 * m32
	cdef float m3 = m._m11 * m13 + m._m12 * m23 + m._m13 * m33
	cdef float m4 = m._m21 * m11 + m._m22 * m21 + m._m23 * m31
	cdef float m5 = m._m21 * m12 + m._m22 * m22 + m._m23 * m32
	cdef float m6 = m._m21 * m13 + m._m22 * m23 + m._m23 * m33
	cdef float m7 = m._m31 * m11 + m._m32 * m21 + m._m33 * m31
	cdef float m8 = m._m31 * m12 + m._m32 * m22 + m._m33 * m32
	cdef float m9 = m._m31 * m13 + m._m32 * m23 + m._m33 * m33

	cdef float n1 = sqrtf(m1*m1 + m2*m2 + m3*m3)
	n1 = onefloat / (onefloat if(n1 == zerfloat) else n1)

	cdef float n2 = sqrtf(m4*m4 + m5*m5 + m6*m6)
	n2 = onefloat / (onefloat if(n2 == zerfloat) else n2)

	cdef float n3 = sqrtf(m7*m7 + m8*m8 + m9*m9)
	n3 = onefloat / (onefloat if(n3 == zerfloat) else n3)

	m._m11 = m1 * n1
	m._m12 = m2 * n1
	m._m13 = m3 * n1
	m._m21 = m4 * n2
	m._m22 = m5 * n2
	m._m23 = m6 * n2
	m._m31 = m7 * n3
	m._m32 = m8 * n3
	m._m33 = m9 * n3

cdef inline void i_mat3_rotation_axis_Lx(mat3 m, float angle):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = onefloat - c
	#cdef float x = (m._global._m11 if m._has_parent else m._m11)
	#cdef float y = (m._global._m12 if m._has_parent else m._m12)
	#cdef float z = (m._global._m13 if m._has_parent else m._m13)
	cdef float x = m._m11
	cdef float y = m._m12
	cdef float z = m._m13
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

	cdef float m1 = m._m11 * m11 + m._m12 * m21 + m._m13 * m31
	cdef float m2 = m._m11 * m12 + m._m12 * m22 + m._m13 * m32
	cdef float m3 = m._m11 * m13 + m._m12 * m23 + m._m13 * m33
	cdef float m4 = m._m21 * m11 + m._m22 * m21 + m._m23 * m31
	cdef float m5 = m._m21 * m12 + m._m22 * m22 + m._m23 * m32
	cdef float m6 = m._m21 * m13 + m._m22 * m23 + m._m23 * m33
	cdef float m7 = m._m31 * m11 + m._m32 * m21 + m._m33 * m31
	cdef float m8 = m._m31 * m12 + m._m32 * m22 + m._m33 * m32
	cdef float m9 = m._m31 * m13 + m._m32 * m23 + m._m33 * m33

	cdef float n1 = sqrtf(m1*m1 + m2*m2 + m3*m3)
	n1 = onefloat / (onefloat if(n1 == zerfloat) else n1)

	cdef float n2 = sqrtf(m4*m4 + m5*m5 + m6*m6)
	n2 = onefloat / (onefloat if(n2 == zerfloat) else n2)

	cdef float n3 = sqrtf(m7*m7 + m8*m8 + m9*m9)
	n3 = onefloat / (onefloat if(n3 == zerfloat) else n3)

	m._m11 = m1 * n1
	m._m12 = m2 * n1
	m._m13 = m3 * n1
	m._m21 = m4 * n2
	m._m22 = m5 * n2
	m._m23 = m6 * n2
	m._m31 = m7 * n3
	m._m32 = m8 * n3
	m._m33 = m9 * n3

cdef inline void i_mat3_rotation_axis_Ly(mat3 m, float angle):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = onefloat - c
	#cdef float x = (m._global._m21 if m._has_parent else m._m21)
	#cdef float y = (m._global._m22 if m._has_parent else m._m22)
	#cdef float z = (m._global._m23 if m._has_parent else m._m23)
	cdef float x = m._m21
	cdef float y = m._m22
	cdef float z = m._m23
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

	cdef float m1 = m._m11 * m11 + m._m12 * m21 + m._m13 * m31
	cdef float m2 = m._m11 * m12 + m._m12 * m22 + m._m13 * m32
	cdef float m3 = m._m11 * m13 + m._m12 * m23 + m._m13 * m33
	cdef float m4 = m._m21 * m11 + m._m22 * m21 + m._m23 * m31
	cdef float m5 = m._m21 * m12 + m._m22 * m22 + m._m23 * m32
	cdef float m6 = m._m21 * m13 + m._m22 * m23 + m._m23 * m33
	cdef float m7 = m._m31 * m11 + m._m32 * m21 + m._m33 * m31
	cdef float m8 = m._m31 * m12 + m._m32 * m22 + m._m33 * m32
	cdef float m9 = m._m31 * m13 + m._m32 * m23 + m._m33 * m33

	cdef float n1 = sqrtf(m1*m1 + m2*m2 + m3*m3)
	n1 = onefloat / (onefloat if(n1 == zerfloat) else n1)

	cdef float n2 = sqrtf(m4*m4 + m5*m5 + m6*m6)
	n2 = onefloat / (onefloat if(n2 == zerfloat) else n2)

	cdef float n3 = sqrtf(m7*m7 + m8*m8 + m9*m9)
	n3 = onefloat / (onefloat if(n3 == zerfloat) else n3)

	m._m11 = m1 * n1
	m._m12 = m2 * n1
	m._m13 = m3 * n1
	m._m21 = m4 * n2
	m._m22 = m5 * n2
	m._m23 = m6 * n2
	m._m31 = m7 * n3
	m._m32 = m8 * n3
	m._m33 = m9 * n3

cdef inline void i_mat3_rotation_axis_Lz(mat3 m, float angle):
	cdef float a = radians(angle)
	cdef float c = cosf(a)
	cdef float s = sinf(a)
	cdef float t = onefloat - c
	#cdef float x = (m._global._m31 if m._has_parent else m._m31)
	#cdef float y = (m._global._m32 if m._has_parent else m._m32)
	#cdef float z = (m._global._m33 if m._has_parent else m._m33)
	cdef float x = m._m31
	cdef float y = m._m32
	cdef float z = m._m33
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

	cdef float m1 = m._m11 * m11 + m._m12 * m21 + m._m13 * m31
	cdef float m2 = m._m11 * m12 + m._m12 * m22 + m._m13 * m32
	cdef float m3 = m._m11 * m13 + m._m12 * m23 + m._m13 * m33
	cdef float m4 = m._m21 * m11 + m._m22 * m21 + m._m23 * m31
	cdef float m5 = m._m21 * m12 + m._m22 * m22 + m._m23 * m32
	cdef float m6 = m._m21 * m13 + m._m22 * m23 + m._m23 * m33
	cdef float m7 = m._m31 * m11 + m._m32 * m21 + m._m33 * m31
	cdef float m8 = m._m31 * m12 + m._m32 * m22 + m._m33 * m32
	cdef float m9 = m._m31 * m13 + m._m32 * m23 + m._m33 * m33

	cdef float n1 = sqrtf(m1*m1 + m2*m2 + m3*m3)
	n1 = onefloat / (onefloat if(n1 == zerfloat) else n1)

	cdef float n2 = sqrtf(m4*m4 + m5*m5 + m6*m6)
	n2 = onefloat / (onefloat if(n2 == zerfloat) else n2)

	cdef float n3 = sqrtf(m7*m7 + m8*m8 + m9*m9)
	n3 = onefloat / (onefloat if(n3 == zerfloat) else n3)

	m._m11 = m1 * n1
	m._m12 = m2 * n1
	m._m13 = m3 * n1
	m._m21 = m4 * n2
	m._m22 = m5 * n2
	m._m23 = m6 * n2
	m._m31 = m7 * n3
	m._m32 = m8 * n3
	m._m33 = m9 * n3





cdef class Rotation(mat3):
	cdef bint _changed_nor
	cdef bint _changed_inv
	cdef bint _has_parent
	cdef mat3 _global

	cdef vec3 _l_right
	cdef vec3 _l_up
	cdef vec3 _l_forward

	cdef vec3 _g_right
	cdef vec3 _g_up
	cdef vec3 _g_forward

	def __init__(self) -> None:
		super().__init__()
		self._global = mat3()
		self._g_right = vec3(0.0)
		self._g_up = vec3(0.0)
		self._g_forward = vec3(0.0)
		self._l_right = vec3(self._m11,self._m12,self._m13)
		self._l_up = vec3(self._m21,self._m22,self._m23)
		self._l_forward = vec3(self._m31,self._m32,self._m33)


	def __str__(self) -> str:
		if(self._has_parent):
			return (
				f'\n┌───────────────────────────────────┐\n'
				f'│   {"":^6}      {"":^6}      {"":^6}  │\n'
				f'│   {self._global._m11:^6.1f}      {self._global._m12:^6.1f}      {self._global._m13:^6.1f}  │\n'
				f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
				f'│   {self._global._m21:^6.1f}      {self._global._m22:^6.1f}      {self._global._m23:^6.1f}  │\n'
				f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
				f'│   {self._global._m31:^6.1f}      {self._global._m32:^6.1f}      {self._global._m33:^6.1f}  │\n'
				f'│   {"":^6}      {"":^6}      {"":^6}  │\n'
				f'└───────────────────────────────────┘'
			)
		return (
			f'\n┌───────────────────────────────────┐\n'
			f'│   {"":^6}      {"":^6}      {"":^6}  │\n'
			f'│   {self._m11:^6.1f}      {self._m12:^6.1f}      {self._m13:^6.1f}  │\n'
			f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
			f'│   {self._m21:^6.1f}      {self._m22:^6.1f}      {self._m23:^6.1f}  │\n'
			f'│   {"":^6}  ○   {"":^6}  ○   {"":^6}  │\n'
			f'│   {self._m31:^6.1f}      {self._m32:^6.1f}      {self._m33:^6.1f}  │\n'
			f'│   {"":^6}      {"":^6}      {"":^6}  │\n'
			f'└───────────────────────────────────┘'
		)



	def GetArray(self) -> Tuple[float, float, float, float, float, float, float, float, float]:
		if(self._has_parent):
			return self._global._m11, self._global._m12, self._global._m13, self._global._m21, self._global._m22, self._global._m23, self._global._m31, self._global._m32, self._global._m33
		return self._m11, self._m12, self._m13, self._m21, self._m22, self._m23, self._m31, self._m32, self._m33

	def SetArray(self,
		float m11 = onefloat, float m12 = zerfloat, float m13 = zerfloat,
		float m21 = zerfloat, float m22 = onefloat, float m23 = zerfloat,
		float m31 = zerfloat, float m32 = zerfloat, float m33 = onefloat,
	) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		self._m11 = m11
		self._m12 = m12
		self._m13 = m13
		self._m21 = m21
		self._m22 = m22
		self._m23 = m23
		self._m31 = m31
		self._m32 = m32
		self._m33 = m33
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self

	def SetValue(self, mat3 value) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		self._m11 = value.m11
		self._m12 = value.m12
		self._m13 = value.m13
		self._m21 = value.m21
		self._m22 = value.m22
		self._m23 = value.m23
		self._m31 = value.m31
		self._m32 = value.m32
		self._m33 = value.m33
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self



	@property
	def m11(self) -> float:
		if(self._has_parent):
			return self._global._m11
		return self._m11
	@m11.setter
	def m11(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m11 = value - self._global._m11
		else: self._m11 = value
		self._l_right._x = self._m11
	@property
	def m12(self) -> float:
		if(self._has_parent):
			return self._global._m12
		return self._m12
	@m12.setter
	def m12(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m12 = value - self._global._m12
		else: self._m12 = value
		self._l_right._x = self._m12
	@property
	def m13(self) -> float:
		if(self._has_parent):
			return self._global._m13
		return self._m13
	@m13.setter
	def m13(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m13 = value - self._global._m13
		else: self._m13 = value
		self._l_right._x = self._m13

	@property
	def m21(self) -> float:
		if(self._has_parent):
			return self._global._m21
		return self._m21
	@m21.setter
	def m21(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m21 = value - self._global._m21
		else: self._m21 = value
		self._l_right._x = self._m21
	@property
	def m22(self) -> float:
		if(self._has_parent):
			return self._global._m22
		return self._m22
	@m22.setter
	def m22(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m22 = value - self._global._m22
		else: self._m22 = value
		self._l_right._x = self._m22
	@property
	def m23(self) -> float:
		if(self._has_parent):
			return self._global._m23
		return self._m23
	@m23.setter
	def m23(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m23 = value - self._global._m23
		else: self._m23 = value
		self._l_right._x = self._m23

	@property
	def m31(self) -> float:
		if(self._has_parent):
			return self._global._m31
		return self._m31
	@m31.setter
	def m31(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m31 = value - self._global._m31
		else: self._m31 = value
		self._l_right._x = self._m31
	@property
	def m32(self) -> float:
		if(self._has_parent):
			return self._global._m32
		return self._m32
	@m32.setter
	def m32(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m32 = value - self._global._m32
		else: self._m32 = value
		self._l_right._x = self._m32
	@property
	def m33(self) -> float:
		if(self._has_parent):
			return self._global._m33
		return self._m33
	@m33.setter
	def m33(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent): self._m33 = value - self._global._m33
		else: self._m33 = value
		self._l_right._x = self._m33

	@property
	def inverse(self) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_mat3_inverse(self)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self

	def __mul__(self, value: Union[mat3, vec3, float]) -> Union[mat3, vec3]:
		if(self._has_parent):
			if isinstance(value, mat3): return mat3_mul_mat3(self._global,value)
			if isinstance(value, vec3): return mat3_mul_vec3(self._global,value)
			return mat3_mul_num(self._global, value)
		if isinstance(value, mat3): return mat3_mul_mat3(self,value)
		if isinstance(value, vec3): return mat3_mul_vec3(self,value)
		return mat3_mul_num(self, value)
	def __rmul__(self, value: Union[mat3, vec3, float]) -> Union[mat3, vec3]:
		if(self._has_parent):
			if isinstance(value, mat3): return mat3_mul_mat3(value,self._global)
			if isinstance(value, vec3): return vec3_mul_mat3(value,self._global)
			return num_mul_mat3(value,self._global)
		if isinstance(value, mat3): return mat3_mul_mat3(value,self)
		if isinstance(value, vec3): return vec3_mul_mat3(value,self)
		return num_mul_mat3(value,self)
	def __imul__(self, value: Union[mat3, float]) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if isinstance(value, mat3): i_mat3_mul_mat3(self,value)
		else: i_mat3_mul_num(self, value)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self


	def GetRotateMat(self, vec3 axis, float angle) -> mat3:
		return mat3_rotation_axis(axis, angle)

	def R(self, vec3 axis, float angle) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_mat3_rotation_axis(self, axis, angle)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self

	def Gx(self, float angle) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_mat3_rotation_axis_Gx(self, angle)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self
	def Gy(self, float angle) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_mat3_rotation_axis_Gy(self, angle)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self
	def Gz(self, float angle) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_mat3_rotation_axis_Gz(self, angle)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self

	def Lx(self, float angle) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_mat3_rotation_axis_Lx(self, angle)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self
	def Ly(self, float angle) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_mat3_rotation_axis_Ly(self, angle)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self
	def Lz(self, float angle) -> Rotation:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_mat3_rotation_axis_Lz(self, angle)
		self._l_right._x, self._l_right._y, self._l_right._z = self._m11, self._m12, self._m13
		self._l_up._x, self._l_up._y, self._l_up._z = self._m21, self._m22, self._m23
		self._l_forward._x, self._l_forward._y, self._l_forward._z = self._m31, self._m32, self._m33
		return self





cdef class Position(vec3):
	cdef bint _changed_nor
	cdef bint _changed_inv
	cdef bint _has_parent
	cdef vec3 _global

	def __init__(self, x: float, y: float = NAN, z: float = NAN) -> None:
		super().__init__(x, y, z)
		self._global = vec3(0.0)

	def __str__(self) -> str:
		if(self._has_parent):
			return (
				f'\n┌───────────────────────────────────┐\n'
				f'│   {self._global._x:^6.1f}  ○   {self._global._y:^6.1f}  ○   {self._global._z:^6.1f}  │\n'
				f'└───────────────────────────────────┘'
			)
		return (
			f'\n┌───────────────────────────────────┐\n'
			f'│   {self._x:^6.1f}  ○   {self._y:^6.1f}  ○   {self._z:^6.1f}  │\n'
			f'└───────────────────────────────────┘'
		)

	@property
	def x(self) -> float:
		if(self._has_parent):
			return self._global._x
		return self._x
	@x.setter
	def x(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent):
			self._x = value - self._global._x
			return
		self._x = value

	@property
	def y(self) -> float:
		if(self._has_parent):
			return self._global._y
		return self._y
	@y.setter
	def y(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent):
			self._y = value - self._global._y
			return
		self._y = value

	@property
	def z(self) -> float:
		if(self._has_parent):
			return self._global._z
		return self._z
	@z.setter
	def z(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent):
			self._z = value - self._global._z
			return
		self._z = value

	def GetArray(self) -> Tuple[float, float, float]:
		if(self._has_parent):
			return self._global._x, self._global._y, self._global._z
		return self._x, self._y, self._z
	def SetArray(self, float x, float y = NAN, float z = NAN) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		self._x = x
		self._y = x if(isnan(<double>y)) else y
		self._z = x if(isnan(<double>z)) else z
		return self
	def SetValue(self, vec3 value) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		self._x = value.x
		self._y = value.y
		self._z = value.z
		return self

	def crossBy(self, vec3 b) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_vec3_cross(self, b)
		return self
	@property
	def normalize(self) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_vec3_normalize(self)
		return self
	def project(self, vec3 b) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_vec3_projection(self, b)
		return self


	def __neg__(self) -> vec3:
		if(self._has_parent):
			return vec3(-self._global._x,-self._global._y,-self._global._z)
		return vec3(-self._x,-self._y,-self._z)
	def __pos__(self) -> vec3:
		if(self._has_parent):
			return vec3(self._global._x,self._global._y,self._global._z)
		return vec3(self._x,self._y,self._z)
	def __abs__(self) -> vec3:
		if(self._has_parent):
			return vec3(abs(self._global._x),abs(self._global._y),abs(self._global._z))
		return vec3(abs(self._x),abs(self._y),abs(self._z))



	def __lt__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_lt_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_lt_vec3(self,value))
		return bool(vec3_lt_num(self,value))
	def __le__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_le_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_le_vec3(self,value))
		return bool(vec3_le_num(self,value))
	def __eq__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_eq_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_eq_vec3(self,value))
		return bool(vec3_eq_num(self,value))
	def __ne__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_ne_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_ne_vec3(self,value))
		return bool(vec3_ne_num(self,value))
	def __ge__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_ge_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_ge_vec3(self,value))
		return bool(vec3_ge_num(self,value))
	def __gt__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_gt_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_gt_vec3(self,value))
		return bool(vec3_gt_num(self,value))



	def __add__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_add_vec3(self._global,value)
			return vec3_add_num(self._global,value)
		if(isinstance(value, vec3)): return vec3_add_vec3(self,value)
		return vec3_add_num(self,value)
	def __radd__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_add_vec3(value,self._global)
			return num_add_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_add_vec3(value,self)
		return num_add_vec3(value,self)
	def __iadd__(self, value: Union[vec3, float]) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, vec3)): i_vec3_add_vec3(self,value)
		else: i_vec3_add_num(self,value)
		return self


	def __sub__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_sub_vec3(self._global,value)
			return vec3_sub_num(self._global,value)
		if(isinstance(value, vec3)): return vec3_sub_vec3(self,value)
		return vec3_sub_num(self,value)
	def __rsub__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_sub_vec3(value,self._global)
			return num_sub_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_sub_vec3(value,self)
		return num_sub_vec3(value,self)
	def __isub__(self, value: Union[vec3, float]) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, vec3)): i_vec3_sub_vec3(self,value)
		else: i_vec3_sub_num(self,value)
		return self


	def __mul__(self, value: Union[mat3, vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, mat3)): return vec3_mul_mat3(self._global,value)
			if(isinstance(value, vec3)): return vec3_mul_vec3(self._global,value)
			return vec3_mul_num(self._global,value)
		if(isinstance(value, mat3)): return vec3_mul_mat3(self,value)
		if(isinstance(value, vec3)): return vec3_mul_vec3(self,value)
		return vec3_mul_num(self,value)
	def __rmul__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_mul_vec3(value,self._global)
			return num_mul_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_mul_vec3(value,self)
		return num_mul_vec3(value,self)
	def __imul__(self, value: Union[mat3, vec3, float]) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, mat3)): i_vec3_mul_mat3(self,value)
		elif(isinstance(value, vec3)): i_vec3_mul_vec3(self,value)
		else: i_vec3_mul_num(self,value)
		return self


	def __pow__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_pow_vec3(self._global,value)
			return vec3_pow_num(self._global,value)
		if(isinstance(value, vec3)): return vec3_pow_vec3(self,value)
		return vec3_pow_num(self,value)
	def __rpow__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_pow_vec3(value,self._global)
			return num_pow_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_pow_vec3(value,self)
		return num_pow_vec3(value,self)
	def __ipow__(self, value: Union[vec3, float]) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, vec3)): i_vec3_pow_vec3(self,value)
		else: i_vec3_pow_num(self,value)
		return self


	def __truediv__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_truediv_vec3(self._global,value)
			return vec3_truediv_num(self._global,value)
		if(isinstance(value, vec3)): return vec3_truediv_vec3(self,value)
		return vec3_truediv_num(self,value)
	def __rtruediv__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_truediv_vec3(value,self._global)
			return num_truediv_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_truediv_vec3(value,self)
		return num_truediv_vec3(value,self)
	def __itruediv__(self, value: Union[vec3, float]) -> Position:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, vec3)): i_vec3_truediv_vec3(self,value)
		else: i_vec3_truediv_num(self,value)
		return self




cdef class Scale(vec3):
	cdef bint _changed_nor
	cdef bint _changed_inv
	cdef bint _has_parent
	cdef vec3 _global

	def __init__(self, x: float, y: float = NAN, z: float = NAN) -> None:
		super().__init__(x, y, z)
		self._global = vec3(0.0)

	def __str__(self) -> str:
		if(self._has_parent):
			return (
				f'\n┌───────────────────────────────────┐\n'
				f'│   {self._global._x:^6.1f}  ○   {self._global._y:^6.1f}  ○   {self._global._z:^6.1f}  │\n'
				f'└───────────────────────────────────┘'
			)
		return (
			f'\n┌───────────────────────────────────┐\n'
			f'│   {self._x:^6.1f}  ○   {self._y:^6.1f}  ○   {self._z:^6.1f}  │\n'
			f'└───────────────────────────────────┘'
		)

	@property
	def x(self) -> float:
		if(self._has_parent):
			return self._global._x
		return self._x
	@x.setter
	def x(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent):
			self._x = value - self._global._x
			return
		self._x = value

	@property
	def y(self) -> float:
		if(self._has_parent):
			return self._global._y
		return self._y
	@y.setter
	def y(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent):
			self._y = value - self._global._y
			return
		self._y = value

	@property
	def z(self) -> float:
		if(self._has_parent):
			return self._global._z
		return self._z
	@z.setter
	def z(self, float value) -> None:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(self._has_parent):
			self._z = value - self._global._z
			return
		self._z = value

	def GetArray(self) -> Tuple[float, float, float]:
		if(self._has_parent):
			return self._global._x, self._global._y, self._global._z
		return self._x, self._y, self._z
	def SetArray(self, float x, float y = NAN, float z = NAN) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		self._x = x
		self._y = x if(isnan(<double>y)) else y
		self._z = x if(isnan(<double>z)) else z
		return self
	def SetValue(self, vec3 value) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		self._x = value.x
		self._y = value.y
		self._z = value.z
		return self

	def crossBy(self, vec3 b) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_vec3_cross(self, b)
		return self
	@property
	def normalize(self) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_vec3_normalize(self)
		return self
	def project(self, vec3 b) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		i_vec3_projection(self, b)
		return self


	def __neg__(self) -> vec3:
		if(self._has_parent):
			return vec3(-self._global._x,-self._global._y,-self._global._z)
		return vec3(-self._x,-self._y,-self._z)
	def __pos__(self) -> vec3:
		if(self._has_parent):
			return vec3(self._global._x,self._global._y,self._global._z)
		return vec3(self._x,self._y,self._z)
	def __abs__(self) -> vec3:
		if(self._has_parent):
			return vec3(abs(self._global._x),abs(self._global._y),abs(self._global._z))
		return vec3(abs(self._x),abs(self._y),abs(self._z))



	def __lt__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_lt_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_lt_vec3(self,value))
		return bool(vec3_lt_num(self,value))
	def __le__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_le_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_le_vec3(self,value))
		return bool(vec3_le_num(self,value))
	def __eq__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_eq_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_eq_vec3(self,value))
		return bool(vec3_eq_num(self,value))
	def __ne__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_ne_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_ne_vec3(self,value))
		return bool(vec3_ne_num(self,value))
	def __ge__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_ge_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_ge_vec3(self,value))
		return bool(vec3_ge_num(self,value))
	def __gt__(self, value: Union[vec3, float]) -> bool:
		if(self._has_parent):
			if(isinstance(value, vec3)): return bool(vec3_gt_vec3(self._global,value))
			return bool(vec3_lt_num(self._global,value))
		if(isinstance(value, vec3)): return bool(vec3_gt_vec3(self,value))
		return bool(vec3_gt_num(self,value))



	def __add__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_add_vec3(self._global,value)
			return vec3_add_num(self._global,value)
		if(isinstance(value, vec3)): return vec3_add_vec3(self,value)
		return vec3_add_num(self,value)
	def __radd__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_add_vec3(value,self._global)
			return num_add_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_add_vec3(value,self)
		return num_add_vec3(value,self)
	def __iadd__(self, value: Union[vec3, float]) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, vec3)): i_vec3_add_vec3(self,value)
		else: i_vec3_add_num(self,value)
		return self


	def __sub__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_sub_vec3(self._global,value)
			return vec3_sub_num(self._global,value)
		if(isinstance(value, vec3)): return vec3_sub_vec3(self,value)
		return vec3_sub_num(self,value)
	def __rsub__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_sub_vec3(value,self._global)
			return num_sub_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_sub_vec3(value,self)
		return num_sub_vec3(value,self)
	def __isub__(self, value: Union[vec3, float]) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, vec3)): i_vec3_sub_vec3(self,value)
		else: i_vec3_sub_num(self,value)
		return self


	def __mul__(self, value: Union[mat3, vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, mat3)): return vec3_mul_mat3(self._global,value)
			if(isinstance(value, vec3)): return vec3_mul_vec3(self._global,value)
			return vec3_mul_num(self._global,value)
		if(isinstance(value, mat3)): return vec3_mul_mat3(self,value)
		if(isinstance(value, vec3)): return vec3_mul_vec3(self,value)
		return vec3_mul_num(self,value)
	def __rmul__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_mul_vec3(value,self._global)
			return num_mul_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_mul_vec3(value,self)
		return num_mul_vec3(value,self)
	def __imul__(self, value: Union[mat3, vec3, float]) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, mat3)): i_vec3_mul_mat3(self,value)
		elif(isinstance(value, vec3)): i_vec3_mul_vec3(self,value)
		else: i_vec3_mul_num(self,value)
		return self


	def __pow__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_pow_vec3(self._global,value)
			return vec3_pow_num(self._global,value)
		if(isinstance(value, vec3)): return vec3_pow_vec3(self,value)
		return vec3_pow_num(self,value)
	def __rpow__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_pow_vec3(value,self._global)
			return num_pow_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_pow_vec3(value,self)
		return num_pow_vec3(value,self)
	def __ipow__(self, value: Union[vec3, float]) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, vec3)): i_vec3_pow_vec3(self,value)
		else: i_vec3_pow_num(self,value)
		return self


	def __truediv__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_truediv_vec3(self._global,value)
			return vec3_truediv_num(self._global,value)
		if(isinstance(value, vec3)): return vec3_truediv_vec3(self,value)
		return vec3_truediv_num(self,value)
	def __rtruediv__(self, value: Union[vec3, float]) -> vec3:
		if(self._has_parent):
			if(isinstance(value, vec3)): return vec3_truediv_vec3(value,self._global)
			return num_truediv_vec3(value,self._global)
		if(isinstance(value, vec3)): return vec3_truediv_vec3(value,self)
		return num_truediv_vec3(value,self)
	def __itruediv__(self, value: Union[vec3, float]) -> Scale:
		self._changed_nor = <bint>1
		self._changed_inv = <bint>1
		if(isinstance(value, vec3)): i_vec3_truediv_vec3(self,value)
		else: i_vec3_truediv_num(self,value)
		return self




cdef class Transform:
	cdef int _changed_nor
	cdef int _changed_inv
	cdef int _changed_parent_nor
	cdef int _changed_parent_inv
	cdef int _changed_local_nor
	cdef int _changed_local_inv

	cdef Transform _parent

	cdef Position _position
	cdef Scale _scale
	cdef Rotation _rotation

	cdef mat4 _m_position_nor
	cdef mat4 _m_scale_nor
	cdef mat4 _m_rotation_nor

	cdef mat4 _m_position_inv
	cdef mat4 _m_scale_inv
	cdef mat4 _m_rotation_inv

	cdef mat4 _L_transformation_matrix_nor
	cdef mat4 _L_transformation_matrix_inv

	cdef mat4 _G_transformation_matrix_nor
	cdef mat4 _G_transformation_matrix_inv


	def __init__(self,
		Position position,
		Scale scale,
		Rotation rotation
	) -> None:
		self._position = position
		self._scale = scale
		self._rotation = rotation

		self._m_position_nor = mat4()
		self._m_scale_nor = mat4()
		self._m_rotation_nor = mat4()

		self._m_position_inv = mat4()
		self._m_scale_inv = mat4()
		self._m_rotation_inv = mat4()

		self._L_transformation_matrix_nor = mat4()
		self._L_transformation_matrix_inv = mat4()
		self._G_transformation_matrix_nor = mat4()
		self._G_transformation_matrix_inv = mat4()

		self._changed_nor = 0
		self._changed_inv = 0
		self._changed_parent_nor = -1
		self._changed_parent_inv = -1
		self._changed_local_nor = -1
		self._changed_local_inv = -1
		i_transform_change(self)
	
	def SetParent(self, Transform parent) -> None:
		self._parent = parent
		self._position._has_parent = <bint>1
		self._scale._has_parent = <bint>1
		self._rotation._has_parent = <bint>1
	def GetParent(self) -> Transform:
		return self._parent
	def ClearParent(self) -> None:
		self._parent = None
		self._position._has_parent = <bint>0
		self._scale._has_parent = <bint>0
		self._rotation._has_parent = <bint>0

	@property
	def right(self) -> vec3:
		i_L_transform_check_atrib_nor(self)
		if(self._parent):
			i_G_transform_check_atrib_nor(self)
			return self._rotation._g_right
		return self._rotation._l_right
	@property
	def up(self) -> vec3:
		i_L_transform_check_atrib_nor(self)
		if(self._parent):
			i_G_transform_check_atrib_nor(self)
			return self._rotation._g_up
		return self._rotation._l_up
	@property
	def forward(self) -> vec3:
		i_L_transform_check_atrib_nor(self)
		if(self._parent):
			i_G_transform_check_atrib_nor(self)
			return self._rotation._g_forward
		return self._rotation._l_forward

	@property
	def localPosition(self) -> vec3:
		return vec3(self._position._x,self._position._y,self._position._z)
	@property
	def position(self) -> Position:
		#print("pos_get")
		i_L_transform_check_atrib_nor(self)
		if(self._parent): i_G_transform_check_atrib_nor(self)
		return self._position
	@position.setter
	def position(self, vec3 value) -> None:
		#print("pos_set")
		i_L_transform_check_atrib_nor(self)
		if(self._parent): i_G_transform_check_atrib_nor(self)
		self._position.SetValue(value)

	@property
	def localScale(self) -> vec3:
		return vec3(self._scale._x,self._scale._y,self._scale._z)
	@property
	def scale(self) -> Scale:
		#print("sca_get")
		i_L_transform_check_atrib_nor(self)
		if(self._parent): i_G_transform_check_atrib_nor(self)
		return self._scale
	@scale.setter
	def scale(self, vec3 value) -> None:
		#print("sca_set")
		i_L_transform_check_atrib_nor(self)
		if(self._parent): i_G_transform_check_atrib_nor(self)
		self._scale.SetValue(value)

	@property
	def localRotation(self) -> mat3:
		return mat3(*self._rotation.GetArray())
	@property
	def rotation(self) -> Rotation:
		#print("rot_get")
		i_L_transform_check_atrib_nor(self)
		if(self._parent): i_G_transform_check_atrib_nor(self)
		return self._rotation
	@rotation.setter
	def rotation(self, mat3 value) -> None:
		#print("rot_set")
		i_L_transform_check_atrib_nor(self)
		if(self._parent): i_G_transform_check_atrib_nor(self)
		self._rotation.SetValue(value)


	def GetTransformationMatrix(self) -> mat4:
		#print("get_mat_nor")
		i_L_transform_check_atrib_nor(self)
		if(self._parent):
			i_G_transform_check_atrib_nor(self)
			return self._G_transformation_matrix_nor
		return self._L_transformation_matrix_nor

	def GetTransformationMatrixInv(self) -> mat4:
		#print("get_mat_inv")
		i_L_transform_check_atrib_inv(self)
		if(self._parent):
			i_G_transform_check_atrib_inv(self)
			return self._G_transformation_matrix_inv
		return self._L_transformation_matrix_inv






cdef inline void i_mat4_mul_mat4r(mat4 a, mat4 b):
	cdef float m11 = a._m11 * b._m11 + a._m12 * b._m21 + a._m13 * b._m31 + a._m14 * b._m41
	cdef float m12 = a._m11 * b._m12 + a._m12 * b._m22 + a._m13 * b._m32 + a._m14 * b._m42
	cdef float m13 = a._m11 * b._m13 + a._m12 * b._m23 + a._m13 * b._m33 + a._m14 * b._m43
	cdef float m14 = a._m11 * b._m14 + a._m12 * b._m24 + a._m13 * b._m34 + a._m14 * b._m44
	cdef float m21 = a._m21 * b._m11 + a._m22 * b._m21 + a._m23 * b._m31 + a._m24 * b._m41
	cdef float m22 = a._m21 * b._m12 + a._m22 * b._m22 + a._m23 * b._m32 + a._m24 * b._m42
	cdef float m23 = a._m21 * b._m13 + a._m22 * b._m23 + a._m23 * b._m33 + a._m24 * b._m43
	cdef float m24 = a._m21 * b._m14 + a._m22 * b._m24 + a._m23 * b._m34 + a._m24 * b._m44
	cdef float m31 = a._m31 * b._m11 + a._m32 * b._m21 + a._m33 * b._m31 + a._m34 * b._m41
	cdef float m32 = a._m31 * b._m12 + a._m32 * b._m22 + a._m33 * b._m32 + a._m34 * b._m42
	cdef float m33 = a._m31 * b._m13 + a._m32 * b._m23 + a._m33 * b._m33 + a._m34 * b._m43
	cdef float m34 = a._m31 * b._m14 + a._m32 * b._m24 + a._m33 * b._m34 + a._m34 * b._m44
	cdef float m41 = a._m41 * b._m11 + a._m42 * b._m21 + a._m43 * b._m31 + a._m44 * b._m41
	cdef float m42 = a._m41 * b._m12 + a._m42 * b._m22 + a._m43 * b._m32 + a._m44 * b._m42
	cdef float m43 = a._m41 * b._m13 + a._m42 * b._m23 + a._m43 * b._m33 + a._m44 * b._m43
	cdef float m44 = a._m41 * b._m14 + a._m42 * b._m24 + a._m43 * b._m34 + a._m44 * b._m44
	a._m11 = m11
	a._m12 = m12
	a._m13 = m13
	a._m14 = m14
	a._m21 = m21
	a._m22 = m22
	a._m23 = m23
	a._m24 = m24
	a._m31 = m31
	a._m32 = m32
	a._m33 = m33
	a._m34 = m34
	a._m41 = m41
	a._m42 = m42
	a._m43 = m43
	a._m44 = m44

cdef inline void vec3r_set_vec3r(vec3 a, vec3 b):
	a._x = b._x
	a._y = b._y
	a._z = b._z


cdef inline void mat3r_set_mat3r(mat3 a, mat3 b):
	a._m11 = b._m11
	a._m12 = b._m12
	a._m13 = b._m13
	a._m21 = b._m21
	a._m22 = b._m22
	a._m23 = b._m23
	a._m31 = b._m31
	a._m32 = b._m32
	a._m33 = b._m33


cdef inline void mat4r_set_mat4r(mat4 a, mat4 b):
	a._m11 = b._m11
	a._m12 = b._m12
	a._m13 = b._m13
	a._m14 = b._m14
	a._m21 = b._m21
	a._m22 = b._m22
	a._m23 = b._m23
	a._m24 = b._m24
	a._m31 = b._m31
	a._m32 = b._m32
	a._m33 = b._m33
	a._m34 = b._m34
	a._m41 = b._m41
	a._m42 = b._m42
	a._m43 = b._m43
	a._m44 = b._m44



cdef inline void i_transform_change(Transform t):
	i_mat4_set_position(t._m_position_nor, t._position)
	t._position._changed_nor = <bint>0
	i_mat4_set_scale(t._m_scale_nor, t._scale)
	t._scale._changed_nor = <bint>0
	i_mat4_set_rotation(t._m_rotation_nor, t._rotation)
	t._rotation._changed_nor = <bint>0

	i_mat4_set_position(t._m_position_inv, t._position)
	t._position._changed_inv = <bint>0
	i_mat4_set_scale(t._m_scale_inv, t._scale)
	t._scale._changed_inv = <bint>0
	i_mat4_set_rotation(t._m_rotation_inv, t._rotation)
	i_mat4_inverse_like_mat3(t._m_rotation_inv)
	t._rotation._changed_inv = <bint>0

	t._L_transformation_matrix_nor.SetValue(t._m_scale_nor)
	i_mat4_mul_mat4r(t._L_transformation_matrix_nor, t._m_rotation_nor)
	i_mat4_mul_mat4r(t._L_transformation_matrix_nor, t._m_position_nor)

	t._L_transformation_matrix_inv.SetValue(t._m_position_inv)
	i_mat4_mul_mat4r(t._L_transformation_matrix_inv, t._m_rotation_inv)
	i_mat4_mul_mat4r(t._L_transformation_matrix_inv, t._m_scale_inv)



cdef inline void i_L_transform_check_atrib_nor(Transform t):
	cdef bint p = t._position._changed_nor
	cdef bint s = t._scale._changed_nor
	cdef bint r = t._rotation._changed_nor
	if(p):
		i_mat4_set_position(t._m_position_nor, t._position)
		t._position._changed_nor = <bint>0
	if(s):
		i_mat4_set_scale(t._m_scale_nor, t._scale)
		t._scale._changed_nor = <bint>0
	if(r):
		i_mat4_set_rotation(t._m_rotation_nor, t._rotation)
		t._rotation._changed_nor = <bint>0
	if(p or s or r):
		#print("set_mat_l_nor")
		mat4r_set_mat4r(t._L_transformation_matrix_nor, t._m_scale_nor)
		#t._L_transformation_matrix_nor.SetValue(t._m_scale_nor)
		i_mat4_mul_mat4r(t._L_transformation_matrix_nor, t._m_rotation_nor)
		i_mat4_mul_mat4r(t._L_transformation_matrix_nor, t._m_position_nor)
		t._changed_nor += 1
		t._changed_inv += 1

cdef inline void i_L_transform_check_atrib_inv(Transform t):
	cdef bint p = t._position._changed_inv
	cdef bint s = t._scale._changed_inv
	cdef bint r = t._rotation._changed_inv
	if(p):
		i_mat4_set_position(t._m_position_inv, t._position)
		t._position._changed_inv = <bint>0
	if(s):
		i_mat4_set_scale(t._m_scale_inv, t._scale)
		t._scale._changed_inv = <bint>0
	if(r):
		i_mat4_set_rotation(t._m_rotation_inv, t._rotation)
		i_mat4_inverse_like_mat3(t._m_rotation_inv)
		t._rotation._changed_inv = <bint>0
	if(p or s or r):
		#print("set_mat_l_inv")
		mat4r_set_mat4r(t._L_transformation_matrix_inv, t._m_position_inv)
		#t._L_transformation_matrix_inv.SetValue(t._m_position_inv)
		i_mat4_mul_mat4r(t._L_transformation_matrix_inv, t._m_rotation_inv)
		i_mat4_mul_mat4r(t._L_transformation_matrix_inv, t._m_scale_inv)
		t._changed_inv += 1



cdef inline mat3 mat3r_mul_mat3r(mat3 a, mat3 b):
	return mat3(
		a._m11 * b._m11 + a._m12 * b._m21 + a._m13 * b._m31,
		a._m11 * b._m12 + a._m12 * b._m22 + a._m13 * b._m32,
		a._m11 * b._m13 + a._m12 * b._m23 + a._m13 * b._m33,
		a._m21 * b._m11 + a._m22 * b._m21 + a._m23 * b._m31,
		a._m21 * b._m12 + a._m22 * b._m22 + a._m23 * b._m32,
		a._m21 * b._m13 + a._m22 * b._m23 + a._m23 * b._m33,
		a._m31 * b._m11 + a._m32 * b._m21 + a._m33 * b._m31,
		a._m31 * b._m12 + a._m32 * b._m22 + a._m33 * b._m32,
		a._m31 * b._m13 + a._m32 * b._m23 + a._m33 * b._m33
	)

cdef inline void i_G_transform_check_atrib_nor(Transform t):
	cdef bint t1 = <bint>(t._changed_parent_nor != t._parent._changed_nor)
	cdef bint t2 = <bint>(t._changed_local_nor != t._changed_nor)
	'''cdef float det
	cdef float m11
	cdef float m12
	cdef float m13
	cdef float m21
	cdef float m22
	cdef float m23
	cdef float m31
	cdef float m32
	cdef float m33'''
	#cdef mat3 m
	if(t1 or t2):
		#print("set_mat_g_nor")
		mat4r_set_mat4r(t._G_transformation_matrix_nor, t._L_transformation_matrix_nor)
		#t._G_transformation_matrix_nor.SetValue(t._L_transformation_matrix_nor)
		i_mat4_mul_mat4r(t._G_transformation_matrix_nor, t._parent.GetTransformationMatrix())

		t._position._global._x = t._G_transformation_matrix_nor._m41
		t._position._global._y = t._G_transformation_matrix_nor._m42
		t._position._global._z = t._G_transformation_matrix_nor._m43

		mat3r_set_mat3r(t._rotation._global,t._rotation)
		i_mat3_mul_mat3(t._rotation._global,t._parent._rotation)

		t._rotation._g_right._x = t._rotation._global._m11
		t._rotation._g_right._y = t._rotation._global._m12
		t._rotation._g_right._z = t._rotation._global._m13
		t._rotation._g_up._x = t._rotation._global._m21
		t._rotation._g_up._y = t._rotation._global._m22
		t._rotation._g_up._z = t._rotation._global._m23
		t._rotation._g_forward._x = t._rotation._global._m31
		t._rotation._g_forward._y = t._rotation._global._m32
		t._rotation._g_forward._z = t._rotation._global._m33

		vec3r_set_vec3r(t._scale._global, t._scale)
		i_vec3_mul_vec3(t._scale._global, t._parent._scale)

		'''
		det = (
			t._rotation._global._m11 * (t._rotation._global._m22 * t._rotation._global._m33 - t._rotation._global._m23 * t._rotation._global._m32) -
			t._rotation._global._m12 * (t._rotation._global._m21 * t._rotation._global._m33 - t._rotation._global._m23 * t._rotation._global._m31) +
			t._rotation._global._m13 * (t._rotation._global._m21 * t._rotation._global._m32 - t._rotation._global._m22 * t._rotation._global._m31)
		)
		det = onefloat / (onefloat if(det == zerfloat) else det)

		m11 = (t._rotation._global._m22 * t._rotation._global._m33 - t._rotation._global._m23 * t._rotation._global._m32) * det
		m12 = (t._rotation._global._m13 * t._rotation._global._m32 - t._rotation._global._m12 * t._rotation._global._m33) * det
		m13 = (t._rotation._global._m12 * t._rotation._global._m23 - t._rotation._global._m13 * t._rotation._global._m22) * det
		m21 = (t._rotation._global._m23 * t._rotation._global._m31 - t._rotation._global._m21 * t._rotation._global._m33) * det
		m22 = (t._rotation._global._m11 * t._rotation._global._m33 - t._rotation._global._m13 * t._rotation._global._m31) * det
		m23 = (t._rotation._global._m13 * t._rotation._global._m21 - t._rotation._global._m11 * t._rotation._global._m23) * det
		m31 = (t._rotation._global._m21 * t._rotation._global._m32 - t._rotation._global._m22 * t._rotation._global._m31) * det
		m32 = (t._rotation._global._m12 * t._rotation._global._m31 - t._rotation._global._m11 * t._rotation._global._m32) * det
		m33 = (t._rotation._global._m11 * t._rotation._global._m22 - t._rotation._global._m12 * t._rotation._global._m21) * det

		t._scale._global._x = (
			t._G_transformation_matrix_nor._m11 * m11 + 
			t._G_transformation_matrix_nor._m12 * m21 + 
			t._G_transformation_matrix_nor._m13 * m31)
		t._scale._global._y = (
			t._G_transformation_matrix_nor._m21 * m12 + 
			t._G_transformation_matrix_nor._m22 * m22 + 
			t._G_transformation_matrix_nor._m23 * m32
		)
		t._scale._global._z = (
			t._G_transformation_matrix_nor._m31 * m13 + 
			t._G_transformation_matrix_nor._m32 * m23 + 
			t._G_transformation_matrix_nor._m33 * m33
		)#'''

		'''m = mat3_mul_mat3(mat3(
			t._G_transformation_matrix_nor._m11, t._G_transformation_matrix_nor._m12, t._G_transformation_matrix_nor._m13,
			t._G_transformation_matrix_nor._m21, t._G_transformation_matrix_nor._m22, t._G_transformation_matrix_nor._m23,
			t._G_transformation_matrix_nor._m31, t._G_transformation_matrix_nor._m32, t._G_transformation_matrix_nor._m33,
		),mat3_inverse(t._rotation._global))
		t._scale._global._x = m._m11
		t._scale._global._y = m._m22
		t._scale._global._z = m._m33'''

		if(t1): t._changed_parent_nor = t._parent._changed_nor
		if(t2): t._changed_local_nor = t._changed_nor



cdef inline void i_G_transform_check_atrib_inv(Transform t):
	cdef bint t1 = <bint>(t._changed_parent_inv != t._parent._changed_inv)
	cdef bint t2 = <bint>(t._changed_local_inv != t._changed_inv)
	if(t1 or t2):
		#print("set_mat_g_inv")
		mat4r_set_mat4r(t._G_transformation_matrix_inv, t._parent.GetTransformationMatrixInv())
		#t._G_transformation_matrix_inv.SetValue(t._parent.GetTransformationMatrixInv())
		i_mat4_mul_mat4r(t._G_transformation_matrix_inv, t._L_transformation_matrix_inv)
		if(t1): t._changed_parent_inv = t._parent._changed_inv*1
		if(t2): t._changed_local_inv = t._changed_inv*1

	'''if(t._parent._changed_inv or t._changed_inv):
		t._G_transformation_matrix_inv.SetValue(t._parent.GetTransformationMatrixInv())
		i_mat4_mul_mat4(t._G_transformation_matrix_inv, t._L_transformation_matrix_inv)
		t._parent._changed_inv = <bint>0
		t._changed_inv = <bint>0'''





cdef inline void i_mat4_set_position(mat4 a, vec3 b):
	a._m41 = b._x
	a._m42 = b._y
	a._m43 = b._z

cdef inline void i_mat4_set_scale(mat4 a, vec3 b):
	a._m11 = b._x
	a._m22 = b._y
	a._m33 = b._z

cdef inline void i_mat4_set_rotation(mat4 a, mat3 b):
	a._m11 = b._m11
	a._m12 = b._m12
	a._m13 = b._m13
	a._m21 = b._m21
	a._m22 = b._m22
	a._m23 = b._m23
	a._m31 = b._m31
	a._m32 = b._m32
	a._m33 = b._m33

cdef inline void i_mat4_inverse_like_mat3(mat4 a):
	'''cdef float det = (
		a._m11 * (a._m22 * a._m33 - a._m23 * a._m32) -
		a._m12 * (a._m21 * a._m33 - a._m23 * a._m31) +
		a._m13 * (a._m21 * a._m32 - a._m22 * a._m31)
	)
	det = onefloat / (onefloat if(det == zerfloat) else det)

	cdef float m11 = (a._m22 * a._m33 - a._m23 * a._m32) * det
	cdef float m12 = (a._m13 * a._m32 - a._m12 * a._m33) * det
	cdef float m13 = (a._m12 * a._m23 - a._m13 * a._m22) * det
	cdef float m21 = (a._m23 * a._m31 - a._m21 * a._m33) * det
	cdef float m22 = (a._m11 * a._m33 - a._m13 * a._m31) * det
	cdef float m23 = (a._m13 * a._m21 - a._m11 * a._m23) * det
	cdef float m31 = (a._m21 * a._m32 - a._m22 * a._m31) * det
	cdef float m32 = (a._m12 * a._m31 - a._m11 * a._m32) * det
	cdef float m33 = (a._m11 * a._m22 - a._m12 * a._m21) * det

	a._m11 = m11
	a._m12 = m12
	a._m13 = m13
	a._m21 = m21
	a._m22 = m22
	a._m23 = m23
	a._m31 = m31
	a._m32 = m32
	a._m33 = m33'''

	cdef float m21 = a._m12
	a._m12 = a._m21
	a._m21 = m21

	cdef float m31 = a._m13
	a._m13 = a._m31
	a._m31 = m31

	cdef float m32 = a._m23
	a._m23 = a._m32
	a._m32 = m32







def CalculateOclusionCulling(
		mat4 projection, 
		Transform view, 
		transforms: Generator[Transform,None,None], 
		Tuple[float,float,float] min_volume, 
		Tuple[float,float,float] max_volume, 
		float far
	) -> List[mat4]:
	return calculate_oclusion_culling(
		projection,
		view,
		transforms,
		min_volume,
		max_volume,
		far
	)

cdef inline void i_reverse_mat4_mul_mat4(mat4 a, mat4 b):
	cdef float m11 = a._m11 * b.m11 + a._m12 * b.m21 + a._m13 * b.m31 + a._m14 * b.m41
	cdef float m12 = a._m11 * b.m12 + a._m12 * b.m22 + a._m13 * b.m32 + a._m14 * b.m42
	cdef float m13 = a._m11 * b.m13 + a._m12 * b.m23 + a._m13 * b.m33 + a._m14 * b.m43
	cdef float m14 = a._m11 * b.m14 + a._m12 * b.m24 + a._m13 * b.m34 + a._m14 * b.m44
	cdef float m21 = a._m21 * b.m11 + a._m22 * b.m21 + a._m23 * b.m31 + a._m24 * b.m41
	cdef float m22 = a._m21 * b.m12 + a._m22 * b.m22 + a._m23 * b.m32 + a._m24 * b.m42
	cdef float m23 = a._m21 * b.m13 + a._m22 * b.m23 + a._m23 * b.m33 + a._m24 * b.m43
	cdef float m24 = a._m21 * b.m14 + a._m22 * b.m24 + a._m23 * b.m34 + a._m24 * b.m44
	cdef float m31 = a._m31 * b.m11 + a._m32 * b.m21 + a._m33 * b.m31 + a._m34 * b.m41
	cdef float m32 = a._m31 * b.m12 + a._m32 * b.m22 + a._m33 * b.m32 + a._m34 * b.m42
	cdef float m33 = a._m31 * b.m13 + a._m32 * b.m23 + a._m33 * b.m33 + a._m34 * b.m43
	cdef float m34 = a._m31 * b.m14 + a._m32 * b.m24 + a._m33 * b.m34 + a._m34 * b.m44
	cdef float m41 = a._m41 * b.m11 + a._m42 * b.m21 + a._m43 * b.m31 + a._m44 * b.m41
	cdef float m42 = a._m41 * b.m12 + a._m42 * b.m22 + a._m43 * b.m32 + a._m44 * b.m42
	cdef float m43 = a._m41 * b.m13 + a._m42 * b.m23 + a._m43 * b.m33 + a._m44 * b.m43
	cdef float m44 = a._m41 * b.m14 + a._m42 * b.m24 + a._m43 * b.m34 + a._m44 * b.m44
	b._m11 = m11
	b._m12 = m12
	b._m13 = m13
	b._m14 = m14
	b._m21 = m21
	b._m22 = m22
	b._m23 = m23
	b._m24 = m24
	b._m31 = m31
	b._m32 = m32
	b._m33 = m33
	b._m34 = m34
	b._m41 = m41
	b._m42 = m42
	b._m43 = m43
	b._m44 = m44
	


cdef float near = <float>0.5
cdef float target2 = <float>1.0
cdef float target3 = <float>0.5

cdef inline List[mat4] calculate_oclusion_culling(
		mat4 projection, 
		Transform view, 
		transforms: Generator[Transform,None,None], 
		Tuple[float,float,float] min_volume, 
		Tuple[float,float,float] max_volume, 
		float far
	):
	cdef List[mat4] lists = []

	cdef float[32] volume
	volume[0] = -min_volume[0]
	volume[1] = min_volume[1]
	volume[2] = min_volume[2]
	volume[3] = onefloat
	volume[4] = -max_volume[0]
	volume[5] = min_volume[1]
	volume[6] = min_volume[2]
	volume[7] = onefloat
	volume[8] = -min_volume[0]
	volume[9] = min_volume[1]
	volume[10] = max_volume[2]
	volume[11] = onefloat
	volume[12] = -max_volume[0]
	volume[13] = min_volume[1]
	volume[14] = max_volume[2]
	volume[15] = onefloat
	volume[16] = -max_volume[0]
	volume[17] = max_volume[1]
	volume[18] = max_volume[2]
	volume[19] = onefloat
	volume[20] = -min_volume[0]
	volume[21] = max_volume[1]
	volume[22] = max_volume[2]
	volume[23] = onefloat
	volume[24] = -max_volume[0]
	volume[25] = max_volume[1]
	volume[26] = min_volume[2]
	volume[27] = onefloat
	volume[28] = -min_volume[0]
	volume[29] = max_volume[1]
	volume[30] = min_volume[2]
	volume[31] = onefloat

	cdef float[32] volume_calc


	cdef mat4 project = mat4_mul_mat4(view.GetTransformationMatrixInv(), projection)

	return [transform.GetTransformationMatrix() for transform in transforms if calc_oclude(volume,volume_calc,view,far,project,transform)]



cdef inline bint calc_oclude(
	float[32] volume,
	float[32] volume_calc,
	Transform view,
	float far,
	mat4 project,
	transform: Transform,
):
	calc_mul_mat4(volume_calc, transform.GetTransformationMatrix(), volume)
	if (volume_calc[20] < view._position._global._x < volume_calc[4] and  # X-axis check
		volume_calc[21] < view._position._global._y < volume_calc[5] and  # Y-axis check
		volume_calc[22] < view._position._global._z < volume_calc[6]):  # Z-axis check
		return <bint>1
	i_mat4_mul_calc(project, volume_calc)
	if(
		near < volume_calc[2] < far or
		near < volume_calc[6] < far or
		near < volume_calc[10] < far or
		near < volume_calc[14] < far or
		near < volume_calc[18] < far or
		near < volume_calc[22] < far or
		near < volume_calc[26] < far or
		near < volume_calc[30] < far
	):
		calc_div_z(volume_calc)
		if( -target2 < volume_calc[0] < target2 and -target2 < volume_calc[1] < target2 or
			-target2 < volume_calc[4] < target2 and -target2 < volume_calc[5] < target2 or
			-target2 < volume_calc[8] < target2 and -target2 < volume_calc[9] < target2 or
			-target2 < volume_calc[12] < target2 and -target2 < volume_calc[13] < target2 or
			-target2 < volume_calc[16] < target2 and -target2 < volume_calc[17] < target2 or
			-target2 < volume_calc[20] < target2 and -target2 < volume_calc[21] < target2 or
			-target2 < volume_calc[24] < target2 and -target2 < volume_calc[25] < target2 or
			-target2 < volume_calc[28] < target2 and -target2 < volume_calc[29] < target2
		): return <bint>1
	return <bint>0

cdef inline void calc_div_z(float[32] volume_calc):
	cdef float value
	value = onefloat/(onefloat if(volume_calc[2] <= target3) else volume_calc[2])
	volume_calc[0] *= value
	volume_calc[1] *= value
	value = onefloat/(onefloat if(volume_calc[6] <= target3) else volume_calc[6])
	volume_calc[4] *= value
	volume_calc[5] *= value
	value = onefloat/(onefloat if(volume_calc[10] <= target3) else volume_calc[10])
	volume_calc[8] *= value
	volume_calc[9] *= value
	value = onefloat/(onefloat if(volume_calc[14] <= target3) else volume_calc[14])
	volume_calc[12] *= value
	volume_calc[13] *= value
	value = onefloat/(onefloat if(volume_calc[18] <= target3) else volume_calc[18])
	volume_calc[16] *= value
	volume_calc[17] *= value
	value = onefloat/(onefloat if(volume_calc[22] <= target3) else volume_calc[22])
	volume_calc[20] *= value
	volume_calc[21] *= value
	value = onefloat/(onefloat if(volume_calc[26] <= target3) else volume_calc[26])
	volume_calc[24] *= value
	volume_calc[25] *= value
	value = onefloat/(onefloat if(volume_calc[30] <= target3) else volume_calc[30])
	volume_calc[28] *= value
	volume_calc[29] *= value

cdef inline void i_mat4_mul_calc(mat4 a, float[32] volume_calc):
	cdef float x
	cdef float y
	cdef float z
	cdef float w

	x = a._m11*volume_calc[0] + a._m21*volume_calc[1] + a._m31*volume_calc[2] + a._m41*volume_calc[3]
	y = a._m12*volume_calc[0] + a._m22*volume_calc[1] + a._m32*volume_calc[2] + a._m42*volume_calc[3]
	z = a._m13*volume_calc[0] + a._m23*volume_calc[1] + a._m33*volume_calc[2] + a._m43*volume_calc[3]
	w = a._m14*volume_calc[0] + a._m24*volume_calc[1] + a._m34*volume_calc[2] + a._m44*volume_calc[3]

	volume_calc[0] = -x
	volume_calc[1] = -y
	volume_calc[2] = z
	volume_calc[3] = w

	x = a._m11*volume_calc[4] + a._m21*volume_calc[5] + a._m31*volume_calc[6] + a._m41*volume_calc[7]
	y = a._m12*volume_calc[4] + a._m22*volume_calc[5] + a._m32*volume_calc[6] + a._m42*volume_calc[7]
	z = a._m13*volume_calc[4] + a._m23*volume_calc[5] + a._m33*volume_calc[6] + a._m43*volume_calc[7]
	w = a._m14*volume_calc[4] + a._m24*volume_calc[5] + a._m34*volume_calc[6] + a._m44*volume_calc[7]

	volume_calc[4] = -x
	volume_calc[5] = -y
	volume_calc[6] = z
	volume_calc[7] = w

	x = a._m11*volume_calc[8] + a._m21*volume_calc[9] + a._m31*volume_calc[10] + a._m41*volume_calc[11]
	y = a._m12*volume_calc[8] + a._m22*volume_calc[9] + a._m32*volume_calc[10] + a._m42*volume_calc[11]
	z = a._m13*volume_calc[8] + a._m23*volume_calc[9] + a._m33*volume_calc[10] + a._m43*volume_calc[11]
	w = a._m14*volume_calc[8] + a._m24*volume_calc[9] + a._m34*volume_calc[10] + a._m44*volume_calc[11]

	volume_calc[8] = -x
	volume_calc[9] = -y
	volume_calc[10] = z
	volume_calc[11] = w

	x = a._m11*volume_calc[12] + a._m21*volume_calc[13] + a._m31*volume_calc[14] + a._m41*volume_calc[15]
	y = a._m12*volume_calc[12] + a._m22*volume_calc[13] + a._m32*volume_calc[14] + a._m42*volume_calc[15]
	z = a._m13*volume_calc[12] + a._m23*volume_calc[13] + a._m33*volume_calc[14] + a._m43*volume_calc[15]
	w = a._m14*volume_calc[12] + a._m24*volume_calc[13] + a._m34*volume_calc[14] + a._m44*volume_calc[15]

	volume_calc[12] = -x
	volume_calc[13] = -y
	volume_calc[14] = z
	volume_calc[15] = w


	x = a._m11*volume_calc[16] + a._m21*volume_calc[17] + a._m31*volume_calc[18] + a._m41*volume_calc[19]
	y = a._m12*volume_calc[16] + a._m22*volume_calc[17] + a._m32*volume_calc[18] + a._m42*volume_calc[19]
	z = a._m13*volume_calc[16] + a._m23*volume_calc[17] + a._m33*volume_calc[18] + a._m43*volume_calc[19]
	w = a._m14*volume_calc[16] + a._m24*volume_calc[17] + a._m34*volume_calc[18] + a._m44*volume_calc[19]

	volume_calc[16] = -x
	volume_calc[17] = -y
	volume_calc[18] = z
	volume_calc[19] = w

	x = a._m11*volume_calc[20] + a._m21*volume_calc[21] + a._m31*volume_calc[22] + a._m41*volume_calc[23]
	y = a._m12*volume_calc[20] + a._m22*volume_calc[21] + a._m32*volume_calc[22] + a._m42*volume_calc[23]
	z = a._m13*volume_calc[20] + a._m23*volume_calc[21] + a._m33*volume_calc[22] + a._m43*volume_calc[23]
	w = a._m14*volume_calc[20] + a._m24*volume_calc[21] + a._m34*volume_calc[22] + a._m44*volume_calc[23]

	volume_calc[20] = -x
	volume_calc[21] = -y
	volume_calc[22] = z
	volume_calc[23] = w

	x = a._m11*volume_calc[24] + a._m21*volume_calc[25] + a._m31*volume_calc[26] + a._m41*volume_calc[27]
	y = a._m12*volume_calc[24] + a._m22*volume_calc[25] + a._m32*volume_calc[26] + a._m42*volume_calc[27]
	z = a._m13*volume_calc[24] + a._m23*volume_calc[25] + a._m33*volume_calc[26] + a._m43*volume_calc[27]
	w = a._m14*volume_calc[24] + a._m24*volume_calc[25] + a._m34*volume_calc[26] + a._m44*volume_calc[27]

	volume_calc[24] = -x
	volume_calc[25] = -y
	volume_calc[26] = z
	volume_calc[27] = w

	x = a._m11*volume_calc[28] + a._m21*volume_calc[29] + a._m31*volume_calc[30] + a._m41*volume_calc[31]
	y = a._m12*volume_calc[28] + a._m22*volume_calc[29] + a._m32*volume_calc[30] + a._m42*volume_calc[31]
	z = a._m13*volume_calc[28] + a._m23*volume_calc[29] + a._m33*volume_calc[30] + a._m43*volume_calc[31]
	w = a._m14*volume_calc[28] + a._m24*volume_calc[29] + a._m34*volume_calc[30] + a._m44*volume_calc[31]

	volume_calc[28] = -x
	volume_calc[29] = -y
	volume_calc[30] = z
	volume_calc[31] = w

cdef inline void calc_mul_mat4(float[32] volume_calc, mat4 a, float[32] volume):
	volume_calc[0] = -(a._m11*volume[0] + a._m21*volume[1] + a._m31*volume[2] + a._m41*volume[3])
	volume_calc[1] = -(a._m12*volume[0] + a._m22*volume[1] + a._m32*volume[2] + a._m42*volume[3])
	volume_calc[2] = -(a._m13*volume[0] + a._m23*volume[1] + a._m33*volume[2] + a._m43*volume[3])
	volume_calc[3] = (a._m14*volume[0] + a._m24*volume[1] + a._m34*volume[2] + a._m44*volume[3])

	volume_calc[4] = -(a._m11*volume[4] + a._m21*volume[5] + a._m31*volume[6] + a._m41*volume[7])
	volume_calc[5] = -(a._m12*volume[4] + a._m22*volume[5] + a._m32*volume[6] + a._m42*volume[7])
	volume_calc[6] = -(a._m13*volume[4] + a._m23*volume[5] + a._m33*volume[6] + a._m43*volume[7])
	volume_calc[7] = (a._m14*volume[4] + a._m24*volume[5] + a._m34*volume[6] + a._m44*volume[7])

	volume_calc[8] = -(a._m11*volume[8] + a._m21*volume[9] + a._m31*volume[10] + a._m41*volume[11])
	volume_calc[9] = -(a._m12*volume[8] + a._m22*volume[9] + a._m32*volume[10] + a._m42*volume[11])
	volume_calc[10] = -(a._m13*volume[8] + a._m23*volume[9] + a._m33*volume[10] + a._m43*volume[11])
	volume_calc[11] = (a._m14*volume[8] + a._m24*volume[9] + a._m34*volume[10] + a._m44*volume[11])

	volume_calc[12] = -(a._m11*volume[12] + a._m21*volume[13] + a._m31*volume[14] + a._m41*volume[15])
	volume_calc[13] = -(a._m12*volume[12] + a._m22*volume[13] + a._m32*volume[14] + a._m42*volume[15])
	volume_calc[14] = -(a._m13*volume[12] + a._m23*volume[13] + a._m33*volume[14] + a._m43*volume[15])
	volume_calc[15] = (a._m14*volume[12] + a._m24*volume[13] + a._m34*volume[14] + a._m44*volume[15])


	volume_calc[16] = -(a._m11*volume[16] + a._m21*volume[17] + a._m31*volume[18] + a._m41*volume[19])
	volume_calc[17] = -(a._m12*volume[16] + a._m22*volume[17] + a._m32*volume[18] + a._m42*volume[19])
	volume_calc[18] = -(a._m13*volume[16] + a._m23*volume[17] + a._m33*volume[18] + a._m43*volume[19])
	volume_calc[19] = (a._m14*volume[16] + a._m24*volume[17] + a._m34*volume[18] + a._m44*volume[19])

	volume_calc[20] = -(a._m11*volume[20] + a._m21*volume[21] + a._m31*volume[22] + a._m41*volume[23])
	volume_calc[21] = -(a._m12*volume[20] + a._m22*volume[21] + a._m32*volume[22] + a._m42*volume[23])
	volume_calc[22] = -(a._m13*volume[20] + a._m23*volume[21] + a._m33*volume[22] + a._m43*volume[23])
	volume_calc[23] = (a._m14*volume[20] + a._m24*volume[21] + a._m34*volume[22] + a._m44*volume[23])

	volume_calc[24] = -(a._m11*volume[24] + a._m21*volume[25] + a._m31*volume[26] + a._m41*volume[27])
	volume_calc[25] = -(a._m12*volume[24] + a._m22*volume[25] + a._m32*volume[26] + a._m42*volume[27])
	volume_calc[26] = -(a._m13*volume[24] + a._m23*volume[25] + a._m33*volume[26] + a._m43*volume[27])
	volume_calc[27] = (a._m14*volume[24] + a._m24*volume[25] + a._m34*volume[26] + a._m44*volume[27])

	volume_calc[28] = -(a._m11*volume[28] + a._m21*volume[29] + a._m31*volume[30] + a._m41*volume[31])
	volume_calc[29] = -(a._m12*volume[28] + a._m22*volume[29] + a._m32*volume[30] + a._m42*volume[31])
	volume_calc[30] = -(a._m13*volume[28] + a._m23*volume[29] + a._m33*volume[30] + a._m43*volume[31])
	volume_calc[31] = (a._m14*volume[28] + a._m24*volume[29] + a._m34*volume[30] + a._m44*volume[31])










cdef inline void i_mat3_mul_vec3_sdf(mat3 a, vec3 b):
	cdef float x = a.m11*b._x + a.m12*b._y + a.m13*b._z
	cdef float y = a.m21*b._x + a.m22*b._y + a.m23*b._z
	cdef float z = a.m31*b._x + a.m32*b._y + a.m33*b._z
	b._x = x
	b._y = y
	b._z = z

cdef vec2 epsilon = vec2(onefloat,negfloat)*0.5773*0.0005




#SPHERE
def sdSphere_dist(vec3 p, Transform l) -> float:
	return __sdSphere_dist(p,l)

def sdSphere_point_on(vec3 p, Transform l) -> Tuple[vec3,vec3]:
	return __sdSphere_point_on(p,l)



cdef inline float __sdSphere_dist( vec3 p, Transform l ):
	cdef vec3 v = vec3_sub_vec3(l.position, p)
	i_mat3_mul_vec3_sdf(l.rotation,v)
	cdef float k0 = vec3_magnitude(vec3_truediv_vec3(v,l.scale))
	cdef float k1 = vec3_magnitude(vec3_truediv_vec3(v,vec3_mul_vec3(l.scale,l.scale)))
	return k0*(k0-onefloat)/(onefloat if k1==zerfloat else k1)



cdef inline Tuple[vec3,vec3] __sdSphere_point_on( vec3 p, Transform l ):

	cdef float d = __sdSphere_dist(p,l)

	cdef vec3 f1 = vec3(epsilon.x,epsilon.y,epsilon.y)
	i_vec3_mul_num(f1,__sdSphere_dist(p+f1,l))
	cdef vec3 f2 = vec3(epsilon.y,epsilon.y,epsilon.x)
	i_vec3_mul_num(f2,__sdSphere_dist(p+f2,l))
	cdef vec3 f3 = vec3(epsilon.y,epsilon.x,epsilon.y)
	i_vec3_mul_num(f3,__sdSphere_dist(p+f3,l))
	cdef vec3 f4 = vec3(epsilon.x,epsilon.x,epsilon.x)
	i_vec3_mul_num(f4,__sdSphere_dist(p+f4,l))

	i_vec3_add_vec3(f1,f2)
	i_vec3_add_vec3(f1,f3)
	i_vec3_add_vec3(f1,f4)

	i_vec3_normalize(f1)

	i_vec3_mul_num(f1, d)

	return vec3_sub_vec3(p,f1), f1



#BOX
def sdBox_dist(vec3 p, Transform l) -> float:
	return __sdBox_dist(p,l)

def sdBox_point_on(vec3 p, Transform l) -> Tuple[vec3,vec3]:
	return __sdBox_point_on(p,l)



cdef inline float __sdBox_calc_q(vec3 a, float b):
	cdef float x = max(a.x, b)
	cdef float y = max(a.y, b)
	cdef float z = max(a.z, b)
	return sqrtf(x*x+y*y+z*z)

cdef inline float __sdBox_dist( vec3 p, Transform l):
	cdef vec3 v = vec3_sub_vec3(l.position, p)
	i_mat3_mul_vec3_sdf(l.rotation,v)
	cdef vec3 q = vec3_sub_vec3(abs(v), l.scale)
	return __sdBox_calc_q(q,zerfloat) + min(max(q.x,max(q.y,q.z)),zerfloat)




cdef inline Tuple[vec3,vec3] __sdBox_point_on( vec3 p, Transform l):

	cdef float d = __sdBox_dist(p,l)

	#'''
	cdef vec3 f1 = vec3(epsilon.x,epsilon.y,epsilon.y)
	i_vec3_mul_num(f1,__sdBox_dist(p+f1,l))
	cdef vec3 f2 = vec3(epsilon.y,epsilon.y,epsilon.x)
	i_vec3_mul_num(f2,__sdBox_dist(p+f2,l))
	cdef vec3 f3 = vec3(epsilon.y,epsilon.x,epsilon.y)
	i_vec3_mul_num(f3,__sdBox_dist(p+f3,l))
	cdef vec3 f4 = vec3(epsilon.x,epsilon.x,epsilon.x)
	i_vec3_mul_num(f4,__sdBox_dist(p+f4,l))

	i_vec3_add_vec3(f1,f2)
	i_vec3_add_vec3(f1,f3)
	i_vec3_add_vec3(f1,f4)

	i_vec3_normalize(f1)

	i_vec3_mul_num(f1, d)#'''

	return vec3_sub_vec3(p,f1), f1



#Cylinder
'''
def sdfCylinder_dist(vec3 p, Transform l) -> float:
	return _sdfCylinder_dist(p,l)

cdef inline float _sdfCylinder_dist(vec3 p, Transform l):
	cdef vec3 ba = 


float sdCappedCylinder( vec3 p, vec3 a, vec3 b, float r )
{
  vec3  ba = b - a;
  vec3  pa = p - a;
  float baba = dot(ba,ba);
  float paba = dot(pa,ba);
  float x = length(pa*baba-ba*paba) - r*baba;
  float y = abs(paba-baba*0.5)-baba*0.5;
  float x2 = x*x;
  float y2 = y*y*baba;
  float d = (max(x,y)<0.0)?-min(x2,y2):(((x>0.0)?x2:0.0)+((y>0.0)?y2:0.0));
  return sign(d)*sqrt(abs(d))/baba;
}'''







