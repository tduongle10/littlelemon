import SwiftUI

let kFirstName = "first name key"
let kLastName = "last name key"
let kEmail = "email key"
let kIsLoggedIn = "kIsLoggedIn"

struct Onboarding: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var isLoggedIn: Bool = false


    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: Home(), isActive: $isLoggedIn) {
                    EmptyView()
                }

                Text("Little Lemon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryGreen)
                    .padding(.top, 40)

                Text("Let's get to know you")
                    .font(.headline)
                    .foregroundColor(.secondaryDarkGray)
                    .padding(.bottom, 20)

                TextField(text: $firstName) {
                    Text("First Name")
                }
                .roundedFieldStyle()

                TextField(text: $lastName) {
                    Text("Last Name")
                }
                .roundedFieldStyle()

                TextField(text: $email) {
                    Text("Email")
                }
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .roundedFieldStyle()

                Button("Register") {
                    if !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty {
                        UserDefaults.standard.set(firstName, forKey: kFirstName)
                        UserDefaults.standard.set(lastName, forKey: kLastName)
                        UserDefaults.standard.set(email, forKey: kEmail)
                        UserDefaults.standard.set(true, forKey: kIsLoggedIn)
                        isLoggedIn = true
                    } else {
                        print("Registration failed: one or more fields are empty")
                    }
                }
                .font(.headline)
                .foregroundColor(.primaryGreen)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryYellow)
                .cornerRadius(10)
                .padding(.top, 10)

                Spacer()
            }
            .padding(.horizontal, 24)
            .onAppear {
                if UserDefaults.standard.bool(forKey: kIsLoggedIn) {
                    isLoggedIn = true
                }
            }
        }
    }
}

private extension View {
    func roundedFieldStyle() -> some View {
        self
            .padding()
            .background(Color.secondaryLightGray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondaryLightPeach, lineWidth: 1)
            )
    }
}

#Preview {
    Onboarding()
}
