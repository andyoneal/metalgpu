//
//  MetalGpuTool.swift
//  metalgpu
//
//  Created by Kenneth Endfinger on 10/29/21.
//

import ArgumentParser
import Foundation
import Metal

struct MetalGpuTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "metalgpu",
        abstract: "View Metal GPU Information"
    )

    @Flag(name: [.customShort("d"), .customLong("default")], help: "View Default GPU")
    var isDefaultOnly = false

    @Option(name: [.customShort("i"), .customLong("index")], help: "View GPU of Specified Index")
    var onlySelectedIndex: Int?

    func run() throws {
        var gpus: [MTLDevice] = []
        if isDefaultOnly {
            guard let gpu = MTLCreateSystemDefaultDevice() else {
                throw DefaultDeviceNotFound()
            }
            gpus.append(gpu)
        } else {
            gpus.append(contentsOf: MTLCopyAllDevices())
        }

        if let onlySelectedIndex = onlySelectedIndex {
            let gpu = gpus[onlySelectedIndex]
            gpus = [gpu]
        }

        for (index, gpu) in gpus.enumerated() {
            printGpuInfo(gpu, index: index)
            if index != gpus.count - 1 {
                print()
            }
        }
    }

    func printGpuInfo(_ gpu: MTLDevice, index: Int? = nil) {
        let characteristics = collectGpuCharacteristics(gpu)

        if index != nil {
            print("Index: \(index!)")
        }

        print("Name: \(gpu.name)")
        print("Location: \(locationAsString(gpu.location))")
        print("Characteristics: \(joinedOrEmpty(characteristics, "(None)"))")
    }

    func collectGpuCharacteristics(_ gpu: MTLDevice) -> [String] {
        var characteristics: [String] = []
        if gpu.isLowPower {
            characteristics.append("Low Power")
        }

        if gpu.isHeadless {
            characteristics.append("Headless")
        }

        if gpu.isRemovable {
            characteristics.append("Removable")
        }

        if gpu.hasUnifiedMemory {
            characteristics.append("Unified Memory")
        }
        return characteristics
    }

    func locationAsString(_ location: MTLDeviceLocation) -> String {
        switch location {
        case .builtIn: return "Built-in"
        case .external: return "External"
        case .slot: return "Slot"
        case .unspecified: return "Unspecified"
        @unknown default:
            fatalError("Unknown GPU Location")
        }
    }

    func joinedOrEmpty(_ items: [String], _ otherwise: String) -> String {
        if items.isEmpty {
            return otherwise
        } else {
            return items.joined(separator: ", ")
        }
    }

    struct DefaultDeviceNotFound: Error {}
}
