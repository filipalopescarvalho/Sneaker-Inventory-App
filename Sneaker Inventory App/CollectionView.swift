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
                        Button("Start adding sneakers") {
                            showingAddSneaker = true
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
                    HStack(spacing: 8) {
                        Text("My Collection")
                            .font(.headline)
                        Spacer(minLength: 16)
                        Text("Total: \(totalValue, specifier: "%.2f") \(sneakers.first?.currency ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
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
                SneakerDetailView(sneaker: sneaker)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func filteredSneakers() -> [Sneaker] {
        sneakers.filter { sneaker in
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
    private var totalValue: Double {
        sneakers.reduce(0) { $0 + $1.price }
    }
}
