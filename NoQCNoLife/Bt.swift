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

import IOBluetooth
import os.log

class Bt {

    private var connectedChannel: IOBluetoothRFCOMMChannel?
    private var connectedDevice: IOBluetoothDevice?
    private var productId: Int?
    
    private var delegate: BluetoothDelegate
    
    private var disconnectBtUserNotification: IOBluetoothUserNotification?
    
    init(_ delegate: BluetoothDelegate) {
        self.connectedChannel = nil
        self.connectedDevice = nil
        self.productId = nil
        self.delegate = delegate
    }
    
    func closeConnection() {
        let result: IOReturn? = self.connectedChannel?.close()
        if (result != nil && result != 0 ) {
            assert(false, "Faild to close connection.")
        }
        self.connectedChannel = nil
        self.connectedDevice = nil
        self.productId = nil
        
        self.disconnectBtUserNotification?.unregister()
    }
    
    private func findConnectedBoseDevice(connectedDevice: inout IOBluetoothDevice!, productId: inout Int!) -> Bool {
        guard let pairedDevices = IOBluetoothDevice.pairedDevices() else {
            return false
        }
        
        for pairedDevice in pairedDevices {
            let pairedDevice = pairedDevice as! IOBluetoothDevice
            if (!pairedDevice.isConnected()) {
                continue
            }
            
            guard let pnpInfo = processPnPInfomation(pairedDevice) else {
                continue
            }
            
            if (Bose.isSupportedBoseProduct(venderId: pnpInfo.venderId, productId: pnpInfo.productId)) {
                connectedDevice = pairedDevice
                productId = pnpInfo.productId
                return true
            }
        }
        
        return false
    }
    
    func getProductId() -> Int? {
        return self.connectedDevice != nil ? self.productId : nil
    }
    
    @objc func onDisconnectDetected() {
        #if DEBUG
        print("[BT]: DisconnectDetected")
        #endif
        self.closeConnection()
        self.delegate.onDisconnect()
    }
    
    
    @objc func onNewConnectionDetected() {
        #if DEBUG
        print("[BT]: NewConnectionDetected")
        #endif
        if (self.connectedDevice != nil) {
            return
        }
        
        if (!findConnectedBoseDevice(connectedDevice: &self.connectedDevice, productId: &self.productId)) {
            #if DEBUG
            print("Connected bose device is not found.")
            #endif
            return
        }
        
        if (!openConnection(connectedDevice: self.connectedDevice, rfcommChannel: &self.connectedChannel)) {
            os_log("Failed to open rfcomm channel.", type: .error)
            return
        }
        
        self.disconnectBtUserNotification = self.connectedDevice?.register(forDisconnectNotification: self,
                                                                           selector: #selector(Bt.onDisconnectDetected))
    }
    
    private func openConnection(connectedDevice: IOBluetoothDevice!, rfcommChannel: inout IOBluetoothRFCOMMChannel!) -> Bool {
        
        assert(connectedDevice != nil, "connectedDevice == nil")
        
        var rfcommChannelId: BluetoothRFCOMMChannelID = 0
        
        let serialPortServiceRecode = connectedDevice.getServiceRecord(for: IOBluetoothSDPUUID(uuid16: 0x1101))
        if (serialPortServiceRecode == nil) {
            return false
        }
        
        if (serialPortServiceRecode!.getRFCOMMChannelID(&rfcommChannelId) != kIOReturnSuccess) {
            return false
        }
        
        if (connectedDevice.openRFCOMMChannelSync(&rfcommChannel,
                                                  withChannelID: rfcommChannelId,
                                                  delegate: self) != kIOReturnSuccess) {
            return false
        }
        
        return true
    }
    
    private func processPnPInfomation (_ device: IOBluetoothDevice) -> (venderId:Int, productId: Int)? {
        
        let uuid: BluetoothSDPUUID16 = 0x1200 // PnPInformation
        let spdUuid: IOBluetoothSDPUUID = IOBluetoothSDPUUID(uuid16: uuid)
        
        guard let serviceRecode = device.getServiceRecord(for: spdUuid) else {
            return nil
        }
        
        guard let venderId = serviceRecode.getAttributeDataElement(0x0201)?.getNumberValue() else {
            return nil
        }
//        print("venderId:\(venderId)")
        
        guard let productId = serviceRecode.getAttributeDataElement(0x0202)?.getNumberValue() else {
            return nil
        }
//        print("productId: \(productId)")
        
        /*guard let version = serviceRecode.getAttributeDataElement(0x0203)?.getNumberValue() else {
            return nil
        }
        print("version: \(version)")*/
        
        return (venderId.intValue, productId.intValue)
    }
    
    func sendGetAnrModePacket () -> Bool {
        guard var packet = Bose.generateGetAnrModePacket() else {
            os_log("Failed to generate getAnrModePacket.", type: .error)
            return false
        }
        return sendPacketSync(&packet)
    }
    
    func sendGetBassControlPacket () -> Bool {
        guard var packet = Bose.generateGetBassControlPacket() else {
            os_log("Failed to generate getBassControlPacket.", type: .error)
            return false
        }
        return sendPacketSync(&packet)
    }
    
    func sendGetBatteryLevelPacket () -> Bool {
        guard var packet = Bose.generateGetBatteryLevelPacket() else {
            os_log("Failed to generate getBatteryLevelPacket.", type: .error)
            return false
        }
        return sendPacketSync(&packet)
    }
    
    /*func sendPacketAsync(_ packet: inout [Int8]) {
        let result = self.connectedChannel?.writeAsync(&packet, length: UInt16(packet.count), refcon: &(self.delegate))
        if (result != kIOReturnSuccess) {
            os_log("Failed to send packet.", type: .error)
        } else {
            #if DEBUG
            print("[Sent]: \(packet)")
            #endif
        }
    }*/
    
    private func sendPacketSync(_ packet: inout [Int8]) -> Bool {
        let result = self.connectedChannel?.writeSync(&packet, length: UInt16(packet.count))
        if (result == nil || result != kIOReturnSuccess) {
            return false
        }
        #if DEBUG
        print("[Sent]: \(packet)")
        #endif
        return true
    }
    
    func sendSetGetAnrModePacket(_ anrMode: Bose.AnrMode) -> Bool {
        guard var packet = Bose.generateSetGetAnrModePacket(anrMode) else {
            os_log("Failed to generate setGetAnrPacket.", type: .error)
            return false
        }
        return sendPacketSync(&packet)
    }
    
    func sendSetGetBassControlPacket(_ step: Int) -> Bool {
        guard var packet = Bose.generateSetGetBassControlPacket(step) else {
            os_log("Failed to generate setGetBassControl packet.", type: .error)
            return false
        }
        return sendPacketSync(&packet)
    }
}

extension Bt: IOBluetoothRFCOMMChannelDelegate {
    
    func rfcommChannelClosed(_ rfcommChannel: IOBluetoothRFCOMMChannel!) {
//        print("rfcommChannelClosed")
        self.connectedChannel = nil
        self.connectedDevice = nil
        self.productId = nil
    }
    
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!,
                           data dataPointer: UnsafeMutableRawPointer!,
                           length dataLength: Int) {
        //        print("rfcommChannelData")
        var array = Array(UnsafeBufferPointer(start: dataPointer.assumingMemoryBound(to: Int8.self), count: dataLength))
        Bose.parsePacket(packet: &array, eventHandler: self.delegate)
    }
    
    func rfcommChannelOpenComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!,
                                   status error: IOReturn) {
//        print("rfcommChannelOpenComplete")
        // [重要] BmapVersionを取得しないと、一切データを送ってこない。
        guard var packet = Bose.generateGetBmapVersionPacket() else {
            assert(false, "Failed to generate getBmapVersionPacket @ Bt::rfcommChannelOpenComplete()")
            os_log("Failed to generate getBmapVersionPacket.", type: .error)
            self.closeConnection()
            self.delegate.bmapVersionEvent(nil)
            return
        }
        
        if (self.sendPacketSync(&packet) == false) {
            self.closeConnection()
            self.delegate.bmapVersionEvent(nil)
        }
    }
    
    /*func rfcommChannelWriteComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!,
                                    refcon: UnsafeMutableRawPointer!,
                                    status error: IOReturn) {
        print("rfcommChannelWriteComplete")
    }*/
}

protocol  BluetoothDelegate: EventHandler {
    func onConnect()
    func onDisconnect()
}

extension BluetoothDelegate {
    func bmapVersionEvent(_ version: String?) {
//        print("[BmapVersionEvent]: \(version)")
        if (version != nil) {
            self.onConnect()
        } else {
            self.onDisconnect()
        }
    }
}
