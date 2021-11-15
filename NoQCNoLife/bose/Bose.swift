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

class Bose {
    
    private static let VENDER_ID: Int = 158
    
    enum AnrMode: Int8, CaseIterable {
        case OFF, HIGH, WIND, LOW
        /*HIGH = new AnrMode("HIGH", 1, 1, "High");
         WIND = new AnrMode("WIND", 2, 2, "Wind");
         LOW = new AnrMode("LOW", 3, 3, "Low");
         $VALUES = new AnrMode[] { OFF, HIGH, WIND, LOW }*/
        
        func toString() -> String {
            switch self {
            case .OFF: return "Off"
            case .HIGH: return "High"
            case .WIND: return "Wind"
            case .LOW: return "Low"
            }
        }
    }
    
    
    enum Products {
//        case ISAAC,
        case WOLFCASTLE
        /*ICE, FOREMAN, POWDER, FLURRY, HARVEY, FOLGERS,*/
        case KLEOS
        /*LEVI, LEVI_SLAVE, MINNOW,*/
        case BAYWOLF
        /*, ATLAS, BB2, CHIBI, STETSON, LEVI_CASE, MOONRAKER, CHAMP,
        KCUP, BB1*/
        
        static func getById(_ id: Int!) -> Products? {
            switch id {
//            case 16394: return .ISAAC
            case 16396: return .WOLFCASTLE
//            case 16402: return .ICE
//            case 16397: return .FOREMAN
//            case 16404: return .POWDER
//            case 16403: return .FLURRY
//            case 16401: return .HARVEY
//            case 16400: return .FOLGERS
            case 16407: return .KLEOS
//            case 16408: return .LEVI
//            case 16409: return .LEVI_SLAVE
//            case 16418: return .MINNOW
            case 16416: return .BAYWOLF
//            case 16417: return .ATLAS
//            case 6258: return .BB2
//            case 41489: return .CHIBI
//            case 16405: return .STETSON
//            case 16410: return .LEVI_CASE
//            case 16392: return .MOONRAKER
//            case 16390: return .CHAMP
//            case 16393: return .KCUP
//            case 6249: return .BB1
            default: return nil
            }
        }
        
        func getId() -> Int {
            switch self {
//            case .ISAAC: return 16394
            case .WOLFCASTLE: return 16396
//            case .ICE: return 16402
//            case .FOREMAN: return 16397
//            case .POWDER: return 16404
//            case .FLURRY: return 16403
//            case .HARVEY: return 16401
//            case .FOLGERS: return 16400
            case .KLEOS: return 16407
//            case .LEVI: return 16408
//            case .LEVI_SLAVE: return 16409
//            case .MINNOW: return 16418
            case .BAYWOLF: return 16416
//            case .ATLAS: return 16417
//            case .BB2: return 6258
//            case .CHIBI: return 41489
//            case .STETSON: return 16405
//            case .LEVI_CASE: return 16410
//            case .MOONRAKER: return 16392
//            case .CHAMP: return 16390
//            case .KCUP: return 16393
//            case .BB1: return 6249
            }
        }
        
        func getName() -> String {
            switch self {
//            case .ISAAC: return "Bose AE2 SoundLink"
            case .WOLFCASTLE: return "QuietComfort 35"
//            case .ICE: return "Bose SoundSport"
//            case .FOREMAN: return "Bose SoundLink Color II"
//            case .POWDER: return "Bose QuietControl 30"
//            case .FLURRY: return "Bose SoundSport Pulse"
//            case .HARVEY: return "Bose Revolve+ Soundlink"
//            case .FOLGERS: return "Bose Revolve Soundlink"
            case .KLEOS: return "SoundWear"
//            case .LEVI: return "Bose SoundSport Free"
//            case .LEVI_SLAVE: return "Bose SoundSport Free"
//            case .MINNOW: return "Bose SoundLink Micro"
            case .BAYWOLF: return "QuietComfort 35 Series 2"
//            case .ATLAS: return "Bose Aviation Headset"
//            case .BB2: return "BOSEbuild:2 (UNLISTED; DEV ONLY)"
//            case .CHIBI: return "Bose Chibi"
//            case .STETSON: return "Bose Hearphones"
//            case .LEVI_CASE: return "Levi Case"
//            case .MOONRAKER: return "SoundLink (UNLISTED; DEV ONLY)"
//            case .CHAMP: return "SoundLink Color (UNLISTED; DEV ONLY)"
//            case .KCUP: return "SoundLink Mini II (UNLISTED; DEV ONLY)"
//            case .BB1: return "BOSEbuild:1 (UNLISTED; DEV ONLY)"
            }
        }
        
        /*
         ICE = new BoseProductId("ICE", 2, 2, 16402, "Bose SoundSport");
         FOREMAN = new BoseProductId("FOREMAN", 3, 5, 16397, "Bose SoundLink Color II", 1);
         POWDER = new BoseProductId("POWDER", 4, 4, 16404, "Bose QuietControl 30");
         FLURRY = new BoseProductId("FLURRY", 5, 3, 16403, "Bose SoundSport Pulse");
         HARVEY = new BoseProductId("HARVEY", 6, 7, 16401, "Bose Revolve+ Soundlink", 1);
         FOLGERS = new BoseProductId("FOLGERS", 7, 6, 16400, "Bose Revolve Soundlink", 1);
         KLEOS = new BoseProductId("KLEOS", 8, 8, 16407, "Bose SoundWear");
         LEVI = new BoseProductId("LEVI", 9, 10, 16408, "Bose SoundSport Free");
         LEVI_SLAVE = new BoseProductId("LEVI_SLAVE", 10, 11, 16409, "Bose SoundSport Free");
         MINNOW = new BoseProductId("MINNOW", 11, 12, 16418, "Bose SoundLink Micro");
         BAYWOLF = new BoseProductId("BAYWOLF", 12, 9, 16416, "Bose QuietComfort 35 Series 2");
         ATLAS = new BoseProductId("ATLAS", 13, 13, 16417, "Bose Aviation Headset");
         BB2 = new BoseProductId("BB2", 14, 14, 6258, "BOSEbuild:2 (UNLISTED; DEV ONLY)", 1);
         CHIBI = new BoseProductId("CHIBI", 15, 21, 41489, "Bose Chibi", 1);
         STETSON = new BoseProductId("STETSON", 16, -1, 16405, "Bose Hearphones", a.a());
         LEVI_CASE = new BoseProductId("LEVI_CASE", 17, -1, 16410, "Levi Case");
         MOONRAKER = new BoseProductId("MOONRAKER", 18, -1, 16392, "SoundLink (UNLISTED; DEV ONLY)");
         CHAMP = new BoseProductId("CHAMP", 19, -1, 16390, "SoundLink Color (UNLISTED; DEV ONLY)", 1);
         KCUP = new BoseProductId("KCUP", 20, -1, 16393, "SoundLink Mini II (UNLISTED; DEV ONLY)", 1);
         BB1 = new BoseProductId("BB1", 21, -1, 6249, "BOSEbuild:1 (UNLISTED; DEV ONLY)", 1);
         UNKNOWN = new BoseProductId("UNKNOWN", 22, -1, 0, "Unknown Device");
         $VALUES = new BoseProductId[] {
         ISAAC, WOLFCASTLE, ICE, FOREMAN, POWDER, FLURRY, HARVEY, FOLGERS, KLEOS, LEVI,
         LEVI_SLAVE, MINNOW, BAYWOLF, ATLAS, BB2, CHIBI, STETSON, LEVI_CASE, MOONRAKER, CHAMP,
         KCUP, BB1, UNKNOWN };
         */
        /*
         ATLAS,
         BAYWOLF,
         BB1,
         BB2,
         CHAMP,
         CHIBI,
         FLURRY,
         FOLGERS,
         FOREMAN,
         HARVEY,
         ICE,
         ISAAC(0, 16394, "Bose AE2 SoundLink"),
         KCUP(0, 16394, "Bose AE2 SoundLink"),
         KLEOS(0, 16394, "Bose AE2 SoundLink"),
         LEVI(0, 16394, "Bose AE2 SoundLink"),
         LEVI_CASE(0, 16394, "Bose AE2 SoundLink"),
         LEVI_SLAVE(0, 16394, "Bose AE2 SoundLink"),
         MINNOW(0, 16394, "Bose AE2 SoundLink"),
         MOONRAKER(0, 16394, "Bose AE2 SoundLink"),
         POWDER(0, 16394, "Bose AE2 SoundLink"),
         STETSON(0, 16394, "Bose AE2 SoundLink"),
         UNKNOWN(0, 16394, "Bose AE2 SoundLink"),
         WOLFCASTLE(1, 16396, "Bose QuietComfort 35");
         */
    }
    
    static func isSupportedBoseProduct(venderId: Int, productId: Int) -> Bool {
        return venderId == self.VENDER_ID && self.Products.getById(productId) != nil ? true : false
    }
    
    static func parsePacket(packet: inout [Int8], eventHandler: EventHandler) {
        let bmapPacket = BmapPacket(&packet)
        guard let functionBlockId = bmapPacket.getFunctionBlockId() else {
            assert(false, "Invalid function block id @ Bose::parsePacket()")
            return
        }
        let functionBlock = FunctionBlockFactory.getFunctionBlockById(functionBlockId)
        functionBlock?.parsePacket(bmapPacket: bmapPacket, eventHandler: eventHandler)
    }
    
    //
    // ProductInfo fuction block
    //
    static func generateGetBmapVersionPacket() -> [Int8]? {
        return  ProductInfoFunctionBlock.generateGetBmapVersionPacket().getPacket()
    }
    
    //
    // Settings function block
    //
    static func generateGetAnrModePacket() -> [Int8]? {
        return SettingsFunctionBlock.generateGetAnrModePacket().getPacket()
    }
    
    static func generateGetBassControlPacket() -> [Int8]? {
        return SettingsFunctionBlock.generateGetBassControlPacket().getPacket()
    }
    
    static func generateSetGetAnrModePacket(_ mode: Bose.AnrMode) -> [Int8]? {
        return SettingsFunctionBlock.generateSetGetAnrModePacket(mode).getPacket()
    }
    
    static func generateSetGetBassControlPacket(_ step: Int) -> [Int8]? {
        return SettingsFunctionBlock.generateSetGetBassControllPacket(step).getPacket()
    }
    
    //
    // Status function blcok
    //
    static func generateGetBatteryLevelPacket() -> [Int8]? {
        return StatusFunctionBlock.generateGetBatteryLevelPacket().getPacket()
    }
}

