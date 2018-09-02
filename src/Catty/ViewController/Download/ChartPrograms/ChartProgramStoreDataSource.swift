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

protocol ChartProgramStoreDataSourceDelegate: class {
    func chartProgramsStoreTableDataSource(_ dataSource: ChartProgramStoreDataSource, didSelectCellWith item: StoreProgram)
}

protocol SelectedChartProgramsDataSource: class {
    func selectedCell(dataSource: ChartProgramStoreDataSource, didSelectCellWith cell: ChartProgramCell)
    func scrollViewHandler()
    func errorAlertHandler(error: StoreProgramDownloaderError)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class ChartProgramStoreDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    weak var delegate: SelectedChartProgramsDataSource?
    
    let downloader: StoreProgramDownloaderProtocol
    var baseUrl = ""
    var programType: ProgramType
    
    var mostDownloadedPrograms = [StoreProgram]()
    var mostViewedPrograms = [StoreProgram]()
    var mostRecentPrograms = [StoreProgram]()
    
    var mostDownloadedOffset = 0
    var mostViewedOffset = 0
    var mostRecentOffset = 0
    
    var mostDownloadedScrollViewOffset = CGPoint(x: 0.0, y: 0.0)
    var mostViewedScrollViewOffset = CGPoint(x: 0.0, y: 0.0)
    var mostRecentScrollViewOffset = CGPoint(x: 0.0, y: 0.0)
    
    var scrollView = UIScrollView()
    
    var programs: [StoreProgram] {
        switch programType {
        case .mostDownloaded:
            return mostDownloadedPrograms
        case .mostViewed:
            return mostViewedPrograms
        case .mostRecent:
            return mostRecentPrograms
        default:
            return [StoreProgram]()
        }
    }
    
    var programOffset: Int {
        switch programType {
        case .mostDownloaded:
            return mostDownloadedOffset
        case .mostViewed:
            return mostViewedOffset
        case .mostRecent:
            return mostRecentOffset
        default:
            return 0
        }
    }
    
    var scrollViewOffset: CGPoint {
        switch programType {
        case .mostDownloaded:
            return mostDownloadedScrollViewOffset
        case .mostViewed:
            return mostViewedScrollViewOffset
        case .mostRecent:
            return mostRecentScrollViewOffset
        default:
            return CGPoint(x: 0,y: 0)
        }
    }
    
    // MARK: - Initializer
    
    fileprivate init(with downloader: StoreProgramDownloaderProtocol) {
        self.downloader = downloader
        self.programType = .mostDownloaded
    }
    
    static func dataSource(with downloader: StoreProgramDownloaderProtocol = StoreProgramDownloader()) -> ChartProgramStoreDataSource {
        return ChartProgramStoreDataSource(with: downloader)
    }
    
    // MARK: - DataSource
    
    func fetchItems(type: ProgramType, completion: @escaping (StoreProgramDownloaderError?) -> Void) {
        
        programType = type
        scrollView.setContentOffset(scrollViewOffset, animated: false)
        
        if (self.programOffset == programs.count) || (programs.count == 0) {
            self.downloader.fetchPrograms(forType: type, offset: self.programOffset) {items, error in
                
                guard let collection = items, error == nil else { completion(error); return }
                
                switch self.programType {
                case .mostDownloaded:
                    self.mostDownloadedPrograms.append(contentsOf: collection.projects)
                    self.mostDownloadedOffset += kRecentProgramsMaxResults
                case .mostViewed:
                    self.mostViewedPrograms.append(contentsOf: collection.projects)
                    self.mostViewedOffset += kRecentProgramsMaxResults
                case .mostRecent:
                    self.mostRecentPrograms.append(contentsOf: collection.projects)
                    self.mostRecentOffset += kRecentProgramsMaxResults
                default:
                    return
                }
                self.baseUrl = collection.information.baseUrl
                completion(nil)
                
            }
        }
        else {
            completion(nil)
        }
    }
    
    func numberOfRows(in tableView: UITableView) -> Int {
        return self.programs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.programs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableUtil.heightForImageCell()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kImageCell, for: indexPath)
        if let cell = cell as? ChartProgramCell {
            cell.tag = indexPath.row
            if programs.isEmpty == false {
                cell.chartImage = nil
                if indexPath.row < self.programs.count {
                    DispatchQueue.global().async {
                        guard let screenshotSmall = self.programs[indexPath.row].screenshotSmall else { return }
                        guard let imageUrl = URL(string: self.baseUrl.appending(screenshotSmall)) else { return }
                        guard let data = try? Data(contentsOf: imageUrl) else { return }
                        DispatchQueue.main.async {
                            // this check is supposed to prevent setting an asynchronously downloaded
                            // image into a cell that has already been reused since then
                            guard cell.tag == indexPath.row else { return }
                            cell.chartImage = UIImage(data: data)
                        }
                    }
                    cell.chartTitle = programs[indexPath.row].projectName
                    cell.program = programs[indexPath.row]
                }
            }
        }
        return cell
    }
    
    // MARK: - Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? ChartProgramCell else { return }
        guard let cellProgram = cell.program else { return }
        let timer = TimerWithBlock(timeInterval: TimeInterval(kConnectionTimeout), repeats: false) { timer in
            self.delegate?.errorAlertHandler(error: .timeout)
            timer.invalidate()
            self.delegate?.hideLoadingIndicator()
        }
        self.delegate?.showLoadingIndicator()
        
        self.downloader.downloadProgram(for: cellProgram) { program, error in
            guard timer.isValid else { return }
            guard let StoreProgram = program, error == nil else { return }
            cell.program = StoreProgram
            self.delegate?.selectedCell(dataSource: self, didSelectCellWith: cell)
            timer.invalidate()
            self.delegate?.hideLoadingIndicator()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.scrollView = scrollView
        
        switch programType {
        case .mostDownloaded:
            mostDownloadedScrollViewOffset = scrollView.contentOffset
        case .mostViewed:
            mostViewedScrollViewOffset = scrollView.contentOffset
        case .mostRecent:
            mostRecentScrollViewOffset = scrollView.contentOffset
        default:
            return
        }
        let checkPoint = Float(scrollView.contentSize.height - TableUtil.heightForImageCell())
        let currentViewBottomEdge = Float(scrollView.contentOffset.y + scrollView.frame.size.height)
        
        if currentViewBottomEdge >= checkPoint {
            self.fetchItems(type: self.programType) { error in
                if error != nil {
                    self.delegate?.errorAlertHandler(error: error!)
                }
            }
            self.delegate?.scrollViewHandler()
        }
    }
}

