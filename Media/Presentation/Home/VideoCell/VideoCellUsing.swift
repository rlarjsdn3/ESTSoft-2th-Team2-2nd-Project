/*
 MARK: - VideoCell 사용법 샘플

 이 파일은 VideoCell과 VideoCellViewModel을 다른 뷰컨트롤러나 컬렉션뷰에서
 어떻게 활용하는지 간단한 샘플과 설명을 정리해둔 참고 문서입니다.

 --------------------------------------------

 1. VideoCell 등록하기

    collectionView.register(
        UINib(nibName: "VideoCell", bundle: nil),
        forCellWithReuseIdentifier: "VideoCell"
    )

 --------------------------------------------

 2. 데이터 모델 준비 (예: PixabayResponse.Hit 타입 데이터)

    // 원본 데이터 배열
    var videos: [PixabayResponse.Hit] = []

 --------------------------------------------

 3. VideoCellViewModel 생성

    // 셀에 보여줄 정보를 뷰모델로 변환
    let viewModel = VideoCellViewModel(
        title: video.user,
        viewCountText: "Views: \(video.views)",
        durationText: formatDuration(seconds: video.duration),
        thumbnailURL: video.videos.medium.thumbnail,
        profileImageURL: video.userImageUrl
    )

 --------------------------------------------

 4. 셀 구성하기 (UICollectionViewDataSource의 cellForItemAt)

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        let video = videos[indexPath.item]

        let viewModel = VideoCellViewModel(
            title: video.user,
            viewCountText: "Views: \(video.views)",
            durationText: formatDuration(seconds: video.duration),
            thumbnailURL: video.videos.medium.thumbnail,
            profileImageURL: video.userImageUrl
        )
        cell.configure(with: viewModel)
        return cell
    }

 --------------------------------------------

 5. formatDuration(seconds:) 유틸 함수 예시

    func formatDuration(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

 --------------------------------------------

 6. 참고 사항

    - VideoCell은 재사용을 고려하여 prepareForReuse()가 구현되어 있습니다.
    - 이미지 로딩은 비동기 처리되어 UI 부드럽게 동작합니다.
    - 뷰모델을 사용하면 UI와 데이터 분리, 유지보수에 유리합니다.
    - 필요한 경우 프로필 이미지나 썸네일이 없을 때 기본 이미지 처리 추가 가능.

 --------------------------------------------

 ※ 위 샘플 코드를 참조하여 프로젝트 내 다른 뷰컨트롤러에서도
    VideoCell을 쉽게 재사용할 수 있습니다.

 */
