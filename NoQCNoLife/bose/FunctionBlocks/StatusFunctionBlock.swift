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

import os.log

class StatusFunctionBlock: FunctionBlock {
    /*
     BATTERY_LEVEL = new FUNCTIONS("BATTERY_LEVEL", 3, (byte)2);
     AUX_CABLE_DETECTION = new FUNCTIONS("AUX_CABLE_DETECTION", 4, (byte)3);
     MIC_LEVEL = new FUNCTIONS("MIC_LEVEL", 5, (byte)4);
     CHARGER_DETECT = new FUNCTIONS("CHARGER_DETECT", 6, (byte)5);
     $VALUES = new FUNCTIONS[] { UNKNOWN, FUNCTION_BLOCK_INFO, GET_ALL_FUNCTIONS, BATTERY_LEVEL, AUX_CABLE_DETECTION, MIC_LEVEL, CHARGER_DETECT };
     */
    static let ID = BmapPacket.FunctionBlockIds.STATUS
    
    enum FunctionIds: Int8 {
        case FUNCTION_BLOCK_INFO, GET_ALL_FUNCTIONS, BATTERY_LEVEL, AUX_CABLE_DETECTION, MIC_LEVEL, CHARGER_DETECT
    }
    
    static func generateGetBatteryLevelPacket() -> BmapPacket {
        return BatteryLevelFunction.generateGetBatteryLevelPacket()
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        switch bmapPacket.getFunctionId() {
        case FunctionIds.BATTERY_LEVEL.rawValue:
            BatteryLevelFunction.parsePacket(bmapPacket:bmapPacket, eventHandler: eventHandler)
        case nil:
            assert(false, "Invalid function id.")
            os_log("Invalid status function block packet.", type: .error)
        default:
            #if DEBUG
            print("Not implemented function \(bmapPacket.getFunctionId()!) @ StatusFunctionBlock")
            print(bmapPacket.toString())
            #endif
        }
    }
}

private class BatteryLevelFunction: Function {
    
    static let FUNCTION_BLOCK_ID = StatusFunctionBlock.ID
    static let FUNCTION_ID = StatusFunctionBlock.FunctionIds.BATTERY_LEVEL
    
    static func generateGetBatteryLevelPacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.GET,
                          deviceId: 0,
                          port: 0,
                          payload: [])
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        if (bmapPacket.getOperatorId() != BmapPacket.OperatorIds.STATUS) {
            assert(false, "Invalid operator.")
            os_log("Invalid battery level packet.", type: .error)
            eventHandler.batteryLevelStatus(nil)
            return;
        }
        
        let payload: [Int8]! = bmapPacket.getPayload()
        if (payload == nil || payload.count == 0) {
            assert(false, "Invalid payload.")
            os_log("Invalid battery level packet.", type: .error)
            eventHandler.batteryLevelStatus(nil)
            return
        }
        
        eventHandler.batteryLevelStatus(Int(UInt8(bitPattern: payload[0])))
    }
} // BatteryLevelFunction
