//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import FluentDarkModeKit

final class DarkModeKitTests: XCTestCase {
  func testSetBackgroundColorSwizzling() {
    UIWindow.appearance().backgroundColor = .white
    DarkModeManager.setup(with: UIApplication.shared)
    _ = UIWindow()
  }

  func testColorInitializer() {
    let color = UIColor(.dm, light: .white, dark: .black)

    perform(with: .light) {
       XCTAssertEqual(color.rgba, UIColor.white.rgba)
    }

    perform(with: .dark) {
       XCTAssertEqual(color.rgba, UIColor.black.rgba)
    }
  }

  func testImageInitializer() {
    let lightImage = UIImage()
    let darkImage = UIImage()
    _ = UIImage(.dm, light: lightImage, dark: darkImage)
  }

  func testDynamicColor() {
    let color = UIColor(.dm) {
      $0.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
    }

    perform(with: .light) {
      XCTAssertEqual(color.rgba, UIColor.white.rgba)
    }

    perform(with: .dark) {
      XCTAssertEqual(color.rgba, UIColor.black.rgba)
    }

    // Test color fetched from specific trait collections
    XCTAssertEqual(color.resolvedColor(.dm, with: DMTraitCollection(userInterfaceStyle: .dark)).rgba, UIColor.black.rgba)
    XCTAssertEqual(color.resolvedColor(.dm, with: DMTraitCollection(userInterfaceStyle: .light)).rgba, UIColor.white.rgba)
  }

  func testColorPropertySetters() {
    let color = UIColor(.dm, light: .white, dark: .black)

    let view = UIView()
    view.backgroundColor = color
    view.tintColor = color
    if #available(iOS 13.0, *) {
      XCTAssertTrue(view.backgroundColor === color)
    }
    else {
      XCTAssertFalse(view.backgroundColor === color)
    }
    XCTAssertTrue(view.tintColor === color)

    // UIView subclasses
    do {
      let activityIndictorView  = UIActivityIndicatorView()
      activityIndictorView.color = color
      XCTAssertTrue(activityIndictorView.color === color)

      // UIControl subclasses
      do {
        let button = UIButton()
        button.setTitleColor(color, for: .normal)
        button.setTitleShadowColor(color, for: .normal)
        XCTAssertTrue(button.titleColor(for: .normal) === color)
        XCTAssertTrue(button.titleShadowColor(for: .normal) === color)

        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = color
        pageControl.currentPageIndicatorTintColor = color
        XCTAssertTrue(pageControl.pageIndicatorTintColor === color)
        XCTAssertTrue(pageControl.currentPageIndicatorTintColor === color)

        if #available(iOS 13, *) {
          let segmentedControl = UISegmentedControl()
          segmentedControl.selectedSegmentTintColor = color
          XCTAssertTrue(segmentedControl.selectedSegmentTintColor === color)
        }

        let slider = UISlider()
        slider.minimumTrackTintColor = color
        slider.maximumTrackTintColor = color
        slider.thumbTintColor = color
        XCTAssertTrue(slider.minimumTrackTintColor === color)
        XCTAssertTrue(slider.maximumTrackTintColor === color)
        XCTAssertTrue(slider.thumbTintColor === color)

        let `switch` = UISwitch()
        `switch`.onTintColor = color
        `switch`.thumbTintColor = color
        XCTAssertTrue(`switch`.onTintColor === color)
        XCTAssertTrue(`switch`.thumbTintColor === color)

        let textField = UITextField()
        textField.textColor = color
        XCTAssertTrue(textField.textColor === color)

        if #available(iOS 13, *) {
          let searchTextField = UISearchTextField()
          searchTextField.tokenBackgroundColor = color
          XCTAssertTrue(searchTextField.tokenBackgroundColor === color)
        }
      }

      let label = UILabel()
      label.textColor = color
      label.shadowColor = color
      label.highlightedTextColor = color
      XCTAssertTrue(label.textColor === color)
      if #available(iOS 13.0, *) {
        XCTAssertTrue(label.shadowColor === color)
      }
      else {
        XCTAssertFalse(label.shadowColor === color)
      }
      XCTAssertTrue(label.highlightedTextColor === color)

      let navigationBar = UINavigationBar()
      navigationBar.barTintColor = color
      XCTAssertTrue(navigationBar.barTintColor === color)

      let progressView = UIProgressView()
      progressView.progressTintColor = color
      progressView.trackTintColor = color
      XCTAssertTrue(progressView.progressTintColor === color)
      XCTAssertTrue(progressView.trackTintColor === color)

      // UIScrollView subclasses
      do {
        let tableView = UITableView()
        tableView.sectionIndexColor = color
        tableView.sectionIndexBackgroundColor = color
        tableView.sectionIndexTrackingBackgroundColor = color
        tableView.separatorColor = color
        XCTAssertTrue(tableView.sectionIndexColor === color)
        XCTAssertTrue(tableView.sectionIndexBackgroundColor === color)
        XCTAssertTrue(tableView.sectionIndexTrackingBackgroundColor === color)
        XCTAssertTrue(tableView.separatorColor === color)

        let textView = UITextView()
        textView.textColor = color
        XCTAssertTrue(textView.textColor === color)
      }

      let searchBar = UISearchBar()
      searchBar.barTintColor = color
      XCTAssertFalse(searchBar.barTintColor === color)

      let tabBar = UITabBar()
      tabBar.barTintColor = color
      tabBar.unselectedItemTintColor = color
      XCTAssertTrue(tabBar.barTintColor === color)
      XCTAssertTrue(tabBar.unselectedItemTintColor === color)

      let toolbar = UIToolbar()
      toolbar.barTintColor = color
      XCTAssertTrue(toolbar.barTintColor === color)
    }
  }

  func perform(with userInterfaceStyle: DMUserInterfaceStyle, expression: () -> Void) {
    if #available(iOS 13.0, *) {
      // On iOS 13, we use the system wide one, while in unit tests there is
      // no actual views, use UITraitCollection.performAsCurrent to simulate
      // theme change
      DMTraitCollection(userInterfaceStyle: userInterfaceStyle).uiTraitCollection.performAsCurrent {
        expression()
      }
    }
    else {
      let saved = DMTraitCollection.current
      DMTraitCollection.setOverride(DMTraitCollection(userInterfaceStyle: userInterfaceStyle), animated: false)
      expression()
      DMTraitCollection.setOverride(saved, animated: false)
    }
  }
}

extension UIColor {
  struct RGBA: Equatable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
  }

  var rgba: RGBA {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    getRed(&red, green: &green, blue: &blue, alpha: &alpha)

    return RGBA(red: red, green: green, blue: blue, alpha: alpha)
  }
}
