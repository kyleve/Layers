//
//  Tests.swift
//  Pods
//
//  Created by Kyle Van Essen on 4/4/20.
//

import XCTest
@testable import Layers


final class Tests : XCTestCase {
    
    func test_tree() {
        let tree = ViewControllerTree(
            root: .init(provider: {
                .init(
                    presentationStyle: .init(positioning: .relativeToWindow),
                    viewController: VC_A()
                )
            }, child: .child(.init(
                provider: {
                    .init(
                        presentationStyle: .init(positioning: .relativeToWindow),
                        viewController: VC_B()
                    )
            }, child: .child(.init(
                provider: {
                    .init(
                        presentationStyle: .init(positioning: .relativeToWindow),
                        viewController: VC_C()
                    )
            }, child: .child(.init(
                provider: {
                    .init(
                        presentationStyle: .init(positioning: .relativeToWindow),
                        viewController: VC_D()
                    )
            }, child: .none))))))
            )
        )
        
        let identified = tree.root.toIdentified()
        
        print(identified)
    }
}


fileprivate final class VC_A : UIViewController {}
fileprivate final class VC_B : UIViewController {}
fileprivate final class VC_C : UIViewController {}
fileprivate final class VC_D : UIViewController {}
fileprivate final class VC_E : UIViewController {}
