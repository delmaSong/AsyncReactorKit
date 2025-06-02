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
	associatedtype R: Reactor
	var reactor: R? { get set }
	
	func bind(reactor: R)
}

extension View {
  public var reactor: R?{
	get { MapTables.reactor.value(forKey: self) as? R }
	set {
	  MapTables.reactor.setValue(newValue, forKey: self)
	  
	  if let reactor = newValue {
		bind(reactor: reactor)
	  }
	}
  }
}
