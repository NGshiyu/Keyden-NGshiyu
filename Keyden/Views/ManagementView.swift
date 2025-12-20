//
//  ManagementView.swift
//  Keyden
//
//  Token management - Authenticator style
//

import SwiftUI

struct ManagementView: View {
    @Binding var isPresented: Bool
    @StateObject private var vaultService = VaultService.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var searchText = ""
    @State private var editingToken: Token?
    @State private var tokenToDelete: Token?
    @State private var showDeleteAlert = false
    
    private var theme: ModernTheme {
        ModernTheme(isDark: themeManager.isDark)
    }
    
    private var filteredTokens: [Token] {
        let sorted = vaultService.vault.tokens.sorted { $0.sortOrder < $1.sortOrder }
        if searchText.isEmpty { return sorted }
        return sorted.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.account.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(L10n.manageAccounts)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.textPrimary)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                        .frame(width: 24, height: 24)
                        .background(theme.surfaceSecondary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            
            Divider().background(theme.separator)
            
            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textTertiary)
                TextField(L10n.search, text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(theme.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(theme.inputBackground)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(theme.inputBorder, lineWidth: 1)
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            
            // List
            if filteredTokens.isEmpty {
                VStack {
                    Spacer()
                    Text(L10n.noAccounts)
                        .font(.system(size: 13))
                        .foregroundColor(theme.textSecondary)
                    Spacer()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 2) {
                        ForEach(filteredTokens) { token in
                            ManageRow(
                                token: token,
                                theme: theme,
                                onEdit: { editingToken = token },
                                onDelete: {
                                    tokenToDelete = token
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
        .background(theme.background)
        .sheet(item: $editingToken) { token in
            EditTokenView(token: token, isPresented: .init(
                get: { editingToken != nil },
                set: { if !$0 { editingToken = nil } }
            ))
        }
        .alert(L10n.deleteAccount, isPresented: $showDeleteAlert) {
            Button(L10n.cancel, role: .cancel) { tokenToDelete = nil }
            Button(L10n.delete, role: .destructive) {
                if let token = tokenToDelete {
                    try? vaultService.deleteToken(id: token.id)
                    tokenToDelete = nil
                }
            }
        } message: {
            Text(L10n.deleteConfirmMessage(tokenToDelete?.displayName ?? ""))
        }
    }
}

// MARK: - Manage Row
struct ManageRow: View {
    let token: Token
    let theme: ModernTheme
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 10) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                Text(String(token.displayName.prefix(1)).uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(token.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                if !token.account.isEmpty {
                    Text(token.account)
                        .font(.system(size: 11))
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Actions - always visible on hover
            HStack(spacing: 4) {
                ManageIconButton(icon: "pencil", theme: theme, action: onEdit)
                ManageIconButton(icon: "trash", theme: theme, isDestructive: true, action: onDelete)
            }
            .opacity(isHovering ? 1 : 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? theme.hoverBackground : Color.clear)
        )
        .onHover { isHovering = $0 }
    }
    
    private var iconColor: Color {
        let hash = abs(token.displayName.hashValue)
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.55, brightness: 0.75)
    }
}

// MARK: - Manage Icon Button
struct ManageIconButton: View {
    let icon: String
    let theme: ModernTheme
    var isDestructive: Bool = false
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isHovering ? .white : (isDestructive ? Color.red.opacity(0.8) : theme.textSecondary))
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovering ? (isDestructive ? Color.red : theme.accent) : theme.surfaceSecondary)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}

// MARK: - Edit Token View
struct EditTokenView: View {
    let token: Token
    @Binding var isPresented: Bool
    @StateObject private var vaultService = VaultService.shared
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = LanguageManager.shared
    
    @State private var issuer: String = ""
    @State private var account: String = ""
    @State private var label: String = ""
    @State private var isSaving = false
    @State private var error: String?
    
    private var theme: ModernTheme {
        ModernTheme(isDark: themeManager.isDark)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(L10n.editAccount)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.textPrimary)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                        .frame(width: 24, height: 24)
                        .background(theme.surfaceSecondary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
            }
            .padding(16)
            
            Divider().background(theme.separator)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Token preview
                    HStack(spacing: 12) {
                        // Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: iconGradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text(String((label.isEmpty ? token.displayName : label).prefix(1)).uppercased())
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 44, height: 44)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(label.isEmpty ? token.displayName : label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.textPrimary)
                                .lineLimit(1)
                            if !account.isEmpty {
                                Text(account)
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.border.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Edit fields
                    VStack(spacing: 14) {
                        EditFieldStyled(
                            label: L10n.label,
                            placeholder: L10n.labelPlaceholder,
                            text: $label,
                            theme: theme
                        )
                        EditFieldStyled(
                            label: L10n.service,
                            placeholder: L10n.servicePlaceholder,
                            text: $issuer,
                            theme: theme
                        )
                        EditFieldStyled(
                            label: L10n.account,
                            placeholder: L10n.accountPlaceholder,
                            text: $account,
                            theme: theme
                        )
                    }
                    
                    if let error = error {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 11))
                            Text(error)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(theme.danger)
                    }
                }
                .padding(16)
            }
            
            Divider().background(theme.separator)
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    Text(L10n.cancel)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(theme.surfaceSecondary)
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: save) {
                    HStack(spacing: 6) {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.7)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .semibold))
                            Text(L10n.save)
                        }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(theme.accentGradient)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }
            .padding(16)
        }
        .frame(width: 320, height: 420)
        .background(theme.background)
        .preferredColorScheme(themeManager.isDark ? .dark : .light)
        .onAppear {
            issuer = token.issuer
            account = token.account
            label = token.label.isEmpty ? token.displayName : token.label
        }
        .id(languageManager.languageMode) // Force refresh on language change
    }
    
    private var iconGradientColors: [Color] {
        let name = label.isEmpty ? token.displayName : label
        let hash = abs(name.hashValue)
        let hue1 = Double(hash % 360) / 360.0
        let hue2 = Double((hash + 40) % 360) / 360.0
        
        let saturation = theme.isDark ? 0.70 : 0.60
        let brightness1 = theme.isDark ? 0.80 : 0.70
        let brightness2 = theme.isDark ? 0.65 : 0.55
        
        return [
            Color(hue: hue1, saturation: saturation, brightness: brightness1),
            Color(hue: hue2, saturation: saturation * 0.9, brightness: brightness2)
        ]
    }
    
    private func save() {
        isSaving = true
        var updated = token
        updated.issuer = issuer.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.account = account.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.updatedAt = Date()
        
        do {
            try vaultService.updateToken(updated)
            ToastManager.shared.show(L10n.saved)
            isPresented = false
        } catch {
            self.error = error.localizedDescription
            isSaving = false
        }
    }
}

// MARK: - Edit Field Styled
struct EditFieldStyled: View {
    let label: String
    var placeholder: String = ""
    @Binding var text: String
    let theme: ModernTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.textSecondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundColor(theme.textPrimary)
                .padding(12)
                .background(theme.inputBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.inputBorder, lineWidth: 1)
                )
        }
    }
}
