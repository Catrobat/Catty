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
            
            if (sensor.showInFormulaEditorFor(self.object)) {
                topAnchorView = self.addButtonToScrollView(scrollView: self.objectScrollView, withSensor: sensor, andTopAnchorView: topAnchorView)
                buttonCount++;
            }
        }
        
        self.objectScrollView.frame = CGRectMake(self.objectScrollView.frame.origin.x, self.objectScrollView.frame.origin.y, self.objectScrollView.frame.size.width, buttonCount * self.calcButton.frame.size.height)
        self.objectScrollView.contentSize = CGSizeMake(self.objectScrollView.frame.size.width, buttonCount * self.calcButton.frame.size.height)
    }
    
    @objc func initSensorView() {
        
        var buttonCount = 0
        var topAnchorView = UIView()
        var sensor: Any
        
        for sensor in CBSensorManager.shared.deviceSensors() {
            if (sensor.showInFormulaEditorFor(self.object)) {
                topAnchorView = self.addButtonToScrollView(scrollView: self.sensorScrollView, withSensor: sensor, andTopAnchorView: topAnchorView)
                buttonCount++;
            }
        }
        
        self.sensorScrollView.frame = CGRectMake(self.sensorScrollView.frame.origin.x, self.sensorScrollView.frame.origin.y, self.sensorScrollView.frame.size.width, buttonCount * self.calcButton.frame.size.height)
        self.sensorScrollView.contentSize = CGSizeMake(self.sensorScrollView.frame.size.width, buttonCount * self.calcButton.frame.size.height)
        
    }
    
    @objc func addButtonToScrollView(scrollView: UIScrollView, sensor: Any, topAnchorView: UIView) -> UIButton {
        
        var button: FormulaEditorSensorButton
        
        [button addTarget:self
            action:@selector(buttonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
        
        button.sensor = sensor
        button.titleLabel.font = UIFont(size: 18)
        button.translatesAutoresizingMaskIntoConstraints = NO
        button.setTitle(sensor.class.name, forState: .normal)
        
        scrollView.addSubview(button)
        
        if (topAnchorView == nil) {
            [button.topAnchor constraintEqualToAnchor:scrollView.topAnchor constant: 0].active = YES;
        } else {
            [button.topAnchor constraintEqualToAnchor:topAnchorView.bottomAnchor constant: 0].active = YES;
        }
        
        [button.heightAnchor constraintEqualToAnchor:self.calcButton.heightAnchor constant:0].active = YES;
        [button.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor constant:0].active = YES;
        [button.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor constant:0].active = YES;
        
        self.normalTypeButton.addObject(button)
        return button;
    }
}
