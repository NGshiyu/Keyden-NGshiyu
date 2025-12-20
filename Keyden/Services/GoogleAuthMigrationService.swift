//
//  GoogleAuthMigrationService.swift
//  Keyden
//
//  Parse Google Authenticator migration format (otpauth-migration://offline?data=)
//

import Foundation

/// Service for parsing Google Authenticator migration data
/// Format: otpauth-migration://offline?data=<base64-encoded-protobuf>
final class GoogleAuthMigrationService {
    static let shared = GoogleAuthMigrationService()
    
    private init() {}
    
    /// Parse otpauth-migration:// URL and extract OTP accounts
    func parseMigrationURL(_ urlString: String) -> [OTPAuthURL]? {
        // Check URL scheme
        guard urlString.lowercased().hasPrefix("otpauth-migration://") else {
            return nil
        }
        
        // Parse URL
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let dataParam = components.queryItems?.first(where: { $0.name == "data" })?.value else {
            print("[GoogleAuthMigration] Failed to parse URL or find data parameter")
            return nil
        }
        
        // URL decode the data parameter (it may be URL-encoded)
        let decodedDataParam = dataParam.removingPercentEncoding ?? dataParam
        
        // Base64 decode
        guard let data = Data(base64Encoded: decodedDataParam, options: .ignoreUnknownCharacters) else {
            // Try with padding
            let padded = padBase64(decodedDataParam)
            guard let paddedData = Data(base64Encoded: padded, options: .ignoreUnknownCharacters) else {
                print("[GoogleAuthMigration] Failed to base64 decode data")
                return nil
            }
            return parseProtobuf(paddedData)
        }
        
        return parseProtobuf(data)
    }
    
    /// Add padding to base64 string if needed
    private func padBase64(_ string: String) -> String {
        var str = string
        let remainder = str.count % 4
        if remainder > 0 {
            str += String(repeating: "=", count: 4 - remainder)
        }
        return str
    }
    
    /// Parse the protobuf data
    /// Google Authenticator uses a simple protobuf format:
    /// message MigrationPayload {
    ///   repeated OtpParameters otp_parameters = 1;
    ///   int32 version = 2;
    ///   int32 batch_size = 3;
    ///   int32 batch_index = 4;
    ///   int32 batch_id = 5;
    /// }
    /// message OtpParameters {
    ///   bytes secret = 1;
    ///   string name = 2;
    ///   string issuer = 3;
    ///   Algorithm algorithm = 4;
    ///   DigitCount digits = 5;
    ///   OtpType type = 6;
    ///   int64 counter = 7;
    /// }
    private func parseProtobuf(_ data: Data) -> [OTPAuthURL]? {
        var results: [OTPAuthURL] = []
        var offset = 0
        
        while offset < data.count {
            // Read field tag
            guard let (fieldNumber, wireType, newOffset) = readTag(data: data, offset: offset) else {
                break
            }
            offset = newOffset
            
            if fieldNumber == 1 && wireType == 2 {
                // otp_parameters (length-delimited)
                guard let (length, lengthOffset) = readVarint(data: data, offset: offset) else {
                    break
                }
                offset = lengthOffset
                
                let endOffset = offset + Int(length)
                guard endOffset <= data.count else {
                    break
                }
                
                let otpData = data.subdata(in: offset..<endOffset)
                if let otpAuth = parseOtpParameters(otpData) {
                    results.append(otpAuth)
                }
                offset = endOffset
            } else {
                // Skip other fields
                guard let newOffset = skipField(data: data, offset: offset, wireType: wireType) else {
                    break
                }
                offset = newOffset
            }
        }
        
        print("[GoogleAuthMigration] Parsed \(results.count) accounts")
        return results.isEmpty ? nil : results
    }

    /// Parse a single OtpParameters message
    private func parseOtpParameters(_ data: Data) -> OTPAuthURL? {
        var secret: Data?
        var name: String = ""
        var issuer: String = ""
        var algorithm: TOTPAlgorithm = .sha1
        var digits: Int = 6
        var otpType: Int = 0
        
        var offset = 0
        
        while offset < data.count {
            guard let (fieldNumber, wireType, newOffset) = readTag(data: data, offset: offset) else {
                break
            }
            offset = newOffset
            
            switch fieldNumber {
            case 1: // secret (bytes)
                if wireType == 2 {
                    guard let (length, lengthOffset) = readVarint(data: data, offset: offset) else { break }
                    offset = lengthOffset
                    let endOffset = offset + Int(length)
                    guard endOffset <= data.count else { break }
                    secret = data.subdata(in: offset..<endOffset)
                    offset = endOffset
                }
                
            case 2: // name (string)
                if wireType == 2 {
                    guard let (length, lengthOffset) = readVarint(data: data, offset: offset) else { break }
                    offset = lengthOffset
                    let endOffset = offset + Int(length)
                    guard endOffset <= data.count else { break }
                    name = String(data: data.subdata(in: offset..<endOffset), encoding: .utf8) ?? ""
                    offset = endOffset
                }
                
            case 3: // issuer (string)
                if wireType == 2 {
                    guard let (length, lengthOffset) = readVarint(data: data, offset: offset) else { break }
                    offset = lengthOffset
                    let endOffset = offset + Int(length)
                    guard endOffset <= data.count else { break }
                    issuer = String(data: data.subdata(in: offset..<endOffset), encoding: .utf8) ?? ""
                    offset = endOffset
                }
                
            case 4: // algorithm (enum)
                if wireType == 0 {
                    guard let (value, newOffset) = readVarint(data: data, offset: offset) else { break }
                    offset = newOffset
                    switch value {
                    case 1: algorithm = .sha1
                    case 2: algorithm = .sha256
                    case 3: algorithm = .sha512
                    default: algorithm = .sha1
                    }
                }
                
            case 5: // digits (enum)
                if wireType == 0 {
                    guard let (value, newOffset) = readVarint(data: data, offset: offset) else { break }
                    offset = newOffset
                    switch value {
                    case 1: digits = 6
                    case 2: digits = 8
                    default: digits = 6
                    }
                }
                
            case 6: // type (enum)
                if wireType == 0 {
                    guard let (value, newOffset) = readVarint(data: data, offset: offset) else { break }
                    offset = newOffset
                    otpType = Int(value)
                }
                
            default:
                guard let newOffset = skipField(data: data, offset: offset, wireType: wireType) else { break }
                offset = newOffset
            }
        }
        
        // Only support TOTP (type 2)
        guard let secretData = secret, otpType == 2 || otpType == 0 else {
            if otpType == 1 {
                print("[GoogleAuthMigration] Skipping HOTP account: \(name)")
            }
            return nil
        }
        
        // Convert secret to Base32
        let base32Secret = base32Encode(secretData)
        
        // Parse name to extract issuer and account
        var parsedIssuer = issuer
        var account = name
        
        // Name format is often "issuer:account" or just "account"
        if name.contains(":") {
            let parts = name.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            if parts.count >= 2 {
                if parsedIssuer.isEmpty {
                    parsedIssuer = String(parts[0]).trimmingCharacters(in: .whitespaces)
                }
                account = String(parts[1]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        var result = OTPAuthURL()
        result.issuer = parsedIssuer
        result.account = account
        result.secret = base32Secret
        result.digits = digits
        result.algorithm = algorithm
        result.period = 30 // Google Authenticator always uses 30 seconds
        
        print("[GoogleAuthMigration] Parsed account: issuer=\(parsedIssuer), account=\(account)")
        return result
    }
    
    // MARK: - Protobuf Helpers
    
    /// Read a varint from data
    private func readVarint(data: Data, offset: Int) -> (UInt64, Int)? {
        var result: UInt64 = 0
        var shift: UInt64 = 0
        var currentOffset = offset
        
        while currentOffset < data.count {
            let byte = data[currentOffset]
            currentOffset += 1
            
            result |= UInt64(byte & 0x7F) << shift
            
            if byte & 0x80 == 0 {
                return (result, currentOffset)
            }
            
            shift += 7
            if shift >= 64 {
                return nil
            }
        }
        
        return nil
    }
    
    /// Read a protobuf tag (field number + wire type)
    private func readTag(data: Data, offset: Int) -> (fieldNumber: Int, wireType: Int, newOffset: Int)? {
        guard let (tag, newOffset) = readVarint(data: data, offset: offset) else {
            return nil
        }
        
        let wireType = Int(tag & 0x07)
        let fieldNumber = Int(tag >> 3)
        
        return (fieldNumber, wireType, newOffset)
    }
    
    /// Skip a field based on wire type
    private func skipField(data: Data, offset: Int, wireType: Int) -> Int? {
        switch wireType {
        case 0: // Varint
            guard let (_, newOffset) = readVarint(data: data, offset: offset) else { return nil }
            return newOffset
        case 1: // 64-bit
            return offset + 8
        case 2: // Length-delimited
            guard let (length, lengthOffset) = readVarint(data: data, offset: offset) else { return nil }
            return lengthOffset + Int(length)
        case 5: // 32-bit
            return offset + 4
        default:
            return nil
        }
    }
    
    // MARK: - Base32 Encoding
    
    private let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    
    /// Encode data to Base32
    private func base32Encode(_ data: Data) -> String {
        var result = ""
        var buffer: UInt64 = 0
        var bitsLeft = 0
        
        for byte in data {
            buffer = (buffer << 8) | UInt64(byte)
            bitsLeft += 8
            
            while bitsLeft >= 5 {
                bitsLeft -= 5
                let index = Int((buffer >> bitsLeft) & 0x1F)
                let char = base32Alphabet[base32Alphabet.index(base32Alphabet.startIndex, offsetBy: index)]
                result.append(char)
            }
        }
        
        // Handle remaining bits
        if bitsLeft > 0 {
            let index = Int((buffer << (5 - bitsLeft)) & 0x1F)
            let char = base32Alphabet[base32Alphabet.index(base32Alphabet.startIndex, offsetBy: index)]
            result.append(char)
        }
        
        return result
    }
}
