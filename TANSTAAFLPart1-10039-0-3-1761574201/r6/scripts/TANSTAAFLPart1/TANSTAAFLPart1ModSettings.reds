module TANSTAAFLPart1ModSettings

public class VehicleInsuranceUserConfig {
	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Vehicle Insurance")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Paid vehicle summon feature on")
	@runtimeProperty("ModSettings.description", "Turn the feature on/off")
	public let PaidSummonEnabled: Bool = true;

	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Vehicle Insurance")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Vehicle summon price multiplier")
	@runtimeProperty("ModSettings.description", "Reduce/increase vehicle summoning price")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "2.0")
	let VehicleSummonPriceMultiplier: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Vehicle Insurance")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Vehicle repair price feature on")
	@runtimeProperty("ModSettings.description", "Turn the feature on/off")
	public let RepairPriceEnabled: Bool = true;

	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Vehicle Insurance")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Vehicle repair price multiplier")
	@runtimeProperty("ModSettings.description", "Reduce/increase vehicle repair price")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "2.0")
	let RepairPriceMultiplier: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Vehicle Insurance")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Traffic accident fine feature on")
	@runtimeProperty("ModSettings.description", "Turn the feature on/off")
	public let TrafficAccidentFineEnabled: Bool = true;

	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Vehicle Insurance")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Traffic accident price multiplier")
	@runtimeProperty("ModSettings.description", "Reduce/increase traffic accident fine")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "2.0")
	let TrafficAccidentPriceMultiplier: Float = 1.0;

	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Vehicle Insurance")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Insurance price multiplier")
	@runtimeProperty("ModSettings.description", "Reduce/increase insurance price")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "2.0")
	let InsurancePriceMultiplier: Float = 1.0;
}

public class FastTravelUserConfig {
	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Fast Travel")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Fast travel pricing on")
	@runtimeProperty("ModSettings.description", "Turn the feature on/off")
	public let FTModEnabled: Bool = true;

	@runtimeProperty("ModSettings.mod", "TANSTAAFL")
	@runtimeProperty("ModSettings.category", "Fast Travel")
	@runtimeProperty("ModSettings.category.order", "1")
	@runtimeProperty("ModSettings.displayName", "Fast travel price multiplier")
	@runtimeProperty("ModSettings.description", "Reduce/increase fast travel price")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.1")
	@runtimeProperty("ModSettings.max", "2.0")
	let FastTravelGlobalPriceMultiplier: Float = 1.0;
}
