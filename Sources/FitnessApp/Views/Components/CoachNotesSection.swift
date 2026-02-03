import SwiftUI

struct CoachNotesSection: View {
    @EnvironmentObject private var dataStore: AppDataStore
    @State private var showAddNote = false

    let user: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Coach Notes")
                    .font(.title2.bold())

                Spacer()

                if !dataStore.notes(for: user.id).isEmpty {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }

                Button("Add") {
                    showAddNote = true
                }
                .buttonStyle(.bordered)
            }

            let userNotes = dataStore.notes(for: user.id)
            if userNotes.isEmpty {
                Text("No notes yet. Add observations, focus areas, or next steps.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(userNotes) { note in
                    CoachNoteCard(note: note) {
                        dataStore.deleteNote(note)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddNote) {
            CoachNoteEditor(user: user)
                .environmentObject(dataStore)
        }
    }

    private var shareText: String {
        let notes = dataStore.notes(for: user.id)
        let header = "Coach Notes for \(user.name)\n"
        let body = notes.map { note in
            let tags = note.tags.isEmpty ? "" : " [\(note.tags.joined(separator: ", "))]"
            return "- \(note.text)\(tags)"
        }
        return ([header] + body).joined(separator: "\n")
    }
}

struct CoachNoteCard: View {
    let note: CoachNote
    let deleteAction: () -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(note.text)
                    .font(.subheadline)
                Spacer()
                Button {
                    deleteAction()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
            }

            if !note.tags.isEmpty {
                CoachTagRow(tags: note.tags)
            }

            Text(dateFormatter.string(from: note.date))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct CoachNoteEditor: View {
    @EnvironmentObject private var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var noteText = ""
    @State private var selectedTags: Set<String> = []
    @State private var newTag = ""

    let user: UserProfile

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextEditor(text: $noteText)
                        .frame(minHeight: 120)
                }

                Section("Tags") {
                    if dataStore.tags.isEmpty {
                        Text("Add a tag to start organizing notes.")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(dataStore.tags, id: \.self) { tag in
                        Toggle(tag, isOn: Binding(
                            get: { selectedTags.contains(tag) },
                            set: { isOn in
                                if isOn {
                                    selectedTags.insert(tag)
                                } else {
                                    selectedTags.remove(tag)
                                }
                            }
                        ))
                    }

                    HStack {
                        TextField("New tag", text: $newTag)
                        Button("Add") {
                            let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            dataStore.addTag(trimmed)
                            selectedTags.insert(trimmed)
                            newTag = ""
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dataStore.addNote(for: user.id, text: noteText, tags: Array(selectedTags))
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct CoachTagRow: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.15))
                        )
                }
            }
        }
    }
}
