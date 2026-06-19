import SwiftUI
import ServiceManagement

struct ContentView: View {
    @Binding var apiKey: String
    @Binding var hasAPIKey: Bool

    @State private var balance: BalanceResponse?
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var errorMessage: String?
    @State private var hoveredButton: String? = nil
    @State private var showKeyEditor = false
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    private let deepseekBlue = Color(red: 0.31, green: 0.42, blue: 0.93)

    var body: some View {
        if showKeyEditor {
            APIKeySetupView(
                apiKey: $apiKey,
                hasAPIKey: $hasAPIKey,
                isEditing: $showKeyEditor
            )
            .frame(width: 300)
        } else {
            VStack(spacing: 0) {
                topBar
                Divider().opacity(0.3)
                statusBar
                Divider().opacity(0.3)
                balanceDisplay
            }
            .frame(width: 300)
            .task { await refreshBalance() }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
                guard hasAPIKey, !apiKey.isEmpty else { return }
                isRefreshing = true
                Task { await refreshBalance() }
            }
        }
    }

    // MARK: - Row 1: Logo + Title | Action Buttons

    private var topBar: some View {
        HStack(spacing: 0) {
            Image("MenuIcon")
                .resizable()
                .renderingMode(.template)
                .frame(width: 18, height: 18)
                .foregroundStyle(deepseekBlue)

            Text("DeepSeekBar")
                .font(.system(size: 13, weight: .semibold))
                .padding(.leading, 4)

            Spacer()

            actionButton(
                id: "refresh",
                icon: "arrow.clockwise",
                label: "刷新",
                action: {
                    isRefreshing = true
                    Task { await refreshBalance() }
                },
                disabled: isLoading
            )

            actionButton(
                id: "key",
                icon: "key",
                label: "修改 Key",
                action: { showKeyEditor = true }
            )

            actionButton(
                id: "launch",
                icon: launchAtLogin ? "bolt.fill" : "bolt.slash",
                label: launchAtLogin ? "开机自启: 开" : "开机自启: 关",
                action: { toggleLaunchAtLogin() }
            )

            actionButton(
                id: "quit",
                icon: "power",
                label: "退出",
                action: { NSApplication.shared.terminate(nil) },
                role: .destructive
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func actionButton(
        id: String,
        icon: String,
        label: String,
        action: @escaping () -> Void,
        disabled: Bool = false,
        role: ButtonRole? = nil
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .frame(width: 28, height: 24)
                .background(
                    hoveredButton == id
                        ? (role == .destructive ? Color.red.opacity(0.12) : .primary.opacity(0.08))
                        : .clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .foregroundStyle(role == .destructive ? .red : .secondary)
        .opacity(disabled ? 0.35 : 1)
        .disabled(disabled)
        .help(label)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                hoveredButton = hovering ? id : nil
            }
        }
    }

    // MARK: - Row 2: Status

    private var statusBar: some View {
        HStack(spacing: 6) {
            Text("账户余额")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()

            if isLoading && balance == nil {
                ProgressView()
                    .scaleEffect(0.5)
                    .frame(width: 14, height: 14)
                Text("查询中...")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            } else if let errorMessage, balance == nil {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                Text("加载失败")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                    .help(errorMessage)
            } else if let isAvailable = balance?.isAvailable {
                Image(systemName: "circle.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(isAvailable ? .green : .red)
                Text(isAvailable ? "可用" : "不可用")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isAvailable ? .green : .red)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    // MARK: - Row 3: Balance Display

    private var balanceDisplay: some View {
        VStack(spacing: 0) {
            if isLoading && balance == nil {
                loadingState
            } else if let errorMessage {
                errorState(errorMessage)
            } else if let balance {
                balanceNumber(balance)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 14)
    }

    private func balanceNumber(_ balance: BalanceResponse) -> some View {
        let amountStr = balance.balanceInfos.first?.totalBalance ?? "-"
        let amount = Double(amountStr)

        return HStack(spacing: 0) {
            Spacer()

            ZStack(alignment: .center) {
                if isRefreshing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(height: 20)
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("¥")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(deepseekBlue.opacity(0.7))
                    if let amount {
                        Text(String(format: "%.2f", amount))
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundStyle(deepseekBlue)
                    } else {
                        Text(amountStr)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundStyle(deepseekBlue)
                    }
                }
                .opacity(isRefreshing ? 0 : 1)
            }
            .animation(.easeInOut(duration: 0.2), value: isRefreshing)

            Spacer()
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(deepseekBlue)
            Text("正在获取余额...")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 30)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(message)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            Button {
                Task { await refreshBalance() }
            } label: {
                Label("重新加载", systemImage: "arrow.clockwise")
                    .font(.system(size: 11))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
            }
            .buttonStyle(.plain)
            .background(.blue.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(.blue.opacity(0.2), lineWidth: 0.5))
        }
        .padding(.vertical, 20)
    }

    // MARK: - Actions

    private func refreshBalance() async {
        // Sync the latest key from binding to service before fetching
        DeepSeekAPIService.shared.setAPIKey(apiKey)
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            isRefreshing = false
        }
        do {
            let result = try await DeepSeekAPIService.shared.fetchBalance()
            balance = result
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func toggleLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.unregister()
                launchAtLogin = false
            } else {
                try SMAppService.mainApp.register()
                launchAtLogin = true
            }
        } catch {
            // Silently fail — user can retry
        }
    }
}
