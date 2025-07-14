import SwiftUI

struct SneakerDetailView: View {
    @ObservedObject var sneaker: Sneaker
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                let validPhotos = PhotoType.allCases.compactMap { type -> (PhotoType, UIImage)? in
                    if let data = imageData(for: type), let image = UIImage(data: data) {
                        return (type, image)
                    }
                    return nil
                }

                if !validPhotos.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                        ForEach(validPhotos, id: \.0) { type, image in
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)

                                Text(type.rawValue)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Group {
                    HStack {
                        Text("Name:")
                            .bold()
                        Spacer()
                        Text(sneaker.name ?? "Unknown")
                    }
                    HStack {
                        Text("Brand:")
                            .bold()
                        Spacer()
                        Text(sneaker.brand ?? "Unknown")
                    }
                    HStack {
                        Text("Size:")
                            .bold()
                        Spacer()
                        Text("\(String(format: "%.1f", sneaker.size)) \(sneaker.sizeUnit ?? "US")")
                    }
                    HStack {
                        Text("Price:")
                            .bold()
                        Spacer()
                        Text("\(String(format: "%.2f", sneaker.price)) \(sneaker.currency ?? "USD")")
                    }
                    HStack {
                        Text("Condition:")
                            .bold()
                        Spacer()
                        Text("\(sneaker.condition)/10")
                    }
                }
                .padding(.horizontal)
                .font(.title3)

                Spacer()

                HStack(spacing: 16) {
                    Button("Edit") {
                        showingEditView = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Delete", role: .destructive) {
                        showingDeleteAlert = true
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .alert("Delete this sneaker?", isPresented: $showingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        deleteSneaker()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(showingEditView)
        .navigationBarHidden(showingEditView)
        
        .sheet(isPresented: $showingEditView) {
                 NavigationView {
                     SneakerEditView(sneaker: sneaker)
                         .environment(\.managedObjectContext, viewContext)
                 }
             }
    }

    private func deleteSneaker() {
        viewContext.delete(sneaker)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to delete sneaker: \(error)")
        }
    }

    private enum PhotoType: String, CaseIterable {
        case front = "Front Photo"
        case box = "Box Photo"
        case insole = "Insole Photo"
        case side = "Side Photo"
        case sole = "Sole Photo"
        case back = "Back Photo"
    }

    private func imageData(for type: PhotoType) -> Data? {
        switch type {
        case .front: return sneaker.photoFront
        case .box: return sneaker.photoBox
        case .insole: return sneaker.photoInsole
        case .side: return sneaker.photoSide
        case .sole: return sneaker.photoSole
        case .back: return sneaker.photoBack
        }
    }
}
