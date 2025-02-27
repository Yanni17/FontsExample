import Foundation
import SwiftUI
import MapKit

struct BasketballCourt: Identifiable, Decodable {
    let id: String
    let name: String?
    let latitude: Double
    let longitude: Double
}


struct OverpassResult: Decodable {
    let elements: [OverpassElement]
}

struct OverpassElement: Decodable {
    let id: Int
    let lat: Double?
    let lon: Double?
    let center: Center?
    let tags: Tags?

    struct Center: Decodable {
        let lat: Double
        let lon: Double
    }

    struct Tags: Decodable {
        let name: String?
    }
}


class CourtViewModel: ObservableObject {
    @Published var courts: [BasketballCourt] = []

    func fetchCourts(for city: String) {
        let query = """
        [out:json];
        area["name"="\(city)"]->.searchArea;
        (
          node["leisure"="pitch"]["sport"="basketball"](area.searchArea);
          way["leisure"="pitch"]["sport"="basketball"](area.searchArea);
          relation["leisure"="pitch"]["sport"="basketball"](area.searchArea);
        );
        out center;
        """
        let urlString = "https://overpass-api.de/api/interpreter?data=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"

        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Fehler beim Abrufen der Daten: \(error?.localizedDescription ?? "Unbekannter Fehler")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(OverpassResult.self, from: data)
                DispatchQueue.main.async {
                    self.courts = result.elements.map { element in
                        BasketballCourt(
                            id: String(element.id),
                            name: element.tags?.name,
                            latitude: element.lat ?? element.center?.lat ?? 0.0,
                            longitude: element.lon ?? element.center?.lon ?? 0.0
                        )
                    }
                }
            } catch {
                print("Fehler beim Dekodieren der Daten: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
struct Testooo: View {
    @StateObject private var viewModel = CourtViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405), // Beispiel: Berlin
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: viewModel.courts) { court in
                MapMarker(
                    coordinate: CLLocationCoordinate2D(latitude: court.latitude, longitude: court.longitude),
                    tint: .orange
                )
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewModel.fetchCourts(for: "Witten") // Beispielstadt
            }
        }
    }
}

#Preview {
    Testooo()
}

