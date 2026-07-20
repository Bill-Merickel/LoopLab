//
//  HomeView.swift
//  LoopLab
//
//  Created by Bill Merickel on 7/19/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct HomeView: View {

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, world!")

            ImmersiveSpaceButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    HomeView()
        .environment(AppModel())
}
