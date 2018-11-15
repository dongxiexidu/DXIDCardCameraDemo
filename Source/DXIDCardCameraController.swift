//
//  DXIDCardCameraController.swift
//  DXIDCardCameraDemo
//
//  Created by fashion on 2018/11/14.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit
import Photos

public enum DXIDCardType {
    case front
    case reverse
}

protocol DXIDCardCameraControllerProtocol {
    func cameraDidFinishShootWithCameraImage(image: UIImage)
}

class DXIDCardCameraController: UIViewController {
    
    fileprivate var isFlashOn : Bool = false
    fileprivate var type = DXIDCardType.front
    fileprivate var imageView : UIImageView?
    
    fileprivate var image : UIImage?
    public var delegate : DXIDCardCameraControllerProtocol!
    
    
    convenience init(type: DXIDCardType) {
        self.init()
        self.type = type
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        if isCanUseCamera() == true {
            setupCamera()
            configureUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let bounds = UIScreen.main.bounds
        let point = CGPoint.init(x: bounds.width/2, y: bounds.height/2)
        focusAtPoint(point: point)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }

    override var shouldAutorotate: Bool{
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UIInterfaceOrientation.portrait
    }
    

    // MARK: getters and setters
    lazy var device: AVCaptureDevice? = {
        let d = AVCaptureDevice.default(for: AVMediaType.video)
        return d
    }()

    lazy var imageOutput: AVCaptureStillImageOutput = {
        let d = AVCaptureStillImageOutput.init()
        return d
    }()

    lazy var session: AVCaptureSession = {
        let s = AVCaptureSession.init()
        return s
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let p = AVCaptureVideoPreviewLayer.init(session: session)
        p.frame = UIScreen.main.bounds
        p.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return p
    }()
    
    lazy var floatingView: DXIDCardFloatingView = {
        let v = DXIDCardFloatingView.init(type: self.type)
        v.frame = view.bounds
        return v
    }()
   
    lazy var photoButton: UIButton = {
        let b = UIButton.init(type: UIButton.ButtonType.custom)
        b.setImage(UIImage.init(contentsOfFile: resouceBundle.path(forResource: "photo@2x", ofType: "png")!), for: UIControl.State.normal)
         b.setImage(UIImage.init(contentsOfFile: resouceBundle.path(forResource: "photo@3x", ofType: "png")!), for: UIControl.State.normal)
        b.addTarget(self, action: #selector(shutterCamera(btn:)), for: UIControl.Event.touchUpInside)
        b.frame = CGRect.init(x: (kScreenW-60)/2, y: kScreenH-60-40, width: 60, height: 60)
        
        return b
    }()
    
    lazy var cancleButton: UIButton = {
        let b = UIButton.init(type: UIButton.ButtonType.custom)
        b.setImage(UIImage.init(contentsOfFile: resouceBundle.path(forResource: "closeButton", ofType: "png")!), for: UIControl.State.normal)
        b.addTarget(self, action: #selector(cancleButtonAction(btn:)), for: UIControl.Event.touchUpInside)
        b.frame = CGRect.init(x: 32, y: kScreenH-45-40, width: 45, height: 45)

        return b
    }()
    
    lazy var flashButton: UIButton = {
        let b = UIButton.init(type: UIButton.ButtonType.custom)
        b.setImage(UIImage.init(contentsOfFile: resouceBundle.path(forResource: "cameraFlash", ofType: "png")!), for: UIControl.State.normal)
        b.addTarget(self, action: #selector(flashOn(btn:)), for: UIControl.Event.touchUpInside)
        b.frame = CGRect.init(x: kScreenW-45-32, y: kScreenH-45-40, width: 45, height: 45)
        return b
    }()
    
    lazy var bottomView: UIView = {
        let b = UIView.init()
        b.backgroundColor = UIColor.init(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
        b.isHidden = true
        b.frame = CGRect.init(x: 0, y: kScreenH-64, width: kScreenW, height: 64)
        do /**重拍**/ {
            let againBtn = UIButton.init(type: UIButton.ButtonType.custom)
            againBtn.setTitle("重拍", for: UIControl.State.normal)
            againBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            againBtn.addTarget(self, action: #selector(takePhotoAgain), for: UIControl.Event.touchUpInside)
            againBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            againBtn.titleLabel?.textAlignment = .center
            againBtn.frame = CGRect.init(x: 12, y: 0, width: 64, height: 64)
            b.addSubview(againBtn)
        }
        do /**使用照片**/ {
            let againBtn = UIButton.init(type: UIButton.ButtonType.custom)
            againBtn.setTitle("使用照片", for: UIControl.State.normal)
            againBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            againBtn.addTarget(self, action: #selector(usePhoto), for: UIControl.Event.touchUpInside)
            againBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            againBtn.titleLabel?.textAlignment = .center
            againBtn.frame = CGRect.init(x: kScreenW-100, y: 0, width: 100, height: 64)
            b.addSubview(againBtn)
        }

        return b
    }()
    
    lazy var resouceBundle: Bundle = {
        let path = Bundle.init(for: self.classForCoder).path(forResource: "DXIDCardCamera", ofType: "bundle")
        let bundle = Bundle.init(path: path!)
        return bundle!
    }()
}

extension DXIDCardCameraController {
    
    @objc private func focusAtPoint(point : CGPoint) {
        let size = view.bounds.size
        let focusPoint = CGPoint.init(x: point.y/size.height, y: 1-point.x/size.width)
        if let device = device {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                // exposure : 暴露
                if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose){
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .autoExpose
                }
                device.unlockForConfiguration()
            } catch let error {
                print(error)
            }
            
            
        }
        
    }
    // 点击聚焦
    @objc private func focusGesture(gesture : UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        focusAtPoint(point: point)
    }
    @objc private func subjectAreaDidChange(notification: Notification) {
        //先进行判断是否支持控制对焦
        if let device = device,device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
            //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
            do {
                try device.lockForConfiguration()
                device.focusMode = .autoFocus
                let bounds = UIScreen.main.bounds
                let point = CGPoint.init(x: bounds.width/2, y: bounds.height/2)
                focusAtPoint(point: point)
                //操作完成后，记得进行unlock
                device.unlockForConfiguration()
            } catch let error as NSError   {
                print(error)
            }
        }
    }
    // MARK:使用照片
    @objc private func usePhoto() {
        
        if let cgImg = image?.cgImage { // 修改图片方向
            let newImg = UIImage.init(cgImage: cgImg, scale: 1.0, orientation: UIImage.Orientation.up)
            // (726.0, 462.0)
            print(newImg.size)
            guard let d = delegate else{
                fatalError("delegate cannot be nil")
            }
            d.cameraDidFinishShootWithCameraImage(image: newImg)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func takePhotoAgain() {
        session.startRunning()
        imageView?.removeFromSuperview()
        imageView = nil
        
        cancleButton.isHidden = false
        flashButton.isHidden = false
        photoButton.isHidden = false
        bottomView.isHidden = true
    }
    @objc private func cancleButtonAction(btn : UIButton) {
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: 拍照
    @objc private func shutterCamera(btn : UIButton) {
        
        if let videoConnection = self.imageOutput.connection(with: AVMediaType.video) {
            self.imageOutput.captureStillImageAsynchronously(from: videoConnection) {[weak self] (imageDataSampleBuffer, error) in
                guard let self = self else {return }
                
                guard let imageDataSampleBuffer = imageDataSampleBuffer else{ return }
                guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) else{ return }
                guard let img = UIImage.init(data: imageData) else{ return }
                guard let clipImage = img.dx_clipImageInRect(rect: self.floatingView.IDCardWindowLayer.frame) else{ return }
                self.image = clipImage
                self.session.stopRunning()
                
                self.imageView = UIImageView.init(frame: self.floatingView.IDCardWindowLayer.frame)
                self.view.insertSubview(self.imageView!, belowSubview: btn)
                self.imageView?.layer.masksToBounds = true
                self.imageView?.image = clipImage
                // 隐藏切换取消闪光灯按钮
                self.cancleButton.isHidden = true
                self.flashButton.isHidden = true
                self.photoButton.isHidden = true
                self.bottomView.isHidden = false
               
            }
  
        }else{
            print("拍照失败!")
            return
        }
    }
    
    // MARK::闪光灯
    @objc private func flashOn(btn : UIButton) {
        if let device = device {
            if device.hasTorch {
                do {// 请求独占访问硬件设备
                    try device.lockForConfiguration()
                    if (isFlashOn == false) {
                        device.torchMode = AVCaptureDevice.TorchMode.on
                        isFlashOn = true
                    } else {
                        device.torchMode = AVCaptureDevice.TorchMode.off
                        isFlashOn = false
                    }// 请求解除独占访问硬件设备
                    device.unlockForConfiguration()
                } catch let error as NSError {
                    print("TorchError  \(error)")
                }
                
            }else{
                let alert = UIAlertController.init(title: "提示", message: "您的设备没有闪光设备，不能提供手电筒功能，请检查", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: false, completion: nil)
            }
        }
        
    }
    
    private func configureUI() {
        
        view.addSubview(photoButton)
        view.addSubview(cancleButton)
        view.addSubview(flashButton)
        view.addSubview(bottomView)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(focusGesture(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange(notification:)), name: Notification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }
    
    private func setupCamera() {
        if session.canSetSessionPreset(AVCaptureSession.Preset.hd1280x720) {
            session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        if let device = device {
            do {
                try device.lockForConfiguration()
                let input = try? AVCaptureDeviceInput.init(device: device)
                
                if let i = input, session.canAddInput(i) {
                    session.addInput(i)
                }
                device.unlockForConfiguration()
            } catch let error {
                print(error)
            }
        }

        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }
        // 使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
        view.layer.addSublayer(previewLayer)
        // 开始启动
        session.startRunning()
        if let device = device {
            do {
                try device.lockForConfiguration()
                if device.isFlashModeSupported(AVCaptureDevice.FlashMode.auto) {
                    device.flashMode = .auto
                }
                // exposure : 暴露
                if device.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance){
                    device.whiteBalanceMode = .autoWhiteBalance
                }
                device.unlockForConfiguration()
            } catch let error {
                print(error)
            }
        }
        view.addSubview(floatingView)
    }
    
   private func isCanUseCamera() -> Bool {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .restricted || authStatus == .denied {
            let alert = UIAlertController.init(title: "请打开相机权限", message: "请到设置中去允许应用访问您的相机: 设置-隐私-相机", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction.init(title: "不需要", style: UIAlertAction.Style.cancel, handler: nil)
            let okAction = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default) { (action) in
                let setUrl = URL.init(string: UIApplication.openSettingsURLString)
                if let url = setUrl, UIApplication.shared.canOpenURL(url) == true {
                    UIApplication.shared.openURL(url)
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.present(alert, animated: false, completion: nil)
            return false
            
        } else {
            return true
        }
    }
}
