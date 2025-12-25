import Foundation

enum CurrencyOption: String, CaseIterable, Identifiable, Codable {
    case kwd = "KWD"
    case sar = "SAR"
    case aed = "AED"
    case qar = "QAR"
    case bhd = "BHD"
    case omr = "OMR"
    case egp = "EGP"
    case jod = "JOD"
    case iqd = "IQD"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .kwd: return "دينار كويتي"
        case .sar: return "ريال سعودي"
        case .aed: return "درهم إماراتي"
        case .qar: return "ريال قطري"
        case .bhd: return "دينار بحريني"
        case .omr: return "ريال عماني"
        case .egp: return "جنيه مصري"
        case .jod: return "دينار أردني"
        case .iqd: return "دينار عراقي"
        }
    }

    var symbol: String { rawValue }
}
