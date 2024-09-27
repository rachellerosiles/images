//
//  OpenFFT.swift
//  images
//
//  Created by Rachelle Rosiles on 6/19/24.
//

import Cocoa
import Accelerate

class ImageWindowController: NSWindowController {
    private var imageView: NSImageView!
    private var fftImageView: NSImageView!

    init(image: NSImage) {
        let window = NSWindow(contentRect: NSMakeRect(0, 0, 800, 600),
                              styleMask: [.titled, .closable, .resizable],
                              backing: .buffered, defer: false)
        window.title = "Image"
        super.init(window: window)

        let stackView = NSStackView()
        stackView.spacing = 10
        
        imageView = NSImageView(image: image)
        fftImageView = NSImageView()

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(fftImageView)

        window.contentView = stackView
        window.makeKeyAndOrderFront(nil)

        displayFFT(of: image)
    }
    
    required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    
    /// compute and display the Fast Fourier Transform
    /// - Parameter image: NS Image to be used
    private func displayFFT(of image: NSImage) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }

        let width = cgImage.width
        let height = cgImage.height
        guard let pixelData = cgImage.dataProvider?.data,
              let dataPointer = CFDataGetBytePtr(pixelData) else { return }

        var real: [Float] = Array(repeating: 0, count: width * height)
        var _: [Float] = Array(repeating: 0, count: width * height)

        // pixel data -> float array
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4 // Assuming RGBA format
                let r = Float(dataPointer[pixelIndex]) / 255.0
                let g = Float(dataPointer[pixelIndex + 1]) / 255.0
                let b = Float(dataPointer[pixelIndex + 2]) / 255.0
                let brightness = (r + g + b) / 3.0
                real[y * width + x] = brightness
            }
        }

        //var complexBuffer = DSPSplitComplex(realp: &real, imagp: &imaginary)

        //FFT
        let fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Float(width))), FFTRadix(kFFTRadix2))!
        //vDSP_fft_zrip(fftSetup, &complexBuffer, 1, vDSP_Length(height), FFTDirection(FFT_FORWARD))
        var fftMagnitude = [Float](repeating: 0, count: width * height)
        //vDSP_zvabs(&complexBuffer, 1, &fftMagnitude, 1, vDSP_Length(width * height))

        //turn to image data
        let maxMagnitude = fftMagnitude.max() ?? 1.0
        var outputImageData = [UInt8](repeating: 0, count: width * height * 4)
        for i in 0..<width * height {
            let magnitude = UInt8((fftMagnitude[i] / maxMagnitude) * 255)
            outputImageData[i * 4] = magnitude
            outputImageData[i * 4 + 1] = magnitude
            outputImageData[i * 4 + 2] = magnitude
            outputImageData[i * 4 + 3] = 255 // Alpha
        }

        let outputImage = NSImage(data: Data(outputImageData))
        fftImageView.image = outputImage

    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let openPanel = NSOpenPanel()
        //openPanel.allowedContentTypes = ["tiff", "tif"]
        openPanel.allowsMultipleSelection = true
        
        openPanel.begin { result in
            if result == .OK {
                for url in openPanel.urls {
                    if let image = NSImage(contentsOf: url) {
                        let imageWindowController = ImageWindowController(image: image)
                        imageWindowController.showWindow(self)
                    }
                }
            }
        }
    }
}
