import PhotosUI
import SwiftUI
import UIKit

struct ComposeTweetView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var parentHash: String?
    var onPublished: ((String) -> Void)?

    @State private var text = ""
    @State private var channelId = ""
    @State private var posting = false
    @State private var error: String?
    @State private var pickerSelections: [PhotosPickerItem] = []
    @State private var attachments: [TweetAttachment] = []
    @State private var uploadError: String?

    private static let maxChars = 280
    private static let maxAttachments = 4

    private var charsLeft: Int { Self.maxChars - text.count }
    private var canPost: Bool {
        let hasContent = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty
        return hasContent && charsLeft >= 0 && !posting && app.appKey != nil && app.myTID != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextEditor(text: $text)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("What's happening in your city?")
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, 17)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                }

            if !attachments.isEmpty {
                attachmentStrip
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }

            if let uploadError {
                Text(uploadError)
                    .font(.footnote)
                    .foregroundStyle(Theme.warning)
                    .padding(.horizontal, 16)
            }
            if let error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Theme.error)
                    .padding(.horizontal, 16)
            }

            Form {
                ChannelPickerField(channelId: $channelId)
            }
            .frame(height: 88)
            .scrollDisabled(true)

            HStack(spacing: 12) {
                PhotosPicker(
                    selection: $pickerSelections,
                    maxSelectionCount: Self.maxAttachments - attachments.count,
                    matching: .images
                ) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title3)
                        .foregroundStyle(attachments.count >= Self.maxAttachments ? Theme.textSecondary : Theme.primary)
                }
                .disabled(attachments.count >= Self.maxAttachments)

                Spacer()
                Text("\(charsLeft)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(charsLeft < 0 ? Theme.error : Theme.textSecondary)
                Button(posting ? "Posting…" : "Post") {
                    Task { await post() }
                }
                .font(.subheadline.weight(.bold))
                .disabled(!canPost)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
        .navigationTitle("New tweet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") { dismiss() }
            }
        }
        .onAppear {
            if channelId.isEmpty {
                channelId = app.currentCity?.id ?? "general"
            }
        }
        .onChange(of: pickerSelections) { _, items in
            Task { await loadPickedItems(items) }
        }
    }

    private var attachmentStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(attachments) { att in
                    ZStack(alignment: .topTrailing) {
                        if let img = UIImage(data: att.data) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        Button {
                            attachments.removeAll { $0.id == att.id }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white, .black.opacity(0.6))
                                .padding(4)
                        }
                    }
                }
            }
        }
    }

    @MainActor
    private func loadPickedItems(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        uploadError = nil
        var loaded: [TweetAttachment] = []
        for item in items {
            do {
                guard let raw = try await item.loadTransferable(type: Data.self),
                      let jpeg = downscaleJPEG(raw) else { continue }
                loaded.append(TweetAttachment(data: jpeg))
            } catch {
                uploadError = error.localizedDescription
            }
        }
        let room = max(0, Self.maxAttachments - attachments.count)
        attachments.append(contentsOf: loaded.prefix(room))
        pickerSelections = []
    }

    private func downscaleJPEG(_ data: Data) -> Data? {
        guard let img = UIImage(data: data) else { return nil }
        let maxEdge: CGFloat = 1600
        let longest = max(img.size.width, img.size.height)
        let scale = longest > maxEdge ? maxEdge / longest : 1
        let target = CGSize(width: img.size.width * scale, height: img.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: target)
        let resized = renderer.image { _ in img.draw(in: CGRect(origin: .zero, size: target)) }
        return resized.jpegData(compressionQuality: 0.85)
    }

    private func post() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        posting = true
        error = nil
        defer { posting = false }
        do {
            var embeds: [String] = []
            for att in attachments {
                let hash = try await app.api.uploadMedia(data: att.data, contentType: "image/jpeg")
                embeds.append("media:\(hash)")
            }
            let hash = try await app.api.publishTweet(
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                as: key,
                tid: tid,
                parentHash: parentHash,
                channelId: channelId.isEmpty ? nil : channelId,
                embeds: embeds.isEmpty ? nil : embeds
            )
            onPublished?(hash)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

private struct TweetAttachment: Identifiable, Hashable {
    let id = UUID()
    let data: Data
}
