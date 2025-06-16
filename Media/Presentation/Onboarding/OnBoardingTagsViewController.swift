//
//  OnBoardingTagsViewController.swift
//  Media
//
//  Created by 전광호 on 6/9/25.
//

import UIKit

class OnBoardingTagsViewController: StoryboardViewController {

    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    @IBOutlet weak var selectedTagButton: UIButton!
    
    @IBAction func selectedTagButton(_ sender: Any) {
        // 선택된 태그 데이터를 가지고 home뷰로 넘어가기
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MainVC") as? UITabBarController, let nav1 = vc.viewControllers?.first as? UINavigationController, let _ = nav1.viewControllers.first as? HomeViewController {
            
            for category in selectedCategories {
                TagsDataManager.shared.save(category: category)
            }
            
            NotificationCenter.default.post(
                name: .didSelectedCategories,
                object: nil,
                userInfo: ["categories": selectedCategories]
            )
            
            UserDefaults.standard.seenOnboarding = true
            
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    var selectedCategories: [Category] = []
    
    let tags: [Category] = Category.allCases
    
    var selectedIndexPath: Set<IndexPath> = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpLayout()
        
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.delegate = self
       
        selectedTagButton.isEnabled = false
        
        self.navigationController?.navigationBar.isHidden = true
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
        if selectedIndexPath.count >= 3 {
            selectedTagButton.isEnabled = true
        } else {
            selectedTagButton.isEnabled = false
        }
    }
    
    func updateCellAppearance(_ cell: OnboardingTagsViewCell, selected: Bool) {
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

extension OnBoardingTagsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTagsViewCell", for: indexPath) as? OnboardingTagsViewCell else { return UICollectionViewCell() }
        
        let target = tags[indexPath.item]
        
        if selectedIndexPath.contains(indexPath) {
            updateCellAppearance(cell, selected: true)
        } else {
            updateCellAppearance(cell, selected: false)
        }
        
        cell.tagsTitle.text = target.rawValue.capitalized
        cell.tagsImageView.image = target.symbolImage

        return cell
    }
}

extension OnBoardingTagsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath.count >= 5 {
            
            showAlert("🔔Can't select more than 5", message: "Only up to 5 categories can be selected") { _ in
                self.dismiss(animated: true)
            } onCancel: { _ in
                self.dismiss(animated: true)
            }

            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        selectedIndexPath.insert(indexPath)
        selectedCategories = selectedIndexPath.map { tags[$0.item] }
        
        // 셀 선택시 색상변경
        if let cell = collectionView.cellForItem(at: indexPath) as? OnboardingTagsViewCell {
            updateCellAppearance(cell, selected: true)
        }
        
       buttonIsEnabled()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndexPath.remove(indexPath)
        selectedCategories = selectedIndexPath.map { tags[$0.item] }
        
        // 셀 선택해제 시 색상변경
        if let cell = collectionView.cellForItem(at: indexPath) as? OnboardingTagsViewCell {
            updateCellAppearance(cell, selected: false)
        }
        
        buttonIsEnabled()
    }
}

extension UserDefaults {
    var seenOnboarding: Bool {
        get {
            bool(forKey: "seenOnboariding")
        }
        set {
           set(newValue, forKey: "seenOnboariding")
        }
    }
}
