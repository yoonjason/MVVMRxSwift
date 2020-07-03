//
//  ViewController.swift
//  MVVMRxSwift
//
//  Created by yoon on 2020/07/03.
//  Copyright © 2020 yeongseok. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct User:Codable {
    let name : String
}

enum LoginError : Error {
    case defaultError
    case error(code : Int)
    
    var msg : String {
        switch self {
        case .defaultError:
            return "ERROR"
        case .error(let code) :
            return "\(code) Error"
        }
    }
}
struct LoginModel {
    //
    func requestLogin(id : String, pw : String) -> Observable<Result<User, LoginError>> {
        return Observable.create{ (observer) -> Disposable in
            if id != "" && pw != "" {
                observer.onNext(.success(User(name: id)))
            }else {
                observer.onNext(.failure(.defaultError))
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
}

struct LoginViewModel {
    let idTfChanged = PublishRelay<String>()
    let pwTfChanged = PublishRelay<String>()
    let loginBtnTouched = PublishRelay<Void>()
    
    let result : Signal<Result<User, LoginError>>
    
    init(model : LoginModel = LoginModel()) {
        result = loginBtnTouched
            .withLatestFrom(Observable.combineLatest(idTfChanged, pwTfChanged))
            .flatMapLatest{model.requestLogin(id: $0.0, pw: $0.1)}
            .asSignal(onErrorJustReturn: .failure(.defaultError))
        
    }
    
}
class ViewController: UIViewController {
    
    @IBOutlet weak var idTf: UITextField!
    @IBOutlet weak var pwTf: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindViewModel()
    }
    
    func bindViewModel(){
        self.idTf.rx.text.orEmpty
            .bind(to: viewModel.idTfChanged)
            .disposed(by: disposeBag)
        
        self.pwTf.rx.text.orEmpty
            .bind(to: viewModel.pwTfChanged)
            .disposed(by: disposeBag)
        
        self.loginBtn.rx.tap
            .bind(to: viewModel.loginBtnTouched)
            .disposed(by: disposeBag)
        
        viewModel.result.emit(onNext : { (result) in
            switch result {
            case .success(let user) :
                print(user)
                self.moveToMain()
            case .failure(let error) :
                print(error)
                self.showError()
            }
        }).disposed(by: disposeBag)
    }
    
    func moveToMain(){
        print("MOVE")
    }
    
    func showError() {
        print("ERROR")
    }
}

