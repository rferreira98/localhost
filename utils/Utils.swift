//
//  Utils.swift
//  localhost
//
//  Created by Pedro Alves on 04/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import UIKit
let biometric = BiometricAuth()
class Utils{
    static func triggerAlert(title:String, error:String? )->UIAlertController{
        let alert = UIAlertController(title: title, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        return alert
    }
    
    static func getBiometricSensor()->String{
        switch BiometricAuth().biometricType() {
        case .faceID:
            return("Face ID")
            
        case .touchID:
            return("Touch ID")
        default:
            return "Erro"
        }
    }

}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
}
