
import Foundation
import CoreGraphics
import SceneKit

extension SCNVector3 {
  
  /**
   Invierte un vector
   */
  mutating func invert() -> SCNVector3 {
    return self * -1
  }
  
  /**
     Calcula la longitud del vector basado en el teorema de pitágoras
   */
  var length:Float {
    get {
      return sqrtf(x*x + y*y + z*z)
    }
    set {
      self = self.unit * newValue
    }
  }
  
  /**
     Calcula la longitud cuadrada de un vector
   */
  var lengthSquared:Float {
    get {
      return self.x * self.x + self.y * self.y + self.z * self.z;
    }
  }
  
  /**
   Retorna un vector unidad
   */
  var unit:SCNVector3 {
    get {
      return self / self.length
    }
  }
  
  /**
   Normaliza un vector
   */
  mutating func normalize() {
    self = self.unit
  }
  
  /**
   Calcula distancia entre vectores
   */
  func distance(toVector: SCNVector3) -> Float {
    return (self - toVector).length
  }
  
  
  /**

   */
  func dot(toVector: SCNVector3) -> Float {
    return x * toVector.x + y * toVector.y + z * toVector.z
  }
  
  /**
   
   */
  func cross(toVector: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(y * toVector.z - z * toVector.y, z * toVector.x - x * toVector.z, x * toVector.y - y * toVector.x)
  }
  
  /**
   
   */
  var xyAngle:Float {
    get {
      return atan2(self.y, self.x)
    }
    set {
      let length = self.length
      self.x = cos(newValue) * length
      self.y = sin(newValue) * length
    }
  }
  
  /**

   */
  var xzAngle:Float {
    get {
      return atan2(self.z, self.x)
    }
    set {
      let length = self.length
      self.x = cos(newValue) * length
      self.z = sin(newValue) * length
    }
  }
  
  /**

   */
  func angleBetweenVectors(_ toVector:SCNVector3) -> Float {
    
    //cos(angle) = (A.B)/(|A||B|)
    let cosineAngle = (dot(toVector: toVector) / (length * toVector.length))
    return Float(acos(cosineAngle))
  }
  
  var up:SCNVector3 {
    get {
      return SCNVector3(0, self.y, 0)
    }
  }
  
  var front:SCNVector3 {
    get {
      return SCNVector3(0, 0, self.z)
    }
  }
  
  var right:SCNVector3 {
    get {
      return SCNVector3(self.x, 0, 0)
    }
  }
}


// Operadores SCNVector

/**
 v1 = v2 + v3
 */
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 v1 += v2
 */
func +=( left: inout SCNVector3, right: SCNVector3) {
  left = left + right
}

/**
 v1 = v2 - v3
 */
func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
 v1 -= v2
 */
func -=( left: inout SCNVector3, right: SCNVector3) {
  left = left - right
}

/**
 v1 = v2 * v3
 */
func *(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
 v1 *= v2
 */
func *=( left: inout SCNVector3, right: SCNVector3) {
  left = left * right
}

/**
 v1 = v2 * x
 */
func *(left: SCNVector3, right: Float) -> SCNVector3 {
  return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

/**
 v *= x
 */
func *=( left: inout SCNVector3, right: Float) {
  left = SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

/**
 v1 = v2 / v3
 */
func /(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 v1 /= v2
 */
func /=( left: inout SCNVector3, right: SCNVector3) {
  left = SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 v1 = v2 / x
 */
func /(left: SCNVector3, right: Float) -> SCNVector3 {
  return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

/**
 v /= x
 */
func /=( left: inout SCNVector3, right: Float) {
  left = SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

/**
 v = -v
 */
prefix func -(v: SCNVector3) -> SCNVector3 {
  return v * -1
}


