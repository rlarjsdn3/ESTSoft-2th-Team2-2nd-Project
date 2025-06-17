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

        tagsCollectionView.collectionViewLayout = createCompositionalLayout()
        
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.delegate = self
       
        selectedTagButton.isEnabled = false
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, environment in

            let itemWidthDimension: NSCollectionLayoutDimension = switch environment.container.effectiveContentSize.width {
            case ..<500:      .fractionalWidth(0.5)  // 아이폰 세로모드
            case 500..<1050:  .fractionalWidth(0.25)  // 아이패드 세로 모드
            default:          .fractionalWidth(0.125) // 아이패드 가로 모드
            }
            let itemSize = NSCollectionLayoutSize(
                widthDimension: itemWidthDimension,
                heightDimension: itemWidthDimension
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let columnCount = switch environment.container.effectiveContentSize.width {
            case ..<500:      2 // 아이폰 세로모드
            case 500..<1050:  4 // 아이패드 세로 모드
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
        if selectedIndexPath.count >= 3 {
            selectedTagButton.isEnabled = true
        } else {
            selectedTagButton.isEnabled = false
        }
    }
    
    func updateCellAppearance(_ cell: OnboardingTagsViewCell, selected: Bool) {
        if selected {
            cell.contentView.backgroundColor = .tagSelected
            cell.tagsTitle.textColor = UIColor.categorySelectedColor
            cell.tagsImageView.tintColor = UIColor.categorySelectedColor
        } else {
            cell.contentView.backgroundColor = UIColor.categoryUnselectedBackgroundColor
            cell.tagsTitle.textColor = UIColor.categoryUnselectedColor
            cell.tagsImageView.tintColor = UIColor.categoryUnselectedColor
        }
        
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.masksToBounds = true
        
        // 그림자 설정
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 5
        cell.layer.masksToBounds = false

        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
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
            
            showAlert(title: "Can't select more than 5", message: "Only up to 5 categories can be selected") { _ in
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
