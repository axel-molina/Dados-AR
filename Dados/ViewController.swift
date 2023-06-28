import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
  // MARK: - Estados del juego
    // El juego tendrá 3 estados posibles
    enum GameState:Int16 {
    case detectSurface
    case pointToSurface
    case swipeToPlay
    }
  
  // MARK: - Propiedades
    var trackingStatus: String = ""
    var diceNodes: [SCNNode] = []
    var diceCount:Int = 5
    var diceStyle:Int = 0
    
    var focusNode:SCNNode!
    var focusPoint:CGPoint!
    
    var diceOffset:[SCNVector3] = [
        SCNVector3(0,0,0),
        SCNVector3(-0.05,0,0),
        SCNVector3(0.05,0,0),
        SCNVector3(-0.05,0.05,0.02),
        SCNVector3(0.05,0.05,0.02),
    ]
    
    var gameState:GameState = .detectSurface
    var statusMessage:String = ""
    
  // MARK: - Objetos
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var styleButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - Acciones
  @IBAction func startButtonPressed(_ sender: Any) {
      self.startGame()
  }
  
    // Cambiar estilo de los dados (textura)
  @IBAction func styleButtonPressed(_ sender: Any) {
      diceStyle = (diceStyle >= 4) ? 0 : diceStyle+1
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
      self.resetGame()
  }
  
  @IBAction func swipeUpGestureHandler(_ sender: Any) {
      // Si el juego esta en estado de swipetoplay se podrán lanzar los dados
      guard gameState == .swipeToPlay else {return}
      
      guard let frame = self.sceneView.session.currentFrame else { return }
      for count in 0..<diceCount {
         if count != 5 && count < 5{
              throwDiceNode(transform: SCNMatrix4(frame.camera.transform), offset: diceOffset[count])
         }
      }
  }
    
    
 
  
  // MARK: - Manejo de vista
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initSceneView()
    self.initScene()
    self.initARSession()
    self.loadModels()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("*** ViewWillAppear()")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("*** ViewWillDisappear()")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** DidReceiveMemoryWarning()")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
    
    @objc func orientationChanged(){
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + (view.center.y * 0.25))
    }
  
  // MARK: - Inicialización
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
      focusPoint = CGPoint(x: view.center.x, y: view.center.y + (view.center.y * 0.25))
    sceneView.debugOptions = [
      SCNDebugOptions.showFeaturePoints,
      //SCNDebugOptions.showWorldOrigin,
      //SCNDebugOptions.showBoundingBoxes,
      //SCNDebugOptions.showWireframe
    ]
      // Observador para detectar la orientacion del telefono
      NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
  }
  
  func initScene() {
    let scene = SCNScene()
    scene.isPaused = false
    sceneView.scene = scene
      
      // Cargar ambiente de iluminación
      scene.lightingEnvironment.contents = "Dados.scnassets/Texturas/Environment_CUBE.jpg"
      scene.lightingEnvironment.intensity = 2
      
      scene.physicsWorld.speed = 0.7
      scene.physicsWorld.timeStep = 1.0/60.0
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: No es compatible")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.planeDetection = .horizontal
    sceneView.session.run(config)
  }
  
  // MARK: - Cargar Modelos
    func loadModels(){
        let diceScene = SCNScene(named: "Dados.scnassets/Escena.scn")!
        let focusScene = SCNScene(named: "Dados.scnassets/FocusScene.scn")
        
        focusNode = focusScene?.rootNode.childNode(withName: "focus", recursively: false)!
        
        for count in 0..<5{
            diceNodes.append(diceScene.rootNode.childNode(
               withName: "Dice\(count)", recursively: false
           )!)
        }
        
        sceneView.scene.rootNode.addChildNode(focusNode)
    }
  
  // MARK: - Funciones de ayuda
    func throwDiceNode(transform:SCNMatrix4, offset:SCNVector3){
        
        let distance = simd_distance(focusNode.simdPosition, simd_make_float3(transform.m41, transform.m42, transform.m43))
        
        let direction = SCNVector3(-(distance*2.5)*transform.m31, -(distance*2.5)*(transform.m32-Float.pi/4), -(distance*2.5)*transform.m33)
        
        // Crea una constante con 3 angulos randoms
        let rotation = SCNVector3(Double.random(min: 0, max: Double.pi), Double.random(min: 0, max: Double.pi), Double.random(min: 0, max: Double.pi))
        
        // Combinamos la transformacion de la posicion deseada con el vector recibido
        let position = SCNVector3(transform.m41 + offset.x, transform.m42 + offset.y, transform.m43 + offset.z)
        
        let diceNode = diceNodes[diceStyle].clone()
        diceNode.name = "Dice"
        diceNode.position = position
        diceNode.eulerAngles = rotation
        diceNode.physicsBody?.resetTransform()
        diceNode.physicsBody?.applyForce(direction, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(diceNode)
        
        // diceCount -= 1
    }
    
    func createARPlaneNode(planeAnchor: ARPlaneAnchor, color: UIColor) -> SCNNode{
        
        let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = "Dados.scnassets/Texturas/Surface_DIFFUSE.png"
        planeGeometry.materials = [planeMaterial]
        
        let planeNode = SCNNode(geometry: planeGeometry)
        
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        planeNode.physicsBody = self.createARPlanePhysics(geometry: planeGeometry)
        
        return planeNode
    }
    
    func updateARPlaneNode(planeNode:SCNNode, planeAnchor:ARPlaneAnchor){
        let planeGeometry = planeNode.geometry as! SCNPlane
        planeGeometry.width = CGFloat(planeAnchor.extent.x)
        planeGeometry.height = CGFloat(planeAnchor.extent.z)
        
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.physicsBody = nil
        planeNode.physicsBody = self.createARPlanePhysics(geometry: planeGeometry)
    }
    
    func removeARPlaneNode(node:SCNNode){
        for childNode in node.childNodes{
            childNode.removeFromParentNode()
        }
    }
    
    func updateFocusNode(){
        let results = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent])
        
        if results.count == 1{
            if let match = results.first{
                let transform = match.worldTransform
                self.focusNode.position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                self.gameState = .swipeToPlay
            }
        } else {
            self.gameState = .pointToSurface
        }
    }
    
    func updateDiceNodes(){
        for node in sceneView.scene.rootNode.childNodes{
            if node.name == "Dice"{
                if node.presentation.position.y < -2{
                    node.removeFromParentNode()
                    diceCount += 1
                }
            }
        }
    }
    
    func createARPlanePhysics(geometry:SCNGeometry)->SCNPhysicsBody{
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: geometry, options: nil))
        physicsBody.restitution = 0.5
        physicsBody.friction = 0.5
        
        return physicsBody
    }
    
    func suspenseARPlaneDetection(){
        let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
        config.planeDetection = []
        sceneView.session.run(config)
    }
    
    func hideARPlaneNodes(){
        for anchor in (self.sceneView.session.currentFrame?.anchors)!{
            if let node = self.sceneView.node(for: anchor){
                for child in node.childNodes{
                    // Quitar la textura del plano (plano a rayas)
                    let material = child.geometry?.materials.first!
                    material?.colorBufferWriteMask = []
                }
            }
        }
    }
    
    // Ocultar start button, detener deteccion de plano y poner estado de pointToSurface
    func startGame(){
        DispatchQueue.main.async{
            self.startButton.isHidden = true
            self.suspenseARPlaneDetection()
            self.hideARPlaneNodes()
            self.gameState = .pointToSurface
        }
    }
    
    // Volver a detectar planos horizontales y remover todo (volver a comenzar)
    func resetARSession(){
        // Crear config de trackeo nuevamente
        let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
        // Establecer deteccion de planos horizontales
        config.planeDetection = [.horizontal]
        // Resetear trackeo cuando inicie la escene y remover los anchor anteriores
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func resetGame(){
        DispatchQueue.main.async {
            // Volver amostrar el boton de juego
            self.startButton.isHidden = false
            // Funcion de arriba
            self.resetARSession()
            // Pasar a estado del juego deteccion de plano
            self.gameState = .detectSurface
        }
    }
    
}

extension ViewController : ARSCNViewDelegate {
  
  // MARK: - Administración de SceneKit (Delegado)
  func renderer(_ renderer: SCNSceneRenderer,
                updateAtTime time: TimeInterval) {
      self.updateFocusNode()
      self.updateDiceNodes()
    DispatchQueue.main.async {
     // self.statusLabel.text = self.trackingStatus
        self.updateStatus()
    }
  }
    
    func updateStatus(){
        switch gameState{
        case .detectSurface: statusMessage = "Escanea una superficie plana"
        case .pointToSurface: statusMessage = "Apunta  a la superficie deseada"
        case .swipeToPlay: statusMessage = "Desliza hacia arriba para tirar"
        }
        
        self.statusLabel.text = statusMessage
    }
  
  
  // MARK: - Administración del state tracking
  func session(_ session: ARSession,
               cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    // 1
    case .notAvailable:
      self.trackingStatus = "Tacking:  No disponible!"
      break
    // 2
    case .normal:
        self.trackingStatus = "Tracking: Todo bien :)!"
      break
    // 3
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = "Tracking: Limitado por exceso de movimiento!"
        break
      // 3.1
      case .insufficientFeatures:
        self.trackingStatus = "Tracking: No hay suficientes elementos (falta de iluminación, etc)!"
        break
      // 3.2
      case .initializing:
        self.trackingStatus = "Tracking: Inicializando..."
        break
      case .relocalizing:
        self.trackingStatus = "Tracking: Relocalizando..."
        break
      default: self.trackingStatus = "Cargando..."
      }
    }
  }
  
  // MARK: - Administración de errores
  func session(_ session: ARSession,
               didFailWithError error: Error) {
    self.trackingStatus = "AR Session ERROR: \(error)"
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    self.trackingStatus = "AR Session interrumpida!"
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    self.trackingStatus = "AR Session Terminada"
      self.resetGame()
  }
  
  // MARK: - Administración de planos
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else{
            return
        }
        
        DispatchQueue.main.async {
            let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor, color: UIColor.yellow.withAlphaComponent(0.5))
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        DispatchQueue.main.async{
            self.updateARPlaneNode(planeNode: node.childNodes[0], planeAnchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async{
            self.removeARPlaneNode(node: node)
        }
    }
  
}

