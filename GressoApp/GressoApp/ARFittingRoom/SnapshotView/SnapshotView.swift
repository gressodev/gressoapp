//
//  SnapshotView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 26.06.2023.
//

import SwiftUI

struct SnapshotView: View {
    @Environment(\.dismiss) var dismiss
    
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
                        Image(systemName: Assets.Images.xmarkCircleFill)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .shadow(radius: 5)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 70)
                    .padding(.leading, 30)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Button {
                        UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
                        dismiss()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .shadow(radius: 5)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .padding(.bottom, 40)
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .shadow(radius: 5)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .padding(.bottom, 40)
                    
                }.padding()
            }
        }
        .ignoresSafeArea(.all)
    }
}

struct SnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        SnapshotView(snapshot: UIImage(named: Assets.Images.menuButtonIcon)!)
    }
}
