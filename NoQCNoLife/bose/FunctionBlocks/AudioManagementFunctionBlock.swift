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

class AudioManagementFunctionBlock: FunctionBlock {
    /*
     GET_ALL = new FUNCTIONS("GET_ALL", 3, (byte)2);
     CONTROL = new FUNCTIONS("CONTROL", 4, (byte)3);
     STATUS = new FUNCTIONS("STATUS", 5, (byte)4);
     VOLUME = new FUNCTIONS("VOLUME", 6, (byte)5);
     NOW_PLAYING = new FUNCTIONS("NOW_PLAYING", 7, (byte)6);
     $VALUES = new FUNCTIONS[] { UNKNOWN, FUNCTION_BLOCK_INFO, SOURCE, GET_ALL, CONTROL, STATUS, VOLUME, NOW_PLAYING };
     */
    
    enum FunctionIds: Int8 {
        case FUNCTION_BLOCK_INFO, SOURCE, GET_ALL, CONTROL, STATUS, VOLUME, NOW_PLAYING
    }
    
    static let ID = BmapPacket.FunctionBlockIds.AUDIO_MANAGEMENT
    
    /*static func generateGetAllFunctionPacket() -> BmapPacket {
        return GetAllFunction.generateGetAllFunctionPacket()
    }*/
    
    /*static func generateGetSourcePacket() -> BmapPacket {
        return SourceFunction.generateGetSourcePacket()
    }*/
    
    /*static func generateStartNowPlayingPacket() -> BmapPacket {
        return NowPlayingFunction.generateStartNowPlayingPacket()
    }*/
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        switch bmapPacket.getFunctionId() {
//        case FunctionIds.GET_ALL.rawValue:
//            GetAllFunction.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
//        case FunctionIds.SOURCE.rawValue:
//            SourceFunction.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
        case FunctionIds.STATUS.rawValue:
            StatusFunction.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
        case FunctionIds.VOLUME.rawValue:
            VolumeFunction.parsePacket(bmapPacket:bmapPacket, eventHandler: eventHandler)
        case FunctionIds.NOW_PLAYING.rawValue:
            NowPlayingFunction.parsePacket(bmapPacket:bmapPacket, eventHandler: eventHandler)
        case nil:
            assert(false, "Invalid function id.")
            os_log("Invalid audio management function block packet.", type: .error)
        default:
            #if DEBUG
            print("Not implemented function: \(bmapPacket.getFunctionId()!)")
            print(bmapPacket.toString())
            #endif
        }
    }
}

/*private class SourceFunction: Function {
    
    private static let FUNCTION_BLOCK_ID = AudioManagementFunctionBlock.ID
    private static let FUNCTION_ID = AudioManagementFunctionBlock.FunctionIds.SOURCE
    
    static func generateGetSourcePacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.GET,
                          deviceId: 0,
                          port: 0,
                          payload: [])
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        print("SourceFunction::parsePacket()")
        print(bmapPacket.toString())
        
        if (bmapPacket.getOperatorId() != BmapPacket.OperatorIds.STATUS) {
            print("Invalid operator.")
            return;
        }
        
        guard let payload = bmapPacket.getPayload() else {
            print("payload is nil.")
            return
        }
        
        if (payload.count == 0) {
            print("Invalid payload.")
            return
        }
        
        
        let val1 = Int16(payload[0]) << 8 | Int16(payload[1])
        print("val1:\(val1)")
        
        let val2 = payload[2]
        print("val1:\(val2)")
        
        *//*if (arrayOfByte != null && (paramBmapPacket.getDataPayload()).length > 0) {
         a((io.intrepid.bose_bmap.c.c.a)new h(new AudioManagementPackets.b(i.a(arrayOfByte[0],
         arrayOfByte[1])), AudioControlSourceType.getByValue(arrayOfByte[2]),
         a(arrayOfByte, 3, arrayOfByte.length)), 5);
         return;
         }*//*
    }
}*/

/*private class GetAllFunction: Function {
    
    private static let FUNCTION_BLOCK_ID = AudioManagementFunctionBlock.ID
    private static let FUNCTION_ID = AudioManagementFunctionBlock.FunctionIds.GET_ALL
    
    static func generateGetAllFunctionPacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.START,
                          deviceId: 0,
                          port: 0,
                          payload: [])
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        print("AudioManagementFunctionBlock::GetAllFunction()")
        print(bmapPacket.toString())
    }
}*/

private class StatusFunction: Function {
    
    private static let FUNCTION_BLOCK_ID = AudioManagementFunctionBlock.ID
    private static let FUNCTION_ID = AudioManagementFunctionBlock.FunctionIds.STATUS
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        switch(bmapPacket.getOperatorId()) {
        case nil:
            print("Invalid operator")
        default:
            switch bmapPacket.getPayload()![0] {
            case 0:
                #if DEBUG
                print("[AudioManagement:StatusEvent]:STOP")
                #endif
            case 1:
                #if DEBUG
                print("[AudioManagement:StatusEvent]:PLAY")
                #endif
            case 2:
                #if DEBUG
                print("[AudioManagement:StatusEvent]:PAUSE")
                #endif
            default:
                #if DEBUG
                print("[AudioManagement:StatusEvent]:OTHER")
                #endif
            }
        }
    }
} // StatusFunction

private class VolumeFunction: Function {
    
    private static let FUNCTION_BLOCK_ID = AudioManagementFunctionBlock.ID
    private static let FUNCTION_ID = AudioManagementFunctionBlock.FunctionIds.VOLUME
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        if (bmapPacket.getOperatorId() != BmapPacket.OperatorIds.STATUS) {
            assert(false, "Invalid operator @  VolumeFunction::parsePacket()")
            return;
        }
        
        guard let payload: [Int8] = bmapPacket.getPayload() else {
            assert(false, "Invalid payload @ VolumeFunction::parsePacket()")
            return
        }
        if (payload.count > 1) {
            let maximumVolume = Int(UInt8(bitPattern: payload[0]))
            let currentVolume = Int(UInt8(bitPattern: payload[1]))
            #if DEBUG
            print("[VolumeEvent] maximum=\(maximumVolume), currentValue=\(currentVolume)")
            #endif
        }
    }
}

private class NowPlayingFunction: Function {
    
    private static let FUNCTION_BLOCK_ID = AudioManagementFunctionBlock.ID
    private static let FUNCTION_ID = AudioManagementFunctionBlock.FunctionIds.NOW_PLAYING
    
    static func generateStartNowPlayingPacket() -> BmapPacket {
        return BmapPacket(functionBlockId: self.FUNCTION_BLOCK_ID,
                          functionId: self.FUNCTION_ID.rawValue,
                          operatorId: BmapPacket.OperatorIds.START,
                          deviceId: 0,
                          port: 0,
                          payload: [])
    }
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        #if DEBUG
        print("NowPlayingFunction::parsePacket()")
        print(bmapPacket.toString())
        #endif
    }
}
