//
//  UIImage+FixOrientation.swift
//  DXIDCardCameraDemo
//
//  Created by fashion on 2018/11/14.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

extension UIImage {
    
    
    public func dx_clipImageInRect(rect: CGRect) -> UIImage?{
       
        let widthScale: CGFloat = self.size.width / kScreenW
        let heightScale: CGFloat = self.size.height / kScreenH
        
        //其实是横屏的
        let originWidth: CGFloat = rect.size.width
        let originHeight: CGFloat = rect.size.height
        
        
        let x: CGFloat = (kScreenH - originHeight) * 0.5 * heightScale
        let y: CGFloat = (kScreenW - originWidth) * 0.5 * widthScale
        let width: CGFloat = originHeight * heightScale
        let height: CGFloat = originWidth * widthScale
        
        let r: CGRect = CGRect.init(x: x, y: y, width: width, height: height)
        if let cgImg = self.cgImage?.cropping(to: r) {
            return UIImage.init(cgImage: cgImg, scale: 1.0, orientation: UIImage.Orientation.right)
        }

        return nil
    }
    
//    // MARK: 修改图片方向
//   public func dx_fixImageOrotation(orientation: UIImage.Orientation) -> UIImage? {
//        var rotate: CGFloat = 0
//        var rect: CGRect!
//        var translateX: CGFloat = 0
//        var translateY: CGFloat = 0
//        var scaleX: CGFloat = 1.0
//        var scaleY: CGFloat = 1.0
//        
//        switch orientation {
//        case .left:
//            rotate = CGFloat.pi/2
//            rect = CGRect.init(x: 0, y: 0, width: self.size.height, height: self.size.width)
//            translateX = 0
//            translateY = -rect.size.width
//            scaleY = rect.size.width/rect.size.height
//            scaleX = rect.size.height/rect.size.width
//        case .right:
//            rotate = CGFloat.pi/2*3
//            rect = CGRect.init(x: 0, y: 0, width: self.size.height, height: self.size.width)
//            translateX = -rect.size.height
//            translateY = 0
//            scaleY = rect.size.width/rect.size.height
//            scaleX = rect.size.height/rect.size.width
//        case .down:
//            rotate = CGFloat.pi
//            rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
//            translateX = -rect.size.width
//            translateY = -rect.size.height
//        default:
//            rotate = 0.0
//            rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
//            translateX = 0
//            translateY = 0
//        }
//        
//        UIGraphicsBeginImageContext(rect.size)
//        let context = UIGraphicsGetCurrentContext()
//        
//        //做CTM变换
//        context?.translateBy(x: 0, y: rect.size.height)
//        context?.scaleBy(x: 1.0, y: -1.0)
//        context?.rotate(by: rotate)
//        context?.translateBy(x: translateX, y: translateY)
//        context?.scaleBy(x: scaleX, y: scaleY)
//        if let cgImg = self.cgImage {
//            context?.draw(cgImg, in: CGRect.init(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
//        }
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
    
}
