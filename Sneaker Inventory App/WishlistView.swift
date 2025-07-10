import SwiftUI
import CoreData

struct WishlistView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Sneaker.name, ascending: true)],
        predicate: NSPredicate(format: "isWishlist == YES")
    )
    private var wishlistSneakers: FetchedResults<Sneaker>

    @State private var showingAddWishlist = false
    @State private var selectedSneakerForEdit: Sneaker?
    @State private var selectedSneakerForDetail: Sneaker?

    var body: some View {
        NavigationView {
            List {
                if wishlistSneakers.isEmpty {
                    Button("Start adding your wishlist sneakers") {
                        showingAddWishlist = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(wishlistSneakers) { sneaker in
                        Button {
                            selectedSneakerForDetail = sneaker
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
                        .buttonStyle(PlainButtonStyle())
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteSneaker(sneaker)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                moveToCollection(sneaker)
                            } label: {
                                Label("Move to Collection", systemImage: "folder.badge.plus")
                            }
                            .tint(.green)
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
            .navigationTitle("Wishlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddWishlist = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWishlist) {
                SneakerAddView(isWishlist: true)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(item: $selectedSneakerForEdit) { sneaker in
                SneakerEditView(sneaker: sneaker)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(item: $selectedSneakerForDetail) { sneaker in
                SneakerDetailView(sneaker: sneaker)
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

    private func moveToCollection(_ sneaker: Sneaker) {
        // Create a new sneaker object with copied properties
        let newSneaker = Sneaker(context: viewContext)
        newSneaker.id = UUID()
        newSneaker.name = sneaker.name
        newSneaker.brand = sneaker.brand
        newSneaker.size = sneaker.size
        newSneaker.sizeUnit = sneaker.sizeUnit
        newSneaker.condition = sneaker.condition
        newSneaker.price = sneaker.price
        newSneaker.currency = sneaker.currency
    
        newSneaker.isWishlist = false 

        viewContext.delete(sneaker)

        do {
            try viewContext.save()
        } catch {
            print("Failed to move sneaker to collection: \(error)")
        }
    }
}
