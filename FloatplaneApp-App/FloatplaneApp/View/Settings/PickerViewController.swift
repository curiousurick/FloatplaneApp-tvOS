//  Copyright © 2023 George Urick
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import FloatplaneApp_Models

protocol PickerDelegate {
    func picker(didSelect row: Int)
}

class PickerViewController: UIViewController, PickerDelegate {
    
    private let optionsContainerSegueId = "OptionsContainer"
    
    var delegate: PickerDelegate?
    var options: [Readable] = []
    var label: String? {
        didSet {
            if let titleLabel = self.titleLabel {
                titleLabel.text = label
            }
        }
    }
    var selectedIndex: Int = 0
    
    @IBOutlet var titleLabel: UILabel!
    private var internalPicker: InternalPickerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = label
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == optionsContainerSegueId {
            internalPicker = segue.destination as? InternalPickerViewController
            internalPicker.options = options
            internalPicker.delegate = self
            internalPicker.selectedIndex = selectedIndex
        }
    }
    
    // From internal picker to actual consumer
    func picker(didSelect row: Int) {
        delegate?.picker(didSelect: row)
        dismiss(animated: true)
    }
}

class InternalPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let optionCellIdentifier = "OptionCell"
    
    var delegate: PickerDelegate?
    
    @IBOutlet var tableView: UITableView!

    var options: [Readable] = []
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.remembersLastFocusedIndexPath = true
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return options.isEmpty ? 0 : 1
    }
    
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        return IndexPath(row: selectedIndex, section: 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath)
        cell.textLabel?.text = options[indexPath.row].readable
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.picker(didSelect: indexPath.row)
    }
}
