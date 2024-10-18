/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

extension SavePlotSVGBrick: CBInstructionProtocol {

    func instruction() -> CBInstruction {
        .action { context in SKAction.run(self.actionBlock(context: context)) }
    }

    func actionBlock(context: CBScriptContextProtocol) -> () -> Void {
        guard let object = self.script?.object,
            let spriteNode = object.spriteNode
            else { fatalError("This should never happen!") }

        return {
            var filename = context.formulaInterpreter.interpretString(self.filename!, for: object)
            if let number = Double(filename) {
                filename = number.displayString
            }

            var paths = ""
            //swiftlint:disable:next unused_enumerated
            for (_, previousCutPositionLine) in spriteNode.penConfiguration.previousCutPositionLines.enumerated() {
                paths += self.getLinePath(with: previousCutPositionLine) + "\n"
            }
            paths += self.getLinePath(with: spriteNode.penConfiguration.previousCutPositions)

            self.saveSVGPlot(with: paths, to: filename, width: Int(object.scene.width() ?? "0") ?? 0, height: Int(object.scene.height() ?? "0") ?? 0)
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func saveSVGPlot(with paths: String, to filename: String, width: Int, height: Int) {
        var filecontent = "<?xml version=\"1.0\" standalone=\"no\"?>\n<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n"
        filecontent += "<svg width=\"" + String(width) + "\" height=\"" + String(height) + "\" viewBox=\"0 0 " + String(width) + " " + String(height) + "\""
        filecontent += " style=\"background-color:#ffffff\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">\n"
        filecontent += "<title>Plotter export</title>\n"
        filecontent += paths
        filecontent += "\n</svg>"

        var filename = filename
        if !filename.hasSuffix(".svg") {
            filename += ".svg"
        }
        let file = self.getDocumentsDirectory().appendingPathComponent(filename)
        try? filecontent.write(to: file, atomically: true, encoding: String.Encoding.utf8)
    }

    private func getLinePath(with positions: SynchronizedArray<CGPoint>) -> String {
        var path = ""
        let positionCount = positions.count
        if positionCount > 1 {
            path = "<path fill=\"none\" style=\"stroke:rgb(0,0,0);stroke-width:1;stroke-linecap:round;stroke-opacity:1;\" d=\"M"
            let startpoint = String(format: "%.2f", positions[0]?.x ?? 0) + " " + String(format: "%.2f", positions[0]?.y ?? 0)

            path += startpoint
            for (index, point) in positions.enumerated() where index > 0 {
                guard positions[index - 1] != nil else {
                    fatalError("This should never happen")
                }
                path = path + " L" + String(format: "%.2f", point.x) + " " + String(format: "%.2f", point.y)
            }
            path += "\" />"
        }
        return path
    }
}
