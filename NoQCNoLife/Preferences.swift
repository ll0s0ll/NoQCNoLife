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

class Preferences {
    
    static let LAST_SELECTED_ANR_MODE_KEY: String = "lastSelectedAnrMode"
    
    static func getLastSelectedAnrMode() -> Bose.AnrMode? {
        // integer()は値が存在しない場合も0を返すので、値が0なのか、値が存在しないのか判別できない。使えない。
        // let rawValue = UserDefaults.standard.integer(forKey: LAST_SELECTED_ANR_MODE_KEY)
        // return rawValue == 0 ? nil : Bose.AnrMode(rawValue: Int8(rawValue))
        
        let object = UserDefaults.standard.object(forKey: LAST_SELECTED_ANR_MODE_KEY)
        return object == nil ? nil : Bose.AnrMode(rawValue: object as! Int8)
    }
    
    static func setLastSelectedAnrMode(_ anrMode: Bose.AnrMode) {
        UserDefaults.standard.set(Int(anrMode.rawValue), forKey: LAST_SELECTED_ANR_MODE_KEY)
    }
    
    static func removeLastSelectedAnrMode() {
        UserDefaults.standard.removeObject(forKey: LAST_SELECTED_ANR_MODE_KEY)
    }
}
