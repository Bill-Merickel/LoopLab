//
//  HomeView.swift
//  LoopLab
//
//  Created by Bill Merickel on 7/19/26.
//

import SwiftUI

struct HomeView: View {

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("LoopLab")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(
                    "Inspect the first procedural track pieces in a mixed "
                        + "immersive-space preview."
                )
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            ImmersiveSpaceButton()
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: 420)
        .padding(40)
    }
}

#Preview(windowStyle: .automatic) {
    HomeView()
        .environment(AppModel())
}
