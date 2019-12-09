//
//  MKPointAnnotation-ObservableObject.swift
//  BucketList
//
//  Created by Mario Alberto Barragán Espinosa on 07/12/19.
//  Copyright © 2019 Mario Alberto Barragán Espinosa. All rights reserved.
//

import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            self.title ?? "Unknown value"
        }

        set {
            title = newValue
        }
    }

    public var wrappedSubtitle: String {
        get {
            self.subtitle ?? "Unknown value"
        }

        set {
            subtitle = newValue
        }
    }
}
