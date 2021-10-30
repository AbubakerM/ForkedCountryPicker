//
//  CountryPickerControllerWithSectionTests.swift
//  CountryPickerTests
//
//  Created by tokopedia on 08/01/21.
//  Copyright © 2021 SuryaKant Sharma. All rights reserved.
//

import Foundation
import XCTest
@testable import CountryPicker

class CountryPickerControllerWithSectionTests: XCTestCase {
        
    func test_presentController_shouldAbleToPresent() {
        let vc = UIViewController()
        let sut = makeSUT(presentingVC: vc)
        XCTAssertEqual(sut.presentingVC, vc)
    }
    
    
    func test_presentController_shouldAbleToSetCallback() {
       
        var logCallbackCounter = 0
        var selectedCountry: Country?
        
        let callback:(Country) -> Void = { country in
            logCallbackCounter += 1
            selectedCountry = country
        }
        let sut = makeSUT(callback: callback)
        let country = Country(countryCode: "IN")
        sut.callBack?(country)
        
        
        XCTAssertEqual(selectedCountry, country)
        XCTAssertEqual(logCallbackCounter, 1)
    }
    
    func test_table_numberOfSection_equalToUniqueCountries() {
        let sut = makeSUT()
        sut.applySearch = false
        
        sut.countries = [Country(countryCode: "IN"), Country(countryCode: "US"), Country(countryCode: "IDN")]
        sut.fetchSectionCountries()
        
        
        XCTAssertEqual(sut.sections, ["I", "U"])
        XCTAssertEqual(sut.sectionCoutries["I"]?.contains(Country(countryCode: "IN")), true)
        XCTAssertEqual(sut.sectionCoutries["I"]?.contains(Country(countryCode: "IDN")), true)
        XCTAssertEqual(sut.sectionCoutries["U"]?.contains(Country(countryCode: "US")), true)
        
        sut.favoriteCountriesLocaleIdentifiers = ["IN"]
        sut.fetchSectionCountries()
    }
    
    func test_scrollToCountryShould_scrollTableViewToContryIndexPath() {
        let sut = makeSUT()
        sut.applySearch = false
        sut.loadCountries()
        let country = Country(countryCode: "IN")
        let row = sut.sectionCoutries["I"]?.firstIndex(where: { $0.countryCode == country.countryCode}) ?? 0
        let section =  sut.sectionCoutries.keys.map { $0 }.sorted().firstIndex(of: "I") ?? 0
        
        sut.scrollToCountry(Country(countryCode: "IN"), withSection: country.countryName.first!, animated: false)
        
        
        XCTAssertTrue(sut.tableView.indexPathsForVisibleRows?.contains(IndexPath(row: row, section: section)) ?? false )
        
    }
    
    func test_scrollToCountryShould_whenApplySearchShouldNotScroll() {
        let sut = makeSUT()
        sut.applySearch = true
        sut.loadCountries()
        let country = Country(countryCode: "IN")
        let row = sut.sectionCoutries["I"]?.firstIndex(where: { $0.countryCode == country.countryCode}) ?? 0
        let section =  sut.sectionCoutries.keys.map { $0 }.sorted().firstIndex(of: "I") ?? 0
        
        sut.scrollToCountry(Country(countryCode: "IN"), withSection: country.countryName.first!, animated: false)
        
        
        XCTAssertFalse(sut.tableView.indexPathsForVisibleRows?.contains(IndexPath(row: row, section: section)) ?? false )
        
    }
    
    func test_numberOfSection_withOutApplySearch_withOutFavorite() {
        let sut = makeSUT()
        sut.applySearch = false
        let sectionCount = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
        
        XCTAssertEqual(sectionCount, sut.sections.count)
    }
    
    func test_numberOfSection_withApplySearch_shouldAlwaysRetrunOneSection() {
        let sut = makeSUT()
        sut.applySearch = true
        
        let sectionCount = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
        sut.applySearch = true
        XCTAssertEqual(sectionCount, 1)
        sut.favoriteCountriesLocaleIdentifiers = ["IN"]
        XCTAssertEqual(sectionCount, 1)
    }
    
    func test_numberOfRowsInSection_withAppliedSeach_shouldShowOnlyFilterCountryCount() {
        let sut = makeSUT()
        sut.applySearch = true
       
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), sut.filterCountries.count)
        
        sut.favoriteCountriesLocaleIdentifiers = ["IN"]
        XCTAssertEqual(sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0), sut.filterCountries.count)
    }
    
    func test_numberOfRowsInSection_withoutAppliedSeach_shouldShowCountryOnSection() {
        let sut = makeSUT()
        sut.applySearch = false
        
        let section = 0
        let rowsCount = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: section)
        XCTAssertEqual(rowsCount, sut.firstSectionCount)
    }
    
    func test_numberOfRowsInSection_withoutAppliedSeach_withFavourites() {
        let sut = makeSUT()
        sut.applySearch = false
        let favouriteIdetifiers = ["IN", "US"]
        sut.favoriteCountriesLocaleIdentifiers = favouriteIdetifiers
        
        
        XCTAssertEqual(sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0), favouriteIdetifiers.count)
        
        XCTAssertEqual(sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 1), sut.firstSectionCount)
    }
    
    func test_titleForHeaderInSectionInRow_withAppliedSearch_shouldReturnSearchTitle() {
        let sut = makeSUT()
        let tableView = sut.tableView
        sut.applySearch = true
    
        XCTAssertEqual(tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: 0), "A")
    }
    
    func test_titleForHeaderInSectionInRow_withoutAppliedSearch_shouldReturnSearchTitle() {
        let sut = makeSUT()
        let tableView = sut.tableView
        sut.applySearch = false
        
        XCTAssertEqual(tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: 0), "A")
        
        sut.favoriteCountriesLocaleIdentifiers = ["IN"]
        XCTAssertNil(tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: 0))
    }
    
    func test_cellConfiguration_ofTableView_withoutAppliedSearch() {
        let sut = makeSUT()
        let tableView = sut.tableView
        sut.applySearch = false
        
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? CountryCell
        XCTAssertEqual(cell?.country, Country(countryCode: "AF"))
    }
    
    func test_cellConfiguration_ofTableView_withAppliedSearch() {
        let sut = makeSUT()
        let tableView = sut.tableView
        
        sut.filterCountries = [Country(countryCode: "IN")]
        sut.applySearch = true
        
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? CountryCell
        XCTAssertEqual(cell?.country, Country(countryCode: "IN"))
    }
    
    func test_cellConfiguration_ofTableView_withoutAppliedSearchWithFavourite() {
        let sut = makeSUT()
        let tableView = sut.tableView
        
        sut.favoriteCountriesLocaleIdentifiers = ["IN", "US"]
        sut.applySearch = false
        CountryManager.shared.lastCountrySelected = Country(countryCode: "IN")
        
        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? CountryCell
        XCTAssertEqual(cell?.country, Country(countryCode: "IN"))
        XCTAssertEqual(cell?.checkMarkImageView.isHidden, false)
        
        let cell2 = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? CountryCell
        XCTAssertEqual(cell2?.country, Country(countryCode: "US"))
        
        let cell3 = tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as? CountryCell
        XCTAssertEqual(cell3?.country, Country(countryCode: "AF"))
    }
    
    
    func test_sectionForIndexTitles() {
        let sut = makeSUT()
        let tableView = sut.tableView
        let sectionTitle = tableView.dataSource?.sectionIndexTitles?(for: tableView) ?? []
        XCTAssertEqual(sectionTitle, sut.sections.map {String($0)})
    }
    
    func test_titleForSectionIndex() {
        let sut = makeSUT()
        let tableView = sut.tableView
        let character = "A"
        let index = tableView.dataSource?.tableView?(tableView, sectionForSectionIndexTitle: character, at: 0)
        XCTAssertEqual(index, sut.sections.firstIndex(of: Character(character))!)
    }
    
    func test_searchEmptyShouldAble_toReloadTableView_withRelatedCountries() {
        let totalCountries = [Country(countryCode: "AF"),
                              Country(countryCode: "IN"),
                              Country(countryCode: "US")]
        

        let sut = makeSUT()
        sut.engine = CountryPickerEngine(countries: totalCountries, filterOptions: [.countryCode])

        sut.applySearch = true
        sut.searchController.searchBar.simulateSearch(text: "IN")
        
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(sut.searchHeaderTitle, "I")
    }
    
    func test_tableView_didSelectShould_triggerCallbackWithRightCountry_withUserSearch() {
        var logCallbackCounter = 0
        var selectedCountry: Country?
        let india = Country(countryCode: "IN")
        let callback:(Country) -> Void = { country in
            logCallbackCounter += 1
            selectedCountry = country
        }
        let sut = makeSUT(callback: callback)
        
        sut.searchController.searchBar.simulateSearch(text: "IN")
        sut.tableView.select(row: 0)
        
        XCTAssertEqual(CountryManager.shared.lastCountrySelected, india)
        XCTAssertEqual(selectedCountry, india)
        XCTAssertEqual(logCallbackCounter, 1)
    
    }
    
    func test_tableView_didSelectShould_triggerCallbackWithRightCountry_withoutUserSearch_withFavourite() {
        var logCallbackCounter = 0
        var selectedCountry: Country?
        let india = Country(countryCode: "IN")
        let unitedStates = Country(countryCode: "US")
        let afganistan = Country(countryCode: "AF")
        
        let callback:(Country) -> Void = { country in
            logCallbackCounter += 1
            selectedCountry = country
        }
        CountryManager.shared.lastCountrySelected = nil
        
        let sut = makeSUT(callback: callback)
        sut.favoriteCountriesLocaleIdentifiers = ["IN", "US"]
        sut.tableView.select(row: 0)
        
        XCTAssertEqual(selectedCountry, india)
        XCTAssertEqual(logCallbackCounter, 1)
        XCTAssertEqual(CountryManager.shared.lastCountrySelected, india)
        
        sut.tableView.select(row: 1)
        
        XCTAssertEqual(selectedCountry, unitedStates)
        XCTAssertEqual(logCallbackCounter, 2)
        XCTAssertEqual(CountryManager.shared.lastCountrySelected, unitedStates)
        
        sut.tableView.select(row: 0, section: 1)
        
        XCTAssertEqual(selectedCountry, afganistan)
        XCTAssertEqual(logCallbackCounter, 3)
        XCTAssertEqual(CountryManager.shared.lastCountrySelected, afganistan)
    }
    
    func test_tableView_didSelectShould_triggerCallbackWithRightCountry_withoutUserSearch_withoutFavouriteSet() {
        var logCallbackCounter = 0
        var selectedCountry: Country?
        let afganistan = Country(countryCode: "AF")
        let callback:(Country) -> Void = { country in
            logCallbackCounter += 1
            selectedCountry = country
        }
        CountryManager.shared.lastCountrySelected = nil
        
        let sut = makeSUT(callback: callback)
        sut.tableView.select(row: 0)
        
        XCTAssertEqual(selectedCountry, afganistan)
        XCTAssertEqual(logCallbackCounter, 1)
        XCTAssertEqual(CountryManager.shared.lastCountrySelected, afganistan)
    }
    
    func test_scrollToPreviousShould_scrollToPreviousCountryInTableView() {
        let sut = makeSUT()
        let india = Country(countryCode: "IN")
        sut.loadCountries()
        CountryManager.shared.lastCountrySelected = india
        sut.scrollToPreviousCountryIfNeeded()
        let isIndiaCellVisible = sut.tableView.visibleCells.filter { cell in
            guard let cell = cell as? CountryCell else { return false }
            return cell.country == india
        }.compactMap{$0}.first
        XCTAssertNotNil(isIndiaCellVisible)
    }
    
    func test_scrollToPreviousShould_scrollToPreviousCountryInTableView_whenFavouriteEnable() {
        let sut = makeSUT()
        let india = Country(countryCode: "IN")
        sut.loadCountries()
        sut.favoriteCountriesLocaleIdentifiers = ["US", "IN"]
        CountryManager.shared.lastCountrySelected = india
        sut.scrollToPreviousCountryIfNeeded()
        let isIndiaCellCount = sut.tableView.visibleCells.filter { cell in
            guard let cell = cell as? CountryCell else { return false }
            return cell.country == india
        }.compactMap{$0}.count
        XCTAssertEqual(isIndiaCellCount, 1)
    }
    
    //MARK: - Helpers
    func makeSUT(presentingVC: UIViewController = UIViewController(), callback:((Country) -> Void)? = nil) -> CountryPickerWithSectionViewController {
        let sut = CountryPickerWithSectionViewController.presentController(on: presentingVC) { country in
            callback?(country)
        }
        sut.startLifeCycle()
        return sut
    }
}

private extension CountryPickerWithSectionViewController {
    var firstSectionCount: Int {
        sectionCoutries["A"]!.count
    }
}
