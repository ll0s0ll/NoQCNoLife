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
import IOBluetooth
import os.log

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var bt: Bt!
    var statusItem: StatusItem!
    var connectBtUserNotification: IOBluetoothUserNotification!
    
//    func applicationWillFinishLaunching(_ aNotification: Notification) {
//        print("applicationWillFinishLaunching()")
//    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        print("applicationDidFinishLaunching()")
        bt = Bt(self)
        connectBtUserNotification = IOBluetoothDevice.register(forConnectNotifications: bt,
                                                               selector:#selector(bt.onNewConnectionDetected))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        connectBtUserNotification?.unregister()
        self.bt?.closeConnection()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.statusItem = StatusItem(self)
    }
}

extension AppDelegate: BluetoothDelegate {
    
    func onConnect() {
        guard let product = Bose.Products.getById(self.bt.getProductId()) else {
            assert(false, "Invalid prodcut id.")
            return
        }
        #if DEBUG
        print("[BT]: Connected to \(product.getName())")
        #endif
        self.statusItem.connected(product)
        
        if let lastSelectedAnrMode = PreferenceManager.getLastSelectedAnrMode(product) {
            if (!self.bt.sendSetGetAnrModePacket(lastSelectedAnrMode)) {
                self.noiseCancelModeChanged(nil)
            }
        }
    }
    
    func onDisconnect() {
        #if DEBUG
        print("[BT]: Disconnected")
        #endif
        self.statusItem.disconnected()
    }
    
    func bassControlStepChanged(_ step: Int?) {
        #if DEBUG
        print("[BassControlEvent]: \(step != nil ? String(step!) : "nil")")
        #endif
        self.statusItem.setBassControlStep(step)
    }
    
    func batteryLevelStatus(_ level: Int?) {
        #if DEBUG
        print("[BatteryLevelEvent]: \(level != nil ? String(level!) : "nil")")
        #endif
        self.statusItem.setBatteryLevel(level)
    }
    
    func noiseCancelModeChanged(_ mode: Bose.AnrMode?) {
        #if DEBUG
        print("[AnrModeEvent]: \(mode?.toString() ?? "nil")")
        #endif
        self.statusItem.setNoiseCancelMode(mode)
        
        if (mode != nil) {
            if let product = Bose.Products.getById(self.bt.getProductId()) {
                PreferenceManager.setLastSelectedAnrMode(product: product, anrMode: mode!)
            }
        }
    }
}

extension AppDelegate: StatusItemDelegate {
    
    func bassControlStepSelected(_ step: Int) {
        if (!self.bt.sendSetGetBassControlPacket(step)) {
            self.noiseCancelModeChanged(nil)
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        for menuItem in menu.items {
            switch menuItem.tag {
            case StatusItem.MenuItemTags.BATTERY_LEVEL.rawValue:
                if (!self.bt.sendGetBatteryLevelPacket()) {
                    self.batteryLevelStatus(nil)
                }
            case StatusItem.MenuItemTags.BASS_CONTROL.rawValue:
                if (!self.bt.sendGetBassControlPacket()) {
                    self.bassControlStepChanged(nil)
                }
            case StatusItem.MenuItemTags.NOISE_CANCEL_MODE.rawValue:
                if (!self.bt.sendGetAnrModePacket()) {
                    self.noiseCancelModeChanged(nil)
                }
            default: break
            }
        }
    }
    
    func noiseCancelModeSelected(_ mode: Bose.AnrMode) {
        if (!self.bt.sendSetGetAnrModePacket(mode)) {
            self.noiseCancelModeChanged(nil)
        }
    }
}
