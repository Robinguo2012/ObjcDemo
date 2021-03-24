//
//  Monitor.swift
//  Runloop Monitor
//
//  Created by Sailer Guo on 2020/12/29.
//

import Foundation
import CoreFoundation

class RunloopMonitor: NSObject {
    
    var dispatchSem:DispatchSemaphore?
    var runloopObserver: CFRunLoopObserver?
    var timeoutCount: Int = 0
    var runloopActivity: CFRunLoopActivity?
    var isMoniting: Bool = false
    
    static let shared = RunloopMonitor()
    
    func beginMonitor() {
        self.isMoniting = true
        
        self.dispatchSem = DispatchSemaphore.init(value: 0)
        
        let info = Unmanaged<RunloopMonitor>.passRetained(self).toOpaque()

        var context = CFRunLoopObserverContext(version: 0, info: info, retain: nil, release: nil, copyDescription: nil)
        
        let allActivityObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0, observerCall(), &context)
        self.runloopObserver = allActivityObserver
        
        CFRunLoopAddObserver(CFRunLoopGetMain(), allActivityObserver, CFRunLoopMode.commonModes)
        
        
        DispatchQueue.global().async {
            
            while true {
                /**
                 当前的runloop 迭代进入beforeSource 时，等待80ms。
                 如果 source0 的回调执行完成，就会执行runloop 回调释放信号量，执行beforeWaiting然后重新timeoutCount；
                 如果没有完成，
                 */
                let semaphoreWait = self.dispatchSem!.wait(timeout: DispatchTime.now() + 0.08)
                if semaphoreWait ==  DispatchTimeoutResult.timedOut{
                    if self.runloopObserver == nil {
                        self.timeoutCount = 0
                        self.dispatchSem = nil
                        self.runloopActivity = CFRunLoopActivity.entry
                        return
                    }
                }
                
                //
                if [CFRunLoopActivity.beforeSources,CFRunLoopActivity.afterWaiting].contains(self.runloopActivity) {
                    if self.timeoutCount < 3 {
                        self.timeoutCount += 1
                        continue
                    }
                    
                    DispatchQueue.global().async {
                        print("监控到卡顿")
                    }
                }
                
                self.timeoutCount = 0
            }
        }
    }
    
    func end() {
        self.isMoniting = false
        guard runloopObserver != nil else {
            return
        }
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.runloopObserver, CFRunLoopMode.commonModes)
    }
    
    func printAct(act: CFRunLoopActivity)  {
        let map = [
            CFRunLoopActivity.beforeSources.rawValue:"将处理source0",
            CFRunLoopActivity.beforeTimers.rawValue:"将处理timer",
            CFRunLoopActivity.beforeWaiting.rawValue:"将进入休眠",
            CFRunLoopActivity.afterWaiting.rawValue:"从休眠中唤醒",
            CFRunLoopActivity.entry.rawValue:"进入runloop",
            CFRunLoopActivity.exit.rawValue:"退出runloop"
        ]
        print(">> \(String(describing: map[act.rawValue]))")
        
    }
    
    func observerCall() -> CFRunLoopObserverCallBack {
        // observer 的回调
        return { (observer , activity, pointer) in
            guard let context = pointer else {
                return
            }
            let weakSelf = Unmanaged<RunloopMonitor>.fromOpaque(context).takeUnretainedValue()
            weakSelf.dispatchSem?.signal()
            weakSelf.runloopActivity = activity
            weakSelf.printAct(act: activity)
        }
    }
}
