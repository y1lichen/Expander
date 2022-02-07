//
//  AppDelegate.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//

import Cocoa
import SwiftUI
import UserNotifications
import DSFQuickActionBar

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	var appData: AppData!
	//
	var originalActiveApp: NSRunningApplication?
	//
	var isOn: Bool = true
	//
	// status bar
	var prefWindow: NSWindow!
	var statusbarItem: NSStatusItem!
	var statusbarMenu: NSMenu!
	var model: ExpanderModel!
	// timer for reload ipdate
	var timer: DispatchSourceTimer?
	
	let userDefaults = UserDefaults.standard
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
		// Add `@Environment(\.managedObjectContext)` in the views that will need the context.
		self.initData()
		self.createStatusBar()
		self.getuserPermission()
		self.openPreferences()
		self.createDefultLongSnippetDirectory()
		self.model = ExpanderModel()
		// load ip address
		self.loadIPdata()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	// MARK: - Core Data stack

	lazy var persistentContainer: NSPersistentContainer = {
	    /*
	     The persistent container for the application. This implementation
	     creates and returns a container, having loaded the store for the
	     application to it. This property is optional since there are legitimate
	     error conditions that could cause the creation of the store to fail.
	    */
	    let container = NSPersistentContainer(name: "Expander")
	    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	        if let error = error {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

	            /*
	             Typical reasons for an error here include:
	             * The parent directory does not exist, cannot be created, or disallows writing.
	             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
	             * The device is out of space.
	             * The store could not be migrated to the current model version.
	             Check the error message to determine what the actual problem was.
	             */
	            fatalError("Unresolved error \(error)")
	        }
	    })
	    return container
	}()

	// MARK: - Core Data Saving and Undo support

	@IBAction func saveAction(_ sender: AnyObject?) {
	    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
	    let context = persistentContainer.viewContext

	    if !context.commitEditing() {
	        NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
	    }
	    if context.hasChanges {
	        do {
	            try context.save()
	        } catch {
	            // Customize this code block to include application-specific recovery steps.
	            let nserror = error as NSError
	            NSApplication.shared.presentError(nserror)
	        }
	    }
	}

	func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
	    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
	    return persistentContainer.viewContext.undoManager
	}

	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
	    // Save changes in the application's managed object context before the application terminates.
	    let context = persistentContainer.viewContext

	    if !context.commitEditing() {
	        NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
	        return .terminateCancel
	    }

	    if !context.hasChanges {
	        return .terminateNow
	    }

	    do {
	        try context.save()
	    } catch {
	        let nserror = error as NSError

	        // Customize this code block to include application-specific recovery steps.
	        let result = sender.presentError(nserror)
	        if (result) {
	            return .terminateCancel
	        }

	        let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
	        let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
	        let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
	        let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
	        let alert = NSAlert()
	        alert.messageText = question
	        alert.informativeText = info
	        alert.addButton(withTitle: quitButton)
	        alert.addButton(withTitle: cancelButton)

	        let answer = alert.runModal()
	        if answer == .alertSecondButtonReturn {
	            return .terminateCancel
	        }
	    }
	    // If we got here, it is time to quit.
	    return .terminateNow
	}
}

/*
*/

extension AppDelegate {
	/*
	## get user permisission
	- https://developer.apple.com/forums/thread/24288
	*/
	// MARK: - remove sandbox to show notification
	//
	func getuserPermission() {
		// for key-press detection
		AXIsProcessTrustedWithOptions(
		[kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary)
		// for notification
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
		_, _ in
		}
	}

	@objc func openPreferences() {
		// Don't open the window but bring the window to front if the window is already opened.
		if let prefWindow = prefWindow {
			if (prefWindow.isVisible) {
				prefWindow.orderFrontRegardless()
				return
			}
		}
		let contentView = ContentView().environment(\.managedObjectContext, persistentContainer.viewContext).environmentObject(self.appData)
		// Create the window and set the content view.
		prefWindow = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered, defer: false)
		prefWindow.center()
		NSToolbar.prefToolBar.delegate = self
		prefWindow.toolbar = .prefToolBar
		prefWindow.contentView = NSHostingView(rootView: contentView)
		prefWindow.orderFrontRegardless()
		NSApplication.shared.activate(ignoringOtherApps: true)
		prefWindow.isReleasedWhenClosed = false
	}

	//
	var allowNotification: Bool {
		get {
			userDefaults.bool(forKey: "showNotification")
		}
	}

	
	@objc func toggleLongSnippetView() {
		let longSnippets = getLongSnippet()
		let searchBar = DSFQuickActionBar.SwiftUI<SearchBarCellView>()
		searchBar.present(placeholderText: "Snippet Search",
						  contentSource: SearchBarContentSource(allSnippets: longSnippets))
		originalActiveApp = NSWorkspace.shared.runningApplications.first(where: {
			$0.isActive
		})
		NSApplication.shared.activate(ignoringOtherApps: true)
	}

	//
	@objc func toggleExpander() {
		self.isOn.toggle()
		self.setStatusBarIcon()
		if self.allowNotification && !self.isOn {
			self.sendNotification()
		}
	}

	func createImage(imgName: String) -> NSImage {
		let image = NSImage(named: imgName)!
		image.isTemplate = true
		image.size = NSSize(width: 16, height: 16)
		return image
	}
	//
	func setStatusBarIcon() {
		let onImage = createImage(imgName: "onImage")
		let offImage = createImage(imgName: "offImage")
		if self.isOn {
			self.statusbarItem.button?.image = onImage
		} else {
			self.statusbarItem.button?.image = offImage
		}
	}

	//
	func createStatusBar() {
		self.statusbarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		self.statusbarMenu = NSMenu()
		self.setStatusBarIcon()
		self.statusbarItem.menu = self.statusbarMenu
		// toggle for the application
		let toggle = NSMenuItem()
		toggle.title = "toggle"
		toggle.action = #selector(toggleExpander)
		toggle.keyEquivalentModifierMask = [.control, .shift]
		toggle.keyEquivalent = "e"
		self.statusbarMenu.addItem(toggle)
		//
		let longSnippetToggle = NSMenuItem()
		longSnippetToggle.title = "show long snippets"
		longSnippetToggle.action = #selector(toggleLongSnippetView)
		longSnippetToggle.keyEquivalentModifierMask = [.control, .shift]
		longSnippetToggle.keyEquivalent = "s"
		self.statusbarMenu.addItem(longSnippetToggle)
		//
		self.statusbarMenu.addItem(withTitle: "Preferences", action: #selector(openPreferences), keyEquivalent: ",")
		self.statusbarMenu.addItem(NSMenuItem.separator())
		self.statusbarMenu.addItem(withTitle: "Quit Expander",
							action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
	}

	func initData() {
		userDefaults.register(defaults: [
			"sortMethod": "snippetTrigger",
			"showNotification": false,
			"passiveMode": false,
			"passiveExpandKey": "\\",
			"dateformat": 0,
			"enableLongSnippets": false,
			"longSnippetsDirectory": URL(fileURLWithPath: (NSHomeDirectory() + "/Documents/Expander/")).absoluteString
			])
		self.appData = AppData()
	}
	//
	func sendNotification() {
	   let content = UNMutableNotificationContent()
	   content.title = "Expander is disabled"
	   content.subtitle = "Press cmd+shift+e to renable Expander."
	   content.sound = UNNotificationSound.default
	   let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
	   let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
		UNUserNotificationCenter.current().add(request)
	}
	
	func postLoadIPdataNotification() {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadipdata"), object: nil)
	}
	
	func loadIPdata() {
		timer = DispatchSource.makeTimerSource()
		timer?.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.seconds(3600), leeway: DispatchTimeInterval.seconds(5))
		timer?.setEventHandler(handler: postLoadIPdataNotification)
		// start the timer
		timer?.resume()
	}
}

extension AppDelegate {
	
	func createDefultLongSnippetDirectory() {
		do {
			try FileManager.default.createDirectory(atPath: NSHomeDirectory() + "/Documents/Expander/", withIntermediateDirectories: false, attributes: nil)
		} catch {
//			print(error)
		}
	}
	
	func getLongSnippet() -> [LongSnippetModel] {
		let fileManager = FileManager.default
		do {
			guard let pathUrl = UserDefaults.standard.string(forKey: "longSnippetsDirectory") else {
				return []
			}
			let files = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: pathUrl), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
			return files.map {
				file in LongSnippetModel(path: file)
			}
		} catch {
			// error (probably no permission)
			let alert = NSAlert.init()
			alert.messageText = "Unexpected error occurs!"
			alert.informativeText = "Please make sure the path of long snippets is exist and grant Expander the permission to access your disk."
			alert.addButton(withTitle: "OK")
			alert.runModal()
			return []
		}
	}
}

/*
*/
