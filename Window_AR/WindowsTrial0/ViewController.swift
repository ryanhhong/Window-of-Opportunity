//
//  ViewController.swift
//  WindowsTrial0
//
//  Created by Mustafa Sarwar on 8/31/20.
//  Copyright © 2020 Mustafa Sarwar. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var grids = [Grid]()
    var resizeFactor = 0.026
    var wWidth = "24.0"
    var wHeight = "17.8"
    var wType = " "
    var uName = "test"
    var uPassword = "test_pass"
    var accessToken = "token"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //adding gesture for tap selector in objc runtime for func touched
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touched))
        sceneView.addGestureRecognizer(gestureRecognizer)
        
//        getAPI
//        set width and height of window
        
//        let user = aToken(access_token: "12345",
//                          refresh_token: "hi")
//        guard let uploadData = try? JSONEncoder().encode(user) else {
//            return
//
//
        
//        let userCredential = URLCredential(user: user,
//                                           password: password,
//                                           persistence: .permanent)
        
//            let json: [String: Any] = ["username": uName,
//                                       "password": uPassword]
//
//            let jsonData = try? JSONSerialization.data(withJSONObject: json)
//
//            // create post request
//            let url = URL(string: "http://back-woop.herokuapp.com/login")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            let accessToken = "your access token"
//            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//            // insert json data to the request
//            request.httpBody = jsonData
//
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let data = data, error == nil else {
//                    print(error?.localizedDescription ?? "No data")
//                    return
//                }
//                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
//                if let responseJSON = responseJSON as? [String: Any] {
//                    print(responseJSON)
//                }
//            }
//
//            task.resume()
        
        postAction()
      
            
    }
    
    func postAction() {
       
        let Url = ("http://back-woop.herokuapp.com/login")
        guard let serviceUrl = URL(string: Url) else { return }
        let parameterDictionary = ["username" : uName, "password" : uPassword]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
//        guard let uploadData = try? JSONEncoder().encode(user) else {
//            return
//        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    //print((json?["access_token"])!)
                    self.accessToken = self.toString((json?["access_token"])!)
                        print(self.accessToken)
                } catch {
                    print(error)
                }
            }
            
            self.getData()
            
        }.resume()
    }
    
    func toString(_ value: Any?) -> String {
      return String(describing: value ?? "")
    }

    private func getData() {
        
        let Url = "http://back-woop.herokuapp.com/get_selected_window"
         guard let serviceUrl = URL(string: Url) else { return }
         var request = URLRequest(url: serviceUrl)
         request.httpMethod = "GET"
         request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
         request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
         request.setValue("Application/json", forHTTPHeaderField: "Accept")

 //        guard let uploadData = try? JSONEncoder().encode(user) else {
 //            return
 //        }
         
         let session = URLSession.shared
         session.dataTask(with: request) { (data, response, error) in
             if let response = response {
                 print(response)
             }
             if let data = data {
                 do {
                     let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    self.wHeight = self.toString((json?["height"])!)
                    self.wWidth = self.toString((json?["width"])!)
                    print(json)
                    self.wType = self.toString((json?["window_type"])!)
                    print((json?["height"])!)
                    print(self.wHeight)
                       
 
                 } catch {
                     print(error)
                 }
             }
             
         }.resume()
       }
    
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let config = ARWorldTrackingConfiguration()
        
        //turn on vertical plane detection
        config.planeDetection = [.vertical, .horizontal]

        // Run the view's session
        sceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }


   
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or rem      ove existing anchors if consistent tracking is required
        
    }
    
    //Rework***
    
    //ARAnchor is a 2D surface that ARkit detects in physical environment
    
   // didAdd() called when new node is aggregated to ARSCNView checks if grid is vertical and then adds it to the Grid array
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else {return}
        let grid = Grid(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
    }
    
    //didUpdate called when newer ARPlanceAnchor nodes are detected and also check if grid is vertical
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else {return}
        let grid = self.grids.filter {grid in return grid.anchor.identifier == planeAnchor.identifier}.first
        guard let foundGrid = grid else {
            return
        }
        foundGrid.update(anchor: planeAnchor)
    }
    
    @objc func touched(gesture:UITapGestureRecognizer) {
        //get xy position of tapped location in sceneView
        let loc = gesture.location(in: sceneView)

        //use hitTest to make xy coordinated to xyz plane
        let hitTestResults = sceneView.hitTest(loc, types: .existingPlaneUsingExtent)
        
        //Get hitTestResults
        guard let hitTest = hitTestResults.first,
              //Might be nil as?
        let anchor = hitTest.anchor as? ARPlaneAnchor,
        // using $0 for first argument shorthand
        let gridIndex = grids.index(where: { $0.anchor == anchor } ) else {return}
        //addPainting(hitTest, grids[gridIndex])
        loadWindow(hitResult: hitTest, grid: grids[gridIndex],theWidth: Double(wWidth)!,theHeight: Double(wHeight)!,type: wType)
    }
    //23 1/4 by 20 1/4
    //19.5/38
    func loadWindow( hitResult: ARHitTestResult,  grid: Grid, theWidth: Double, theHeight: Double, type: String){
            // set the plane that the image will fill
            //type will be the first part of the name of the window image.
            let ratioNum = theWidth/theHeight
            var imageName = type
            // ratioNum < .8 use tall and skinny (t)all
            // ratioNum > 1.25 use short and wide (w)ide
            // ratioNum in between then use square (s)quare
            // singlehungt, singlehungw, singlehungs

        let planeGeometry = SCNPlane(width: CGFloat(theWidth * resizeFactor), height: CGFloat(theHeight * resizeFactor))
            let material = SCNMaterial()
            if(ratioNum < 0.8){
                imageName = imageName + "t"
            }
            else if(ratioNum > 1.25){
                imageName = imageName + "w"
            }
            else {
                imageName = imageName + "s"
            }
        
            material.diffuse.contents = UIImage(named: imageName)
            planeGeometry.materials = [material]


            let paintingNode = SCNNode(geometry: planeGeometry)
                   paintingNode.transform = SCNMatrix4(hitResult.anchor!.transform)
                   paintingNode.eulerAngles = SCNVector3(paintingNode.eulerAngles.x + (-Float.pi / 2), paintingNode.eulerAngles.y,paintingNode.eulerAngles.z)
                   paintingNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)

                   sceneView.scene.rootNode.addChildNode(paintingNode)
                   grid.removeFromParentNode()

        }

    
    func addPainting(_ hitResult: ARHitTestResult, _ grid: Grid) {
        //first painting
        //get api width and height, then change planegeometry of SCNPLANE
        //if width > height then use wide png, if width = height use square png, else width < height use tall png
        let planeGeometry = SCNPlane(width: 0.30, height: 0.60)
        let material = SCNMaterial()
        //use api to configure which type of window is displayed
        material.diffuse.contents = UIImage(named: wType)
        planeGeometry.materials = [material]
        
       
        let paintingNode = SCNNode(geometry: planeGeometry)
        paintingNode.transform = SCNMatrix4(hitResult.anchor!.transform)
        paintingNode.eulerAngles = SCNVector3(paintingNode.eulerAngles.x + (-Float.pi / 2), paintingNode.eulerAngles.y,paintingNode.eulerAngles.z)
        paintingNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(paintingNode)
        grid.removeFromParentNode()
    }
    
}



struct Response: Codable{
    let window: MyWindow
    let user: MyUser
}

struct ResponseW: Codable{
    let token: aToken
}

struct aToken: Codable{
    let access_token: String
    let refresh_token: String
}

struct MyWindow: Codable{
      let type: String
      let width: Double
      let height: Double
}

struct MyUser: Codable{
      let name: String
}


//API DATA Format

/*
{
 window: {
    type: "t"
    width: "x"
    height: "y"
 },
 user: {
    name: "name"
 }
 */






//
//    private func getData(from url: String) {
//        let user = aToken(access_token: "12345",
//                          refresh_token: "hi")
//        guard let uploadData = try? JSONEncoder().encode(user) else {
//            return
//        }
////        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
////            guard let data = data, error == nil else {
////                print(error)
////                return
////            }
////
//            //recieved data in bytes do json decoding
//
////            let access_token: String
////            let refresh_token: String
////
////
//
//            var result: Response?
//            do {
//
//
//            }
//            catch let error{
//                print(error)
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print(jsonString)
//            }
//
//            }
//
//            guard let json = result else {
//                return
//            }

            //print(json)
//            print(json.window.type)
//            print(json.window.width)
//            print(json.window.height)
//            print(json.user.name)
//
//            self.wWidth = json.window.width
//            self.wHeight = json.window.height
//            self.wType = json.window.type
//            self.uName = json.user.name
//        })
//        task.resume() //fires request
//    }
