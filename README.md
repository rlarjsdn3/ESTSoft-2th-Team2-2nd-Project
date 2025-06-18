# ESTSoft 2기 Team2 2차 프로젝트 🎥

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org) [![iOS](https://img.shields.io/badge/iOS-17.0%2B-blue.svg)](https://developer.apple.com/ios) [![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)  

<br>
<br>
<br>

<p align="center">
  <img src="https://github.com/user-attachments/assets/99ea2882-8bf8-4d62-957a-17d265f98d02" width="200" />
</p>

<h1 align="center"><strong>굳이오</strong></h1>
<p align="center"><em>사용자의 취향 분석을 통한 맞춤형 비디오 스트리밍 플레이어</em></p>

<br>
<br>
<br>

## 📖 프로젝트 개요
**굳이오**는 
AVFoundation, AVKit을 활용해 네이티브 앱 내에서 Pixabay REST API로 동영상을 스트리밍하고,  
사용자가 원하는 방향으로 **필터링**, **북마킹**, **플레이리스트 추가** 등 다양한 맞춤형 기능을 사용할 수 있는 iOS 애플리케이션입니다.
<br>
<br>



## 📅 개발 기간
| 기간              | 작업 내용                                 |
|-----------------|---------------------------------------|
| 6월 5일 ~ 6월 8일   | 기획 및 디자인, 요구사항 정리, 공통 코드 기반 구축        |
| 6월 9일 ~ 6월 15일  | UI 설계 및 로직 구현                         |
| 6월 15일 ~ 6월 18일 | QA 테스트, UX/UI 개선 (GitHub Projects 사용) |


<br>


## 주요 기능
- 사용자 취향 분석 알고리즘을 통한 추천 동영상 제시
- 검색어를 통한 비디오 검색 및 필터링 
- 시청한 비디오 기록 트래킹 및 저장
- 비디오 북마크 기능, 플레이 리스트 생성
- 다양한 탭 제스쳐 (Context Menu, Swipe to delete…)
- 비디오 화질 선택에 따른 사용자 네트워크 안정성 지원
- 비디오 PIP(Picture-in-Picture) 모드 전환 기능


## 추가 기능
- 다크모드 지원
- iPad: 세로/가로 방향 모두 최적화된 UI 지원

<br>


## 📝 화면 별 주요 기능 명세서
| 화면           | 주요 기능                                                        |
|--------------|--------------------------------------------------------------|
| Onboarding   | - 앱 최초 실행 시 온보딩 슬라이드 실행                                      |
| HomeView     | - 기본 비디오 목록 출력 및 개인화 된 맞춤형 비디오를 페이지네이션으로 출력 <br>- 비디오 북마크 등록 및 플레이리스트 추가 |
| SearchView   | - 사용자가 입력한 키워드로 영상 검색<br>- 카테고리, 정렬 기준(인기순 / 최신순), 영상 길이의 필터링 기능 제공 |
| LibraryView  | - 시청한 비디오 목록 출력 및 검색 기능 제공<br>- 북마크된 비디오 보관, 플레이리스트 생성 및 보관  |
| InterestView | - 다양한 분야의 취향 선택 (최대 5개)                                      |
| SettingView  | - 다크모드 지원<br>- 비디오 해상도 설정 <br>- 메일 피드백 기능 지원             |
| VideoPlayer | - PIP 모드 전환 가능 |


<br>

## 📱주요 화면 스크린샷

<table align="center">
  <thead>
    <tr>
      <th align="center"><strong>Home</strong></th>
      <th align="center"><strong>Search</strong></th>
      <th align="center"><strong>History</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><img src="https://github.com/user-attachments/assets/76350a33-ea5b-4b45-adb1-1ec8ffed6006" width="300"/></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/a7dc312b-52a6-46b0-8238-dbf7a28e1778" width="300"/></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/42faa00e-e95b-4a52-b1cf-55295e599be4" width="300"/></td>
    </tr>
  </tbody>
</table>

<br>

<table align="center">
  <thead>
    <tr>
      <th align="center"><strong>Interest</strong></th>
      <th align="center"><strong>Settings</strong></th>
      <th align="center"><strong>Video Player</strong></th>
      <th align="center"><strong>PIP</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center"><img src="https://github.com/user-attachments/assets/bbd666c4-6566-4fb2-a8dd-2a6721b6570d" width="300"/></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/19b96915-e0b8-45cd-8c36-477723e579d0" width="300"/></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/5924cad6-4b6e-445c-a212-a0ac876b4612" width="300"/></td>
      <td align="center"><img src="https://github.com/user-attachments/assets/339e1d08-a4a7-4cc2-b32c-670bb7f7a796" width="300"/></td>
    </tr>
  </tbody>
</table>

<br>


## 📁 파일 구조
~~~ bash
├── Media/
│   ├── Application/
│   ├── Core/
│   │   ├── Common/
│   │   ├── Extensions/
│   │   ├── Protocols/
│   │   └── Utils/
│   │       ├── NibView/
│   │       ├── Shimmer/
│   │       └── StoryboardViewController/
│   ├── Infrastructure/
│   ├── Model/
│   ├── Presentation/
│   │   ├── Bookmark/
│   │   ├── Home/
│   │   ├── Main/
│   │   ├── Onboarding/
│   │   ├── Search/
│   │   ├── SelectedCategory/
│   │   └── Settings/
│   ├── Resources/
│   │   ├── Assets/
│   │   ├── Info/
│   │   └── LaunchScreen/
└── Frameworks/
~~~

<br>

## ⚙️ 기술 스택
- **언어**: Swift  
- **프레임워크**: AVFoundation, AVKit, UIKit  
- **비동기 처리**: GCD(DispatchQueue), Swift Concurrency (async/await)  
- **네트워킹**: URLSession  
- **저장소**: UserDefaults, CoreData  
- **외부 라이브러리**: [TSAlertController](https://github.com/rlarjsdn3/TSAlertController-iOS) – 커스텀 알림창 구성  
- **API**: Pixabay REST API  
- **버전 관리 및 협업**: Git, GitHub (GitHub Issues, Projects, Pull Requests 활용)

<br>

## 🚀 설치 및 실행 방법

1. 리포지토리 클론  
   ```bash
   git clone https://github.com/rlarjsdn3/ESTSoft-2th-Team2-2nd-Project.git
   cd ESTSoft-2th-Team2-2nd-Project
   ```

2. Xcode에서 프로젝트 열기
   Media.xcodeproj 또는 .xcworkspace 파일을 실행하세요.

3. **빌드 설정 변경**
   **Xcode 상단의** Run **대상 설정에서** Release **모드로 변경 후 실행해야 합니다.** <br>(기본 Debug 모드로 실행 시 일부 UI 또는 기능이 정상 동작하지 않을 수 있습니다)

5. 실행 (⌘ + R)
   iOS 17+ 시뮬레이터 또는 실제 디바이스에서 실행 가능합니다.


<br>


## 👥 팀원 소개

<table align="center">
  <tr>
    <td align="center"><img src="https://github.com/aldalddl.png" width="100"/></td>
    <td align="center"><img src="https://github.com/rlarjsdn3.png" width="100"/></td>
    <td align="center"><img src="https://github.com/jaehun6165.png" width="100"/></td>
    <td align="center"><img src="https://github.com/HyeonjinBack.png" width="100"/></td>
    <td align="center"><img src="https://github.com/puuurm.png" width="100"/></td>
    <td align="center"><img src="https://github.com/Jeon-GwangHo.png" width="100"/></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/aldalddl">@aldalddl</a></td>
    <td align="center"><a href="https://github.com/rlarjsdn3">@rlarjsdn3</a></td>
    <td align="center"><a href="https://github.com/jaehun6165">@jaehun6165</a></td>
    <td align="center"><a href="https://github.com/HyeonjinBack">@HyeonjinBack</a></td>
    <td align="center"><a href="https://github.com/puuurm">@puuurm</a></td>
    <td align="center"><a href="https://github.com/Jeon-GwangHo">@Jeon-GwangHo</a></td>
  </tr>
  <tr>
    <td align="center">Design Lead<br>UX/UI 및 기능 개발</td>
    <td align="center">Project Manager<br>UX/UI 및 기능 개발</td>
    <td align="center">Speaker(자료)<br>UX/UI 및 기능 개발</td>
    <td align="center">Technical Writer<br>UX/UI 및 기능 개발</td>
    <td align="center">QA<br>UX/UI 및 기능 개발</td>
    <td align="center">Speaker<br>UX/UI 및 기능 개발</td>
  </tr>
</table>
</table>
