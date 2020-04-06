//
//  Tests.swift
//  Pods
//
//  Created by Kyle Van Essen on 4/4/20.
//

import XCTest
@testable import Layers


final class Tests : XCTestCase {
    
    func test_viewControllers()
    {
        let root = RootViewController()
        
        let child = ChildViewController(children: [
            ChildViewController(children: [
                ChildViewController(),
                ChildViewController(),
            ]),
            ChildViewController(children: [
                ChildViewController(),
            ]),
            ChildViewController(),
        ])
        
        root.layers.presenter.children = [child]
        
        print(root.toFlattenedLayers())
    }
    
    func test_tree() {
        let tree = ViewControllerTree(
            root: .init(
                provider: {
                    .init(presentationStyle: .init(positioning: .relativeToWindow), viewController: VC_A())
            }, children: [
                .init(
                    provider: {
                        .init(presentationStyle: .init(positioning: .relativeToWindow), viewController: VC_B())
                }, children: [
                    .init(
                        provider: {
                            .init(presentationStyle: .init(positioning: .relativeToWindow), viewController: VC_C())
                    }, children: []
                    ),
                    .init(
                        provider: {
                            .init(presentationStyle: .init(positioning: .relativeToWindow), viewController: VC_C())
                    }, children: []
                    )
                    ]
                ),
                .init(
                    provider: {
                        .init(presentationStyle: .init(positioning: .relativeToWindow), viewController: VC_B())
                }, children: [
                    .init(
                        provider: {
                            .init(presentationStyle: .init(positioning: .relativeToWindow), viewController: VC_D())
                    }, children: []
                    ),
                    .init(
                        provider: {
                            .init(presentationStyle: .init(positioning: .relativeToWindow), viewController: VC_D())
                    }, children: []
                    )
                    ]
                )
                ]
            )
        )
        
        let identified = tree.root.toIdentified()
        
        print(identified)
    }
}

fileprivate final class RootViewController : UIViewController, LayersRootViewController {
    var layers: LayersRootPresenter = LayersRootPresenter()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.layers.host = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

fileprivate final class ChildViewController : UIViewController, LayerViewController {
    var layers: LayerPresenter = LayerPresenter()

    init(children : [UIViewController] = []) {
        self.layers.children = children
        
        super.init(nibName: nil, bundle: nil)
        
        self.layers.viewController = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
}


fileprivate final class VC_A : UIViewController {}
fileprivate final class VC_B : UIViewController {}
fileprivate final class VC_C : UIViewController {}
fileprivate final class VC_D : UIViewController {}
fileprivate final class VC_E : UIViewController {}
