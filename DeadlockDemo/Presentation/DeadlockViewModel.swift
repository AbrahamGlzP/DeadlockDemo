//
//  DeadlockViewModel.swift
//  DeadlockDemo
//
//  Created by Abraham Gonzalez Puga on 20/02/26.
//

import SwiftUI

@Observable
@MainActor
class DeadlockViewModel {
    var log: [String] = []
    var isRunning = false
    
    func triggerDeadlock() {
        log = []
        isRunning = true
        log.insert("🚀 Launching operation", at: 0)
        
        let queue = DispatchQueue(label: "com.app.deadlock")
        
        queue.async { [weak self] in
            DispatchQueue.main.async {
                self?.log.insert("✅ Step one completed", at: 0)
            }
            
            // Simulates the classic deadlock
            // sync within the same queue
            // queue.sync { } // 💀 DEADLOCK
            
            // We can also simulate the frezze with the use of an sleep
            // Just to not to frezze the demo
            Thread.sleep(forTimeInterval: 2)
            
            DispatchQueue.main.async {
                self?.log.insert("💀 Here would occur the deadlock with queue.sync", at: 0)
                self?.log.insert("🧵 The thread would be blocked forever", at: 0)
                self? .isRunning = false
            }
        }
    }
    
    func runSafely() async {
        log = []
        isRunning = true
        log.insert("🚀 Initiating safe operation", at: 0)
        
        // Task.sleep suspends without blocking - imposible deadlock
        try? await Task.sleep(for: .seconds(1))
        log.insert("✅ Step 1 completed", at: 0)
        
        try? await Task.sleep(for: .seconds(1))
        log.insert("✅ Step 2 completed", at: 0)
        
        try? await Task.sleep(for: .seconds(1))
        log.insert("🎉 Everything completed without deadlock", at: 0)
        
        isRunning = false
    }
    
    func demonstrateMutualDeadlock() async {
        log = []
        isRunning = false
        
        let lockA = NSLock()
        let lockB = NSLock()
        
        log.insert("⚠️ Simulating deadlock between two resources", at: 0)
        
        // Thread 1: takes A, awaits B
        let task1 = Task.detached {
            lockA.lock()
            try? await Task.sleep(for: .milliseconds(100)) // gives time to thread 2
            lockB.lock() // 💀 waits for thread 2 to release B - never happens
            lockA.unlock()
            lockB.unlock()
        }
        
        // Thread 2: takes B, awaits A
        let task2 = Task.detached {
            lockB.lock()
            try? await Task.sleep(for: .milliseconds(100))
            lockA.lock() // 💀 waits till thread 1 releases A - never happens
            lockA.unlock()
            lockB.unlock()
        }
        
        try? await Task.sleep(for: .seconds(3))
        task1.cancel()
        task2.cancel()
        
        log.insert("⏱️ Timeout — both tasks cancelled", at: 0)
        log.insert("💀 None of the tasks could be completed", at: 0)
        log.insert("🔑 Solution: aquire locks always in the same order", at: 0)
        isRunning = false
    }
}
