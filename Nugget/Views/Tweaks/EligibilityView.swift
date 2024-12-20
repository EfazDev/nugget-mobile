//
//  EligibilityView.swift
//  Nugget
//
//  Created by lemin on 9/20/24.
//

import SwiftUI

struct EligibilityView: View {
    @StateObject var manager = EligibilityManager.shared
    @State var euEnabler: Bool = false
    @State var aiEnabler: Bool = false
    @State var changeDeviceModel: Bool = false
    @State private var CurrentSubTypeDisplay: String = "Default"
    @State private var CurrentSubType: String = "-1"

    struct DeviceSubType: Identifiable {
        var id = UUID()
        var key: String
        var title: String
        var alternateTitle: String?
        var minVersion: Version = Version(string: "18.1")
    }

    @State private var spoofDeviceStack: [DeviceSubType] = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [
                .init(key: "-1", title: NSLocalizedString("\(UIDevice().modelName) (\(EligibilityManager.shared.getDeviceCode())) (Original)", comment: "")),
                .init(key: "iPad16,1", title: NSLocalizedString("iPad Mini (A17 Pro) (W)", comment: "")),
                .init(key: "iPad16,2", title: NSLocalizedString("iPad Mini (A17 Pro) (C)", comment: "")),
            
                .init(key: "iPad16,5", title: NSLocalizedString("iPad Pro (13-inch) (M4) (W)", comment: "")),
                .init(key: "iPad16,6", title: NSLocalizedString("iPad Pro (13-inch) (M4) (C)", comment: "")),
                .init(key: "iPad16,3", title: NSLocalizedString("iPad Pro (11-inch) (M4) (W)", comment: "")),
                .init(key: "iPad16,4", title: NSLocalizedString("iPad Pro (11-inch) (M4) (C)", comment: "")),

                .init(key: "iPad14,5", title: NSLocalizedString("iPad Pro (12.9-inch) (M2) (W)", comment: "")),
                .init(key: "iPad14,6", title: NSLocalizedString("iPad Pro (12.9-inch) (M2) (C)", comment: "")),
                .init(key: "iPad14,3", title: NSLocalizedString("iPad Pro (11-inch) (M2) (W)", comment: "")),
                .init(key: "iPad14,4", title: NSLocalizedString("iPad Pro (11-inch) (M2) (C)", comment: "")),
                .init(key: "iPad14,10", title: NSLocalizedString("iPad Air (13-inch) (M2) (W)", comment: "")),
                .init(key: "iPad14,11", title: NSLocalizedString("iPad Air (13-inch) (M2) (C)", comment: "")),
                .init(key: "iPad14,8", title: NSLocalizedString("iPad Air (11-inch) (M2) (W)", comment: "")),
                .init(key: "iPad14,9", title: NSLocalizedString("iPad Air (11-inch) (M2) (C)", comment: "")),

                .init(key: "iPad13,4", title: NSLocalizedString("iPad Pro (11-inch) (M1) (W)", comment: "")),
                .init(key: "iPad13,5", title: NSLocalizedString("iPad Pro (11-inch) (M1) (C)", comment: "")),
                .init(key: "iPad13,8", title: NSLocalizedString("iPad Pro (12.9-inch) (M1) (W)", comment: "")),
                .init(key: "iPad13,9", title: NSLocalizedString("iPad Pro (12.9-inch) (M1) (C)", comment: "")),
                .init(key: "iPad13,16", title: NSLocalizedString("iPad Air (M1) (W)", comment: "")),
                .init(key: "iPad13,17", title: NSLocalizedString("iPad Air (M1) (C)", comment: "")),
            ]
        } else {
            return [
                .init(key: "-1", title: NSLocalizedString("\(UIDevice().modelName) (OG)", comment: EligibilityManager.shared.getDeviceCode())),
                .init(key: "iPhone16,1", title: NSLocalizedString("iPhone 15 Pro", comment: "")),
                .init(key: "iPhone16,2", title: NSLocalizedString("iPhone 15 Pro Max", comment: "")),
                .init(key: "iPhone17,3", title: NSLocalizedString("iPhone 16", comment: "")),
                .init(key: "iPhone17,4", title: NSLocalizedString("iPhone 16 Plus", comment: "")),
                .init(key: "iPhone17,1", title: NSLocalizedString("iPhone 16 Pro", comment: "")),
                .init(key: "iPhone17,2", title: NSLocalizedString("iPhone 16 Pro Max", comment: ""))
            ]
        }
    }()
    
    var body: some View {
        List {
            // MARK: EU Enabler
//            Section {
//                Toggle(isOn: $euEnabler) {
//                    Text("Enable EU Sideloading")
//                }.onChange(of: euEnabler) { nv in
//                    manager.euEnabler = nv
//                }
//            } header: {
//                Text("EU Enabler")
//            }
            
            // MARK: AI Enabler
            if #available(iOS 18.1, *) {
                Section {
                    Toggle(isOn: $aiEnabler) {
                        HStack {
                            Text("Enable Apple Intelligence")
                            Spacer()
                            Button(action: {
                                showInfoAlert(NSLocalizedString("Enables Apple Intelligence on unsupported devices. It may take a long time to download, be patient and check [Settings] -> General -> iPhone/iPad Storage -> iOS -> Apple Intelligence to see if it is downloading.\n\nIf it doesn't apply, try applying again.", comment: "AI info popup"))
                            }) {
                                Image(systemName: "info.circle")
                            }
                        }
                    }.onChange(of: aiEnabler) { nv in
                        manager.toggleAI(nv)
                    }
                    if aiEnabler {
                        Toggle(isOn: $changeDeviceModel) {
                            HStack {
                                Text("Spoof Device Model")
                                Spacer()
                                Button(action: {
                                    showInfoAlert(NSLocalizedString("Spoofs your device model to the selected device that supports Apple Intelligence, allowing you to download the AI models. \n\nWARNING: Enabling Apple Intelligence while not spoofing a device that supports AI will cause a redownload which will never end. Please be warned!!", comment: "Device model changer info popup"))
                                }) {
                                    Image(systemName: "info.circle")
                                }
                            }
                        }.onChange(of: changeDeviceModel) { nv in
                            manager.setDeviceModelCode(nv, CurrentSubType)
                        }
                        if changeDeviceModel {
                            Section {
                                // device subtype
                                HStack {
                                    Image(systemName: "ipodtouch")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.blue)
                                    
                                    Text("Spoofing Model").minimumScaleFactor(0.5)
                                    Spacer()
                                    
                                    Picker(selection: $CurrentSubType, label: Text("")) {
                                        ForEach(spoofDeviceStack) { device in
                                            Text(device.title)
                                                .tag(device.key)
                                                .font(.system(size: 12))
                                        }
                                    }
                                    .onChange(of: CurrentSubType) { nv in
                                        if let selectedDevice = spoofDeviceStack.first(where: { $0.key == String(nv) }) {
                                            CurrentSubTypeDisplay = selectedDevice.title
                                            manager.setDeviceModelCode(changeDeviceModel, String(nv))
                                        }
                                    }
                                    .pickerStyle(DefaultPickerStyle())
                                }
                            }
                        }
                    }
                } header: {
                    Text("AI Enabler")
                } footer: {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        Text("* (C = Cellular, W = Wi-Fi)").minimumScaleFactor(0.5)
                    }
                }
            }
        }
        .tweakToggle(for: .Eligibility)
        .navigationTitle("Eligibility")
        .onAppear {
            euEnabler = manager.euEnabler
            aiEnabler = manager.aiEnabler
            changeDeviceModel = manager.spoofingDevice
            CurrentSubType = manager.selectedModel
            for dev in spoofDeviceStack.reversed() {
                if dev.key == CurrentSubType {
                    CurrentSubTypeDisplay = dev.title
                }
            }
        }
    }
    
    func showInfoAlert(_ body: String) {
        UIApplication.shared.alert(title: "Info", body: body)
    }
}
