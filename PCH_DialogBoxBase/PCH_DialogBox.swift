//
//  PCH_DialogBox.swift
//  PCH_DialogBoxBase
//
//  Created by PeterCoolAssHuber on 2019-10-22.
//  Copyright © 2019 Peter Huber. All rights reserved.
//

// Class to simplify the creation of old-style "Dialog Boxes". The calling project should have a PCH_DialogBox-derived class to which the interface elements of a dialog box are hardwired. The parent class will take care of adding Cancel and Ok buttons (and handling their actions), so enough room should be left at the bottom-right for these items.

import Foundation
import Cocoa

// File-private Extension of Selector for button-action stuff. This is a cool idea from "https://medium.com/@abhimuralidharan/selectors-in-swift-a-better-approach-using-extensions-aa6b0416e850"
fileprivate extension Selector
{
    static let okButtonTapped = #selector(PCH_DialogBox.handleOk)
    static let cancelButtonTapped = #selector(PCH_DialogBox.handleCancel)
}

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
    
    /// The viewNibFileName must point at a XIB file that has room at the bottom-right to add Cancel and Ok buttons (do not actually add these buttons to the view). All other interface elements' handlers should be wired (in IB) to a PCH_DialogBox-derived class.
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
        
        // constants for the OK and Cancel buttons
        let edgeDistance:CGFloat = 20.0
        let buttonHt:CGFloat = 25.0
        let buttonW:CGFloat = 80.0
        let betweenButtons:CGFloat = 10.0
        
        // NSRects for the buttons
        let okRect = NSRect(x: theView.frame.origin.x + theView.frame.size.width - edgeDistance - buttonW, y: edgeDistance, width: buttonW, height: buttonHt)
        let cancelRect = NSRect(x: okRect.origin.x - betweenButtons - buttonW, y: edgeDistance, width: buttonW, height: buttonHt)
        
        // Create the OK button
        let okButton = NSButton(title: "Ok", target: self, action: .okButtonTapped)
        okButton.setButtonType(.momentaryPushIn)
        okButton.isHidden = false
        okButton.frame = okRect
        theView.addSubview(okButton)
        
        // Create the Cancel button
        let cancelButton = NSButton(title: "Cancel", target: self, action: .cancelButtonTapped)
        cancelButton.setButtonType(.momentaryPushIn)
        cancelButton.frame = cancelRect
        theView.addSubview(cancelButton)
        
        // create the window
        let theWindow = NSWindow(contentRect: theView.frame, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        
        // Set the view and the window delegate (this is for future expansion)
        theWindow.contentView = theView
        theWindow.delegate = self
        
        self.window = theWindow
        self.setupIsDone = true
    }
    
    func runModal() -> NSApplication.ModalResponse
    {
        if !self.setupIsDone
        {
            do
            {
                try self.SetupDialogBox()
            }
            catch
            {
                let alert = NSAlert(error: error)
                let _ = alert.runModal()
                return .cancel
            }
        }
        
        let result = NSApp.runModal(for: self.window!)
        
        return result
    }
    
    @objc func handleOk()
    {
        // DLog("Ok was pushed")
        NSApp.stopModal(withCode: .OK)
        self.window!.orderOut(self)
    }
    
    @objc func handleCancel()
    {
        // DLog("Cancel was pushed")
        NSApp.stopModal(withCode: .cancel)
        self.window!.orderOut(self)
    }
}
