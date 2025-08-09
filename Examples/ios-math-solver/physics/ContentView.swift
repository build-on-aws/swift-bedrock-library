import MarkdownUI
import PhotosUI
import SwiftUI
//import LaTeXSwiftUI

struct ContentView: View {
    @StateObject private var viewModel: MathSolverViewModel
    @State private var showImagePicker = false
    @State private var showPhotoLibrary = false
    @State private var selectedImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isResponseExpanded = false
    @EnvironmentObject var authManager: AuthenticationManager

    init() {
        // Initialize the view model with the auth manager that will be provided via environment
        _viewModel = StateObject(wrappedValue: MathSolverViewModel())
    }

    var body: some View {
        NavigationView {
            VStack {
                // Image and buttons section - collapses when response is streaming
                if !isResponseExpanded {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .transition(.opacity)
                    }

                    HStack {
                        // Camera Button
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Label("Camera", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        // Photo Library Button
                        PhotosPicker(selection: $photoPickerItem,
                                     matching: .images)
                        {
                            Label("Library", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                } else {
                    // Minimized controls when expanded
                    HStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .cornerRadius(5)
                        }

                        Spacer()

                        Button(action: {
                            showImagePicker = true
                        }) {
                            Image(systemName: "camera")
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        PhotosPicker(selection: $photoPickerItem, matching: .images) {
                            Image(systemName: "photo.on.rectangle")
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }

                // Toggle button for expanding/collapsing
                if !viewModel.streamedResponse.isEmpty {
                    Button(action: {
                        withAnimation {
                            isResponseExpanded.toggle()
                        }
                    }) {
                        Label(isResponseExpanded ? "Show Image" : "Expand Solution",
                              systemImage: isResponseExpanded ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                            .font(.caption)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 4)
                }

                // Response section with auto-scrolling
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            }

                            if !viewModel.streamedResponse.isEmpty {
                                // Display the full response
                                 Markdown(viewModel.streamedResponse)
                                    .padding(.horizontal)
                                    .textSelection(.enabled)
                                    .id("response")

                                // Debug info
                                Text("Response length: \(viewModel.streamedResponse.count) characters")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
//                            else {
//                                Text("Hello")
//                                MarkdownLatexView(markdownContent: viewModel.streamedResponse)
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            }

                            // Invisible element at the bottom for scrolling
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .onChange(of: viewModel.streamedResponse) {
                        // Delay the scroll slightly to ensure content is rendered
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Math Problem Solver")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .camera) { image in
                    if let image = image {
                        selectedImage = image
                        viewModel.analyzeImage(image)
                    }
                }
            }
            .onChange(of: photoPickerItem) {
                Task {
                    if let data = try? await photoPickerItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data)
                    {
                        selectedImage = image
                        viewModel.analyzeImage(image)
                    }
                }
            }
            .onChange(of: viewModel.isLoading) {
                // Auto-expand when response starts streaming
                if viewModel.isLoading {
                    withAnimation {
                        isResponseExpanded = true
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Sign Out")
                    }
                }
            }
            .onAppear {
                // Connect the view model to the auth manager when the view appears
                viewModel.setAuthManager(authManager)
                // No need to call updateCredentials() as setAuthManager already sets up the client
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
        {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
