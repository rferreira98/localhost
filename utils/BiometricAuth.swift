//
//  BiometricAuth.swift
//  localhost
//
//  Created by Pedro Alves on 19/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation
import LocalAuthentication

class BiometricAuth{
    let context = LAContext()
    
    var loginReason = "Logging in with Touch ID"
    
    func canEvaluatePolicy() -> Bool {
      return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    enum BiometricType {
      case none
      case touchID
      case faceID
    }
    
    func biometricType() -> BiometricType {
      let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
      switch context.biometryType {
      case .none:
        return .none
      case .touchID:
        return .touchID
      case .faceID:
        return .faceID
      }
    }
    
    
    func authenticateUser(completion: @escaping () -> Void) {
      // is capable of biometric
      guard canEvaluatePolicy() else {
        return
      }

      context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
        localizedReason: loginReason) { (success, evaluateError) in
          if success {
            DispatchQueue.main.async {
              // User authenticated successfully, take appropriate action
              completion()
            }
          } else {
            // TODO: deal with LAError cases
          }
      }
    }
}
