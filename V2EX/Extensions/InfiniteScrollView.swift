//
//  InfiniteScrollView.swift
//  V2EX
//
//  Created by wgh on 2017/3/15.
//  Copyright © 2017年 wgh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    var showsInfiniteScrolling: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, show in
      
           view.showsInfiniteScrolling = show
        }
    }
}

private let infiniteScrollingViewHeight: CGFloat = 60

extension UIScrollView {
    private struct AssociatedKeys {
        static let infiniteScrollingViewKey = UnsafeRawPointer(bitPattern: "infiniteKey".hashValue)!
    }
    
    func addInfiniteScrolling(_ actionHandler: (() -> Void)?) {
        if let infiniteScrollingView = infiniteScrollingView {
            infiniteScrollingView.infiniteScrollingHandler = actionHandler
        }else {
            let view = InfiniteScrollingView(frame: CGRect(x: 0, y: contentSize.height, width: bounds.width, height: infiniteScrollingViewHeight))
            view.infiniteScrollingHandler = actionHandler
            addSubview(view)
            
            view.originalBottomInset = contentInset.bottom
            infiniteScrollingView = view
            showsInfiniteScrolling = true
            view.resetScrollViewContentInset()
        }
    }
    
    var infiniteScrollingView: InfiniteScrollingView? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.infiniteScrollingViewKey) as? InfiniteScrollingView
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, AssociatedKeys.infiniteScrollingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var showsInfiniteScrolling: Bool {
        get {
            guard let infiniteView = infiniteScrollingView else {
                return false
            }
            return !infiniteView.isHidden
        }
        set {
            guard let infiniteView = infiniteScrollingView else {
                return
            }
            infiniteView.isHidden = !newValue
            if !newValue {
                if infiniteView.isObserving {
                    removeObserver(infiniteView, forKeyPath: "contentOffset")
                    removeObserver(infiniteView, forKeyPath: "contentSize")
                    panGestureRecognizer.removeTarget(infiniteView, action: #selector(infiniteView.scrollViewPanGestureUpdate(_:)))
                    infiniteView.resetScrollViewContentInset()
                    infiniteView.isObserving = false
                    infiniteView.enabled = false
                }
            }else {
                if !infiniteView.isObserving {
                    infiniteView.enabled = true
                    addObserver(infiniteView, forKeyPath: "contentOffset", options: .new, context: nil)
                    addObserver(infiniteView, forKeyPath: "contentSize", options: .new, context: nil)
                    panGestureRecognizer.addTarget(infiniteView, action: #selector(infiniteView.scrollViewPanGestureUpdate(_:)))
                    infiniteView.setScrollViewContentInsetForInfiniteScrolling()
                    infiniteView.isObserving = true
                    
                    infiniteView.frame = CGRect(x: 0, y: contentSize.height, width: infiniteView.bounds.width, height: infiniteScrollingViewHeight)
                    infiniteView.layoutIfNeeded()
                }
            }
        }
    }
}

enum InfiniteScrollingState {
    case stopped, triggered, loading, all
}

class InfiniteScrollingView: UIView {
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        return view
    }()
    
    fileprivate var isObserving: Bool = false
    fileprivate var originalBottomInset: CGFloat = 0
    
    var enabled: Bool = false
    var infiniteScrollingHandler: (() -> Void)?
    
    var state: InfiniteScrollingState = .stopped {
        willSet {
            if newValue != state {
                let previousState = state
                switch newValue {
                case .stopped:
                    resetScrollViewContentInset()
                    activityIndicatorView.stopAnimating()
                case .triggered:
                    setScrollViewContentInsetForInfiniteScrolling()
                    activityIndicatorView.startAnimating()
                case .loading:
                    activityIndicatorView.startAnimating()
                default:
                    break
                }

                if previousState == .triggered && newValue == .loading && enabled {
                    infiniteScrollingHandler?()
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func triggerRefresh() {
        state = .triggered
        state = .loading
    }
    
    func startAnimating() {
        state = .loading
    }
    
    func stopAnimating() {
        state = .stopped
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if let scrollView = superview as? UIScrollView, newSuperview == nil {
            if scrollView.showsInfiniteScrolling && isObserving {
                scrollView.removeObserver(self, forKeyPath: "contentOffset")
                scrollView.removeObserver(self, forKeyPath: "contentSize")
                scrollView.panGestureRecognizer.removeTarget(self, action: #selector(scrollViewPanGestureUpdate(_:)))
                isObserving = false
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let newPoint = change?[.newKey] as? CGPoint, newPoint.y >= 0 {
                scrollViewDidScroll(newPoint)
            }
        }else if keyPath == "contentSize" {
            guard let scrollView = object as? UIScrollView else { return }
            self.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: bounds.width, height: infiniteScrollingViewHeight)
            layoutIfNeeded()
        }
    }
    
    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        guard let scrollView = superview as? UIScrollView else { return }
        if state != .loading && enabled {
            let scrollOffsetThreshold = scrollView.contentSize.height - scrollView.bounds.height
            let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
            
            if yVelocity < 0 && contentOffset.y > scrollOffsetThreshold && state == .stopped && scrollView.isDragging  {
                state = .triggered
            }else if contentOffset.y < scrollOffsetThreshold && state != .stopped {
                state = .stopped
            }
        }
    }
    
    func scrollViewPanGestureUpdate(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended && state == .triggered {
            state = .loading
        }
    }
    
    func resetScrollViewContentInset() {
        guard let scrollView = superview as? UIScrollView else { return }
        var currentInsets = scrollView.contentInset
        currentInsets.bottom = originalBottomInset
        setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        guard let scrollView = superview as? UIScrollView else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            scrollView.contentInset = contentInset
        }, completion: nil)
    }
    
    func setScrollViewContentInsetForInfiniteScrolling() {
        guard let scrollView = superview as? UIScrollView else { return }
        var currentInsets = scrollView.contentInset
        currentInsets.bottom = originalBottomInset + infiniteScrollingViewHeight
        setScrollViewContentInset(currentInsets)
    }
}
