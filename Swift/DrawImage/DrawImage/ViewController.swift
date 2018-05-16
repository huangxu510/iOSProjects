//
//  ViewController.swift
//  DrawImage
//
//  Created by huangxu on 2017/8/22.
//  Copyright © 2017年 huangxu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(), size: CGSize(width: 100, height: 100)))
        imageView.center = view.center
        view.addSubview(imageView)
        
        let image = UIImage(named: "apply")
        
        imageView.image =  optimizedImage(image: image!, size: imageView.frame.size, backgroundColor: UIColor.white) //#imageLiteral(resourceName: "apply.png")
        
    }
    
    func optimizedImage(image: UIImage, size: CGSize, backgroundColor: UIColor) -> UIImage? {
        
        let rect = CGRect(origin: CGPoint(), size: size)
        
        // 1.图像上下文 scale 屏幕分辨率 0默认为当前屏幕分辨率
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        // 背景颜色 
        backgroundColor.setFill()
        UIRectFill(rect)
        
        // 裁剪
        let path = UIBezierPath.init(ovalIn: rect)
        path.addClip()
        
        // 2.绘图
        image.draw(in: rect)
        
        // 3.绘制内切圆
        UIColor.darkGray.setStroke()
        path.lineWidth = 2
        path.stroke()
        
        
        // 4.获取结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5.关闭上下文
        UIGraphicsEndImageContext()
        
        return result
    }
}

