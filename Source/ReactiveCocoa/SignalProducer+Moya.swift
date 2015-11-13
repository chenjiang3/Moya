import Foundation
import ReactiveCocoa

/// Extension for processing raw NSData generated by network access.
extension SignalProducerType where Value == MoyaResponse, Error == MoyaError {

    /// Filters out responses that don't fall within the given range, generating errors when others are encountered.
    public func filterStatusCodes(range: ClosedInterval<Int>) -> SignalProducer<Value, Error> {
        return producer.flatMap(.Latest) { response -> SignalProducer<Value, Error> in
            do {
                return SignalProducer(value: try response.filterStatusCodes(range))
            } catch let error as MoyaError {
                return SignalProducer(error: error)
            } catch {
                return SignalProducer(error: .StatusCode(response))
            }
        }
    }
    
    public func filterStatusCode(code: Int) -> SignalProducer<Value, Error> {
        return filterStatusCodes(code...code)
    }
    
    public func filterSuccessfulStatusCodes() -> SignalProducer<Value, Error> {
        return filterStatusCodes(200...299)
    }
    
    public func filterSuccessfulStatusAndRedirectCodes() -> SignalProducer<Value, Error> {
        return filterStatusCodes(200...399)
    }
    
    /// Maps data received from the signal into an Image. If the conversion fails, the signal errors.
    public func mapImage() -> SignalProducer<Image, Error> {
        return producer.flatMap(.Latest) { response -> SignalProducer<Image, Error> in
            do {
                return SignalProducer(value: try response.mapImage())
            } catch {
                return SignalProducer(error: .ImageMapping(response))
            }
        }
    }
    
    /// Maps data received from the signal into a JSON object. If the conversion fails, the signal errors.
    public func mapJSON() -> SignalProducer<AnyObject, Error> {
        return producer.flatMap(.Latest) { response -> SignalProducer<AnyObject, Error> in
            do {
                return SignalProducer(value: try response.mapJSON())
            } catch {
                return SignalProducer(error: .JSONMapping(response))
            }
        }
    }
    
    /// Maps data received from the signal into a String. If the conversion fails, the signal errors.
    public func mapString() -> SignalProducer<String, Error> {
        return producer.flatMap(.Latest) { response -> SignalProducer<String, Error> in
            do {
                return SignalProducer(value: try response.mapString())
            } catch {
                return SignalProducer(error: .StringMapping(response))
            }
        }
    }
}