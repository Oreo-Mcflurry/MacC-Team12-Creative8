//
//  ArtistViewModel.swift
//  Feature
//
//  Created by 고혜지 on 10/21/23.
//  Copyright © 2023 com.creative8.seta. All rights reserved.
//

import Foundation
import Core
import SwiftUI

class ArtistViewModel: ObservableObject {
  let dataService: SetlistDataService = SetlistDataService.shared
  let koreanConverter: KoreanConverter = KoreanConverter.shared
  let artistDataManager: ArtistDataManager = ArtistDataManager.shared
  let archivingviewModel = ArchivingViewModel.shared
  let dataManager = SwiftDataManager()
  
  var artistInfo: ArtistInfo
  var setlists: [Setlist]?
  var page: Int = 1
  var totalPage: Int = 0
  
  @Published var showBookmarkedSetlists: Bool
  @Published var isLoading1: Bool
  @Published var isLoading2: Bool
  @Published var isLoading3: Bool
  @Published var image: UIImage?
  @Published var isLikedArtist: Bool

  init() {
    self.showBookmarkedSetlists = false
    self.isLoading1 = false
    self.isLoading2 = false
    self.isLoading3 = false
    self.image = nil
    self.isLikedArtist = false
    self.artistInfo = ArtistInfo(name: "", mbid: "")
  }
  
  func getArtistInfoFromGenius(artistName: String, artistAlias: String?, artistMbid: String) {
    self.isLoading1 = true
    artistDataManager.getArtistInfo(artistInfo: ArtistInfo(name: artistName, alias: artistAlias, mbid: artistMbid)) { result in
      if let result = result {
        DispatchQueue.main.async {
          self.artistInfo = result
          self.isLoading1 = false
        }
      } else {
        print("Failed to fetch artist info. 1")
        self.artistDataManager.getArtistInfo(artistInfo: ArtistInfo(name: artistName, alias: artistAlias, mbid: artistMbid)) { result in
          if let result = result {
            DispatchQueue.main.async {
              self.artistInfo = result
              self.isLoading1 = false
            }
          } else {
            self.isLoading1 = false
            print("Failed to fetch artist info. 2")
          }
        }
      }
    }
  }
  
  func getSetlistsFromSetlistFM(artistMbid: String) {
    if self.setlists == nil {
      self.isLoading2 = true
      dataService.fetchSetlistsFromSetlistFM(artistMbid: artistMbid, page: page) { result in
        if let result = result {
          DispatchQueue.main.async {
            self.setlists = result.setlist
            self.totalPage = Int((result.total ?? 1) / (result.itemsPerPage ?? 1) + 1)
            self.isLoading2 = false
          }
        } else {
          self.isLoading2 = false
          print("Failed to fetch setlist data.")
        }
      }
    }
  }

  func fetchNextPage(artistMbid: String) {
    page += 1
    self.isLoading3 = true
    dataService.fetchSetlistsFromSetlistFM(artistMbid: artistMbid, page: page) { result in
      if let result = result {
        DispatchQueue.main.async {
          self.setlists?.append(contentsOf: result.setlist ?? [])
          self.isLoading3 = false
        }
      } else {
        self.isLoading3 = false
        print("Failed to fetch setlist data.")
      }
    }
  }
  
  func loadImage() {
    if let imageUrl = artistInfo.imageUrl {
      if let url = URL(string: imageUrl) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
          if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
              self.image = image
            }
          }
        }
        .resume()
      } else {
        self.image = UIImage(named: "artistViewTicket", in: Bundle(identifier: "com.creative8.seta.UI"), compatibleWith: nil)
        print("Invalid Image URL")
      }
    } else {
      self.image = UIImage(named: "artistViewTicket", in: Bundle(identifier: "com.creative8.seta.UI"), compatibleWith: nil)
      return
    }
  }

  func getFormattedDateFromString(date: String, format: String) -> String? {
    let inputDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "dd-MM-yyyy"
      return formatter
    }()
    
    let outputDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = format
      return formatter
    }()
    
    if let inputDate = inputDateFormatter.date(from: date) {
      return outputDateFormatter.string(from: inputDate)
    } else {
      return nil
    }
  }
  
  func getFormattedDateFromDate(date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
  }
  
  func isEmptySetlist(_ setlist: Setlist) -> Bool {
    if setlist.sets?.setsSet?.isEmpty == true {
      return true
    }
    return false
  }
  
}
