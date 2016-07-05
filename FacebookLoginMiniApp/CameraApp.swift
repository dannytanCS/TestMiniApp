//
//  CameraApp.swift
//  FacebookLoginMiniApp
//
//  Created by Danny Tan on 7/5/16.
//  Copyright © 2016 Danny Tan. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseStorage
import FirebaseAuth



class CamViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var captureSession: AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var user = FIRAuth.auth()?.currentUser
    
    @IBOutlet weak var nextScreenButton: UIButton!
    @IBOutlet var takePictureButton: UIView!
    @IBOutlet weak var ImageView: UIImageView!
    @IBAction func chooseFromLibrary(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker,animated: true, completion:nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://facebooklogin-50952.appspot.com")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://facebooklogin-50952.appspot.com")
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        ImageView.image = image
        
        let imageName = NSUUID().UUIDString
        let profilePicRef = storageRef.child(self.user!.uid+"/\(imageName).jpg")
        self.captureSession?.stopRunning()
        self.nextScreenButton.hidden = false
        if let uploadData = UIImageJPEGRepresentation(image!, 0){
            profilePicRef.putData(uploadData, metadata: nil, completion: { (meta, error) in
                if error != nil {
                    print (error)
                }
            })
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame  = ImageView.bounds
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
            var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            
            var error: NSError?
            var input = AVCaptureDeviceInput()
            do {
                input = try AVCaptureDeviceInput(device: backCamera)
                if error == nil && (captureSession?.canAddInput(input))!{
                    captureSession?.addInput(input)
                    
                    stillImageOutput = AVCaptureStillImageOutput()
                    stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                    
                    if captureSession!.canAddOutput(stillImageOutput){
                        captureSession?.addOutput(stillImageOutput)
                        
                        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                        previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                        ImageView.layer.addSublayer(previewLayer!)
                        captureSession?.startRunning()
                    }
                }
                
            } catch {
                print (error)
            }
        }
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://cameraapp-26c67.appspot.com")
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                    //images we want to store
                    var image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: .Right)
                    self.ImageView.image = image
                    let imageName = NSUUID().UUIDString
                    let profilePicRef = storageRef.child(self.user!.uid+"/\(imageName).jpg")
                    self.captureSession?.stopRunning()
                    self.nextScreenButton.hidden = false
                    if let uploadData = UIImageJPEGRepresentation(image, 0){
                        profilePicRef.putData(uploadData, metadata: nil, completion: { (meta, error) in
                            if error != nil {
                                print (error)
                            }
                        })
                    }
                }
            })
        }
        
    }
    @IBAction func nextScreen(sender: AnyObject) {
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
