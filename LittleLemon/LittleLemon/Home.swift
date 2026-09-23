import SwiftUI
import CoreData

struct Home: View {
    let persistence = PersistenceController.shared

    @AppStorage(kAvatar) private var avatarData: Data?

    var body: some View {
        TabView {
            Menu()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .tabItem {
                    Label("Menu", systemImage: "list.dash")
                }
            UserProfile()
                .tabItem {
                    Label("Profile", systemImage: "square.and.pencil")
                }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("LittleLemon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarTrailing) {
                    profileIcon
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    profileIcon
                }
            }
        }
    }

    private var profileIcon: some View {
        Group {
            if let avatarData, let image = UIImage(data: avatarData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Image("profile-icon")
                    .resizable()
            }
        }
        .frame(width: 29, height: 29)
    }
}

#Preview {
    Home()
}
