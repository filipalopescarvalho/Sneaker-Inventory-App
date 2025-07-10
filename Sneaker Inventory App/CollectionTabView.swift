import SwiftUI

struct CollectionTabView: View {
    var body: some View {
        TabView {
            CollectionView()
                .tabItem {
                    Label("Inventory", systemImage: "list.bullet")                }

            WishlistView()
                .tabItem {
                    Label("Wishlist", systemImage: "heart.fill")
                }
        }
    }
}
