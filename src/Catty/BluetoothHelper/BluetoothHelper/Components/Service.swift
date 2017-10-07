/**
 *  Copyright (C) 2010-2017 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import UIKit
import CoreBluetooth

//MARK: Service
public final class Service : ServiceWrapper {
    
    internal var helper = ServiceHelper<Service>()
    private let profile         : ServiceProfile?
    internal let _peripheral    : Peripheral
    internal let cbService      : CBService
    
    internal var ownCharacteristics  = [CBUUID:Characteristic]()
    
    
    //MARK: init
    internal init(ownService:CBService, peripheral:Peripheral) {
        self.cbService = ownService
        self._peripheral = peripheral
        self.profile = ProfileManager.sharedInstance.serviceProfiles[cbService.uuid]
    }
    

    //MARK:getter
    public var characteristics : [Characteristic]{
        let values : [Characteristic] = [Characteristic](self.ownCharacteristics.values)
        return values
    }
    
    public var peripheral : Peripheral {
        return self._peripheral
    }
    
    //MARK:Characteristic
    public func discoverCharacteristics(_ characteristics:[CBUUID]) -> Future<Service> {
        return self.helper.discoverCharacteristicsIfConnected(self, characteristics:characteristics)
    }
    public func characteristic(_ uuid:CBUUID) -> Characteristic? {
        return self.ownCharacteristics[uuid]
    }
    public func didDiscoverCharacteristics(_ error:NSError?) {
        self.helper.didDiscoverCharacteristics(self, error:error)
    }
    
    //MARK: ServiceWrapper
    public var name : String {
        if let profile = self.profile {
            return profile.name
        } else {
            return "Unknown"
        }
    }
    
    public var uuid : CBUUID {
        return self.cbService.uuid
    }
    
    public var state : CBPeripheralState {
        return self.peripheral.state
    }
    
    public func discoverCharacteristics(_ characteristics:[CBUUID]?) {
        self.peripheral.cbPeripheral.discoverCharacteristics(characteristics, for:self.cbService)
    }
    
    public func initCharacteristics() {
        self.ownCharacteristics.removeAll()
        guard let ownChracteristics = self.cbService.characteristics else {
            NSLog("error")
            return
        }
        for cbCharacteristic in ownChracteristics {
            let ownCharacteristic = Characteristic(cbCharacteristic:cbCharacteristic, service:self)
            self.ownCharacteristics[ownCharacteristic.uuid] = ownCharacteristic
            ownCharacteristic.didDiscover()
//            NSLog("Characteristic uuid=\(ownCharacteristic.uuid.UUIDString), name=\(ownCharacteristic.name)")
        }
        
    }
    
    public func discoverAllCharacteristics() -> Future<Service> {
        return self.helper.discoverCharacteristicsIfConnected(self, characteristics:nil)
    }


}

//MARK: Service Implementation
public final class ServiceHelper<S:ServiceWrapper> {
    
    private var characteristicsDiscoveredPromise = Promise<S>()
    
    public init() {
    }
    
    
    public func discoverCharacteristicsIfConnected(_ service:S, characteristics:[CBUUID]?=nil) -> Future<S> {
//        NSLog("uuid=\(service.uuid.UUIDString), name=\(service.name)")
        self.characteristicsDiscoveredPromise = Promise<S>()
        if service.state == .connected {
            service.discoverCharacteristics(characteristics)
        } else {
            self.characteristicsDiscoveredPromise.failure(BluetoothError.peripheralDisconnected)
        }
        return self.characteristicsDiscoveredPromise.future
    }
    
    
    
    public func didDiscoverCharacteristics(_ service:S, error:NSError?) {
        if let error = error {
            self.characteristicsDiscoveredPromise.failure(error)
        } else {
            service.initCharacteristics()
            self.characteristicsDiscoveredPromise.success(service)
        }
    }
    
}
