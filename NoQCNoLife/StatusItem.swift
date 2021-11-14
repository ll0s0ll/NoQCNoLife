/*
 Copyright (C) 2021 Shun Ito
 
 This file is part of 'No QC, No Life'.
 
 'No QC, No Life' is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 1, or (at your option)
 any later version.
 
 'No QC, No Life' is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

import Cocoa

class StatusItem {
    
    var statusItem: NSStatusItem
    var statusItemDelegate: StatusItemDelegate
    
    enum MenuItemTags: Int {
        case UNDEFINED, // NSMenuItemのtagに0を指定すると、なぜかNSMenu.item(withTag: tag)でエラーが出る。
        ABOUT,
        BASS_CONTROL,
        BATTERY_LEVEL,
        DEVICE_NAME,
        NOISE_CANCEL_MODE,
        QUIT
    }
    
    init (_ delegate: StatusItemDelegate) {
        
        self.statusItemDelegate = delegate
        
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let buttonImage = NSImage(named: "ButtonImg")
        buttonImage?.isTemplate = true
        self.statusItem.button?.image = buttonImage

        let mainMenu = NSMenu.init()
        mainMenu.delegate = delegate
//        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(DeviceNameMenuItem.init())
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(AboutMenuItem.init())
        mainMenu.addItem(QuitMenuItem.init())

        self.statusItem.menu = mainMenu
    }
    
    func buildMenuItems(_ id: Bose.ProductIds) -> [NSMenuItem] {
        var menuItems: [NSMenuItem] = []
        switch id {
        case Bose.ProductIds.WOLFCASTLE: // QuietComfort 35
            menuItems.append(BatteryLevelMenuItem.init())
            menuItems.append(NoiseCancelModeMenuItem.init(high: true, low: true, wind: false, off: true,
                                                          delegate: self.statusItemDelegate))
        case Bose.ProductIds.BAYWOLF: // Bose QuietComfort 35 Series 2
            menuItems.append(BatteryLevelMenuItem.init())
            menuItems.append(NoiseCancelModeMenuItem.init(high: true, low: true, wind: false, off: true,
                                                          delegate: self.statusItemDelegate))
        case Bose.ProductIds.KLEOS: // SoundWear
            menuItems.append(BatteryLevelMenuItem.init())
            menuItems.append(BassControlMenuItem.init(steps:8, delegate: self.statusItemDelegate))
        }
        return menuItems
    }
    
    func connected (_ productId: Bose.ProductIds!) {
        let deviceNameMenuItemTag = StatusItem.MenuItemTags.DEVICE_NAME.rawValue
        let deviceNameMenuItem = self.statusItem.menu?.item(withTag: deviceNameMenuItemTag) as! DeviceNameMenuItem
        deviceNameMenuItem.setDeviceName(productId.getProductName())
        
        for menuItem in buildMenuItems(productId).reversed() {
            self.statusItem.menu?.insertItem(menuItem, at: 1)
        }
    }
    
    func disconnected () {
        let deviceNameMenuItemTag = StatusItem.MenuItemTags.DEVICE_NAME.rawValue
        let deviceNameMenuItem = self.statusItem.menu?.item(withTag: deviceNameMenuItemTag) as! DeviceNameMenuItem
        deviceNameMenuItem.clearDeviceName()
        
        for menuItem in self.statusItem.menu?.items ?? [] {
            if (menuItem.tag != MenuItemTags.ABOUT.rawValue &&
                menuItem.tag != MenuItemTags.DEVICE_NAME.rawValue &&
                menuItem.tag != MenuItemTags.QUIT.rawValue &&
                !menuItem.isSeparatorItem) {
                menuItem.menu?.removeItem(menuItem)
            }
        }
    }
    
    func setBassControlStep(_ step: Int?) {
        let tag = StatusItem.MenuItemTags.BASS_CONTROL.rawValue
        let menuItem = self.statusItem.menu?.item(withTag: tag) as! BassControlMenuItem
        menuItem.setBassControlStep(step)
        
    }
    
    func setBatteryLevel(_ level: Int?) {
        let tag = StatusItem.MenuItemTags.BATTERY_LEVEL.rawValue
        let menuItem = self.statusItem.menu?.item(withTag: tag) as! BatteryLevelMenuItem
        menuItem.setBatteryLevel(level)
    }
    
    func setNoiseCancelMode(_ mode: Bose.AnrMode?) {
        let tag: Int = StatusItem.MenuItemTags.NOISE_CANCEL_MODE.rawValue
        let menuItem = self.statusItem.menu?.item(withTag: tag) as! NoiseCancelModeMenuItem
        menuItem.setNoiseCancelMode(mode)
    }
}


protocol StatusItemDelegate : NSMenuDelegate {
    func bassControlStepSelected(_ step: Int)
    func noiseCancelModeSelected(_ mode: Bose.AnrMode)
}


class AboutMenuItem : NSMenuItem {
    init() {
        super.init(title: "About No QC, No Life", action: #selector(self.openAboutPanel(_:)), keyEquivalent: "")
        self.tag = StatusItem.MenuItemTags.ABOUT.rawValue
        self.target = self
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openAboutPanel(_ sender: NSMenuItem) {
        // MenuItemのactionから直接orderFrontStandardAboutPanel()を呼ぶと、
        // バックグラウンドになってしまい、パネルが表示されないので、
        // 一旦フォアグランドにしてから、パネルを表示する。
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }
}

class BassControlMenuItem : NSMenuItem {
    
    var delegate: StatusItemDelegate
    var steps: Int
    var titleStr = "Dialogue Adjust"
    
    init(steps: Int, delegate: StatusItemDelegate) {
        self.steps = steps
        self.delegate = delegate
        
        super.init(title: "\(titleStr): N/A", action: nil, keyEquivalent: "")
        
        self.tag = StatusItem.MenuItemTags.BASS_CONTROL.rawValue
        self.target = self
        self.submenu = buildSubmenu()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func bassControlStepSelected(_ sender: NSMenuItem) {
        self.delegate.bassControlStepSelected(sender.tag)
    }
    
    func buildSubmenu() -> NSMenu {
        let submenu = NSMenu.init()
        
        for step in 0 ... self.steps {
            let menuItem = NSMenuItem.init(title: String(step - step * 2),
                                           action: #selector(self.bassControlStepSelected(_:)),
                                           keyEquivalent: "")
            menuItem.target = self
            menuItem.tag = step - step * 2
            submenu.addItem(menuItem)
        }
        
        return submenu
    }
    
    func setBassControlStep(_ step: Int?) {
        if (step == nil) {
            self.title = "\(titleStr): error"
        } else {
            self.title = "\(titleStr): \(step!)"
        }
    }
}


class BatteryLevelMenuItem : NSMenuItem {
    
    init() {
        super.init(title: "Battery: N/A", action: nil, keyEquivalent: "")
        self.tag = StatusItem.MenuItemTags.BATTERY_LEVEL.rawValue
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBatteryLevel(_ level: Int?) {
        if (level == nil) {
            self.title = "Battery: error"
        } else {
            self.title = "Battery: \(level!)%"
        }
    }
}


class DeviceNameMenuItem : NSMenuItem {
    
    private let defaultTitle = "No device connected."
    
    init() {
        super.init(title: self.defaultTitle, action: nil, keyEquivalent: "")
        self.tag = StatusItem.MenuItemTags.DEVICE_NAME.rawValue
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearDeviceName() {
        self.title = defaultTitle
    }
    
    func setDeviceName(_ name: String) {
        self.title = name
    }
}


class NoiseCancelModeMenuItem : NSMenuItem {
    
    var delegate: StatusItemDelegate
    
    init(high: Bool, low: Bool, wind: Bool, off: Bool, delegate: StatusItemDelegate) {
        
        self.delegate = delegate
        
        super.init(title: "Noise cancel: N/A", action: nil, keyEquivalent: "")
        
        self.tag = StatusItem.MenuItemTags.NOISE_CANCEL_MODE.rawValue
        self.target = self
        self.submenu = buildSubmenu(high: high, low: low, wind: wind, off: off)
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildSubmenu(high: Bool, low: Bool, wind: Bool, off: Bool) -> NSMenu {
        let submenu = NSMenu.init()
        for mode in Bose.AnrMode.allCases {
            if (mode == Bose.AnrMode.HIGH && !high) {
                continue
            } else if (mode == Bose.AnrMode.LOW && !low) {
                continue
            } else if (mode == Bose.AnrMode.WIND && !wind) {
                continue
            } else if (mode == Bose.AnrMode.OFF && !off) {
                continue
            }
            
            let menuItem = NSMenuItem.init(title: mode.toString(),
                                           action: #selector(self.noiseCancelModeSelected(_:)),
                                           keyEquivalent: "")
            menuItem.target = self
            menuItem.tag = Int(mode.rawValue)
            submenu.addItem(menuItem)
        }
        
        // OFFは順番的にLOWの次にしたい、それだけ。
        let offMenuItem = submenu.item(withTag: Int(Bose.AnrMode.OFF.rawValue))
        submenu.removeItem(offMenuItem!)
        submenu.insertItem(offMenuItem!, at: submenu.numberOfItems)
        
        return submenu
    }
    
    @objc func noiseCancelModeSelected(_ sender: NSMenuItem) {
        switch sender.tag {
        case Int(Bose.AnrMode.OFF.rawValue):
            self.delegate.noiseCancelModeSelected(Bose.AnrMode.OFF)
        case Int(Bose.AnrMode.HIGH.rawValue):
            self.delegate.noiseCancelModeSelected(Bose.AnrMode.HIGH)
        case Int(Bose.AnrMode.WIND.rawValue):
            self.delegate.noiseCancelModeSelected(Bose.AnrMode.WIND)
        case Int(Bose.AnrMode.LOW.rawValue):
            self.delegate.noiseCancelModeSelected(Bose.AnrMode.LOW)
        default:
            assert(false, "Invalid menu item")
        }
    }
    
    func setNoiseCancelMode(_ mode: Bose.AnrMode!) {
        if (mode == nil) {
            self.title = "Noise cancel: error"
            for subMenuItem in self.submenu?.items ?? [] {
                subMenuItem.state = NSControl.StateValue.off
            }
        } else {
            self.title = "Noise cancel: \(mode.toString())"
            for subMenuItem in self.submenu?.items ?? [] {
                if (subMenuItem.tag == mode.rawValue) {
                    subMenuItem.state = NSControl.StateValue.on
                } else {
                    subMenuItem.state = NSControl.StateValue.off
                }
            }
        }
    }
}

class QuitMenuItem : NSMenuItem {
    init() {
        super.init(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        self.tag = StatusItem.MenuItemTags.QUIT.rawValue
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
