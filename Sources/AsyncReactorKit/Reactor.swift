//
//  Reactor.swift
//  AsyncReactorKit
//
//  Created by Delma Song on 5/25/25.
//

import Foundation
import Combine
@preconcurrency import WeakMapTable

private enum CombineMapTables {
  static let state = WeakMapTable<AnyObject, Any>()
  static let currentState = WeakMapTable<AnyObject, Any>()
  static let actionSubject = WeakMapTable<AnyObject, Any>()
  static let cancellables = WeakMapTable<AnyObject, Set<AnyCancellable>>()
}

public protocol Reactor: AnyObject {
  associatedtype Action
  associatedtype Mutation = Action
  associatedtype State

  var initialState: State { get }

  var state: AnyPublisher<State, Never> { get }
  var currentState: State { get set }

  func mutate(action: Action) -> AnyPublisher<Mutation, Never>
  func reduce(state: State, mutation: Mutation) -> State
}

extension Reactor {
  private var actionSubject: PassthroughSubject<Action, Never> {
	CombineMapTables.actionSubject.forceCastedValue(forKey: self, default: {
	  let subject = PassthroughSubject<Action, Never>()
	  bindStream(actionStream: subject)
	  return subject
	}())
  }

  public func send(_ action: Action) {
	actionSubject.send(action)
  }

  public var state: AnyPublisher<State, Never> {
	CombineMapTables.state.forceCastedValue(forKey: self, default: {
	  let subject = CurrentValueSubject<State, Never>(initialState)
	  CombineMapTables.currentState.setValue(initialState, forKey: self)
	  return subject.eraseToAnyPublisher()
	}())
  }

  public var currentState: State {
	get {
	  CombineMapTables.currentState.forceCastedValue(forKey: self, default: initialState)
	}
	set {
	  CombineMapTables.currentState.setValue(newValue, forKey: self)
	}
  }

  private func bindStream(actionStream: PassthroughSubject<Action, Never>) {
	var cancellables = CombineMapTables.cancellables.value(forKey: self, default: [])

	let mutationStream = actionStream
	  .flatMap { [weak self] action -> AnyPublisher<Mutation, Never> in
		guard let self else { return Empty().eraseToAnyPublisher() }
		return self.mutate(action: action)
	  }

	let statePublisher = mutationStream
	  .scan(initialState) { [weak self] state, mutation in
		guard let self else { return state }
		return self.reduce(state: state, mutation: mutation)
	  }
	  .receive(on: DispatchQueue.main)
	  .handleEvents(receiveOutput: { [weak self] newState in
		self?.currentState = newState
	  })
	  .multicast(subject: CurrentValueSubject(initialState))

	statePublisher
	  .sink { _ in }
	  .store(in: &cancellables)

	statePublisher
	  .connect()
	  .store(in: &cancellables)

	CombineMapTables.state.setValue(statePublisher.eraseToAnyPublisher(), forKey: self)
	CombineMapTables.cancellables.setValue(cancellables, forKey: self)
  }
}

final class CounterReactor: Reactor {
  enum Action {
	case plus
	case minus
  }

  enum Mutation {
	case increase
	case decrease
  }

  struct State {
	var count = 0
  }

  var initialState: State { .init() }

  func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
	switch action {
	case .plus: return Just(.increase).eraseToAnyPublisher()
	case .minus: return Just(.decrease).eraseToAnyPublisher()
	}
  }

  func reduce(state: State, mutation: Mutation) -> State {
	var newState = state
	switch mutation {
	case .increase: newState.count += 1
	case .decrease: newState.count -= 1
	}
	return newState
  }
}
