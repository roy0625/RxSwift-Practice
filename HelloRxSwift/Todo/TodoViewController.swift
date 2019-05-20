//
//  ViewController.swift
//  HelloRxSwift
//
//  Created by roy on 2019/5/13.
//  Copyright © 2019 roy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

class TodoViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: TodoViewModel
    private let sections = BehaviorRelay<[SectionModel<String, TodoModel>]>(value: [])

    private let tableView = UITableView()
    private let deleteButton = UIButton(type: .custom)
    private var rightButton: UIBarButtonItem?

    init(viewModel: TodoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "To Do List"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        addRightButton()
        setupViews()
        bindViewModel()
        bindTableView()

        let observable = Observable<Any>.never()

        observable
            .debug()
            .subscribe { print("Hi") }
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.inputs.refreshTrigger.onNext(())
    }

    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(deleteButton)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        deleteButton.backgroundColor = .gray
        deleteButton.setTitle("Delete All", for: .normal)
        deleteButton.layer.cornerRadius = 25
        deleteButton.layer.masksToBounds = true


        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        deleteButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-100)
            make.right.equalToSuperview().offset(-30)
            make.size.equalTo(CGSize(width: 110, height: 50))
        }
    }

    private func addRightButton() {
        rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        navigationItem.rightBarButtonItem = rightButton
    }

    private func bindViewModel() {
        let inputs = viewModel.inputs
        let outputs = viewModel.outputs

        // output
        outputs.todoItems
            .map { todoListModel -> [SectionModel<String, TodoModel>] in
                return [SectionModel<String, TodoModel>(model: "", items: todoListModel.todo), SectionModel<String, TodoModel>(model: "", items: todoListModel.done)]
            }
            .bind(to: sections)
            .disposed(by: disposeBag)


        // input
        rightButton?.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showTodoAlert()
            })
            .disposed(by: disposeBag)

        deleteButton.rx.tap
            .subscribe({ _ in
                inputs.deleteAllItemTrigger.onNext(())
            })
            .disposed(by: disposeBag)
    }

    private func bindTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TodoModel>>(configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
                fatalError("Get UITableViewCell fail")
            }
            cell.textLabel?.text = element.name
            return cell
        })

        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func showTodoAlert() {
        let alert = UIAlertController(title: "Enter", message: "What do you want to do?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            if let name = alert.textFields?.first?.text {
                self.viewModel.inputs.addItemTrigger.onNext(name)
            }
            print("click OK")
        })
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("click cancel")
        }
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            textField.placeholder = "to do"
        }

        present(alert, animated: true, completion: {
            print("alert complete")
        })
    }
}

