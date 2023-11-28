//
//  SearchArtistCell.swift
//  Feature
//
//  Created by A_Mcflurry on 10/8/23.
//  Copyright © 2023 com.creative8. All rights reserved.
//

import SwiftUI
import UI
import Core

struct SearchArtistCell: View {
  @Binding var selectedTab: Tab
  let imageURL: String
  let artistName: String
  let artistMbid: String
  
  var body: some View {
    VStack(alignment: .leading) {
      NavigationLink(value: NavigationDelivery(artistInfo: SaveArtistInfo(name: artistName, country: "", alias: "", mbid: artistMbid, gid: 0, imageUrl: imageURL, songList: []))) {
        AsyncImage(url: URL(string: imageURL)) { phase in
          switch phase {
          case .empty:
            Image("ticket", bundle: setaBundle)
              .resizable()
              .scaledToFill()
          case .success(let image):
            image
              .resizable()
              .scaledToFill()
          case .failure:
            Image("ticket", bundle: setaBundle)
              .resizable()
              .scaledToFill()
          @unknown default:
            EmptyView()
          }
        }
      }
      .aspectRatio(contentMode: .fit)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.lineGrey1, lineWidth: 1))
      
      Text("\(artistName)")
        .foregroundStyle(Color.mainBlack)
        .font(.footnote)
        .lineLimit(1)
    }
  }
}
