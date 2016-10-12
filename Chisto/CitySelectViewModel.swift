//
//  CitySelectViewModel.swift
//  Chisto
//
//  Created by Алексей on 11.10.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa
import UIKit
import CoreLocation

struct City {
    let index = 0
    var title = ""
    
    init(title: String) {
        self.title = title
    }
}

typealias CitySelectSectionModel = SectionModel<String, City>

protocol CitySelectViewModelType {
    
    // Input
    var locationButtonDidTap: PublishSubject<Void> { get }
    var itemDidSelect: PublishSubject<NSIndexPath> { get }
    var cancelSearchButtonDidTap: PublishSubject<Void> { get }
    
    // Output
    var navigationBarTitle: Driver<String?> { get }
    var sections: Driver<[CitySelectSectionModel]> { get }
    
}

class CitySelectViewModel: CitySelectViewModelType {
    
    var defaultCities = [
        City(title: "Москва"),
        City(title: "Нижний Новгород"),
        City(title: "Санкт-петербург"),
        ]
    
    private let disposeBag = DisposeBag()
    
    // Input
    var locationButtonDidTap = PublishSubject<Void>()
    var cancelSearchButtonDidTap = PublishSubject<Void>()
    var itemDidSelect = PublishSubject<NSIndexPath>()
    var searchString = ReplaySubject<String>.create(bufferSize: 1)
    
    // Output
    var navigationBarTitle: Driver<String?>
    var sections: Driver<[CitySelectSectionModel]>
    
    // Data
    var shownCities: Variable<[City]>
    var location = Variable<CLLocationCoordinate2D>(CLLocationCoordinate2D())
    
    init() {
        self.navigationBarTitle = .just("Города")
        
        for _ in 0...100 {
            defaultCities.append(City(title: "Город"))
        }
        
        let cities = Variable<[City]>(defaultCities)
        self.shownCities = cities
        
        //locationButtonDidTap.
        
        LocationManager.instance.location.asObservable().bindTo(location).addDisposableTo(disposeBag)
        
        self.sections = Observable.combineLatest(cities.asObservable(), searchString.asObservable(), location.asObservable(), resultSelector: { cities, searchString, location -> [CitySelectSectionModel] in
            print(location)
            if searchString.characters.count > 0 {
                let filteredCities = cities.filter {$0.title.lowercased().range(of: searchString.lowercased()) != nil}
                let section = [SectionModel(model: "", items: filteredCities)]
                return section
            } else {
                return  [SectionModel(model: "", items: cities)]
            }
        }).asDriver(onErrorJustReturn: [])
        
        cancelSearchButtonDidTap.asObservable().map { event in
            return ""
        }.bindTo(self.searchString).addDisposableTo(disposeBag)
        
    }
    
    
}
