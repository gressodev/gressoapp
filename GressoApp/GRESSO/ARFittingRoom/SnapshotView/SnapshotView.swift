//
//  SnapshotView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 26.06.2023.
//

import SwiftUI

struct SnapshotView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingShareScreen = false
    
    let snapshot: UIImage
    
    var body: some View {
        ZStack {
            Image(uiImage: snapshot)
                .resizable()
                .scaledToFit()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                )
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(uiImage: Images.cross)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(10)
                        }
                        .background(.black)
                        .cornerRadius(4)
                        .frame(width: 44, height: 44)
                    }
                    .padding(.top, 54)
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 10) {
                    Button {
                        UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
                        dismiss()
                    } label: {
                        GressoStyiledButton(
                            image: Images.download,
                            verticalPadding: .zero,
                            horizontalPadding: .zero
                        )
                    }
                    VStack {
                        if #available(iOS 16.0, *) {
                            ShareLink(
                                item: Image(uiImage: snapshot),
                                preview: SharePreview(
                                    "GRESSO",
                                    image: Image(uiImage: snapshot)
                                )
                            ) {
                                GressoStyiledButton(
                                    image: Images.share,
                                    verticalPadding: .zero,
                                    horizontalPadding: .zero
                                )
                            }
                        } else {
                            Button {
                                showingShareScreen = true
                            } label: {
                                GressoStyiledButton(
                                    image: Images.share,
                                    verticalPadding: .zero,
                                    horizontalPadding: .zero
                                )
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
                .tint(.white)
                .background(.black)
            }
        }
        .ignoresSafeArea(.all)
        .sheet(isPresented: $showingShareScreen) {
            ActivityView(items: [snapshot])
        }
    }
}

struct SnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        SnapshotView(snapshot: UIImage(named: Images.menuButtonIcon)!)
    }
}
