module TANSTAAFLPart1Localizable

public class VehicleInsurancePhoneTexts {
	public static func ContactName() -> String = s"Vehicle Insurance"
	//bot messages
	public static func GreetingLine() -> String = s"Vehicle Insurance automated requests system is at your service."
	public static func ActiveSubStatusReport() -> String = s"Your subscription is currently active and at {DURATION}%. Your debt with the system is \u{20ac}$ {DEBT}. This request cost is \u{20ac}$ {COST}. Have a pleasant day!"
	public static func ExpiredSubStatusReport() -> String = s"Your subscription is expired. Your debt with the system is \u{20ac}$ {DEBT}. This request cost is \u{20ac}$ {COST}. Have a pleasant day!"
	public static func NoSubStatusReport() -> String = s"There are no prior records of your subscriptions (for more information visit or web portal NETdir://vehicle.insurance). Your debt with the system is \u{20ac}$ {DEBT}. This request cost is \u{20ac}$ {COST}. Have a pleasant day!"
	public static func SubRenewPaymentData() -> String = s"Your subscription renewal cost is \u{20ac}$ {TOTALCOST}: \u{20ac}$ {SUBCOST} subscription cost plus \u{20ac}$ {COST} service cost. Do you wish to proceed?"
	public static func SubRenewPaymentDataWithDebt() -> String = s"Your subscription renewal cost is \u{20ac}$ {TOTALCOST}: \u{20ac}$ {SUBCOST} subscription cost plus \u{20ac}$ {DEBT} debt plus \u{20ac}$ {COST} service cost. Do you wish to proceed?"
	public static func DebtPaymentData() -> String = s"Your debt payment is \u{20ac}$ {TOTALCOST}: \u{20ac}$ {DEBT} debt plus \u{20ac}$ {COST} service cost. Do you wish to proceed?"
	public static func FailureNoMoney() -> String = s"You do not have enough funds to cover the operation cost. Request canceled."
	public static func SubRenewSuccess() -> String = s"Your subscription was successfully renewed. Drive safe!"
	public static func DebtPaymentSuccess() -> String = s"You no longer have a debt with the system. Drive safe!"
	public static func SafeDrivingGift() -> String = s"You were an example of safe driving today! We want to offer you this little gift as a reward: \u{20ac}$ {GIFT}."
	//player answers
	public static func SubStatusRequest() -> String = s"I want to know my subscription status."
	public static func SubRenewRequest() -> String = s"I want to renew my subscription."
	public static func PayDebtRequest() -> String = s"I want to pay my debt."
	public static func SubRenewYes() -> String = s"Yes, I want to renew my subscription."
	public static func PayDebtYes() -> String = s"Yes, I want to pay my debt."
	public static func GenericCancel() -> String = s"No, cancel the request."
	//notifications
	public static func SubExpiredNotification() -> String = s"Your subscription has expired."
	public static func SafeDrivingGiftNotification() -> String = s"A present for a long safe drive!"
}

public class TANSTAAFLMSGTexts {
	public static func FastTravelPaidMessage() -> String = s"Public transportation service payment: \u{20ac}$ "
	public static func VehicleBumpPaidMessage() -> String = s"Traffic accident payment: \u{20ac}$ "
	public static func VehicleBumpNoMoneyMessage() -> String = s"Traffic accident payment: not enough money"
	public static func VehDispatchedPaidMessage() -> String = s"Client vehicle dispatched: \u{20ac}$ "
	public static func VehDispatchedFreeMessage() -> String = s"Client vehicle dispatched for free"
	public static func VehUnableToDispatchMessage() -> String = s"Sorry, unable to dispatch client vehicle"
	public static func VehInsuranceIncludedRepairsMessage() -> String = s"Vehicle repaired (price included into the final service cost)"
	public static func VehInsuranceDebtPaidMessage() -> String = s"Vehicle insurance debt paid successfully: \u{20ac}$ "
	public static func VehInsuranceDebtAcquiredMessage() -> String = s"Vehicle insurance debt acquired: \u{20ac}$ "
	public static func VehInsuranceDebtMessage() -> String = s"Your debt with vehicle insurance system is \u{20ac}$ "
	public static func VehInsurancePayYorDebtMessage() -> String = s"Pay your debt to restore access to the services"
}

public class VehicleInsuranceWebTexts {
	public static func LOGO() -> String = s"VEHICLE INSURANCE"
	public static func Level() -> String = s"Level"
	public static func Discount() -> String = s"Discount"
	public static func Price() -> String = s"Price"
	//public static func MoneyPool() -> String = s"Pool left"
	public static func SubDurationLeft() -> String = s"Duration left"
	public static func Debt() -> String = s"Debt"
	public static func NoMoney() -> String = s"You don't have enough money"
	public static func ConfirmTransaction() -> String = s"Confirm transaction"
	public static func DebtInfo() -> String = s"Your debt with vehicle insurance system is "
	public static func PayDebt() -> String = s"Pay your debt"
	public static func ManageSubscription() -> String = s"Manage your subscription"
	public static func SubscriptionStatus() -> String = s"Subscription status"
	public static func SubscriptionLevel() -> String = s"Subscription level"
	public static func Back() -> String = s"Back"
	public static func About() -> String = s"Tell me more..."
	public static func AboutText() -> String = s"Tired of paying arm and leg for road services in Night City? Traffic accident bills put you into a debt hole? Worry no more, our Vehicle Insurance program got you covered! Subscribe to one of our plans to receive a discount for each and every vehicle related expenses: traffic accidents, vehicle delivery, vehicle repairs."
}
