//
//  CategoryViewModel.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 11/3/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import RxSwift

class CategoryViewModel: GridCollectionViewModel {
    var cartItemsCount = PublishSubject<Int>()
    
    var categoryId: String!
    var selectedSortingValue = SortingValue.createdAt
    
    private let cartProductListUseCase = CartProductListUseCase()
    private let categoryUseCase = CategoryUseCase()
    
    public func getCartItemsCount() {
        cartProductListUseCase.getCartProductList { [weak self] (products) in
            self?.cartItemsCount.onNext(products.count)
        }
    }
    
    public func reloadData() {
        paginationValue = nil
        loadRemoteData()
    }
    
    public func loadNextPage() {
        paginationValue = products.value.last?.paginationValue
        loadRemoteData()
    }
    
    private func loadRemoteData() {
        let showHud = products.value.count == 0
        state.onNext(.loading(showHud: showHud))
        let reverse = selectedSortingValue == .createdAt
        categoryUseCase.getCategory(with: categoryId, paginationValue: paginationValue, sortingValue: selectedSortingValue, reverse: reverse) { [weak self] (result, error) in
            if let error = error {
                self?.state.onNext(.error(error: error))
            }
            if let category = result {
                self?.updateData(category: category)
                self?.state.onNext(.content)
            }
            self?.canLoadMore = result?.products?.count ?? 0 == kItemsPerPage
        }
    }
    
    // MARK: - private
    private func updateData(category: Category) {
        if let items = category.products {
            updateProducts(products: items)
            canLoadMore = products.value.count == kItemsPerPage
        }
    }
}