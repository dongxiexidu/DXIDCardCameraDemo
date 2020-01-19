//
//  ViewController.swift
//  DXIDCardCameraDemo
//
//  Created by fashion on 2018/11/14.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // 身份证正面
    @IBAction func frontClick(_ sender: Any) {
        let vc = DXIDCardCameraController.init(type: DXIDCardType.front)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // 身份证反面
    @IBAction func reverseClick(_ sender: Any) {
        let vc = DXIDCardCameraController.init(type: DXIDCardType.reverse)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}
extension ViewController : DXIDCardCameraControllerProtocol {
    func cameraDidFinishShootWithCameraImage(image: UIImage) {
        self.imageView.image = image
    }
}
