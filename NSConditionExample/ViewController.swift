//
//  ViewController.swift
//  NSConditionExample
//
//  Created by Pankaj Kulkarni on 15/05/20.
//  Copyright © 2020 Pankaj Kulkarni. All rights reserved.
//

import UIKit

class LMSemaphore: Equatable {
    static func == (lhs: LMSemaphore, rhs: LMSemaphore) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    let uuid = UUID()
    let nsCondition = NSCondition()
    var doneCondition = false
}

class ViewController: UIViewController {
    
    var semaphores = [LMSemaphore]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }



    func method1() {
        
        guard semaphores.count < 5 else {
            print("To many calls...")
            return
        }
        
        let semaphore = LMSemaphore()
        self.semaphores.append(semaphore)
        print("STARTING METHOD 1 - \(semaphore.uuid)")

//        print("WILL LOCK METHOD 1")
//        myCondition.lock()
//        print("DID LOCK METHOD 1")

//        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
//            self.method2(uuid: semaphore.uuid)
//        }
        method2(uuid: semaphore.uuid)
        
        while (!semaphore.doneCondition) {
            print("WILL WAIT METHOD 1 - \(semaphore.uuid)")
            semaphore.nsCondition.wait()
            print("DID WAIT METHOD 1 - \(semaphore.uuid)")
        }

        print("WILL UNLOCK METHOD 1 - \(semaphore.uuid)")
        semaphore.nsCondition.unlock()
        print("DID UNLOCK METHOD 1 - \(semaphore.uuid)")
        
        if let index = self.semaphores.firstIndex(where: { (item) -> Bool in
            return item == semaphore
        }) {
            self.semaphores.remove(at: index)
        }
        print("ENDING METHOD 1 - \(semaphore.uuid)")
    }

    func method2(uuid: UUID) {
        
        guard let semaphore = semaphores.first(where: { (item) -> Bool in
            return item.uuid == uuid
        }) else {
            return
        }
        
        print("STARTING METHOD 2 - \(semaphore.uuid)")
        let delay = Double.random(in: 2...5)
        print("DELAY: \(delay)")
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) {
            
            semaphore.doneCondition = true
            
            print("WILL SIGNAL FROM METHOD 2 - \(semaphore.uuid)")
            semaphore.nsCondition.signal()
            print("DID SIGNAL FROM METHOD 2 - \(semaphore.uuid)")
        }

        print("ENDING METHOD 2 - \(semaphore.uuid)")
    }

    
    @IBAction func demoPressed(_ sender: UIButton) {
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.method1()
        }

    }
    
    
}

