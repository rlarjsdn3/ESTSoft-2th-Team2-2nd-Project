//
//  OnBoardingTagsViewController.swift
//  Media
//
//  Created by 전광호 on 6/9/25.
//

import UIKit

class OnBoardingTagsViewController: StoryboardViewController {

    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    @IBAction func skipTagButton(_ sender: Any) {
        // 바로 home뷰로 넘어가기
    }
    
    @IBOutlet weak var selectedTagButton: UIButton!
    
    @IBAction func selectedTagButton(_ sender: Any) {
        // 선택된 태그 데이터를 가지고 home뷰로 넘어가기
        
    }
    
    let Tags: [Category] = Category.allCases
    
    var selectIndexPath: Set<IndexPath> = []
    
    func setUpLayout() {
        // item 사이즈
        let itemSize: NSCollectionLayoutSize
        
        // 디바이스 정보에 따라 카테고리 아이템 크기 분기
        if traitCollection.userInterfaceIdiom == .phone {
            itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.47), heightDimension: .absolute(150))
        } else {
            itemSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(160))
        }
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 그룹 사이즈
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150))
        
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpLayout()
        
        tagsCollectionView.allowsMultipleSelection = true
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.delegate = self
       
        selectedTagButton.isEnabled = false
        
        self.navigationItem.hidesBackButton = true
    }
    
    // 셀이 1개 이상 선택되면 버튼 활성화
    func buttonIsEnabled() {
        if selectIndexPath.count >= 1 {
            selectedTagButton.isEnabled = true
        } else {
            selectedTagButton.isEnabled = false
        }
    }
    
}

extension OnBoardingTagsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTagsViewCell", for: indexPath) as? OnboardingTagsViewCell else { return UICollectionViewCell() }
        
        let target = Tags[indexPath.item]
        
        if selectIndexPath.contains(indexPath) {
            cell.contentView.backgroundColor = .tagSelected
        } else {
            cell.contentView.backgroundColor = .tagBorder
        }
        
        cell.TagsTitle.text = target.rawValue.capitalized
        cell.tagsImageView.image = target.symbolImage

        return cell
    }
}

extension OnBoardingTagsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectIndexPath.count >= 5 {
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        selectIndexPath.insert(indexPath)
        
        // 셀 선택시 색상변경
        if let cell = collectionView.cellForItem(at: indexPath) as? OnboardingTagsViewCell {
            cell.contentView.backgroundColor = .tagSelected
        }
        
       buttonIsEnabled()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectIndexPath.remove(indexPath)
        
        // 셀 선택해제 시 색상변경
        if let cell = collectionView.cellForItem(at: indexPath) as? OnboardingTagsViewCell {
            cell.contentView.backgroundColor = .tagBorder
        }
        
        buttonIsEnabled()
    }
}
