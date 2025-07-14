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
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search by name or brand", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.horizontal, .top])

                List {
                    if filteredSneakers().isEmpty {
                        Button("Start adding your wishlist sneakers") {
                            showingAddWishlist = true
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(filteredSneakers()) { sneaker in
                            Button {
                                selectedSneakerForDetail = sneaker
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    if let image = frontImage(for: sneaker) {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                            .cornerRadius(8)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                    }

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

                                        Text("Price: \(sneaker.price, specifier: "%.2f") \(sneaker.currency ?? "")")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
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
                .listStyle(PlainListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Wishlist")
                        .font(.headline)
                }
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


    private func filteredSneakers() -> [Sneaker] {
        wishlistSneakers.filter { sneaker in
            if searchText.isEmpty {
                return true
            }

            let matchesNameOrBrand =
                sneaker.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                sneaker.brand?.localizedCaseInsensitiveContains(searchText) ?? false

            if let conditionInt = Int(searchText) {
                let matchesCondition = sneaker.condition == Int16(conditionInt)
                return matchesNameOrBrand || matchesCondition
            } else {
                return matchesNameOrBrand
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

    private func frontImage(for sneaker: Sneaker) -> Image? {
        if let data = sneaker.photoFront, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    private func moveToCollection(_ sneaker: Sneaker) {
        let newSneaker = Sneaker(context: viewContext)
        newSneaker.id = UUID()
        newSneaker.name = sneaker.name
        newSneaker.brand = sneaker.brand
        newSneaker.size = sneaker.size
        newSneaker.sizeUnit = sneaker.sizeUnit
        newSneaker.condition = sneaker.condition
        newSneaker.price = sneaker.price
        newSneaker.currency = sneaker.currency

        newSneaker.photoFront = sneaker.photoFront
        newSneaker.photoBack = sneaker.photoBack
        newSneaker.photoSole = sneaker.photoSole
        newSneaker.photoInsole = sneaker.photoInsole
        newSneaker.photoSide = sneaker.photoSide
        newSneaker.photoBox = sneaker.photoBox

        newSneaker.isWishlist = false

        viewContext.delete(sneaker)

        do {
            try viewContext.save()
        } catch {
            print("Failed to move sneaker to collection: \(error)")
        }
    }
}
