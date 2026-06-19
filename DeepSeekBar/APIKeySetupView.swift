import SwiftUI

struct APIKeySetupView: View {
    @Binding var apiKey: String
    @Binding var hasAPIKey: Bool
    @Binding var isEditing: Bool

    @State private var inputKey: String = ""
    @State private var showError = false
    @State private var isVerifying = false
    @FocusState private var isFocused: Bool

    private let deepseekBlue = Color(red: 0.31, green: 0.42, blue: 0.93)

    var body: some View {
        VStack(spacing: 0) {
            if isEditing {
                editingMode
            } else {
                firstLaunchMode
            }
        }
        .frame(width: 300)
        .onAppear { inputKey = apiKey }
        .onSubmit { saveKey() }
    }

    // MARK: - Editing Mode

    private var editingMode: some View {
        VStack(spacing: 0) {
            // Row 1: Icon + Title | Close
            HStack(spacing: 6) {
                Image(systemName: "key.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(deepseekBlue)

                Text("修改 API Key")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()

                Button(action: { isEditing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .help("取消")
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Description
            Text("输入新的 Key 替换当前配置")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            // Row 2: Input
            SecureField("sk-...", text: $inputKey)
                .textFieldStyle(.plain)
                .font(.system(size: 12, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.thinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isFocused ? deepseekBlue.opacity(0.5) : Color.gray.opacity(0.25), lineWidth: isFocused ? 1.5 : 0.5)
                )
                .focused($isFocused)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

            if showError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption2)
                    Text("请输入有效的 API Key")
                        .font(.caption)
                }
                .foregroundStyle(.red)
                .padding(.bottom, 8)
            }

            // Row 3: Cancel + Save
            HStack(spacing: 10) {
                Button(action: { isEditing = false }) {
                    Text("取消")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.thinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 0.5)
                        )
                }
                .buttonStyle(.plain)

                Button(action: saveKey) {
                    ZStack {
                        if isVerifying {
                            ProgressView()
                                .scaleEffect(0.6)
                                .tint(.white)
                        } else {
                            Text("保存")
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(inputKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? deepseekBlue.opacity(0.35) : deepseekBlue)
                    )
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(isVerifying)
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    // MARK: - First Launch Mode

    private var firstLaunchMode: some View {
        VStack(spacing: 0) {
            // Title
            HStack(spacing: 6) {
                Image(systemName: "key.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(deepseekBlue)

                Text("欢迎使用 DeepSeekBar")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.top, 16)
            .padding(.bottom, 4)

            Text("请输入您的 DeepSeek API Key")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)

            // Input
            SecureField("sk-...", text: $inputKey)
                .textFieldStyle(.plain)
                .font(.system(size: 12, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.thinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isFocused ? deepseekBlue.opacity(0.5) : Color.gray.opacity(0.25), lineWidth: isFocused ? 1.5 : 0.5)
                )
                .focused($isFocused)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            if showError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption2)
                    Text("请输入有效的 API Key")
                        .font(.caption)
                }
                .foregroundStyle(.red)
                .padding(.bottom, 8)
            }

            // Save button
            Button(action: saveKey) {
                ZStack {
                    if isVerifying {
                        ProgressView()
                            .scaleEffect(0.6)
                            .tint(.white)
                    } else {
                        Text("保存并开始使用")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(inputKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? deepseekBlue.opacity(0.35) : deepseekBlue)
                )
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(isVerifying)
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    // MARK: - Actions

    private func saveKey() {
        let trimmed = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty && isEditing {
            UserDefaults.standard.removeObject(forKey: "api_key")
            DeepSeekAPIService.shared.setAPIKey(nil)
            apiKey = ""
            hasAPIKey = false
            isEditing = false
            return
        }

        guard !trimmed.isEmpty else {
            withAnimation { showError = true }
            return
        }

        showError = false
        isVerifying = true

        UserDefaults.standard.set(trimmed, forKey: "api_key")
        DeepSeekAPIService.shared.setAPIKey(trimmed)
        apiKey = trimmed
        hasAPIKey = true
        isEditing = false

        isVerifying = false
    }
}
