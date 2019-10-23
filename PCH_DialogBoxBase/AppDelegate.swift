//
//  AppDelegate.swift
//  PCH_DialogBoxBase
//
//  Created by PeterCoolAssHuber on 2019-10-22.
//  Copyright © 2019 Peter Huber. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let test = PCH_DialogBox(viewNibFileName: "PCH_DialogBoxView")
        
        let result =  test.runModal()
            
        if result == .OK
        {
            DLog("User chose OK")
        }
        else
        {
            DLog("User chose Cancel")
        }
       
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

