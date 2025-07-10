import SwiftUI

struct SneakerEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var sneaker: Sneaker

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var size: Double = 9.0
    @State private var price: Double = 0.0
    @State private var currency: String = "USD"
    @State private var sizeUnit: String = "US"
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
            .navigationTitle("Edit Sneaker")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadSneaker)

            .sheet(isPresented: $showingImagePicker, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentPhotoSelection = nil
                }
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
                    switch type {
                    case .front: photoFront = nil
                    case .box: photoBox = nil
                    case .insole: photoInsole = nil
                    case .side: photoSide = nil
                    case .sole: photoSole = nil
                    case .back: photoBack = nil
                    }
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

    private func loadSneaker() {
        name = sneaker.name ?? ""
        brand = sneaker.brand ?? ""
        size = sneaker.size
        price = sneaker.price
        currency = sneaker.currency ?? "USD"
        sizeUnit = sneaker.sizeUnit ?? "US"
        condition = Int(sneaker.condition)

        if let data = sneaker.photoFront { photoFront = UIImage(data: data) }
        if let data = sneaker.photoBox { photoBox = UIImage(data: data) }
        if let data = sneaker.photoInsole { photoInsole = UIImage(data: data) }
        if let data = sneaker.photoSide { photoSide = UIImage(data: data) }
        if let data = sneaker.photoSole { photoSole = UIImage(data: data) }
        if let data = sneaker.photoBack { photoBack = UIImage(data: data) }
    }

    private func saveChanges() {
        sneaker.name = name
        sneaker.brand = brand
        sneaker.size = size
        sneaker.price = price
        sneaker.currency = currency
        sneaker.sizeUnit = sizeUnit
        sneaker.condition = Int16(condition)

        sneaker.photoFront = photoFront?.jpegData(compressionQuality: 0.8)
        sneaker.photoBox = photoBox?.jpegData(compressionQuality: 0.8)
        sneaker.photoInsole = photoInsole?.jpegData(compressionQuality: 0.8)
        sneaker.photoSide = photoSide?.jpegData(compressionQuality: 0.8)
        sneaker.photoSole = photoSole?.jpegData(compressionQuality: 0.8)
        sneaker.photoBack = photoBack?.jpegData(compressionQuality: 0.8)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving sneaker changes: \(error)")
        }
    }
}
