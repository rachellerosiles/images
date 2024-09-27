//
//  ContentView.swift
//  images
//
//  Created by Rachelle Rosiles on 6/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var images: [NSImage] = []
    
    var body: some View {
        VStack {
            Button(action: openImagePicker) {
                Text("Select TIFF Images")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            ScrollView {
                HStack {
                    ForEach(images, id: \.self) { image in
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .padding()
                            .border(Color.gray, width: 1)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        displayFFT(for: image, in: geometry.size)
                                    }
                                }
                            )
                    }
                }
            }
        }
        .padding()
    }
    
    private func openImagePicker() {
        let openPanel = NSOpenPanel()
        //openPanel.allowedContentTypes = ["tiff", "tif"]
        openPanel.allowsMultipleSelection = true
        
        openPanel.begin { result in
            if result == .OK {
                for url in openPanel.urls {
                    if let image = NSImage(contentsOf: url) {
                        images.append(image)
                    }
                }
            }
        }
    }
    
    private func displayFFT(for image: NSImage, in size: CGSize) {
        
    }
}
