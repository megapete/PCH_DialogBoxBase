//
//  PCH_DialogBox.swift
//  PCH_DialogBoxBase
//
//  Created by PeterCoolAssHuber on 2019-10-22.
//  Copyright © 2019 Peter Huber. All rights reserved.
//

import Foundation
import Cocoa

class PCH_DialogBox
{
    var window:NSWindow? = nil
    var view:NSView? = nil
    
    let nibName:NSNib.Name
    
    var setupIsDone = false
    
    struct DialogBoxError:Error
    {
        enum errorType
        {
            case InvalidViewBaseClass
            case InvalidViewNibName
            case InvalidView
            case InvalidTopLevelObject
        }
        
        let info:String
        let type:errorType
        
        var localizedDescription: String
        {
            get
            {
                if self.type == .InvalidViewBaseClass
                {
                   return "Your view must be derived from PCH_DialogBoxView."
                }
                else if self.type == .InvalidViewNibName
                {
                    return "Could not open nib file: " + self.info
                }
                else if self.type == .InvalidView
                {
                    return "Could not create view from nib file: " + self.info
                }
                else if self.type == .InvalidTopLevelObject
                {
                    return "Topmost-level object is not an NSView"
                }
                
                return "An unknown erro occurred."
            }
        }
    }
    
    // The viewNibFileName must point at a XIB file that should be derived from PCH_DialogBoxView so that the Cancel & Ok buttons appear and they track the bottom-right corner of the view. Any NSView can actually be used, provided 
    init(viewNibFileName:String)
    {
        self.nibName = viewNibFileName
    }
    
    // This function is meant to be called internally by this class (ie: it should probably be declared as private)
    func SetupDialogBox() throws
    {
        if self.setupIsDone
        {
            return
        }
        
        guard let viewNib = NSNib(nibNamed: self.nibName, bundle: nil) else
        {
            throw DialogBoxError(info: self.nibName, type: .InvalidViewNibName)
        }
        
        var topLevelObs:NSArray?
        
        if !viewNib.instantiate(withOwner: self, topLevelObjects: &topLevelObs)
        {
            throw DialogBoxError(info: self.nibName, type: .InvalidView)
        }
        
        guard topLevelObs != nil else
        {
            throw DialogBoxError(info: self.nibName, type: .InvalidView)
        }
        
        self.view = topLevelObs![0] as? NSView
        if self.view == nil
        {
            throw DialogBoxError(info: self.nibName, type: .InvalidTopLevelObject)
        }
        
        self.setupIsDone = true
    }
    
    func runModal() -> NSApplication.ModalResponse
    {
        
    }
}
