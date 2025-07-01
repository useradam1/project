# BindlessTexture.py
from OpenGL.GL.ARB.bindless_texture import *
from numpy import uint64, uint32

def CreateBindlessHandle(texture_id: uint32) -> uint64:
    """Создает bindless handle для текстуры"""
    handle = glGetTextureHandleARB(texture_id)
    return uint64(handle)

def MakeTextureResident(handle: uint64) -> None:
    """Делает текстуру резидентной (доступной в шейдере)"""
    glMakeTextureHandleResidentARB(handle)

def MakeTextureNonResident(handle: uint64) -> None:
    """Убирает текстуру из резидентных"""
    glMakeTextureHandleNonResidentARB(handle)

def IsTextureResident(handle: uint64) -> bool:
    """Проверяет, является ли текстура резидентной"""
    return bool(glIsTextureHandleResidentARB(handle))