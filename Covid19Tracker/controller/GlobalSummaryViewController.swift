//
//  TotalStatisticsViewController.swift
//  Covid19Tracker
//
//  Created by Andy on 23.05.2020.
//  Copyright © 2020 AndyRadionov. All rights reserved.
//

import UIKit
import SMDiagramViewSwift

class GlobalSummaryViewController: UIViewController {

    var globalSummary: GlobalSummary!
    @IBOutlet weak var dayLabelView: UILabel!
    @IBOutlet weak var totalDiagramView: SMDiagramView!
    @IBOutlet weak var dayDiagramView: SMDiagramView!
    private var maxTotalValue: Int!
    private var maxDayValue: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDayLabel()
        initMaxValues()
        initDiagram(totalDiagramView)
        initDiagram(dayDiagramView)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func initMaxValues() {
        maxTotalValue = Int(globalSummary.totalConfirmed + globalSummary.totalDeaths + globalSummary.totalRecovered)
        maxDayValue = Int(globalSummary.newConfirmed + globalSummary.newDeaths + globalSummary.newRecovered)
    }
    
    private func initDiagram(_ diagram: SMDiagramView) {
        diagram.dataSource = self
        diagram.diagramViewMode = .segment
        diagram.radiusOfSegments = 120.0
        diagram.radiusOfViews = 80.0
        diagram.reloadData()
    }
    
    private func initDayLabel() {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy"
        dayLabelView.text = "Summary for: \(dateFormatterGet.string(from: globalSummary.date!))"
    }
    
    private func getProportion(_ diagramView: SMDiagramView, _ index: Int) -> Float {
        if (diagramView == totalDiagramView) {
            switch index {
            case 0: return Float(globalSummary.totalConfirmed) / Float(maxTotalValue)
            case 1: return Float(globalSummary.totalDeaths) / Float(maxTotalValue)
            case 2: return Float(globalSummary.totalRecovered) / Float(maxTotalValue)
            default: return 0.0
            }
        } else {
            switch index {
            case 0: return Float(globalSummary.newConfirmed) / Float(maxDayValue)
            case 1: return Float(globalSummary.newDeaths) / Float(maxDayValue)
            case 2: return Float(globalSummary.newRecovered) / Float(maxDayValue)
            default: return 0.0
            }
        }
    }
    
    private func getLabelText(_ diagramView: SMDiagramView, _ index: Int) -> String {
        if (diagramView == totalDiagramView) {
            switch index {
            case 0: return String(globalSummary.totalConfirmed)
            case 1: return String(globalSummary.totalDeaths)
            case 2: return String(globalSummary.totalRecovered)
            default: return ""
            }
        } else {
            switch index {
            case 0: return String(globalSummary.newConfirmed)
            case 1: return String(globalSummary.newDeaths)
            case 2: return String(globalSummary.newRecovered)
            default: return ""
            }
        }
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.textAlignment = .center
        label.textColor = .black
        label.clipsToBounds = true
        return label
    }
}

extension GlobalSummaryViewController: SMDiagramViewDataSource {
    func numberOfSegmentsIn(diagramView: SMDiagramView) -> Int {
        return 3
    }
    
    func diagramView(_ diagramView: SMDiagramView, proportionForSegmentAtIndex index: NSInteger) -> CGFloat {
        return CGFloat(getProportion(diagramView, index))
    }
    
    func diagramView(_ diagramView: SMDiagramView, colorForSegmentAtIndex index: NSInteger, angle: CGFloat) -> UIColor? {
        switch index {
        case 1: return .red
        case 2: return .green
        default: return .orange
        }
    }
    
    func diagramView(_ diagramView: SMDiagramView, viewForSegmentAtIndex index: NSInteger, colorOfSegment color:UIColor?, angle: CGFloat) -> UIView? {
        let label = createLabel()
        label.text = getLabelText(diagramView, index)
        return label
    }
}
