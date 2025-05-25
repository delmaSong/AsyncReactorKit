//
//  Reactor.swift
//  AsyncReactorKit
//
//  Created by Delma Song on 5/25/25.
//

import Foundation
import UIKit

@MainActor
protocol AsyncReactor {
	associatedtype Action
	associatedtype Mutation = Action
	associatedtype State

	var initialState: State { get }
	var currentState: State { get }
	
//	var action

	func send(_ action: Action) async
}


class SampleReactor: AsyncReactor {
	var initialState: State
	
	var currentState: State
	
	
	
	enum Action {
		case plus
		case minus
	}
	
	struct State {
		
	}
	
	init(initialState: State, currentState: State) {
		self.initialState = initialState
		self.currentState = currentState
	}
	
	func send(_ action: Action) async {
		
	}
}

class SampleViewController: UIViewController, View {

	func bind(reactor: SampleReactor) async {
		await reactor.send(.plus)
	}
	
	typealias Reactor = SampleReactor
	
	
}
