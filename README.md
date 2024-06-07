

![seta](https://github.com/Oreo-Mcflurry/Seta/assets/96654328/d71b34cd-7ab3-42fd-9a5f-11aff69cac87)

## [출시] Seta | 2023.10.01 ~ 2023.11.30 (2달)

<aside>
⭐ 음악으로 연결되는 순간, Seta
 
Seta는 손쉽게 세트리스트를 찾아 볼 수 있고, 유저가 사용하는 음악플랫폼으로 세트리스트를 플레이리스트로 변환시켜 손쉽게 예습을 할 수 있게 하는 앱 입니다.

</aside>

![sseata](https://github.com/Oreo-Mcflurry/Seta/assets/96654328/1c0e865d-b6c5-48f1-9b7e-91f74952652f)

### 🔗 앱스토어 링크

[<img width="220" alt="스크린샷 2021-11-19 오후 3 52 02" src="https://user-images.githubusercontent.com/55099365/196023806-5eb7be0f-c7cf-4661-bb39-35a15146c33a.png">](https://apps.apple.com/kr/app/seta-%EC%84%B8%ED%83%80/id6471524204)



### 🧑‍🤝‍🧑 팀, 프로젝트 구성

- iOS 5명, 디자인 2명, PM 1명
- iOS 17.0+

### 🥕 기능

- 가수와 세트리스트 검색 기능
- 세트리스트를 Apple Music으로 옮기기
- OCR기능을 사용하는 벅스, 플로, 지니에 세트리스트를 옮기기 위한 세트리스트를 이미지로 저장기능
- 인스타그램, 트위터등의 SNS에 공유하기 위한 이미지 저장, 공유 기능
- 세트리스트 북마크, 아티스트 찜하기등의 아카이빙 기능



### 🔨 기술 스택 및 사용한 라이브러리

- SwiftUI
- Tuist
- MVVM
- Combine
- URLSession
- MusicKit
- Node.js

### 👏 해당 기술을 사용하며 이룬 성과

- SwiftData의 SwiftDataManager를 만들어 코드의 재사용성을 높임.

~~~swift
public final class SwiftDataManager: ObservableObject {
  public var modelContext: ModelContext?
  public init(modelContext: ModelContext? = nil) { self.modelContext = modelContext }

  // MARK: - Save SwiftData func
  public func save() {
    do {
      try modelContext?.save()
    } catch {
      print(error.localizedDescription)
    }
    
    // ....
 }
~~~

### 🌠 Trouble Shooting

#### 1. List의 onMove로 구현된 순서 이동이 저장이 안되는 이슈, 순서를 저장하는 ordered Property를 생성, 순서를 변경할때 ordered를 서로 변경하여 순서 저장

```swift
public func addLikeArtist(name: String,
                            country: String,
                            alias: String,
                            mbid: String,
                            gid: Int,
                            imageUrl: String?,
                            songList: [Titles]) {
    
    let descriptor = FetchDescriptor<LikeArtist>()
    let likeArtist = try? modelContext?.fetch(descriptor)
    var max = 0
    guard let likeArtist = likeArtist else { return }
    for i in 0..<likeArtist.count {
      if max < likeArtist[i].orderIndex {
        max = likeArtist[i].orderIndex
      }
    }
    let newLikeArtist = LikeArtist(artistInfo: SaveArtistInfo(name: name,
                                                              country: country,
                                                              alias: alias,
                                                              mbid: mbid,
                                                              gid: gid,
                                                              imageUrl: imageUrl ?? "",
                                                              songList: songList),
                                                              orderIndex: max+1)
    modelContext?.insert(newLikeArtist)
    self.save()
  }
```

#### 2. ObservableObject의 인스턴스를 명시적으로 생성하면, 상위View가 다시 그려질때마다 다시 ObservableObject를 재생성 하므로, 성능문제가 발생할 수 있음. 따라서 StateObject로 변경

#### 이전 코드
~~~swift
@ObservedObject var onboardingViewModel = OnboardingViewModel()
~~~

#### 수정 후 코드
~~~swift
@StateObject var onboardingViewModel = OnboardingViewModel()
~~~

#### 3. 인기 아티스트의 이름을 받아오는 과정에서 중복을 손쉽게 처리하기 위하여 Set 자료형 사용

```js
var parsing_artists = new Set();

async function crawlingArtist(database) {
    const korea_url = "https://kworb.net/spotify/country/kr_daily_totals.html";
    await request(korea_url, function (error, response, html) {
      if (!error) {
        var $ = cheerio.load(html);
        $("tbody tr").each(function (index, element) {
          var artistElement = $(element).find("td:eq(0) a");
          var artistName = artistElement.contents().first().text().trim();
          parsing_artists.add(artistName);
        });
      }
      fetchdata(database);
    });
  }
}
```

#### 4. 비슷한 의미의 태그들을 구별해주기 위하여 이런식으로 처리

```js
async function fetchTags(value) {
    const kpopGenres = [
      "k-pop",
      "Kpop",
      "Korean",
      "Korean Pop",
      "Kpop Star",
      "korean indie",
      "korean rock",
    ];
  
     // ....
  
    const jpopJrockGenres = [
      "j-pop",
      "japanese",
      "JPop",
      "J-rock",
      "J-urban",
      "J-Punk",
    ];
  
    try {
      const response = await axios.get(
        `https://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=${value}&api_key=0f54e196c4a83ed95d87c8ee18c3fdcd&format=json`
      );
      const data = response.data.artist.tags.tag;
      const tagNames = data.map((tag) => tag.name);
      var returnTags = new Set();
      for (const tag of tagNames) {
        if (kpopGenres.includes(tag)) {
          returnTags.add("K-Pop");
        } else if (popGenres.includes(tag)) {
          returnTags.add("Pop");
        } else if (hipHopRapGenres.includes(tag)) {
          returnTags.add("Hip-Hop");
        } else if (rnbSoulGenres.includes(tag)) {
          returnTags.add("R&B");
        } else if (rockAlternativeGenres.includes(tag)) {
          returnTags.add("Rock");
        } else if (metalGenres.includes(tag)) {
          returnTags.add("Metal");
        } else if (electronicGenres.includes(tag)) {
          returnTags.add("Electronic");
        } else if (countryFolkGenres.includes(tag)) {
          returnTags.add("Country/Folk");
        } else if (jpopJrockGenres.includes(tag)) {
          returnTags.add("J-Pop");
        } else {
          continue;
        }
      }

      if (returnTags.has("K-Pop") && returnTags.has("Pop")) {
        returnTags.delete("Pop");
      }
  
      return Array.from(new Set(returnTags));
    } catch (error) {
      console.error(`Error fetching data for ${value}:`, error.message);
    }
  }

  module.exports = fetchTags;
```

## 🗂️ 폴더 구조

~~~

📦Projects
 ┣ 📂App
 ┃ ┣ 📂Resources
 ┃ ┣ 📂Sources
 ┃ ┣ 📂Support
 ┣ 📂Core
 ┃ ┣ 📂Sources
 ┃ ┃ ┣ 📂Model
 ┃ ┃ ┃ ┣ 📂ArchivedConcertInfo
 ┃ ┃ ┃ ┣ 📂ArtistInfoModel
 ┃ ┃ ┃ ┣ 📂LikeArtist
 ┃ ┃ ┃ ┣ 📂SearchHistory
 ┃ ┃ ┗ 📂Service
 ┃ ┃ ┃ ┣ 📂SearchHistoryDataManager
 ┃ ┃ ┃ ┣ 📂SwiftDataManager
 ┣ 📂Feature
 ┃ ┣ 📂Scenes
 ┃ ┃ ┣ 📂ArchiveScene
 ┃ ┃ ┃ ┣ 📂Component
 ┃ ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┗ 📂ViewModel
 ┃ ┃ ┣ 📂ArtistScene
 ┃ ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┗ 📂ViewModel
 ┃ ┃ ┣ 📂MainScene
 ┃ ┃ ┃ ┣ 📂Component
 ┃ ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┗ 📂ViewModel
 ┃ ┃ ┣ 📂OnboardingScene
 ┃ ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┗ 📂ViewModel
 ┃ ┃ ┣ 📂SearchScene
 ┃ ┃ ┃ ┣ 📂Component
 ┃ ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┗ 📂ViewModel
 ┃ ┃ ┣ 📂SetlistScene
 ┃ ┃ ┃ ┣ 📂Component
 ┃ ┃ ┃ ┃ ┣ 📂CaptureSetlist
 ┃ ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┗ 📂ViewModel
 ┃ ┃ ┣ 📂SettingScene
 ┃ ┃ ┃ ┗ 📂View
 ┣ 📂UI
 ┃ ┣ 📂Resources
 ┃ ┃ ┣ 📂Colors.xcassets
 ┃ ┣ 📂Sources
 ┗ ┗ ┗ 📂Extensions
~~~

### 📺 앱 구동 화면

| 뷰 | 이미지 |
| --- | --- |
| 온보딩 뷰 | <img src="https://github.com/Oreo-Mcflurry/Seta/assets/96654328/79f5aad9-3a2d-4648-8b42-0f2599935d05" width="188" height="408"> |
| 메인 뷰 | <img src="https://github.com/Oreo-Mcflurry/Seta/assets/96654328/539f95dc-bdee-4ba2-8c35-9ecdac19e436" width="188" height="408"> |
| 서치 뷰 | <img src="https://github.com/Oreo-Mcflurry/Seta/assets/96654328/aca7c4b7-bc10-40a2-baa1-1529c09aba82" width="188" height="408"> |
| 보관함 뷰 | <img src="https://github.com/Oreo-Mcflurry/Seta/assets/96654328/71a3de3b-47a6-4922-a70a-cfa5d957e023" width="188" height="408"> |
| 아티스트 뷰 | <img src="https://github.com/Oreo-Mcflurry/Seta/assets/96654328/9b83dd2b-9be3-450e-8d35-60bab84cb5be" width="188" height="408"> |
| 세트리스트 뷰 | <img src="https://github.com/Oreo-Mcflurry/Seta/assets/96654328/4b9664f2-4123-4cd9-97da-d8f420da9d57" width="188" height="408"> |

