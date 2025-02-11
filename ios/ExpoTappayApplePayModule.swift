import ExpoModulesCore
import TPDirect
import PassKit

public class ExpoTappayApplePayModule: Module {
    private let APPLE_PAY_START_EVENT_NAME = "onApplePayStart"
    private let APPLE_PAY_CANCEL_EVENT_NAME = "onApplePayCancel"
    private let APPLE_PAY_SUCCESS_EVENT_NAME = "onApplePaySuccess"
    private let APPLE_PAY_RECEIVE_PRIME_EVENT_NAME = "onReceivePrime"
    private let APPLE_PAY_FAILED_EVENT_NAME = "onApplePayFailed"
    private let APPLE_PAY_FINISH_EVENT_NAME = "onApplePayFinished"
    
    private var applePay: TPDApplePay!
    private let merchant: TPDMerchant = TPDMerchant()
    private let consumer: TPDConsumer = TPDConsumer()
    private var cart: TPDCart = TPDCart()
    private var applePayDelegate: ApplePayDelegate!
    
    public func definition() -> ModuleDefinition {
        Name("ExpoTappayApplePay")
        
        Events(APPLE_PAY_START_EVENT_NAME)
        Events(APPLE_PAY_CANCEL_EVENT_NAME)
        Events(APPLE_PAY_SUCCESS_EVENT_NAME)
        Events(APPLE_PAY_RECEIVE_PRIME_EVENT_NAME)
        Events(APPLE_PAY_FAILED_EVENT_NAME)
        Events(APPLE_PAY_FINISH_EVENT_NAME)
        
        Function("isApplePayAvailable") { () -> Bool in
            return TPDApplePay.canMakePayments()
        }
        
        AsyncFunction("setupMerchant") { (name: String, merchantCapability: String, merchantId: String, countryCode: String, currencyCode: String, promise: Promise) in
            merchant.merchantName = name
            switch merchantCapability {
            case "debit":
                merchant.merchantCapability = .debit
            case "credit":
                merchant.merchantCapability = .credit
            case "emv":
                merchant.merchantCapability = .emv
            default:
                merchant.merchantCapability = .capability3DS
            }
            merchant.applePayMerchantIdentifier = merchantId
            merchant.countryCode = countryCode
            merchant.currencyCode = currencyCode
            merchant.supportedNetworks = [.amex, .masterCard, .visa, .JCB]
            promise.resolve(nil)
        }
        
        AsyncFunction("clearCart") { (promise: Promise) in
            cart = TPDCart()
            promise.resolve(nil)
        }
        
        AsyncFunction("addToCart") { (name: String, amount: Int, promise: Promise) in
            let amountValue = NSDecimalNumber(value: amount)
            cart.add(TPDPaymentItem(itemName: name, withAmount: amountValue))
            promise.resolve(nil)
        }
        
        AsyncFunction("startPayment") { (promise: Promise) in
            self.applePayDelegate = ApplePayDelegate { [weak self] (name, body) in
                self?.sendEvent(name, body)
            }
            
            applePay = TPDApplePay.setupWthMerchant(merchant, with: consumer, with: cart, withDelegate: applePayDelegate)
            applePay.startPayment()
            promise.resolve(nil)
        }
        
        Function("showSetup") {
            TPDApplePay.showSetupView()
        }
        
        Function("showResult") { (isSuccess: Bool) in
            guard let applePay = self.applePay else { return }
            applePay.showPaymentResult(isSuccess)
        }
    }
    
    deinit {
        applePayDelegate = nil
        applePay = nil
    }
}
