//
//  SelectedCategoryViewController.swift
//  Media
//
//  Created by 전광호 on 6/10/25.
//

import UIKit

class SelectedTagsViewController: StoryboardViewController {
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    @IBOutlet weak var selectedTagsButton: UIButton!
    
    @IBAction func selectedTagsButton(_ sender: Any) {
        
        TagsDataManager.shared.deleteAllTagsData()

        for category in selectedCategories {
            TagsDataManager.shared.save(category: category)
        }
        
        
        NotificationCenter.default.post(
            name: .didSelectedCategories,
            object: nil,
            userInfo: ["categories": selectedCategories]
        )
        
        showAlert(title: "Notification", message: "\(selectedCategories.count) categories have been selected.") { _ in
            /// 확인 버튼을 눌렀을 경우
            // 태그 코어데이터의 모든 데이터를 삭제
            TagsDataManager.shared.deleteAllTagsData()
            
            // 선택한 태그들을 코어데이터에 저장
            for category in self.selectedCategories {
                TagsDataManager.shared.save(category: category)
            }
            
            // homeView로 선택한 카테고리 데이터 Notification 전달
            NotificationCenter.default.post(
                name: .didSelectedCategories,
                object: nil,
                userInfo: ["categories": self.selectedCategories]
            )
            
            self.dismiss(animated: true)
        } onCancel: { _ in
            self.dismiss(animated: true)
        }
        
    }
    
    let tags: [Category] = Category.allCases
    
    var selectIndexPath: Set<IndexPath> = []
    
    var selectedCategories: [Category] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Onboarding, Setting View에서 선택된 카테고리 다시 로드
        selectedCategories = TagsDataManager.shared.fetchSelectedCategories()
        
        // IndexPath 재구성
        selectIndexPath.removeAll()
        
        for (index, tag) in tags.enumerated() {
            if selectedCategories.contains(tag) {
                selectIndexPath.insert(IndexPath(item: index, section: 0))
            }
        }
        
        // 온보딩에서의 셀 선택이 반영되도록 메인 스레드에서 업데이트
        DispatchQueue.main.async {
            for indexPath in self.selectIndexPath {
                self.tagsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                
                if let cell = self.tagsCollectionView.cellForItem(at: indexPath) as? SelectedTagsViewControllerCell {
                    self.updateCellAppearance(cell, selected: true)
                }
            }
        }

        // UI 갱신
        tagsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        tagsCollectionView.collectionViewLayout = createCompositionalLayout()
        
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.delegate = self
        
        buttonIsEnabled()
        
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, environment in

            let itemWidthDimension: NSCollectionLayoutDimension = switch environment.container.effectiveContentSize.width {
            case ..<500:      .fractionalWidth(0.5)  // 아이폰 세로모드
            case 500..<1050:  .fractionalWidth(0.2)  // 아이패드 세로 모드
            default:          .fractionalWidth(0.125) // 아이패드 가로 모드
            }
            let itemSize = NSCollectionLayoutSize(
                widthDimension: itemWidthDimension,
                heightDimension: itemWidthDimension
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let columnCount = switch environment.container.effectiveContentSize.width {
            case ..<500:      2 // 아이폰 세로모드
            case 500..<1050:  5 // 아이패드 세로 모드
            default:          8 // 아이패드 가로 모드
            }
            print(environment.container.effectiveContentSize.width)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: itemWidthDimension
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: columnCount
            )
            group.interItemSpacing = .flexible(20)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)

           
            return section
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    // 셀이 3개 이상 선택되면 버튼 활성화
    func buttonIsEnabled() {
        if selectIndexPath.count >= 3 {
            selectedTagsButton.isEnabled = true
        } else {
            selectedTagsButton.isEnabled = false
        }
    }
    
    // 다크모드와 셀 선택에 따른 셀의 색상변경
    func updateCellAppearance(_ cell: SelectedTagsViewControllerCell, selected: Bool) {
        if selected {
            cell.contentView.backgroundColor = .tagSelected
            cell.tagsTitle.textColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
            cell.tagsImageView.tintColor = traitCollection.userInterfaceStyle == .dark ? .black : .white
        } else {
            cell.contentView.backgroundColor = .tagBorderColorAlpha
            cell.tagsTitle.textColor = .label
            cell.tagsImageView.tintColor = .label
        }
    }
}

extension SelectedTagsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedTagsViewControllerCell", for: indexPath) as? SelectedTagsViewControllerCell else { return UICollectionViewCell() }
        
        let target = tags[indexPath.item]

        cell.tagsTitle.text = target.rawValue.capitalized
        cell.tagsImageView.image = target.symbolImage
        
        if selectIndexPath.contains(indexPath) {
            updateCellAppearance(cell, selected: true)
        } else {
            updateCellAppearance(cell, selected: false)
        }
        return cell
    }
}

extension SelectedTagsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectIndexPath.count >= 5 {
            
            showAlert(title: "Can't select more than 5", message: "Only up to 5 categories can be selected") { _ in
                self.dismiss(animated: true)
            } onCancel: { _ in
                self.dismiss(animated: true)
            }
            
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        selectIndexPath.insert(indexPath)
        selectedCategories = selectIndexPath.map { tags[$0.item] }
        
        
        // 셀 선택시 색상변경
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectedTagsViewControllerCell {
            updateCellAppearance(cell, selected: true)
        }
        
        buttonIsEnabled()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectIndexPath.remove(indexPath)
        selectedCategories = selectIndexPath.map { tags[$0.item] }
        
        // 셀 선택해제 시 색상변경
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectedTagsViewControllerCell {
            updateCellAppearance(cell, selected: false)
        }
        
        buttonIsEnabled()
    }
}
