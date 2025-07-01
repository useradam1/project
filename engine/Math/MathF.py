from vec__.vecf import vec2, mat2, vec3, mat3, Rotation, vec4, mat4, Transform
#from glm import vec3, mat3, inverse



import unittest
from ctypes import c_float

class TestVec2(unittest.TestCase):
    def test_initialization(self):
        v = vec2(1.0, 2.0)
        self.assertEqual(v.x, 1.0)
        self.assertEqual(v.y, 2.0)

    def test_default_initialization(self):
        v = vec2()
        self.assertEqual(v.x, 0.0)
        self.assertEqual(v.y, 0.0)

    def test_set_values(self):
        v = vec2()
        v.SetValues(3.0, 4.0)
        self.assertEqual(v.x, 3.0)
        self.assertEqual(v.y, 4.0)

    def test_magnitude(self):
        v = vec2(3.0, 4.0)
        self.assertAlmostEqual(v.magnitude, 5.0, places=6)

    def test_normalize(self):
        v = vec2(3.0, 4.0)
        v.Normalize()
        self.assertAlmostEqual(v.magnitude, 1.0, places=6)

    def test_dot_product(self):
        v1 = vec2(1.0, 2.0)
        v2 = vec2(3.0, 4.0)
        self.assertEqual(vec2.GetDotProduct(v1, v2), 11.0)

    def test_addition(self):
        v1 = vec2(1.0, 2.0)
        v2 = vec2(3.0, 4.0)
        v3 = v1 + v2
        self.assertEqual(v3.x, 4.0)
        self.assertEqual(v3.y, 6.0)

    def test_subtraction(self):
        v1 = vec2(5.0, 6.0)
        v2 = vec2(2.0, 3.0)
        v3 = v1 - v2
        self.assertEqual(v3.x, 3.0)
        self.assertEqual(v3.y, 3.0)

    def test_multiplication(self):
        v1 = vec2(2.0, 3.0)
        v2 = v1 * 2
        self.assertEqual(v2.x, 4.0)
        self.assertEqual(v2.y, 6.0)

    def test_create_ctype(self):
        v = vec2(1.0, 2.0)
        c_array = v.CreateCType()
        self.assertEqual(c_array[0], 1.0)
        self.assertEqual(c_array[1], 2.0)


class TestMat2(unittest.TestCase):
    def test_initialization(self):
        m = mat2(1.0, 2.0, 3.0, 4.0)
        self.assertEqual(m[0], 1.0)
        self.assertEqual(m[1], 2.0)
        self.assertEqual(m[2], 3.0)
        self.assertEqual(m[3], 4.0)

    def test_default_initialization(self):
        m = mat2()
        self.assertEqual(m[0], 1.0)
        self.assertEqual(m[1], 0.0)
        self.assertEqual(m[2], 0.0)
        self.assertEqual(m[3], 1.0)

    def test_set_values(self):
        m = mat2()
        m.SetValues(5.0, 6.0, 7.0, 8.0)
        self.assertEqual(m[0], 5.0)
        self.assertEqual(m[1], 6.0)
        self.assertEqual(m[2], 7.0)
        self.assertEqual(m[3], 8.0)

    def test_transpose(self):
        m = mat2(1.0, 2.0, 3.0, 4.0)
        m.Transpose()
        self.assertEqual(m[0], 1.0)
        self.assertEqual(m[1], 3.0)
        self.assertEqual(m[2], 2.0)
        self.assertEqual(m[3], 4.0)

    def test_inverse(self):
        m = mat2(4.0, 7.0, 2.0, 6.0)
        m.Inverse()
        self.assertAlmostEqual(m[0], 0.6, places=6)
        self.assertAlmostEqual(m[1], -0.7, places=6)
        self.assertAlmostEqual(m[2], -0.2, places=6)
        self.assertAlmostEqual(m[3], 0.4, places=6)

    def test_matrix_multiplication(self):
        m1 = mat2(1.0, 2.0, 3.0, 4.0)
        m2 = mat2(5.0, 6.0, 7.0, 8.0)
        m3 = m1 @ m2
        self.assertEqual(m3[0], 19.0)
        self.assertEqual(m3[1], 22.0)
        self.assertEqual(m3[2], 43.0)
        self.assertEqual(m3[3], 50.0)

    def test_matrix_vector_multiplication(self):
        m = mat2(1.0, 2.0, 3.0, 4.0)
        v = vec2(1.0, 2.0)
        result = m @ v
        self.assertEqual(result.x, 5.0)
        self.assertEqual(result.y, 11.0)


if __name__ == '__main__':
    unittest.main()
