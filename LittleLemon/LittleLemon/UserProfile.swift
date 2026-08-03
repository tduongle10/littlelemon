import SwiftUI

struct UserProfile: View {
    @Environment(\.presentationMode) var presentation

    let firstName = UserDefaults.standard.string(forKey: kFirstName)
    let lastName = UserDefaults.standard.string(forKey: kLastName)
    let email = UserDefaults.standard.string(forKey: kEmail)

    var body: some View {
        VStack {
            Text("Personal information")

            Image("profile-image-placeholder")

            Text(firstName ?? "")
            Text(lastName ?? "")
            Text(email ?? "")

            Button("Logout") {
                UserDefaults.standard.set(false, forKey: kIsLoggedIn)
                self.presentation.wrappedValue.dismiss()
            }

            Spacer()
        }
    }
}

#Preview {
    UserProfile()
}
