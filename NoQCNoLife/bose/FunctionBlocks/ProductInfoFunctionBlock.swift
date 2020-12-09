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

class ProductInfoFunctionBlock: FunctionBlock {
    /*
     BMAP_VERSION = new FUNCTIONS("BMAP_VERSION", 2, (byte)1);
     ALL_FUNCTION_BLOCKS = new FUNCTIONS("ALL_FUNCTION_BLOCKS", 3, (byte)2);
     PRODUCT_ID_VARIANT = new FUNCTIONS("PRODUCT_ID_VARIANT", 4, (byte)3);
     GET_ALL_FUNCTIONS = new FUNCTIONS("GET_ALL_FUNCTIONS", 5, (byte)4);
     FIRMWARE_VERSION = new FUNCTIONS("FIRMWARE_VERSION", 6, (byte)5);
     MAC_ADDRESS = new FUNCTIONS("MAC_ADDRESS", 7, (byte)6);
     SERIAL_NUMBER = new FUNCTIONS("SERIAL_NUMBER", 8, (byte)7);
     HARDWARE_REVISION = new FUNCTIONS("HARDWARE_REVISION", 9, (byte)10);
     COMPONENT_DEVICES = new FUNCTIONS("COMPONENT_DEVICES", 10, (byte)11);
     $VALUES = new FUNCTIONS[] {
     UNKNOWN, FUNCTION_BLOCK_INFO, BMAP_VERSION, ALL_FUNCTION_BLOCKS, PRODUCT_ID_VARIANT, GET_ALL_FUNCTIONS, FIRMWARE_VERSION, MAC_ADDRESS, SERIAL_NUMBER, HARDWARE_REVISION,
     COMPONENT_DEVICES };
     */
    
    enum FunctionIds: Int8 {
        case FUNCTION_BLOCK_INFO,
        BMAP_VERSION,
        ALL_FUNCTION_BLOCKS,
        PRODUCT_ID_VARIANT,
        GET_ALL_FUNCTIONS,
        FIRMWARE_VERSION,
        MAC_ADDRESS,
        SERIAL_NUMBER,
        UNDEFINED_1,
        UNDEFINED_2,
        HARDWARE_REVISION,
        COMPONENT_DEVICES/*,
        UNKNOWN*/
    }
    
    /*static func generateGetAllFunctionBlocksPacket() -> BmapPacket {
        return AllFunctionBlocksFunction.generateGetAllFunctionBlocksPacket()
    }*/
    
    static func generateGetBmapVersionPacket() -> BmapPacket {
        return BmapVersionFunction.generateGetBmapVersionPacket()
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        guard let functionId = bmapPacket.getFunctionId() else {
            assert(false, "Invalid function id @ ProductInfoFunctionBlock::parsePacket")
            os_log("Invalid productInfo function block packet.", type: .error)
            return
        }
        
        switch self.FunctionIds(rawValue: functionId) {
        case self.FunctionIds.BMAP_VERSION:
            BmapVersionFunction.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
//        case self.FunctionIds.ALL_FUNCTION_BLOCKS:
//            AllFunctionBlocksFunction.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
        default:
            #if DEBUG
            print("Not implemented func: \(bmapPacket.getFunctionId()!) @ ProductInfoFunctionBlock")
            print(bmapPacket.toString())
            #endif
        }
    }
}

private class BmapVersionFunction : Function {
    
    private static let FUNCTION_BLOCK_ID = BmapPacket.FunctionBlockIds.PRODUCT_INFO
    private static let FUNCTION_ID = ProductInfoFunctionBlock.FunctionIds.BMAP_VERSION
    
    static func generateGetBmapVersionPacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.GET,
                          deviceId: 0,
                          port: 0,
                          payload: [])
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        let payload: [Int8]! = bmapPacket.getPayload()
        if (payload == nil || payload.count == 0) {
            assert(false, "Invalid payload @ BmapVersionFunction::parsePacket()")
            os_log("Invalid bmap version packet.", type: .error)
            eventHandler.bmapVersionEvent(nil)
            return
        }
        
        var versionStr = ""
        for data in payload {
            guard let scaler = UnicodeScalar(Int(UInt8(bitPattern: data))) else {
                continue
            }
            versionStr.append(String(scaler))
        }
        
        eventHandler.bmapVersionEvent(versionStr)
    }
}

/*private class AllFunctionBlocksFunction: Function {
    
    private static let FUNCTION_BLOCK_ID = BmapPacket.FunctionBlockIds.PRODUCT_INFO
    private static let FUNCTION_ID = ProductInfoFunctionBlock.FunctionIds.ALL_FUNCTION_BLOCKS
    
    static func generateGetAllFunctionBlocksPacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.GET,
                          deviceId: 0,
                          port: 0,
                          payload: [])
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        var versionStr = ""
        for data in bmapPacket.getPayload() ?? [] {
            guard let scaler = UnicodeScalar(Int(UInt8(bitPattern: data))) else {
                continue
            }
            versionStr.append(String(scaler))
        }
        print("[AllFunctionBlocksEvent]: \(versionStr)")
    }
}*/
