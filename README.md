# DXIDCardCameraDemo

![front](https://github.com/dongxiexidu/DXIDCardCameraDemo/blob/master/front.jpg)

![reverse](https://github.com/dongxiexidu/DXIDCardCameraDemo/blob/master/reverse.jpg)

# Sample Code

```
// 身份证正面
@IBAction func frontClick(_ sender: Any) {
    let vc = DXIDCardCameraController.init(type: DXIDCardType.front)
    vc.delegate = self
    self.present(vc, animated: true, completion: nil)
}

// 身份证反面
@IBAction func reverseClick(_ sender: Any) {
    let vc = DXIDCardCameraController.init(type: DXIDCardType.reverse)
    vc.delegate = self
    self.present(vc, animated: true, completion: nil)
}


extension ViewController : DXIDCardCameraControllerProtocol {
    func cameraDidFinishShootWithCameraImage(image: UIImage) {
        self.imageView.image = image
    }
}
```


