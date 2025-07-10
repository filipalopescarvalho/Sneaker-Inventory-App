import SwiftUI

struct SneakerAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var brand = ""
    @State private var size: Double = 9.0
    @State private var price: Double = 0.0
    @State private var currency = "USD"
    @State private var sizeUnit = "US"
    @State private var condition: Int = 10

    @State private var photoFront: UIImage?
    @State private var photoBox: UIImage?
    @State private var photoInsole: UIImage?
    @State private var photoSide: UIImage?
    @State private var photoSole: UIImage?
    @State private var photoBack: UIImage?

    @State private var showingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var currentPhotoSelection: PhotoType?

    enum PhotoType: String, CaseIterable {
        case front = "Front Photo"
        case box = "Box Photo"
        case insole = "Insole Photo"
        case side = "Side Photo"
        case sole = "Sole Photo"
        case back = "Back Photo"
    }

    let currencies = ["USD", "GBP", "EUR"]
    let sizeUnits = ["US", "EU", "UK"]
    let isWishlist: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sneaker Details")) {
                    TextField("Name", text: $name)
                    TextField("Brand", text: $brand)

                    HStack {
                        Text("Size")
                        Spacer()
                        TextField("Size", value: $size, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                    }

                    Picker("Size Unit", selection: $sizeUnit) {
                        ForEach(sizeUnits, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("Price", value: $price, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .frame(width: 100)
                    }

                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { curr in
                            Text(curr)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Stepper(value: $condition, in: 1...10) {
                        Text("Condition: \(condition)/10")
                    }
                }

                Section(header: Text("Sneaker Photos")) {
                    ForEach(PhotoType.allCases, id: \.self) { type in
                        photoPickerRow(for: type)
                    }
                }
            }
            .navigationTitle("Add Sneaker")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSneaker()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: {
                currentPhotoSelection = nil
            }) {
                if let currentType = currentPhotoSelection {
                    ImagePicker(sourceType: imagePickerSource, selectedImage: bindingForPhotoType(currentType))
                }

            }
            .confirmationDialog("Select Photo Source", isPresented: .constant(currentPhotoSelection != nil && !showingImagePicker), titleVisibility: .visible) {
                Button("Camera") {
                    imagePickerSource = .camera
                    showingImagePicker = true
                }
                Button("Photo Library") {
                    imagePickerSource = .photoLibrary
                    showingImagePicker = true
                }
                Button("Cancel", role: .cancel) {
                    currentPhotoSelection = nil
                }
            }
        }
    }

    @ViewBuilder
    private func photoPickerRow(for type: PhotoType) -> some View {
        HStack {
            Text(type.rawValue)
            Spacer()
            if let img = image(for: type) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(6)

                Button(role: .destructive) {
                    setImage(nil, for: type)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
            Button("Select") {
                currentPhotoSelection = type
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }

    private func image(for type: PhotoType) -> UIImage? {
        switch type {
        case .front: return photoFront
        case .box: return photoBox
        case .insole: return photoInsole
        case .side: return photoSide
        case .sole: return photoSole
        case .back: return photoBack
        }
    }

    private func bindingForPhotoType(_ type: PhotoType) -> Binding<UIImage?> {
        switch type {
        case .front: return $photoFront
        case .box: return $photoBox
        case .insole: return $photoInsole
        case .side: return $photoSide
        case .sole: return $photoSole
        case .back: return $photoBack
        }
    }

    private func setImage(_ image: UIImage?, for type: PhotoType) {
        switch type {
        case .front: photoFront = image
        case .box: photoBox = image
        case .insole: photoInsole = image
        case .side: photoSide = image
        case .sole: photoSole = image
        case .back: photoBack = image
        }
    }

    private func saveSneaker() {
        print("Saving sneaker with isWishlist = \(self.isWishlist)")
        let newSneaker = Sneaker(context: viewContext)
        newSneaker.name = name
        newSneaker.brand = brand
        newSneaker.size = size
        newSneaker.price = price
        newSneaker.currency = currency
        newSneaker.sizeUnit = sizeUnit
        newSneaker.condition = Int16(condition)
        newSneaker.isWishlist = self.isWishlist

        newSneaker.photoFront = photoFront?.jpegData(compressionQuality: 0.8)
        newSneaker.photoBox = photoBox?.jpegData(compressionQuality: 0.8)
        newSneaker.photoInsole = photoInsole?.jpegData(compressionQuality: 0.8)
        newSneaker.photoSide = photoSide?.jpegData(compressionQuality: 0.8)
        newSneaker.photoSole = photoSole?.jpegData(compressionQuality: 0.8)
        newSneaker.photoBack = photoBack?.jpegData(compressionQuality: 0.8)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving sneaker: \(error)")
        }
    }
}
