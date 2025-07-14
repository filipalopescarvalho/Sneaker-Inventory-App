

import SwiftUI

struct SneakerFormView: View {
    @Binding var name: String
    @Binding var brand: String
    @Binding var size: Double
    @Binding var price: Double
    @Binding var currency: String
    @Binding var sizeUnit: String
    @Binding var condition: Int
    @Binding var sneakerImage: UIImage?
    @Binding var showingImagePicker: Bool
    @Binding var imagePickerSource: UIImagePickerController.SourceType
    @Binding var showingPhotoSourceActionSheet: Bool

    let currencies = ["USD", "GBP", "EUR"]
    let sizeUnits = ["US", "EU", "UK"]

    var body: some View {
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

            Section(header: Text("Sneaker Photo")) {
                if let image = sneakerImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.vertical)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .foregroundColor(.gray)
                        .opacity(0.5)
                        .padding(.vertical)
                }

                Button("Choose Photo") {
                    showingPhotoSourceActionSheet = true
                }
            }
        }
    }
}
