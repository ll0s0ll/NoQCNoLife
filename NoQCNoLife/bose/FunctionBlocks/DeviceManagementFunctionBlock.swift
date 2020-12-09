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

class DeviceManagementFunctionBlock: FunctionBlock {
    
    /*
     CONNECT = new FUNCTIONS("CONNECT", 2, (byte)1);
     DISCONNECT = new FUNCTIONS("DISCONNECT", 3, (byte)2);
     REMOVE_DEVICE = new FUNCTIONS("REMOVE_DEVICE", 4, (byte)3);
     LIST_DEVICES = new FUNCTIONS("LIST_DEVICES", 5, (byte)4);
     INFO = new FUNCTIONS("INFO", 6, (byte)5);
     EXTENDED_INFO = new FUNCTIONS("EXTENDED_INFO", 7, (byte)6);
     CLEAR_DEVICE_LIST = new FUNCTIONS("CLEAR_DEVICE_LIST", 8, (byte)7);
     PAIRING_MODE = new FUNCTIONS("PAIRING_MODE", 9, (byte)8);
     LOCAL_MAC_ADDRESS = new FUNCTIONS("LOCAL_MAC_ADDRESS", 10, (byte)9);
     PREPARE_P2P = new FUNCTIONS("PREPARE_P2P", 11, (byte)10);
     P2P_MODE = new FUNCTIONS("P2P_MODE", 12, (byte)11);
     ROUTING = new FUNCTIONS("ROUTING", 13, (byte)12);
     $VALUES = new FUNCTIONS[] {
     UNKNOWN, FUNCTION_BLOCK_INFO, CONNECT, DISCONNECT, REMOVE_DEVICE, LIST_DEVICES, INFO, EXTENDED_INFO, CLEAR_DEVICE_LIST, PAIRING_MODE,
     LOCAL_MAC_ADDRESS, PREPARE_P2P, P2P_MODE, ROUTING };
     */
    
    static let id = BmapPacket.FunctionBlockIds.DEVICE_MANAGEMENT
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
        switch bmapPacket.getFunctionId() {
        case ConnectFunction.id:
            ConnectFunction.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
        case DisconnectFunction.id:
            DisconnectFunction.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
        case nil:
            assert(false, "Invalid function id.")
        default:
            print("Not implemented func: \(bmapPacket.getFunctionId()!) @ DeviceManagementFunctionBlock")
            print(bmapPacket.toString())
        }
    }
}

private class ConnectFunction : Function {
    
    static let id: Int8 = 1

    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
//        print("[ConnectEvent]")
    }
}


private class DisconnectFunction: Function {
    
    static let id: Int8 = 2
    
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler) {
//        print("[DisconnectEvent]")
    }
}
