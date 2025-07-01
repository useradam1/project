from OpenGL.GL import *
from .CreateMesh import GpuMeshInstanced


def DrawMesh(mesh: GpuMeshInstanced) -> None:
	glBindVertexArray(mesh.vao)
	glDrawElements(GL_TRIANGLES, mesh.len_faces, GL_UNSIGNED_INT, None)
	glBindVertexArray(0)


def DrawMeshInstanced(mesh: GpuMeshInstanced, instanceCount: int) -> None:
	glBindVertexArray(mesh.vao)
	glDrawElementsInstanced(GL_TRIANGLES, mesh.len_faces, GL_UNSIGNED_INT, None, instanceCount)
	glBindVertexArray(0)