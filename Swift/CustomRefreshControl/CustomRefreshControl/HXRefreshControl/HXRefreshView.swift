//
//  HXRefreshView.swift
//  CustomRefreshControl
//
//  Created by huangxu on 2017/8/30.
//  Copyright © 2017年 huangxu. All rights reserved.
//

import UIKit

class HXRefreshView: UIView {

    /// 指示器
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    /// 箭头
    @IBOutlet weak var arrowImageView: UIImageView?
    /// 提示标签
    @IBOutlet weak var tipLabel: UILabel?
    /// 父视图高度
    var parentViewHeight: CGFloat = 0
  
    class var refreshView: HXRefreshView {
        // HXRefreshView  HXMeituanRefreshView
        let nib = UINib(nibName: "HXMeituanRefreshView", bundle: nil)
        let refreshView = nib.instantiate(withOwner: nil, options: nil)[0] as! HXRefreshView
        refreshView.refreshState = .normal
        return refreshView
    }
    
    var refreshState: HXRefreshState = .normal {
        didSet {
            switch refreshState {
            case .normal:
                tipLabel?.text = "继续使劲拉"
                UIView.animate(withDuration: 0.25, animations: { 
                    self.arrowImageView?.transform = CGAffineTransform.identity
                })
                arrowImageView?.isHidden = false
                indicator?.stopAnimating()
            case .pulling:
                tipLabel?.text = "放手就刷新"
                UIView.animate(withDuration: 0.25, animations: {
                    self.arrowImageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi - 0.01))
                })
                
            case .refreshing:
                tipLabel?.text = "刷新中..."
                arrowImageView?.isHidden = true
                indicator?.startAnimating()
            }
        }
    }
    
}
