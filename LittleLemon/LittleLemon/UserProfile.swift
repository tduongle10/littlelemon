import SwiftUI
import PhotosUI

struct UserProfile: View {
    private enum Field {
        case firstName, lastName, email, phoneNumber
    }

    @Environment(\.presentationMode) var presentation

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var avatarImage: UIImage?
    @State private var avatarItem: PhotosPickerItem?
    @State private var showingAvatarOptions = false
    @State private var showingPhotoPicker = false
    @State private var shouldPickPhoto = false
    @FocusState private var focusedField: Field?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PERSONAL INFORMATION")
                        .font(.sectionTitle)
                        .foregroundColor(.black)

                    Text("Complete the form below to reserve your table at Little Lemon")
                        .font(.leadText)
                        .foregroundColor(.textSecondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Avatar")
                        .font(.cardTitle)
                        .foregroundColor(.black)

                    avatar
                        .frame(width: 169, height: 169)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            focusedField = nil
                            showingAvatarOptions = true
                        }
                }

                field("First Name", placeholder: "Enter first name here", text: $firstName, field: .firstName)
                field("Last Name", placeholder: "Enter last name here", text: $lastName, field: .lastName)
                field("Email", placeholder: "Enter email here", text: $email, field: .email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                field("Phone number", placeholder: "Enter phone number here", text: $phoneNumber, field: .phoneNumber)
                    .keyboardType(.phonePad)

                Button {
                    UserDefaults.standard.set(false, forKey: kIsLoggedIn)
                    self.presentation.wrappedValue.dismiss()
                } label: {
                    Text("Log out")
                        .font(.buttonText)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.primaryYellow)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                HStack(spacing: 10) {
                    Button {
                        loadStoredDetails()
                    } label: {
                        Text("Discard")
                            .font(.buttonText)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.secondaryLightGray)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        saveDetails()
                    } label: {
                        Text("Save")
                            .font(.buttonText)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.secondaryDarkGray)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $showingAvatarOptions, onDismiss: {
            if shouldPickPhoto {
                shouldPickPhoto = false
                showingPhotoPicker = true
            }
        }) {
            avatarOptionsSheet
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $avatarItem, matching: .images)
        .onChange(of: avatarItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    saveAvatar(data)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .onAppear {
            loadStoredDetails()
        }
    }

    private var avatarOptionsSheet: some View {
        VStack(spacing: 12) {
            Text("Avatar")
                .font(.cardTitle)
                .foregroundColor(.black)
                .padding(.top, 8)

            Button {
                shouldPickPhoto = true
                showingAvatarOptions = false
            } label: {
                Text("Change photo")
                    .font(.buttonText)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.primaryYellow)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                removeAvatar()
                showingAvatarOptions = false
            } label: {
                Text("Remove photo")
                    .font(.buttonText)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.secondaryLightGray)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(avatarImage == nil)

            Button {
                showingAvatarOptions = false
            } label: {
                Text("Cancel")
                    .font(.buttonText)
                    .foregroundColor(.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }

            Spacer()
        }
        .padding(24)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var avatar: some View {
        if let avatarImage {
            Image(uiImage: avatarImage)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else {
            Image("profile-avatar")
                .resizable()
        }
    }

    private func saveAvatar(_ data: Data) {
        UserDefaults.standard.set(data, forKey: kAvatar)
        avatarImage = UIImage(data: data)
    }

    private func removeAvatar() {
        UserDefaults.standard.removeObject(forKey: kAvatar)
        avatarItem = nil
        avatarImage = nil
    }

    private func field(_ label: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.cardTitle)
                .foregroundColor(.black)

            TextField(label, text: text, prompt: placeholderText(placeholder))
                .focused($focusedField, equals: field)
                .roundedFieldStyle()
        }
    }

    private func loadStoredDetails() {
        firstName = UserDefaults.standard.string(forKey: kFirstName) ?? ""
        lastName = UserDefaults.standard.string(forKey: kLastName) ?? ""
        email = UserDefaults.standard.string(forKey: kEmail) ?? ""
        phoneNumber = UserDefaults.standard.string(forKey: kPhoneNumber) ?? ""

        if let data = UserDefaults.standard.data(forKey: kAvatar) {
            avatarImage = UIImage(data: data)
        } else {
            avatarImage = nil
        }
    }

    private func saveDetails() {
        UserDefaults.standard.set(firstName, forKey: kFirstName)
        UserDefaults.standard.set(lastName, forKey: kLastName)
        UserDefaults.standard.set(email, forKey: kEmail)
        UserDefaults.standard.set(phoneNumber, forKey: kPhoneNumber)
        focusedField = nil
    }
}

#Preview {
    UserProfile()
}
