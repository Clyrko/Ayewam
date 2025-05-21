//
//  AyewamWidgetExtensionBundle.swift
//  AyewamWidgetExtension
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import WidgetKit
import SwiftUI

@main
struct AyewamWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        AyewamWidgetExtension()
        AyewamWidgetExtensionControl()
        AyewamWidgetExtensionLiveActivity()
    }
}
