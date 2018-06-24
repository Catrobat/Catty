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

@objc extension FormulaEditorViewController {
 
    @objc func initObjectView() {
        var buttonCount = 0
        var topAnchorView = UIView()
        var sensor: Any
        
        for sensor in CBSensorManager.shared.objectSensors() {
            if (sensor.showInFormulaEditor(for: self.object)) {
                topAnchorView = self.addButtonToScrollView(scrollView: self.objectScrollView, sensor: sensor, topAnchorView: topAnchorView)
                buttonCount++;
            }
        }
        
        self.objectScrollView.frame = CGRect(x: self.objectScrollView.frame.origin.x, y: self.objectScrollView.frame.origin.y, width: self.objectScrollView.frame.size.width, height: buttonCount * self.calcButton.frame.size.height)
        self.objectScrollView.contentSize = CGSize(width: self.objectScrollView.frame.size.width, height: buttonCount * self.calcButton.frame.size.height)
    }
    
    @objc func initSensorView() {
        
        var buttonCount = 0
        var topAnchorView = UIView()
        var sensor: Any
        
        for sensor in CBSensorManager.shared.deviceSensors() {
            if (sensor.showInFormulaEditor()) {
                topAnchorView = self.addButtonToScrollView(scrollView: self.sensorScrollView, sensor: sensor, topAnchorView: topAnchorView)
                buttonCount++;
            }
        }
        
        self.sensorScrollView.frame = CGRect(x: self.objectScrollView.frame.origin.x, y: self.objectScrollView.frame.origin.y, width: self.objectScrollView.frame.size.width, height: buttonCount * self.calcButton.frame.size.height)
        self.sensorScrollView.contentSize = CGSize(width: self.objectScrollView.frame.size.width, height: buttonCount * self.calcButton.frame.size.height)
        
    }
    
    @objc func addButtonToScrollView(scrollView: UIScrollView, sensor: Any, topAnchorView: UIView) -> UIButton {
    
        var button: FormulaEditorSensorButton
        //[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        button.sensor = sensor
        button.titleLabel.font = UIFont(size: 18)
        button.translatesAutoresizingMaskIntoConstraints = NO
        button.setTitle(sensor.class.name, forState: .normal)
        
        return button;
    }
}
