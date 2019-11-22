//
//  NetworkErrors.swift
//  localhost
//
//  Created by Pedro Alves on 17/11/2019.
//  Copyright © 2019 Ricardo Filipe Ribeiro Ferreira. All rights reserved.
//

import Foundation

struct NetworkError:Error {

    let code: Int
    let message: String

    let messages = [
        
        "O email inserido é inválido",
        "O email inserido já se encontra em uso",
        "Password inválida",
        
        "Ocorreu um erro a efetuar a autenticaçāo",
        "Ocorreu um erro a validar o utilizador",
        "Utilizador não encontrado",
        "Ocorreu um erro a guardar o avatar",

        "Está actualmente sem ligação à internet",
        "Ocorreu um erro desconhecido",
        
        "Erro ao fazer parse do objeto JSON"
    ]

    init(code: Int) {
        self.code = code
        
        if code > messages.count {
            self.message = self.messages[code]
        } else {
            self.message = self.messages[NetworkError.ERROR_CODE_UNKNOWN]
        }
    }

    private static var errorCounter = 0;
    
    static let ERROR_CODE_USER_EMAIL_INVALID = errorCounter++;
    static let ERROR_CODE_USER_EMAIL_EXISTS = errorCounter++;
    static let ERROR_CODE_USER_PASSWORD_INVALID = errorCounter++;
    
    static let ERROR_CODE_USER_TOKEN_GENERATE = errorCounter++;
    static let ERROR_CODE_USER_VALIDATE = errorCounter++;
    static let ERROR_CODE_USER_NOT_FOUND = errorCounter++;
    static let ERROR_CODE_USER_AVATAR_ERROR = errorCounter++;
    
    static let ERROR_NETWORK_CONNECTION = errorCounter++;
    static let ERROR_CODE_UNKNOWN = errorCounter++;
    
    static let ERROR_CODE_PARSE_JSON = errorCounter++;

}

extension Int{
    static prefix func ++(x: inout Int) -> Int {
        x += 1
        return x
    }

    static postfix func ++(x: inout  Int) -> Int {
        defer {x += 1}
        return x
    }

    static prefix func --(x: inout Int) -> Int {
        x -= 1
        return x
    }

    static postfix func --(x: inout Int) -> Int {
        defer {x -= 1}
        return x
    }
}
