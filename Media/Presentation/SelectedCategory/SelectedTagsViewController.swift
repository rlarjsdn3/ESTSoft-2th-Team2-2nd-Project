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
        
        showAlert("Notification", message: "\(selectedCategories.count) categories have been selected.") { _ in
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
            #warning("전광호 -> 수정해야 됨!!!!!!!!!!!!!!!!!!!!!")
            /// 취소버튼을 눌렀을 경우
            // 선택된 모든 셀의 선택을 해제하고 기본색상으로 설정
            for indexPath in self.selectIndexPath {
                self.tagsCollectionView.deselectItem(at: indexPath, animated: false)
                if let cell = self.tagsCollectionView.cellForItem(at: indexPath) as? SelectedTagsViewControllerCell {
//                    cell.contentView.backgroundColor = .tagBorderColorAlpha
                    self.updateCellAppearance(cell, selected: false)
                }
            }
            
            // 백업 해두었던 태그 index와 categoty배열을 불러온 후
            self.selectedCategories = self.backUpCategories
            self.selectIndexPath = self.backUpIndexPath
            
            // 백업으로 불러온 데이터들의 셀을 선택한 후 선택색상으로 처리
            for indexPath in self.selectIndexPath {
                self.tagsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                if let cell = self.tagsCollectionView.cellForItem(at: indexPath) as? SelectedTagsViewControllerCell {
//                    cell.contentView.backgroundColor = .tagSelected
                    self.updateCellAppearance(cell, selected: true)
                }
            }
            
            self.buttonIsEnabled()
            
            self.dismiss(animated: true)
        }
        
    }
    
    let tags: [Category] = Category.allCases
    
    var selectIndexPath: Set<IndexPath> = []
    
    var selectedCategories: [Category] = []
    
    var backUpIndexPath: Set<IndexPath> = []
    
    var backUpCategories: [Category] = []
    
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

        // UI 갱신
        tagsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, tag) in tags.enumerated() {
            if selectedCategories.contains(tag) {
                let indexPath = IndexPath(item: index, section: 0)
                selectIndexPath.insert(indexPath)
            }
        }
        
        backUpCategories = selectedCategories
        backUpIndexPath = selectIndexPath
        
        setUpLayout()
        
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.delegate = self
        
        // 온보딩에서의 셀 선택이 반영되도록 메인 스레드에서 업데이트
        DispatchQueue.main.async {
            for indexPath in self.selectIndexPath {
                self.tagsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                
                if let cell = self.tagsCollectionView.cellForItem(at: indexPath) as? SelectedTagsViewControllerCell {
                    cell.contentView.backgroundColor = .tagSelected
                }
            }
        }
        
        buttonIsEnabled()
        
    }
    
    func setUpLayout() {
        // item 사이즈
        let itemSize: NSCollectionLayoutSize
        let groupSize: NSCollectionLayoutSize
        
        // 디바이스 정보에 따라 카테고리 아이템 크기 분기
        if traitCollection.userInterfaceIdiom == .phone {
            itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.47), heightDimension: .fractionalWidth(0.47))
            groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.47))
        } else {
            itemSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(160))
            groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
        }
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        group.interItemSpacing = .flexible(10)
        
        // 섹션 구성
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        section.interGroupSpacing = 25
        
        // 레이아웃을 만들어서 컬렉션 뷰에 저장
        let layout = UICollectionViewCompositionalLayout(section: section)
        tagsCollectionView.collectionViewLayout = layout
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
        print("셀 선택")
        if selectIndexPath.count >= 5 {
            
            showAlert("❌Can't select more than 5", message: "Only up to 5 categories can be selected") { _ in
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
        
        print("셀 선택 해제")
        // 셀 선택해제 시 색상변경
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectedTagsViewControllerCell {
            updateCellAppearance(cell, selected: false)
        }
        
        buttonIsEnabled()
    }
}
