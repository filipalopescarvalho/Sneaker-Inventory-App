import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Sneaker.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Sneaker.name, ascending: true)]
    ) private var sneakers: FetchedResults<Sneaker>
    
    @State private var showingScanner = false
    @State private var scannedCode: String?
    
    @State private var showingAddCollection = false
    @State private var showingAddWishlist = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(sneakers, id: \.self) { sneaker in
                        VStack(alignment: .leading) {
                            Text(sneaker.name ?? "Unnamed")
                                .font(.headline)
                            Text("Brand: \(sneaker.brand ?? "Unknown")")
                                .font(.subheadline)
                        }
                    }
                    .onDelete(perform: deleteSneakers)
                }
                
                if let code = scannedCode {
                    VStack(spacing: 4) {
                        Text("Last scanned code:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(code)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                
                HStack(spacing: 16) {
                    Button(action: {
                        showingAddCollection = true
                    }) {
                        Label("Add to Collection", systemImage: "plus.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showingAddWishlist = true
                    }) {
                        Label("Add to Wishlist", systemImage: "heart.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Button(action: {
                    showingScanner = true
                }) {
                    Label("Scan QR / Barcode", systemImage: "qrcode.viewfinder")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("All Sneakers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView { code in
                    scannedCode = code
                    showingScanner = false
                }
            }
            .sheet(isPresented: $showingAddCollection) {
                SneakerAddView(isWishlist: false)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingAddWishlist) {
                SneakerAddView(isWishlist: true)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteSneakers(offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(sneakers[index])
        }
        try? viewContext.save()
    }
}
