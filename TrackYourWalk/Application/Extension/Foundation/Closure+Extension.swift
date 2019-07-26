//
//  Closure+Extension.swift
//  TrackYourWalk
//
//  Created by Konstantyn on 7/19/19.
//  Copyright © 2019 Kostiantyn Bykhkalo. All rights reserved.
//

import Foundation

// MARK: - State without Cahnges
enum SuccessCompletionState {
  case success
  case error(Error)
}

// MARK: - State Generic Cahnge
enum SuccessCompletionChangeState<T> {
  case success(T)
  case error(Error)
}

typealias CompletionChangeHandler<ChangeValue> = (ChangeValue) -> Void
typealias CompletionHandler = () -> Void
typealias CompletionActionHandler = (Bool) -> Void
typealias CompletionErrorHandler = (Error?) -> Void
typealias CompletionSuccessHandler = (Bool, Error?) -> Void
typealias CompletionResponseHandler<Value> = (Value?, Error?) -> Void
typealias CompletionWithSuccessState = CompletionChangeHandler<SuccessCompletionState>
typealias CompletionChangeStateHandler<VariableType>
  = CompletionChangeHandler<SuccessCompletionChangeState<VariableType>>
