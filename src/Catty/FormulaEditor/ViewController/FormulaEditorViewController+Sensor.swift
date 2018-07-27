/**
 *  Copyright (C) 2010-2018 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

extension FormulaEditorViewController {

    @objc func initObjectView(objectScrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        var topAnchorView: UIView?
        var buttons = [UIButton]()
        
        for sensor in CBSensorManager.shared.objectSensors(for: self.object) {
            topAnchorView = self.addButtonToScrollView(scrollView: objectScrollView, sensor: sensor, topAnchorView: topAnchorView, buttonHeight: buttonHeight)
            buttons.append(topAnchorView as! UIButton)
        }
        
        objectScrollView.frame = CGRect(x: objectScrollView.frame.origin.x, y: objectScrollView.frame.origin.y, width: objectScrollView.frame.size.width, height: CGFloat(buttons.count) * buttonHeight)
        objectScrollView.contentSize = CGSize(width: objectScrollView.frame.size.width, height: CGFloat(buttons.count) * buttonHeight)
        
        return buttons
    }
    
    @objc func initSensorView(sensorScrollView: UIScrollView, buttonHeight: CGFloat) -> [UIButton] {
        var topAnchorView: UIView?
        var buttons = [UIButton]()
        
        for sensor in CBSensorManager.shared.deviceSensors(for: self.object) {
            topAnchorView = self.addButtonToScrollView(scrollView: sensorScrollView, sensor: sensor, topAnchorView: topAnchorView, buttonHeight: buttonHeight)
            buttons.append(topAnchorView as! UIButton)
        }
        
        sensorScrollView.frame = CGRect(x: sensorScrollView.frame.origin.x, y: sensorScrollView.frame.origin.y, width: sensorScrollView.frame.size.width, height: CGFloat(buttons.count) * buttonHeight)
        sensorScrollView.contentSize = CGSize(width: sensorScrollView.frame.size.width, height: CGFloat(buttons.count) * buttonHeight)
        
        return buttons
        
    }
    
    private func addButtonToScrollView(scrollView: UIScrollView, sensor: CBSensor, topAnchorView: UIView?, buttonHeight: CGFloat) -> UIButton {
        let button = FormulaEditorSensorButton(sensor: sensor)
        
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        
        scrollView.addSubview(button)
        if (topAnchorView == nil) {
            button.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        } else {
            button.topAnchor.constraint(equalTo: (topAnchorView?.bottomAnchor)!, constant: 0).isActive = true
        }
        
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        
        return button;
    }
    
    @objc func buttonPressed(sender: UIButton) {
        if (sender is FormulaEditorSensorButton) {
            let button = sender as! FormulaEditorSensorButton
            self.handleInput(withSensor: button.sensor)
        } 
    }
    
    private func handleInput(withSensor sensor:CBSensor) {
        self.internFormula.handleKeyInput(withSensor: sensor)
        self.handleInput()
    }
}
