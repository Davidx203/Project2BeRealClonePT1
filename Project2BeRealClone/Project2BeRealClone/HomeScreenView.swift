//
//  HomeScreenView.swift
//  Project2BeRealClone
//
//  Created by David Perez on 9/22/24.
//

import SwiftUI
import ParseCore

struct HomeScreenView: View {
    @State private var photos = [PhotoPostModel]()
    @State private var isRefreshing = false
    @Environment(\.presentationMode) var presentationMode // To dismiss view

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.2.fill")
                    .clipShape(Circle())
                Spacer()
                Text("BeReal.")
                Spacer()
                Button(action: {
                    logOut()
                }, label: {
                    Text("Logout")
                })
                .font(.subheadline)
            }
            .font(.title)

            ScrollView {
                ForEach(photos) { photo in
                    PhotoRowView(username: photo.username, caption: photo.caption, date: photo.createdAt, image: photo.image)
                }

                NavigationLink(destination: PostPhotoView()) {
                    Text("Post a Photo")
                        .fontWeight(.bold)
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .frame(maxWidth: .infinity)
            .refreshable(action: {
                fetchPhotos()
                print("refreshing")
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(35)
        .foregroundColor(.white)
        .background(Color.black.ignoresSafeArea())
    }

    func logOut() {
        PFUser.logOutInBackground { (error) in
            if let error = error {
                print("Error logging out: \(error.localizedDescription)")
            } else {
                // Go back to the WelcomeView
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    struct PhotoPostModel: Identifiable {
        let id: String
        let caption: String
        let username: String
        let createdAt: Date
        let image: UIImage
    }

    func fetchPhotos() {
        let query = PFQuery(className: "PhotoPost")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error) in
            if let objects = objects {
                var fetchedPhotos: [PhotoPostModel] = []
                let dispatchGroup = DispatchGroup()

                for object in objects {
                    dispatchGroup.enter()

                    if let file = object["photo"] as? PFFileObject {
                        file.getDataInBackground { (data, error) in
                            if let data = data, let image = UIImage(data: data) {
                                let photoPostModel = PhotoPostModel(
                                    id: object.objectId!,
                                    caption: object["caption"] as? String ?? "",
                                    username: object["username"] as? String ?? "",
                                    createdAt: object.createdAt ?? Date(),
                                    image: image
                                )
                                fetchedPhotos.append(photoPostModel)
                            } else {
                                print("Error fetching image: \(error?.localizedDescription ?? "Unknown error")")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    photos = fetchedPhotos
                    isRefreshing = false
                }
            } else {
                print("Error fetching photos: \(error?.localizedDescription ?? "Unknown error")")
                isRefreshing = false
            }
        }
    }
}


struct PhotoRowView: View {
    var username: String
    var caption: String
    var date: Date
    var image: UIImage // Added image property

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                
                Text(username)
                    .font(.headline)
                Spacer()
                Text(date, style: .date)
                    .font(.caption)
            }
            .padding(.bottom, 5)

            // Display the image
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Optional: rounded corners
            
            Text(caption)
                .font(.body)
                .padding(.vertical)
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
    }
}


struct PullToRefresh: UIViewRepresentable {
    @Binding var isRefreshing: Bool

    class Coordinator {
        var control: UIRefreshControl

        init(control: UIRefreshControl) {
            self.control = control
        }

        @objc func onRefresh() {
            control.beginRefreshing()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(control: UIRefreshControl())
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let refreshControl = context.coordinator.control
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.onRefresh), for: .valueChanged)

        let scrollView = UIScrollView()
        scrollView.refreshControl = refreshControl

        // Adding pull to refresh functionality
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.onRefresh), for: .valueChanged)

        view.addSubview(scrollView)

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let scrollView = uiView.subviews.compactMap { $0 as? UIScrollView }.first

        if isRefreshing {
            scrollView?.refreshControl?.beginRefreshing()
        } else {
            scrollView?.refreshControl?.endRefreshing()
        }
    }
}

#Preview {
    HomeScreenView()
}
