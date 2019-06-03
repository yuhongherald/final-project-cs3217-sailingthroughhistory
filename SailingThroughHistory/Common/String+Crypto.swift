//
//  StringHashDigest.swift
//  SailingThroughHistory
//
//  Created by henry on 16/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import CommonCrypto

enum HashOutput {
    case hex
    case base64
}

enum HashType {
    case md5
    case sha1
    case sha224
    case sha256
    case sha384
    case sha512

    var length: Int32 {
        switch self {
        case .md5:
            return CC_MD5_DIGEST_LENGTH
        case .sha1:
            return CC_SHA1_DIGEST_LENGTH
        case .sha224:
            return CC_SHA224_DIGEST_LENGTH
        case .sha256:
            return CC_SHA256_DIGEST_LENGTH
        case .sha384:
            return CC_SHA384_DIGEST_LENGTH
        case .sha512:
            return CC_SHA512_DIGEST_LENGTH
        }
    }
}

extension String {
    func hashed(_ type: HashType, output: HashOutput = .hex) -> String? {
        guard let message = data(using: .utf8) else {
            return nil
        }
        return message.hashed(type, output: output)
    }
}

extension Data {
    func hashed(_ type: HashType, output: HashOutput = .hex) -> String? {
        var digest = Data(count: Int(type.length))
        _ = digest.withUnsafeMutableBytes { (digestBytes: UnsafeMutablePointer<UInt8>) in
            self.withUnsafeBytes { (messageBytes: UnsafePointer<UInt8>) in
                let length = CC_LONG(self.count)
                switch type {
                case .md5:
                    CC_MD5(messageBytes, length, digestBytes)
                case .sha1:
                    CC_SHA1(messageBytes, length, digestBytes)
                case .sha224:
                    CC_SHA224(messageBytes, length, digestBytes)
                case .sha256:
                    CC_SHA256(messageBytes, length, digestBytes)
                case .sha384:
                    CC_SHA384(messageBytes, length, digestBytes)
                case .sha512:
                    CC_SHA512(messageBytes, length, digestBytes)
                }
            }
        }

        switch output {
        case .hex:
            return digest.map { String(format: "%02hhx", $0) }.joined()
        case .base64:
            return digest.base64EncodedString()
        }
    }
}
