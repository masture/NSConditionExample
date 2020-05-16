//
//  ViewController.swift
//  NSConditionExample
//
//  Created by Pankaj Kulkarni on 15/05/20.
//  Copyright © 2020 Pankaj Kulkarni. All rights reserved.
//

import UIKit

var semaphoreCount = 1000

class LMSemaphore: Equatable {

    static func == (lhs: LMSemaphore, rhs: LMSemaphore) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    let uuid: Int
    let nsCondition = NSCondition()
    var doneCondition = false
    
    init() {
        semaphoreCount += 1
        uuid = semaphoreCount
    }
    
    
}

class ViewController: UIViewController {
    
    var semaphores = [LMSemaphore]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }



    func method1() {
        print("STARTING METHOD_1: Semaphore count: \(semaphores.count)")
        guard semaphores.count < 10 else {
            print("To many calls...")
            return
        }
        
        let semaphore = LMSemaphore()
        semaphore.nsCondition.lock()
        self.semaphores.append(semaphore)
        print("STARTING METHOD_1 - \(semaphore.uuid) : Semaphore count: \(semaphores.count)")
//        print("WILL LOCK METHOD 1")
//        myCondition.lock()
//        print("DID LOCK METHOD 1")

//        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
//            self.method2(uuid: semaphore.uuid)
//        }
        method2(uuid: semaphore.uuid)
        
        while (!semaphore.doneCondition) {
            print("WILL WAIT METHOD_1 - \(semaphore.uuid)")
            semaphore.nsCondition.wait()
            print("DID WAIT METHOD_1 - \(semaphore.uuid)")
        }

        if let index = self.semaphores.firstIndex(where: { (item) -> Bool in
            return item == semaphore
        }) {
            print("METHOD_1: DELETING Semaphore: \(semaphore.uuid)")
            self.semaphores.remove(at: index)
        } else {
            print("METHOD_1: NOT FOUD TO DELETE Semaphore: \(semaphore.uuid)")
        }
        
        print("WILL UNLOCK METHOD_1 - \(semaphore.uuid)")
        semaphore.nsCondition.unlock()
        print("DID UNLOCK METHOD_1 - \(semaphore.uuid)")
        
        print("ENDING METHOD_1 - \(semaphore.uuid)")
    }

    func method2(uuid: Int) {
        
        guard let semaphore = semaphores.first(where: { (item) -> Bool in
            return item.uuid == uuid
        }) else {
            return
        }
//        semaphore.nsCondition.lock()
        print("STARTING METHOD_2 - \(semaphore.uuid)")
        let delay = Double.random(in: 5...15)
        print("DELAY: \(delay)")
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) {
            
            semaphore.doneCondition = true
            
            print("WILL SIGNAL FROM METHOD_2 - \(semaphore.uuid)")
            semaphore.nsCondition.signal()
            print("DID SIGNAL FROM METHOD_2 - \(semaphore.uuid)")
            
        }

        print("ENDING METHOD_2 - \(semaphore.uuid) : Semaphore count: \(semaphores.count)")
//        semaphore.nsCondition.unlock()
    }

    
    @IBAction func demoPressed(_ sender: UIButton) {
        
        var count = 0
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            count += 1
            DispatchQueue.global(qos: .background).async {
                self.method1()
            }

            if count >= 20 {
                print("TIMER STOPED")
                timer.invalidate()
            }
        }
    }
    
    
}

