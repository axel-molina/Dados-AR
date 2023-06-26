import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
  
  // MARK: - Propiedades
  var trackingStatus: String = ""
    var diceNodes: [SCNNode] = []
    var diceCount:Int = 5
    var diceStyle:Int = 0
    var diceOffset:[SCNVector3] = [
        SCNVector3(0,0,0),
        SCNVector3(-0.05,0,0),
        SCNVector3(0.05,0,0),
        SCNVector3(-0.05,0.05,0.02),
        SCNVector3(0.05,0.05,0.02),
    ]
  
  // MARK: - Objetos
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var styleButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - Acciones
  
  @IBAction func startButtonPressed(_ sender: Any) {
  }
  
  @IBAction func styleButtonPressed(_ sender: Any) {
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
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
  
  // MARK: - Inicialización
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
    sceneView.debugOptions = [
      SCNDebugOptions.showFeaturePoints,
      //SCNDebugOptions.showWorldOrigin,
      //SCNDebugOptions.showBoundingBoxes,
      //SCNDebugOptions.showWireframe
    ]
  }
  
  func initScene() {
    let scene = SCNScene()
    scene.isPaused = false
    sceneView.scene = scene
      
      // Cargar ambiente de iluminación
      scene.lightingEnvironment.contents = "Dados.scnassets/Texturas/Enviroment_CUBE.jpg"
      scene.lightingEnvironment.intensity = 2
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: No es compatible")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    sceneView.session.run(config)
  }
  
  // MARK: - Cargar Modelos
    func loadModels(){
        let diceScene = SCNScene(named: "Dados.scnassets/Escena.scn")!
        for count in 0..<5{
            diceNodes.append(diceScene.rootNode.childNode(
                withName: "dice:\(count)", recursively: false
            )!)
        }
    }
  
  // MARK: - Funciones de ayuda
    func throwDiceNode(transform:SCNMatrix4, offset:SCNVector3){
        // Combinamos la transformacion de la posicion deseada con el vector recibido
        let position = SCNVector3(transform.m41 + offset.x, transform.m42 + offset.y, transform.m43 + offset.z)
        
        let diceNode = diceNodes[diceStyle].clone()
        diceNode.name = "dice"
        diceNode.position = position
        
        sceneView.scene.rootNode.addChildNode(diceNode)
        
        diceCount -= 1
    }
}

extension ViewController : ARSCNViewDelegate {
  
  // MARK: - Administración de SceneKit (Delegado)
  
  func renderer(_ renderer: SCNSceneRenderer,
                updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.statusLabel.text = self.trackingStatus
    }
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
  }
  
  // MARK: - Administración de planos
  
}

