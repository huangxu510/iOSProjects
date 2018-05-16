//
//  HXMeituanRefreshView.swift
//  CustomRefreshControl
//
//  Created by huangxu on 2017/9/3.
//  Copyright © 2017年 huangxu. All rights reserved.
//

import UIKit

class HXMeituanRefreshView: HXRefreshView {

    @IBOutlet weak var buildingImageView: UIImageView!
   
    @IBOutlet weak var earthImageView: UIImageView!

    @IBOutlet weak var kangarooImageView: UIImageView!
    
    override var parentViewHeight: CGFloat {
        didSet {
            print("父视图高度  \(parentViewHeight)")
            
            // 调整袋鼠大小
            if parentViewHeight < 23 {
                return
            }
            
            var scale: CGFloat
            scale = 0.8 / (126 - 23) * (parentViewHeight - 23) + 0.2
            scale = min(scale, 1)
            kangarooImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. 房子动画
        let buidingImage1 = #imageLiteral(resourceName: "icon_building_loading_1")
        let buidingImage2 = #imageLiteral(resourceName: "icon_building_loading_2")
        buildingImageView.image = UIImage.animatedImage(with: [buidingImage1, buidingImage2], duration: 0.5)
        
        // 2. 地球
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = -2 * Double.pi
        animation.repeatCount = MAXFLOAT
        animation.duration = 3
        animation.isRemovedOnCompletion = false
//        animation.fillMode = kCAFillModeForwards
        earthImageView.layer.add(animation, forKey: nil)
        
        // 3. 袋鼠
        let kImage1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1")
        let kImage2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2")
        kangarooImageView.image = UIImage.animatedImage(with: [kImage1, kImage2], duration: 0.5)
        
        kangarooImageView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        // 设置锚点
        kangarooImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        // 设置 center
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 23
        kangarooImageView.center = CGPoint(x: x, y: y)
    }
}
