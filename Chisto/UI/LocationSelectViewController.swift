//
//  LocationSelectViewController.swift
//  Chisto
//
//  Created by Алексей on 10.11.16.
//  Copyright © 2016 Binary Blitz. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import GoogleMaps
import GooglePlaces

class LocationSelectViewController: UIViewController {
  let disposeBag = DisposeBag()
  var viewModel: LocationSelectViewModel? = nil
  var searchController: UISearchController? = nil
  let resultsViewController = GMSAutocompleteResultsViewController()
  let marker = GMSMarker()

  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var saveButton: GoButton!
  @IBOutlet weak var searchView: UIView!
  
  override func viewDidLoad() {
    saveButton.isEnabled = false
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconLocation"), style: .plain, target: nil, action: nil)
    
    configureNavigation()
    configureMap()
    configureSearch()
  }
  
  func configureNavigation() {
    
    guard let viewModel = viewModel else { return }
    
    navigationItem.rightBarButtonItem?.rx.tap.bindTo(viewModel.locationButtonDidTap).addDisposableTo(disposeBag)
    navigationItem.rightBarButtonItem?.rx.tap.asDriver().drive(onNext: { [weak self] in
      self?.mapView.isMyLocationEnabled = true
    }).addDisposableTo(disposeBag)
    
    viewModel.popViewContoller.drive(onNext: { [weak self] in
      _ = self?.navigationController?.popViewController(animated: true)
    }).addDisposableTo(disposeBag)

  }
  
  func configureMap() {
    mapView.delegate = self
    
    guard let viewModel = viewModel else { return }
    
    mapView.camera = GMSCameraPosition.camera(withLatitude: viewModel.cityLocation.latitude, longitude: viewModel.cityLocation.longitude, zoom: viewModel.cityZoom)
    
    marker.icon = #imageLiteral(resourceName: "iconPoint")
    marker.isDraggable = true
    marker.map = mapView
    
    viewModel.markerLocation.asObservable().subscribe(onNext: { [weak self] location in
      self?.saveButton.isEnabled = true
      self?.marker.position = location
      let cameraUpdate = GMSCameraUpdate.setTarget(location, zoom: viewModel.markerZoom)
      self?.mapView.animate(with: cameraUpdate)
    }).addDisposableTo(disposeBag)
    
    saveButton.rx.tap.asObservable()
      .map { self.marker.position }
      .bindTo(viewModel.didPickCoordinate)
      .addDisposableTo(disposeBag)

  }
  
  func configureSearch() {
    resultsViewController.delegate = self
    resultsViewController.tableCellBackgroundColor = UIColor.chsWhiteTwo

    searchController = UISearchController(searchResultsController: resultsViewController)
    searchController?.searchResultsUpdater = resultsViewController
    searchController?.definesPresentationContext = true
    searchController?.extendedLayoutIncludesOpaqueBars = true
    searchController?.hidesNavigationBarDuringPresentation = false
    searchController?.dimsBackgroundDuringPresentation = false
    
    guard let searchBar = searchController?.searchBar else { return }
    
    searchBar.barTintColor = UIColor.chsSkyBlue
    searchBar.tintColor = UIColor.white
    searchBar.backgroundColor = UIColor.chsSkyBlue
    searchBar.backgroundImage = UIImage()
    searchBar.setSearchFieldBackgroundImage(#imageLiteral(resourceName: "searchBarTextBack"), for: .normal)
    searchBar.setImage(#imageLiteral(resourceName: "iconSearch"), for: .search, state: .normal)
    searchBar.setTextColor(color: UIColor.white)
    searchBar.searchTextPositionAdjustment = UIOffsetMake(5.0, 0.0)
    
    searchBar.sizeToFit()
    searchView.addSubview(searchBar)
  }
}

extension LocationSelectViewController: GMSAutocompleteResultsViewControllerDelegate {
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController?.isActive = false
    viewModel?.markerLocation.onNext(place.coordinate)
  }
  
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
    let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    self.present(alertController, animated: true, completion: nil)

  }
 
}

extension LocationSelectViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    viewModel?.markerLocation.onNext(coordinate)
  }
}
