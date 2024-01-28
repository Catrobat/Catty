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

public extension URLSession {

    func jsonDataTask(with url: URL, bodyData: [String: Any], headers: [String: String] = [:], completionHandler: @escaping ([String: Any]?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        let body = try? JSONSerialization.data(withJSONObject: bodyData)
        request.httpBody = body

        let task = self.dataTask(with: request, completionHandler: { data, response, error in

            if let data = data, error == nil {
                let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                completionHandler(dictionary, response, error)
            } else {
                completionHandler(nil, response, error)
            }
        })
        return task
    }
}
