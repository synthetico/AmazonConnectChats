//
//  HomeViewController.swift
//  WkWebView Demo
//
//  Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//  SPDX-License-Identifier: MIT-0
//

import AVFoundation
import UIKit
import WebKit

class HomeViewController: UIViewController {
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let targetUrl = AppConfiguration.url
        guard let url = URL(string: targetUrl) else {
            return
        }
        webView.load(URLRequest(url: url))
        view.addSubview(webView)
    }
    
    override func viewDidAppear(_: Bool) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            return
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    return
                } else {
                    self.presentCameraPermissionDeniedAlert()
                }
            }
        case .denied,
             .restricted: // The user has previously denied access.
            presentCameraPermissionDeniedAlert()
        }

        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            return
        case AVAudioSession.RecordPermission.denied:
            presentMicrophonePermissionDeniedAlert()
        case AVAudioSession.RecordPermission.undetermined:
            // Request to record audio
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    return
                } else {
                    self.presentMicrophonePermissionDeniedAlert()
                }
            }
        }
    }

    func presentAlert(title: String, message: String, acceptText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acceptText, style: .default, handler: nil))
        present(alert, animated: true)
    }

    func presentCameraPermissionDeniedAlert() {
        presentAlert(title: "Access to Camera Denied",
                     message: "Check Settings to make sure Camera access is enabled for this application.",
                     acceptText: "OK")
    }

    func presentMicrophonePermissionDeniedAlert() {
        presentAlert(title: "Access to Microphone Denied",
                     message: "Check Settings to make sure Camera access is enabled for this application.",
                     acceptText: "OK")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
}
