//
//  ViewController.swift
//  Pods
//
//  Created by Kyle Van Essen on 4/4/20.
//

import UIKit


protocol LayerRootViewController : LayerViewController {
    var layers : LayerRootPresenter { get }
}

final class LayerRootPresenter {
    
}

protocol LayerViewController : UIViewController {
    var layers : LayerPresenter { get }
}

final class LayerPresenter {
            
    var children : [UIViewController] {
        get { _children }
        set { self.set(children: newValue, animated: false) }
    }
    
    func present(_ viewController : UIViewController, animated : Bool = false, completion : () -> () = {})
    {
        self.set(
            children: self.children + [viewController],
            animated: animated,
            completion: completion
        )
    }
    
    func dismiss(_ viewController : UIViewController, animated : Bool = false, completion : () -> () = {})
    {
        var new = self.children
        
        if let index = self.children.firstIndex(of: viewController) {
            new.remove(at: index)
        }
        
        self.set(
            children: new,
            animated: animated,
            completion: completion
        )
    }
    
    func set(children : [UIViewController], animated : Bool = false, completion : () -> () = {})
    {
        guard self.children != children else {
            completion()
            return
        }
        
        _children = children
    }
    
    private var _children : [UIViewController] = []
}

extension UIViewController {
        
    fileprivate func recurseAll(using block : (UIViewController) -> ()) {
        block(self)
        
        for child in self.children {
            child.recurseAll(using: block)
        }
    }
    
    func toFlattenedLayers() -> [UIViewController] {
        
        var viewControllers = [UIViewController]()
        
        self.flattenedSelf(into: &viewControllers)
        self.flattenedChildren(into: &viewControllers)
        
        return viewControllers
    }
    
    private func flattenedSelf(into viewControllers : inout [UIViewController])
    {
        viewControllers.append(self)
    }
    
    private func flattenedChildren(into viewControllers : inout [UIViewController])
    {
        if let self = self as? LayerViewController {
            self.layers.children.forEach { $0.flattenedSelf(into: &viewControllers) }
            self.layers.children.forEach { $0.flattenedChildren(into: &viewControllers) }
        }
    }
}









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
        var children : [Node]
        
        init<ViewControllerType:UIViewController>(
            provider : @escaping () -> ViewControllerContainer<ViewControllerType>,
            children : [Node]
        ) {
            self.viewControllerType = ViewControllerType.self
            
            self.provider = provider
            self.children = children
        }
        
        func toIdentified(with depth : Int = 0) -> IdentifiedViewControllerTree.Node {
            .init(
                provider: self.provider,
                viewControllerType: self.viewControllerType,
                identifier: .init(
                    viewControllerType: self.viewControllerType,
                    depth: depth
                ),
                children: self.children.map { $0.toIdentified(with: depth + 1) }
            )
        }
    }
}

struct IdentifiedViewControllerTree {
    
    var root : Node
    
    struct Node {
        var provider : () -> AnyViewControllerContainer
        var viewControllerType : UIViewController.Type
        var identifier : Identifier
        var children : [Node]
        
        func flattened() -> [FlatNode] {
            var flattened = [FlatNode]()
            
            self.flattenSelf(into: &flattened)
            self.flattenChildren(into: &flattened)
            
            return flattened
        }
        
        private func flattenSelf(into flattened : inout [FlatNode]) {
            
            flattened.append(FlatNode(
                provider: self.provider,
                viewControllerType: self.viewControllerType,
                identifier: self.identifier
            ))
        }
        
        private func flattenChildren(into flattened : inout [FlatNode]) {
            
            for child in self.children {
                child.flattenSelf(into: &flattened)
            }
            
            for child in self.children {
                child.flattenChildren(into: &flattened)
            }
        }
    }
    
    struct FlatNode {
        var provider : () -> AnyViewControllerContainer
        var viewControllerType : UIViewController.Type
        var identifier : Identifier
    }
    
    struct Identifier {
        var viewControllerType : UIViewController.Type
        var depth : Int
    }
}
