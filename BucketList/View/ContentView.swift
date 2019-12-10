//
//  ContentView.swift
//  BucketList
//
//  Created by Mario Alberto Barragán Espinosa on 07/12/19.
//  Copyright © 2019 Mario Alberto Barragán Espinosa. All rights reserved.
//

import LocalAuthentication
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [CodableMKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingAlert = false
    @State private var showingEditScreen = false
    @State private var isUnlocked = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var loadSecondaryButton = true
    
    var renderAlert: Alert {
        if self.loadSecondaryButton {
            return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                self.showingEditScreen = true
            })
        }
        return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("OK")) {
            self.loadSecondaryButton = true
        })
    }
    
    var body: some View {
        ZStack {
            if self.isUnlocked {
                MainScreenView(centerCoordinate: $centerCoordinate, locations: $locations, selectedPlace: $selectedPlace, showingPlaceDetails: $showingAlert, showingEditScreen: $showingEditScreen, alertTitle: $alertTitle, alertMessage: $alertMessage)
            } else {
                Button("Unlock Places") {
                    self.authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .alert(isPresented: $showingAlert) {
            self.renderAlert
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
            if self.selectedPlace != nil {
                EditView(placemark: self.selectedPlace!)
            }
        }
        .onAppear(perform: loadData)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")

        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("Unable to load saved data.")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // error
                        self.showingAlert = true
                        self.alertTitle = "Error"
                        self.alertMessage = "Could not authenticate"
                        self.loadSecondaryButton = false
                    }
                }
            }
        } else {
            // no biometrics
            self.showingAlert = true
            self.alertTitle = "Error"
            self.alertMessage = "no biometrics on device"
            self.loadSecondaryButton = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
