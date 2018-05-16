//
//  HXRefreshControl.swift
//  CustomRefreshControl
//
//  Created by huangxu on 2017/8/30.
//  Copyright © 2017年 huangxu. All rights reserved.
//

import UIKit

private let kRefreshOffset: CGFloat = 126


/// 刷新状态
enum HXRefreshState {
    /// 普通状态
    case normal
    /// 超过临界点，如果放手，开始刷新
    case pulling
    /// 刷新中
    case refreshing
}

class HXRefreshControl: UIControl {
    
    
    var scrollView: UIScrollView?
    /// 刷新视图
    fileprivate lazy var refreshView = HXRefreshView.refreshView
    
    init() {
        super.init(frame: CGRect())
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    /// 添加到父视图时
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        self.scrollView = scrollView
        // KVO监听scrollView 的 contentOffset
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    override func removeFromSuperview() {
        // 移除KVO
        super.removeObserver(self, forKeyPath: "contentOffset")
        
        super.removeFromSuperview()
    }
    
    // KVO监听 contentOffset属性的变化
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = scrollView else {
            return
        }
        

        let height = -(scrollView.contentInset.top + scrollView.contentOffset.y)
        if height < 0 {
            return
        }
        
        frame = CGRect(x: 0, y: -height, width: scrollView.bounds.width, height: height)
        
        if refreshView.refreshState != .refreshing {
            refreshView.parentViewHeight = height
        }

        if scrollView.isDragging {
            if height > kRefreshOffset && refreshView.refreshState == .normal {
                print("放手开始刷新")
                refreshView.refreshState = .pulling
                
            } else if height <= kRefreshOffset && refreshView.refreshState == .pulling {
                print("使劲再使劲")
                refreshView.refreshState = .normal
            }
        } else {
            if refreshView.refreshState == .pulling {
                print("开始刷新")
                beginRefreshing()
                
                // 发送valueChanged事件
                sendActions(for: .valueChanged)
            } 
        }
    }

    
    /// 开始刷新
    func beginRefreshing() {
        
        guard let scrollView = scrollView else {
            return
        }
        
        if refreshView.refreshState == .refreshing {
            return
        }
        // 改变状态
        refreshView.refreshState = .refreshing
        
        refreshView.parentViewHeight = kRefreshOffset
        
        // 调整scrollView的contentInset
        var contentInset = scrollView.contentInset
        contentInset.top += kRefreshOffset
        scrollView.contentInset = contentInset
    }
    
    
    /// 结束刷新
    func endRefreshing() {
        
        guard let scrollView = scrollView else {
            return
        }
        
        // 如果不是正在刷新的状态直接返回
        if refreshView.refreshState != .refreshing {
            return
        }
        // 改变状态
        refreshView.refreshState = .normal
        
        // 活肤scrollView的contentInset
        var contentInset = scrollView.contentInset
        contentInset.top -= kRefreshOffset
        UIView.animate(withDuration: 0.25) {
            scrollView.contentInset = contentInset
        }
        
    }
}

extension HXRefreshControl {
    
    fileprivate func setupUI() {
        
        self.addSubview(refreshView)
        
        // 自动布局
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.width))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.height))
    }
}
