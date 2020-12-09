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

class SettingsFunctionBlock : FunctionBlock {
    /*
     STANDBY_TIMER = new FUNCTIONS("STANDBY_TIMER", 5, (byte)4);
     CNC = new FUNCTIONS("CNC", 6, (byte)5);
     ANR = new FUNCTIONS("ANR", 7, (byte)6);
     BASS_CONTROL = new FUNCTIONS("BASS_CONTROL", 8, (byte)7);
     ALERTS = new FUNCTIONS("ALERTS", 9, (byte)8);
     BUTTONS = new FUNCTIONS("BUTTONS", 10, (byte)9);
     MULTIPOINT = new FUNCTIONS("MULTIPOINT", 11, (byte)10);
     $VALUES = new FUNCTIONS[] {
     UNKNOWN, FUNCTION_BLOCK_INFO, GET_ALL, PRODUCT_NAME, VOICE_PROMPTS, STANDBY_TIMER, CNC, ANR, BASS_CONTROL, ALERTS,
     BUTTONS, MULTIPOINT };
     */
    
    static let ID = BmapPacket.FunctionBlockIds.SETTINGS
    
    enum FunctionIds: Int8 {
        case FUNCTION_BLOCK_INFO, GET_ALL, PRODUCT_NAME, VOICE_PROMPTS, STANDBY_TIMER, CNC, ANR, BASS_CONTROL, ALERTS,
        BUTTONS, MULTIPOINT
    }
    
    
    static func generateGetAnrModePacket() -> BmapPacket {
        return AnrModeFunction.generateGetAnrModePacket()
    }
    
    static func generateSetGetAnrModePacket(_ anrMode: Bose.AnrMode) -> BmapPacket {
        return AnrModeFunction.generateSetGetAnrModePacket(anrMode)
    }
    
    /*static func generateGetMultiPointPacket() -> BmapPacket {
        return MultiPointFunction.generateGetMultiPointPacket()
    }
    
    static func generateSetGetMultiPointPacket() -> BmapPacket {
        return MultiPointFunction.generateSetGetMultiPointPacket()
    }*/
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        switch bmapPacket.getFunctionId() {
        case FunctionIds.ANR.rawValue:
            AnrModeFunction.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
        case nil:
            assert(false, "Invalid function id.")
            os_log("Invalid settings function block packet.", type: .error)
        default:
            #if DEBUG
            print("Not implemented func: \(String(describing: bmapPacket.getFunctionId())) @ SettingsFunctionBlock")
            print(bmapPacket.toString())
            #endif
        }
    }
}


private class AnrModeFunction: Function {
    
    static let FUNCTION_BLOCK_ID = SettingsFunctionBlock.ID
    static let FUNCTION_ID = SettingsFunctionBlock.FunctionIds.ANR
    
    static func generateGetAnrModePacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.GET,
                          deviceId: 0,
                          port: 0,
                          payload: [])
    }
    
    static func generateSetGetAnrModePacket(_ anrMode: Bose.AnrMode) -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.SET_GET,
                          deviceId: 0,
                          port: 0,
                          payload: [anrMode.rawValue])
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        if (bmapPacket.getOperatorId() != BmapPacket.OperatorIds.STATUS) {
            assert(false, "Invalid operator.")
            os_log("Invalid anr mode packet.", type: .error)
            eventHandler.noiseCancelModeChanged(nil)
            return
        }
        
        let payload: [Int8]! = bmapPacket.getPayload()
        if (payload == nil || payload.count == 0) {
            assert(false, "Invalid payload.")
            os_log("Invalid anr mode packet.", type: .error)
            eventHandler.noiseCancelModeChanged(nil)
            return
        }
        
        // TODO Implement supportedAnrMode
        let currentAnrModeVal = payload[0]
        guard let anrMode = Bose.AnrMode(rawValue: currentAnrModeVal) else {
            assert(false, "Unknown anr mode: \(currentAnrModeVal)")
            os_log("Invalid anr mode packet.", type: .error)
            eventHandler.noiseCancelModeChanged(nil)
            return
        }
        
        eventHandler.noiseCancelModeChanged(anrMode)
    }
} // AnrModeFunction


/*private class MultiPointFunction: Function {
    
    static let FUNCTION_BLOCK_ID = SettingsFunctionBlock.ID
    static let FUNCTION_ID = SettingsFunctionBlock.FunctionIds.MULTIPOINT
    
    static func generateGetMultiPointPacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.GET,
                          deviceId: 0,
                          port: 0,
                          payload: [])
    }
    
    static func generateSetGetMultiPointPacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.SET_GET,
                          deviceId: 0,
                          port: 0,
                          payload: [0])
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        print("MultiPointFunction::parsePacket()")
    }
}*/ // MultiPointFunction
