//
//  ViewController.swift
//  Pods
//
//  Created by Kyle Van Essen on 4/4/20.
//

import UIKit

final class Container {
    
    var root : ViewController? {
        didSet {
            guard self.root !== oldValue else {
                return
            }
        }
    }
    
    let host : UIViewController
    
    init(root : ViewController? = nil, host : UIViewController) {
        self.root = root
        self.host = host
    }
    
    private func updateRoot(from : ViewController?, to : ViewController?) {
        
    }
}


final class ViewController {
    
    var presentationStyle : PresentationStyle
    
    var viewController : UIViewController
    
    var child : ViewController?
}


struct PresentationStyle {
    
    var positioning : Positioning {
        didSet {
            // TODO
        }
    }
    
    /// Used to occlude any views behind the view controller, for performance in deep hierarchies.
    var isFullScreen : Bool = false
    
    enum Positioning {
        case relativeToWindow
        case relativeToPosition(PositionProvider)
    }
}

final class PositionProvider {
    
    var provider : () -> (UICoordinateSpace, CGPoint)
    
    func setNeedsUpdate() {
        self.setNeededUpdate?(self)
    }
    
    init(provider : @escaping () -> (UICoordinateSpace, CGPoint)) {
        self.provider = provider
    }
    
    var setNeededUpdate : ((PositionProvider) -> ())? = nil
}
