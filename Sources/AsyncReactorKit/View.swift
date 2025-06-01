//
//  View.swift
//  AsyncReactorKit
//
//  Created by Delma Song on 5/25/25.
//

import Foundation
@preconcurrency import WeakMapTable

private typealias AnyView = AnyObject

private enum MapTables {
  static let reactor = WeakMapTable<AnyView, Any>()
}

protocol View: AnyObject {
	var reactor: Reactor? { get set }
	
	func bind(reactor: Reactor) async
}

extension View {
  public var reactor: Reactor? {
	get { MapTables.reactor.value(forKey: self) as? Reactor }
	set {
	  MapTables.reactor.setValue(newValue, forKey: self)
	  
	  if let reactor = newValue {
		bind(reactor: reactor)
	  }
	}
  }
}
