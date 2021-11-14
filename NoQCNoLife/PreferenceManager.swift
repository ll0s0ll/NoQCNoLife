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

import Cocoa

class PreferenceManager {
    
    static let LAST_SELECTED_ANR_MODE_KEY: String = "lastSelectedAnrMode"
    
    static func getLastSelectedAnrMode(_ product: Bose.ProductIds) -> Bose.AnrMode? {
        let storedObject = UserDefaults.standard.dictionary(forKey: LAST_SELECTED_ANR_MODE_KEY)
        if let storedValue = storedObject?[String(product.getProductId())] as? Int8 {
            return Bose.AnrMode(rawValue: storedValue)
        } else {
            return nil
        }
    }
    
    static func setLastSelectedAnrMode(product: Bose.ProductIds, anrMode: Bose.AnrMode) {
        
        var storedObject = UserDefaults.standard.dictionary(forKey: LAST_SELECTED_ANR_MODE_KEY)
        
        if (storedObject == nil) {
            storedObject = [String(product.getProductId()): anrMode.rawValue] as [String: Any]
        } else {
            storedObject![String(product.getProductId())] = anrMode.rawValue
        }
        
        UserDefaults.standard.set(storedObject, forKey: LAST_SELECTED_ANR_MODE_KEY)
    }
    
    static func removeLastSelectedAnrMode() {
        UserDefaults.standard.removeObject(forKey: LAST_SELECTED_ANR_MODE_KEY)
    }
}
