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

protocol FunctionBlock {
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler)
}

class FunctionBlockFactory {
    
    static func getFunctionBlockById(_ id: BmapPacket.FunctionBlockIds) -> FunctionBlock.Type? {
        switch id {
        case BmapPacket.FunctionBlockIds.PRODUCT_INFO:
            return ProductInfoFunctionBlock.self
        case BmapPacket.FunctionBlockIds.SETTINGS:
            return SettingsFunctionBlock.self
        case BmapPacket.FunctionBlockIds.STATUS:
            return StatusFunctionBlock.self
        case BmapPacket.FunctionBlockIds.DEVICE_MANAGEMENT:
            return DeviceManagementFunctionBlock.self
        case BmapPacket.FunctionBlockIds.AUDIO_MANAGEMENT:
            return AudioManagementFunctionBlock.self
        default:
            #if DEBUG
            print("Not implemented function block: \(id)")
            #endif
            return nil
        }
    }
}

protocol Function {
    static func parsePacket(bmapPacket: BmapPacket, eventHandler: EventHandler)
}
