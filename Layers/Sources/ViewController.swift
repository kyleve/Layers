//
//  ViewController.swift
//  Pods
//
//  Created by Kyle Van Essen on 4/4/20.
//

import UIKit


final class ViewControllerContainer<ViewControllerType : UIViewController> : AnyViewControllerContainer {
    
    var presentationStyle : PresentationStyle
    
    var viewController : ViewControllerType
    
    var child : AnyViewControllerContainer?
    
    init(
        presentationStyle : PresentationStyle,
        viewController : ViewControllerType,
        child : AnyViewControllerContainer? = nil
    ) {
        self.presentationStyle = presentationStyle
        self.viewController = viewController
        self.child = child
    }
    
    // MARK: AnyViewControllerContainer
    
    var anyViewController : UIViewController {
        self.viewController
    }
    
    var anyViewControllerType : UIViewController.Type {
        ViewControllerType.self
    }
}

protocol AnyViewControllerContainer {
    var presentationStyle : PresentationStyle { get }
    
    var anyViewController : UIViewController { get }
    var anyViewControllerType : UIViewController.Type { get }
    
    var child : AnyViewControllerContainer? { get }
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


struct ViewControllerTree {
    
    var root : Node
    
    struct Node {
        var provider : () -> AnyViewControllerContainer
        var viewControllerType : UIViewController.Type
        var child : Child
        
        init<ViewControllerType:UIViewController>(
            provider : @escaping () -> ViewControllerContainer<ViewControllerType>,
            child : Child
        ) {
            self.viewControllerType = ViewControllerType.self
            
            self.provider = provider
            self.child = child
        }
        
        func toIdentified(with depth : Int = 0) -> IdentifiedViewControllerTree.Node {
            .init(
                provider: self.provider,
                viewControllerType: self.viewControllerType,
                identifier: .init(
                    viewControllerType: self.viewControllerType,
                    depth: depth
                ),
                child: self.child.node.flatMap { .child($0.toIdentified(with: depth + 1)) } ?? .none
            )
        }
    }
    
    indirect enum Child {
        case none
        case child(Node)
        
        var node : Node? {
            switch self {
            case .none: return nil
            case .child(let node): return node
            }
        }
    }
}

struct IdentifiedViewControllerTree {
    
    var root : Node
    
    struct Node {
        var provider : () -> AnyViewControllerContainer
        var viewControllerType : UIViewController.Type
        var identifier : Identifier
        var child : Child
        
        func flattened() -> [FlatNode] {
            var flattened = [FlatNode]()
            
            self.flatten(into: &flattened)
            
            return flattened
        }
        
        private func flatten(into flattened : inout [FlatNode]) {
            
            flattened.append(FlatNode(
                provider: self.provider,
                viewControllerType: self.viewControllerType,
                identifier: self.identifier
            ))
            
            if let child = self.child.node {
                child.flatten(into: &flattened)
            }
        }
    }
    
    struct FlatNode {
        var provider : () -> AnyViewControllerContainer
        var viewControllerType : UIViewController.Type
        var identifier : Identifier
    }
    
    indirect enum Child {
        case none
        case child(Node)
        
        var node : Node? {
            switch self {
            case .none: return nil
            case .child(let node): return node
            }
        }
    }
    
    struct Identifier {
        var viewControllerType : UIViewController.Type
        var depth : Int
    }
}
