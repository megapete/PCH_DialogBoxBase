//
//  PCH_DialogBox.swift
//  PCH_DialogBoxBase
//
//  Created by PeterCoolAssHuber on 2019-10-22.
//  Copyright © 2019 Peter Huber. All rights reserved.
//

import Foundation
import Cocoa

class PCH_DialogBox:NSObject, NSWindowDelegate
{
    var window:NSWindow? = nil
    var view:NSView? = nil
    
    let nibName:NSNib.Name
    
    var setupIsDone = false
    
    // My new favorite thing, throwing exceptions with custom-built errors
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
                
                return "An unknown error occurred."
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
        // Load the nib file that holds our view
        guard let viewNib = NSNib(nibNamed: self.nibName, bundle: Bundle.main) else
        {
            throw DialogBoxError(info: self.nibName, type: .InvalidViewNibName)
        }
        
        // Instantiation of the view will put the nib's top level objects in an NSArray?
        var topLevelObs:NSArray?
        
        if !viewNib.instantiate(withOwner: self, topLevelObjects: &topLevelObs)
        {
            throw DialogBoxError(info: self.nibName, type: .InvalidView)
        }
        
        guard let nibObjects = topLevelObs else
        {
            throw DialogBoxError(info: self.nibName, type: .InvalidView)
        }
        
        // find our view in the array of objects and set the class' property to it
        for nextObject in nibObjects
        {
            if let view = nextObject as? NSView
            {
                self.view = view
                break
            }
        }
        
        // make sure we found a view
        guard let theView = self.view else
        {
            throw DialogBoxError(info: self.nibName, type: .InvalidTopLevelObject)
        }
        
        // create the window
        let theWindow = NSWindow(contentRect: theView.frame, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        
        theWindow.contentView = theView
        theWindow.delegate = self
        
        self.window = theWindow
        self.setupIsDone = true
    }
    
    func runModal() throws -> NSApplication.ModalResponse
    {
        if !self.setupIsDone
        {
            do
            {
                try self.SetupDialogBox()
            }
            catch
            {
                throw error
            }
        }
        
        let result = NSApp.runModal(for: self.window!)
        
        return result
    }
}
