import SwiftUI

let kFirstName = "first name key"
let kLastName = "last name key"
let kEmail = "email key"
let kPhoneNumber = "phone number key"
let kAvatar = "avatar key"
let kIsLoggedIn = "kIsLoggedIn"

struct Onboarding: View {
    private enum Field {
        case firstName, lastName, email, phoneNumber
    }

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var isLoggedIn: Bool = false
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                NavigationLink(destination: Home(), isActive: $isLoggedIn) {
                    EmptyView()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("ONBOARDING")
                        .font(.sectionTitle)
                        .foregroundColor(.black)

                    Text("Fill in the form below to complete you onboarding process")
                        .font(.leadText)
                        .foregroundColor(.textSecondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.cardTitle)
                        .foregroundColor(.black)

                    TextField("First Name", text: $firstName, prompt: placeholderText("Enter first name here"))
                    .focused($focusedField, equals: .firstName)
                    .roundedFieldStyle()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(.cardTitle)
                        .foregroundColor(.black)

                    TextField("Last Name", text: $lastName, prompt: placeholderText("Enter last name here"))
                    .focused($focusedField, equals: .lastName)
                    .roundedFieldStyle()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.cardTitle)
                        .foregroundColor(.black)

                    TextField("Email", text: $email, prompt: placeholderText("Enter email here"))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .email)
                    .roundedFieldStyle()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone number")
                        .font(.cardTitle)
                        .foregroundColor(.black)

                    TextField("Phone number", text: $phoneNumber, prompt: placeholderText("Enter phone number here"))
                    .keyboardType(.phonePad)
                    .focused($focusedField, equals: .phoneNumber)
                    .roundedFieldStyle()
                }

                Button {
                    if !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && isValidPhoneNumber(phoneNumber) {
                        UserDefaults.standard.set(firstName, forKey: kFirstName)
                        UserDefaults.standard.set(lastName, forKey: kLastName)
                        UserDefaults.standard.set(email, forKey: kEmail)
                        UserDefaults.standard.set(phoneNumber, forKey: kPhoneNumber)
                        UserDefaults.standard.set(true, forKey: kIsLoggedIn)
                        isLoggedIn = true
                    } else {
                        print("Registration failed: one or more fields are empty or invalid")
                    }
                } label: {
                    Text("Register")
                        .font(.buttonText)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.primaryYellow)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("LittleLemon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                if UserDefaults.standard.bool(forKey: kIsLoggedIn) {
                    isLoggedIn = true
                }
            }
        }
    }

    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let digits = phoneNumber.filter { $0.isNumber }
        return digits.count >= 7 && digits.count <= 15
    }
}

#Preview {
    Onboarding()
}
