//
//  ShazamAPIManager.swift
//  MoveMe
//
//  Created by User on 2024-08-29.
//

import Foundation

final class ShazamAPIManager {
    
    private let apiKey = "cbaf1041cfmsh3c99ac9d79df2c5p13d85cjsnbb7c790b1813"
    private let apiHost = "shazam.p.rapidapi.com"
    
    func searchTrack(term: String, completion: @escaping (Result<Response, Error>) -> Void) {
        let urlString = "https://shazam.p.rapidapi.com/search?term=\(term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&locale=en-US&offset=0&limit=5"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let shazamResponse = try decoder.decode(Response.self, from: data)
                completion(.success(shazamResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        dataTask.resume()
    }
}

struct Response: Codable {
    let tracks: Tracks?
    let artists: Artists?
}

struct Tracks: Codable {
    let hits: [TrackHit]?
}

struct TrackHit: Codable {
    let track: TrackAPI?
}

struct TrackAPI: Codable {
    let layout: String?
    let type: String?
    let key: String?
    let title: String?
    let subtitle: String?
    let share: Share?
    let images: Images?
    let hub: Hub?
    let artists: [Artist]?
    let url: String?
}

struct Share: Codable {
    let subject: String?
    let text: String?
    let href: String?
    let image: String?
    let twitter: String?
    let html: String?
    let avatar: String?
    let snapchat: String?
}

struct Images: Codable {
    let background: String?
    let coverart: String?
    let coverarthq: String?
    let joecolor: String?
}

struct Hub: Codable {
    let type: String?
    let image: String?
    let actions: [Action]?
    let options: [Option]?
    let providers: [Provider]?
    let explicit: Bool?
    let displayname: String?
}

struct Action: Codable {
    let name: String?
    let type: String
    let id: String?
    let uri: String?
}

struct Option: Codable {
    let caption: String?
    let actions: [Action]?
    let beacondata: BeaconData?
    let image: String?
    let type: String?
    let listcaption: String?
    let overflowimage: String?
    let colouroverflowimage: Bool?
    let providername: String?
}

struct BeaconData: Codable {
    let type: String?
    let providername: String?
}

struct Provider: Codable {
    let caption: String?
    let images: ProviderImages?
    let actions: [Action]?
    let type: String?
}

struct ProviderImages: Codable {
    let overflow: String?
}

struct Artist: Codable {
    let id: String?
    let adamid: String?
}

struct Artists: Codable {
    let hits: [ArtistHit]?
}

struct ArtistHit: Codable {
    let artist: ArtistDetail?
}

struct ArtistDetail: Codable {
    let avatar: String?
    let name: String?
    let verified: Bool?
    let weburl: String?
    let adamid: String?
}
