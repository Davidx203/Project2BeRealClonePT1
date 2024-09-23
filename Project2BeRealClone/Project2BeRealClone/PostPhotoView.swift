//
//  PostPhotoView.swift
//  Project2BeRealClone
//
//  Created by David Perez on 9/22/24.
//

import SwiftUI
import ParseCore


struct PostPhotoView: View {
    @State var caption = ""
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage? = nil
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            HStack {
                Text("Photo")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .overlay(content: {
                HStack {
                    Spacer()
                    Button(action: {
                        postPhoto()
                    }, label: {
                        Text("Post")
                    })
                }
            })

            TextField("Caption", text: $caption)
                .padding(5)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Button(action: {
                isImagePickerPresented = true
            }, label: {
                Text("Select Photo")
            })
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.blue.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 5))

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
            
            Spacer()

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(35)
        .foregroundColor(.white)
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    func postPhoto() {
        guard let image = selectedImage else {
            errorMessage = "Please select a photo."
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Error converting image."
            return
        }

        let file = PFFileObject(name: "photo.jpg", data: imageData)

        guard let currentUser = PFUser.current() else {
            errorMessage = "Error: No user is logged in."
            return
        }

        let photoPost = PFObject(className: "PhotoPost")
        photoPost["caption"] = caption
        photoPost["username"] = currentUser.username
        photoPost["photo"] = file

        // Print debug statement
        print("Attempting to save photo post...")

        photoPost.saveInBackground { (success, error) in
            if let error = error {
                // Check if it's a timeout error
                if let parseError = error as? NSError, parseError.domain == NSURLErrorDomain {
                    errorMessage = "Request timed out. Please try again."
                } else {
                    errorMessage = "Error posting photo: \(error.localizedDescription)"
                }
                print("Error: \(error.localizedDescription)")
            } else if success {
                errorMessage = "Photo posted successfully!"
                print("Photo post saved successfully.")
            }
        }
    }

}

// Image picker using UIViewControllerRepresentable
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    PostPhotoView()
}
