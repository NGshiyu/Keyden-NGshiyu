//
//  TOTPTimerService.swift
//  Keyden
//
//  Centralized timer service for TOTP code updates
//  Optimizes CPU usage by using a single timer for all tokens
//

import Foundation
import Combine

/// Cached TOTP data for a single token
struct TOTPCacheEntry: Equatable {
    var code: String
    var remainingSeconds: Int
    let period: Int
}

/// Centralized timer service for TOTP updates
/// Uses a single timer instead of one timer per token to reduce CPU usage
final class TOTPTimerService: ObservableObject {
    static let shared = TOTPTimerService()
    
    /// Published tick counter that increments every second
    /// Views observe this to trigger UI updates
    @Published private(set) var tick: UInt64 = 0
    
    /// Cached TOTP codes and remaining seconds, keyed by token ID
    /// Not @Published - we use tick to trigger updates instead
    private(set) var cache: [UUID: TOTPCacheEntry] = [:]
    
    private var timer: Timer?
    private var isActive = false
    private var shouldRun = false
    
    /// Track registered token IDs to know what to update
    private var registeredTokens: [UUID: Token] = [:]
    
    private init() {
        // Listen for panel visibility changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(panelDidShow),
            name: .totpTimerShouldStart,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(panelDidHide),
            name: .totpTimerShouldStop,
            object: nil
        )
    }
    
    // MARK: - Timer Control
    
    /// Start the shared timer
    func start() {
        guard shouldRun, !isActive, !registeredTokens.isEmpty else { return }
        isActive = true
        
        // Immediately update all registered tokens
        updateAllCodes()
        
        // Create timer on main run loop
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerFired()
        }
        // Ensure timer fires even during UI tracking (e.g., scrolling)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    /// Stop the shared timer
    func stop() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func panelDidShow() {
        shouldRun = true
        start()
    }
    
    @objc private func panelDidHide() {
        shouldRun = false
        stop()
    }
    
    // MARK: - Token Registration
    
    /// Register a token for updates
    func register(_ token: Token) {
        registeredTokens[token.id] = token
        
        // Generate initial code and cache it
        let now = Date()
        let nowSeconds = Int(now.timeIntervalSince1970)
        let period = token.period
        let remaining = period - (nowSeconds % period)
        let code = TOTPService.shared.generateCode(
            secret: token.secret,
            digits: token.digits,
            period: period,
            algorithm: token.algorithm,
            time: now
        ) ?? "------"
        cache[token.id] = TOTPCacheEntry(code: code, remainingSeconds: remaining, period: token.period)
        
        // Start timer if not already running and we have tokens
        start()
    }
    
    /// Unregister a token
    func unregister(_ tokenId: UUID) {
        registeredTokens.removeValue(forKey: tokenId)
        cache.removeValue(forKey: tokenId)
        
        // Stop timer if no tokens are registered
        if registeredTokens.isEmpty {
            stop()
        }
    }
    
    /// Get cached data for a token
    func getCachedData(for tokenId: UUID) -> TOTPCacheEntry? {
        return cache[tokenId]
    }
    
    // MARK: - Timer Logic
    
    private func timerFired() {
        updateAllRemainingSeconds()
        // Only increment tick after cache is updated, triggers single UI refresh
        tick &+= 1
    }
    
    /// Update remaining seconds for all registered tokens
    /// Only regenerates code when period boundary is crossed
    private func updateAllRemainingSeconds() {
        let now = Date()
        let nowSeconds = Int(now.timeIntervalSince1970)
        var remainingByPeriod: [Int: Int] = [:]
        
        for (id, token) in registeredTokens {
            guard var entry = cache[id] else { continue }
            
            let period = token.period
            let newRemaining = remainingByPeriod[period] ?? {
                let value = period - (nowSeconds % period)
                remainingByPeriod[period] = value
                return value
            }()
            
            // Check if we crossed the period boundary (remaining reset to period)
            // This happens when newRemaining > entry.remainingSeconds (e.g., 30 > 1)
            if newRemaining > entry.remainingSeconds || entry.remainingSeconds == period {
                // Period boundary crossed - regenerate code
                let code = TOTPService.shared.generateCode(
                    secret: token.secret,
                    digits: token.digits,
                    period: period,
                    algorithm: token.algorithm,
                    time: now
                ) ?? "------"
                entry.code = code
            }
            
            entry.remainingSeconds = newRemaining
            cache[id] = entry
        }
    }
    
    /// Force update all codes (used on start)
    private func updateAllCodes() {
        let now = Date()
        let nowSeconds = Int(now.timeIntervalSince1970)
        var remainingByPeriod: [Int: Int] = [:]
        
        for (id, token) in registeredTokens {
            let period = token.period
            let remaining = remainingByPeriod[period] ?? {
                let value = period - (nowSeconds % period)
                remainingByPeriod[period] = value
                return value
            }()
            let code = TOTPService.shared.generateCode(
                secret: token.secret,
                digits: token.digits,
                period: period,
                algorithm: token.algorithm,
                time: now
            ) ?? "------"
            cache[id] = TOTPCacheEntry(code: code, remainingSeconds: remaining, period: period)
        }
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let totpTimerShouldStart = Notification.Name("totpTimerShouldStart")
    static let totpTimerShouldStop = Notification.Name("totpTimerShouldStop")
}
