/*
 Copyright (C) 2020 Shun Ito
 
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
    
    private func sendSetGetAnrModePacket(_ anrMode: Bose.AnrMode) -> Bool {
        assert(self.bt != nil, "self.bt is nil")
        
        guard var packet = Bose.generateSetGetAnrModePacket(anrMode) else {
            os_log("Failed to generate setGetAnrPacket.", type: .error)
            return false
        }
        if (self.bt.sendPacketSync(&packet) == false) {
            return false
        }
        
        return true
    }
}

extension AppDelegate: BluetoothDelegate {
    
    func onConnect() {
        guard let productID = Bose.ProductIds.getById(self.bt.getProductId()) else {
            assert(false, "Invalid prodcut id.")
            return
        }
        #if DEBUG
        print("[BT]: Connected to \(productID.getProductName())")
        #endif
        self.statusItem.connected(productID)
        
        if (Preferences.getLastSelectedAnrMode() != nil) {
            let result = sendSetGetAnrModePacket(Preferences.getLastSelectedAnrMode()!)
            if (!result) {
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
            Preferences.setLastSelectedAnrMode(mode!)
        }
    }
}

extension AppDelegate: StatusItemDelegate {

    func menuWillOpen(_ menu: NSMenu) {
        for menuItem in menu.items {
            switch menuItem.tag {
            case StatusItem.MenuItemTags.BATTERY_LEVEL.rawValue:
                guard var packet = Bose.generateGetBatteryLevelPacket() else {
                    os_log("Failed to generate getBatteryLevelPacket.", type: .error)
                    self.batteryLevelStatus(nil)
                    return
                }
                if (self.bt.sendPacketSync(&packet) == false) {
                    self.batteryLevelStatus(nil)
                }
            case StatusItem.MenuItemTags.NOISE_CANCEL_MODE.rawValue:
                guard var packet = Bose.generateGetAnrModePacket() else {
                    os_log("Failed to generate getAnrModePacket.", type: .error)
                    self.noiseCancelModeChanged(nil)
                    return
                }
                if (self.bt.sendPacketSync(&packet) == false) {
                    self.noiseCancelModeChanged(nil)
                }
            default: break
            }
        }
    }
    
    func noiseCancelModeSelected(_ mode: Bose.AnrMode) {
        let result = sendSetGetAnrModePacket(mode)
        if (!result) {
            self.noiseCancelModeChanged(nil)
        }
    }
}
