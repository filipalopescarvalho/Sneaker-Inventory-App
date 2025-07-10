import SwiftUI
import CoreData

struct CollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Sneaker.name, ascending: true)],
        predicate: NSPredicate(format: "isWishlist == NO")
    )
    private var sneakers: FetchedResults<Sneaker>

    @State private var showingAddSneaker = false
    @State private var selectedSneakerForEdit: Sneaker?
    @State private var selectedSneakerForDetail: Sneaker?  // <-- Add this

    var body: some View {
        NavigationView {
            List {
                if sneakers.isEmpty {
                    Button("Start adding sneakers") {
                        showingAddSneaker = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(sneakers) { sneaker in
                        Button {
                            selectedSneakerForDetail = sneaker   // <-- Show detail as sheet
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sneaker.name ?? "Unnamed")
                                    .font(.headline)
                                Text("Brand: \(sneaker.brand ?? "Unknown")")
                                    .font(.subheadline)

                                HStack(spacing: 16) {
                                    Text("Size: \(sneaker.size, specifier: "%.1f") \(sneaker.sizeUnit ?? "")")
                                    Text("Condition: \(sneaker.condition)/10")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)

                                HStack(spacing: 16) {
                                    Text("Price: \(sneaker.price, specifier: "%.2f") \(sneaker.currency ?? "")")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle()) // Important to avoid button styling on list rows
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteSneaker(sneaker)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                selectedSneakerForEdit = sneaker
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .navigationTitle("My Collection")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSneaker = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSneaker) {
                SneakerAddView(isWishlist: false)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(item: $selectedSneakerForEdit) { sneaker in
                SneakerEditView(sneaker: sneaker)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(item: $selectedSneakerForDetail) { sneaker in
                SneakerDetailView(sneaker: sneaker)  // <-- Detail as sheet modal
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteSneaker(_ sneaker: Sneaker) {
        viewContext.delete(sneaker)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete sneaker: \(error)")
        }
    }
}
