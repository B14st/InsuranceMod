module TANSTAAFLPart1Configs

public class FastTravelPaymentConfig {
	//cost per meter traveled
	public static func CostPerMeter() -> Float = 0.5;
}

public class VehicleInsuranceSystemConfig {
	//summon price in percents (0...100) from vehicle base cost
	public static func SummonPricePrc() -> Float = 1.0
	//absolute min summon price
	public static func SummonMinPrice() -> Int32 = 100
	//repair price in percents (0...100) from vehicle base cost (for 100% damaged vehicle, adjusted by damage percentage)
	public static func RepairPricePrc() -> Float = 80.0
	//absolute min repair price for 100% damaged vehicle
	public static func RepairMinPrice() -> Int32 = 500
	//bump price in percents (0...100) from vehicle base cost (adjusted by hit velocity)
	public static func BumpPricePrc() -> Float = 0.1
	//absolute min bump price
	public static func BumpMinPrice() -> Int32 = 1
	//cooldown for charging for bump event - don't set it to a low value, otherwise you can have multiple hits registered for one accident due to game's physics!
	public static func BumpEventPaymentCooldown() -> Float = 5.0
	//max subscription level
	public static func MaxSubscriptionLevel() -> Int32 = 3
	//discount all services in percents (0...100)
	public static func SubscriptionPrc(level: Int32) -> Float {
		switch level {
			case 0:
				return 0.0;
			case 1:
				return 30.0;
			case 2:
				return 50.0;
			case 3:
				return 75.0;
			default:
				return 0.0;
		};
		return 0.0;
	}
	//subscription duration adjustment: the bigger it is, the "longer" the subscription will last,
	//i.e. the more money you're allowed to spend before it expires
	public static func SubscriptionDurationMultiplier() -> Float = 1.0
	//subscription price
	public static func SubscriptionCost(level: Int32) -> Int32 {
		switch level {
			case 0:
				return 0;
			case 1:
				return 12500;
			case 2:
				return 33000;
			case 3:
				return 68000;
			default:
				return 0;
		};
		return 0;
	}
	
	//periodic gift for safe driving
	public static func SafeDriveGiftDistance() -> Float = 10000.0 //meters
	public static func SafeDriveGiftMoney() -> Int32 = 1000

	//debt reminder
	public let UseDebtReminder: Bool = true;
}

public class TANSTAAFLMSGConfig {
	//message duration per line of text on screen
	public static func MessageDuration() -> Float = 3.0
}

public class VehicleInsurancePhoneConfig {
	//basic cost of operation
	public static func BaseOperationCost() -> Int32 = 50;
	//additional fee for phone operation services
	public static func ServicePercentage() -> Float = 5.0;
}
