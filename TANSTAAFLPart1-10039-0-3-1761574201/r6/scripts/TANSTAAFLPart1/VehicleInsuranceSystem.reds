module VehicleInsuranceMod
import TANSTAAFLPart1Messages.*
import TANSTAAFLPart1Configs.VehicleInsuranceSystemConfig
import TANSTAAFLPart1ModSettings.VehicleInsuranceUserConfig
import PhoneExtension.System.*
import VehicleInsurancePhone.VehicleInsuranceContactHash
import TANSTAAFLPart1Localizable.*

public struct VehicleHealthTriplet {
	public persistent let id: Uint64;
	public persistent let healthPrc: Float;
	public persistent let idx: Int32;
}

public struct InsuranceSystemPaymentResult {
	public let moneyPaid: Int32 = 0;
	public let debtPaid: Int32 = 0;
	public let debtAcquired: Int32 = 0;
	public let debtTotal: Int32 = 0;
}

public struct InsuranceSystemSubscriptionState {
	public persistent let moneyPool: Int32 = 0;
	public persistent let level: Int32 = 0; //0 - expired, 1 - basic, 2 - ...
	public persistent let lastKnownLevel: Int32 = 0;
}

public class VehicleInsuranceSystem extends ScriptableSystem {
	private persistent let m_lastSpawnedPlayerVehicleID: TweakDBID;
	private persistent let m_vehicleInsuranceDebt: Int32;
	private persistent let m_lastBumpEvtTime: Float;
	private persistent let m_vehHealthMap: array<VehicleHealthTriplet>; //ink maps are not persistable, hence patchwork scriptaround
	private persistent let m_subState: InsuranceSystemSubscriptionState;
	
	private let m_player: wref<PlayerPuppet>;
	private let m_vehicleSummonDataBB: wref<IBlackboard>;
	//private let m_psmBB: wref<IBlackboard>;
	private let m_vehicleDefBB: wref<IBlackboard>;
	private let m_activeVehIdx: Int32;
	private let m_vehicleSummonStateCallback: ref<CallbackHandle>;
	//private let m_playerDriverMountedCallback: ref<CallbackHandle>;
	private let m_vehicleSpeedCallbackID: ref<CallbackHandle>;
	private let m_config: ref<VehicleInsuranceUserConfig>;
	
	public static func GetInstance(obj: ref<GameObject>) -> ref<VehicleInsuranceSystem> {
		let gi: GameInstance = obj.GetGame();
		let system: ref<VehicleInsuranceSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"VehicleInsuranceMod.VehicleInsuranceSystem") as VehicleInsuranceSystem;
		return system;
	}
	
	public func GetLastSpawnedPlayerVehicleID() -> TweakDBID {
		return this.m_lastSpawnedPlayerVehicleID;
	}
	
	public func SetLastSpawnedPlayerVehicleID(id: TweakDBID) {
		this.m_lastSpawnedPlayerVehicleID = id;
	}
	
	public func Init(player: ref<PlayerPuppet>) {
		this.m_player = player;

		FTLog("VehicleInsuranceSystem.Init");
		
		this.m_vehicleSummonDataBB = GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().VehicleSummonData);
		this.m_vehicleSummonStateCallback = this.m_vehicleSummonDataBB.RegisterListenerUint(GetAllBlackboardDefs().VehicleSummonData.SummonState, this, n"OnVehicleSummonStateChanged");
		
		//psm is not yet spawned OnGameAttached (?)
		//this.m_psmBB = this.m_player.GetPlayerStateMachineBlackboard();
		//if !IsDefined(this.m_psmBB) {
		//	FTLog("PSM not found!");
		//};
		//this.m_playerDriverMountedCallback = this.m_psmBB.RegisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicleInDriverSeat, this, n"OnMountedInDriverSeatChanged");
		
		//fill in last know subscription level retroactively
		if this.m_subState.lastKnownLevel == 0 && this.m_subState.level != 0 {
			this.m_subState.lastKnownLevel = this.m_subState.level;
		};
		
		//this.m_vehicleInsuranceDebt += 111; //for testing
		//this.RenewSubscription(1); //for testing
		//this.m_subState.level = 0; //for testing
		//this.m_subState.lastKnownLevel = 1; //for testing
		//this.m_subState.moneyPool = 0; //for testing
	}
	
	public func Uninit() {
		FTLog("VehicleInsuranceSystem.Uninit");
		
		this.m_vehicleSummonDataBB.UnregisterListenerUint(GetAllBlackboardDefs().VehicleSummonData.SummonState, this.m_vehicleSummonStateCallback);
		//this.m_psmBB.UnregisterListenerBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicleInDriverSeat, this.m_playerDriverMountedCallback);
	}

	public func GetConfig() -> ref<VehicleInsuranceUserConfig> {
		if this.m_config == null {
			this.m_config = new VehicleInsuranceUserConfig();
			ModSettings.RegisterListenerToClass(this.m_config);
		};
		return this.m_config;
	}
	
	//player mounted as driver watcher
	
	private let m_distanceTravelled: Float;
	private let m_lastSpeedVal: Float;
	private let m_lastTimeVal: Float;
	//private let m_bumpsCount: Int32;
	private let m_presentMessagePending: Bool;
	
	//protected cb func OnMountedInDriverSeatChanged(value: Bool) -> Bool {
	public func OnMountedInDriverSeatChanged(value: Bool, veh: ref<VehicleObject>) -> Bool {
		//FTLog("PlayerMountedAsDriver: " + ToString(value));
		if value {
			//this.m_distanceTravelled = 0.0; //resets in on bump event
			//this.m_bumpsCount = 0;
			this.m_vehicleDefBB = veh.GetBlackboard();
			this.m_vehicleSpeedCallbackID = this.m_vehicleDefBB.RegisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this, n"OnVehicleSpeedChange");
		} else {
			//FTLog("distanceTravelled: " + ToString(this.m_distanceTravelled));
			//FTLog("bumpsCount: " + ToString(this.m_bumpsCount));
			this.m_vehicleDefBB.UnregisterListenerFloat(GetAllBlackboardDefs().Vehicle.SpeedValue, this.m_vehicleSpeedCallbackID);
			//push safe driving gift message
			if this.m_distanceTravelled > VehicleInsuranceSystemConfig.SafeDriveGiftDistance() {
				let syst = PhoneExtensionSystem.GetInstance(this.m_player);
				syst.NotifyNewMessageCustom(VehicleInsuranceContactHash(), VehicleInsurancePhoneTexts.ContactName(), VehicleInsurancePhoneTexts.SafeDrivingGiftNotification());
				this.m_presentMessagePending = true;
				this.m_distanceTravelled = 0.0;
			};
		};
	}
	
	//calc distance travelled based on vehicle speed
	protected final func OnVehicleSpeedChange(speed: Float) -> Void {
		let timeDelta = EngineTime.ToFloat(GameInstance.GetEngineTime(this.m_player.GetGame())) - this.m_lastTimeVal;
		this.m_distanceTravelled += this.m_lastSpeedVal * timeDelta;
		this.m_lastTimeVal = EngineTime.ToFloat(GameInstance.GetEngineTime(this.m_player.GetGame()));
		this.m_lastSpeedVal = AbsF(speed);
	}
	
	//handle mapping of vehicles to their min health values to track repair forced by native code on summon
	//needs to be persistent but ink maps are not, hence, all the dancing around
	public func UpdateVehHealthMap(id: Uint64, healthPrc: Float) {
		let item: VehicleHealthTriplet;
		
		if (this.m_vehHealthMap)[this.m_activeVehIdx].id == id {
			(this.m_vehHealthMap)[this.m_activeVehIdx].healthPrc = healthPrc;
			return;
		};
		
		for item in this.m_vehHealthMap {
			if item.id == id {
				this.m_activeVehIdx = item.idx;
				(this.m_vehHealthMap)[this.m_activeVehIdx].healthPrc = healthPrc;
				return;
			};
		};
		
		item.id = id;
		item.healthPrc = healthPrc;
		item.idx = ArraySize(this.m_vehHealthMap);
		ArrayPush(this.m_vehHealthMap, item);
		this.m_activeVehIdx = item.idx;
		(this.m_vehHealthMap)[this.m_activeVehIdx].healthPrc = healthPrc;
	}
	
	public func GetVehHealthPrc(id: Uint64) -> Float {
		let item: VehicleHealthTriplet;
		
		if (this.m_vehHealthMap)[this.m_activeVehIdx].id == id {
			return (this.m_vehHealthMap)[this.m_activeVehIdx].healthPrc;
		};

		for item in this.m_vehHealthMap {
			if item.id == id {
				this.m_activeVehIdx = item.idx;
				return (this.m_vehHealthMap)[this.m_activeVehIdx].healthPrc;
			};
		};
		
		//if we don't have a record, assume 100% not to charge ppl accidentally
		return 100.0;
	}
	
	//handle vehicle summoning process: repair and summon payment
	//currently also auto-payment of debt if possible
	protected cb func OnVehicleSummonStateChanged(value: Uint32) -> Bool {
		let vehicle: ref<VehicleObject>;
		let vehicleRecord: ref<Vehicle_Record>;
		let vehicleDBID: TweakDBID;
		let summonStateEnum: vehicleSummonState;
		let vehName: String;
		//let distance: Int32 = 0;
		let vehPrice: Int32 = 0;
		let vehSummonPrice: Int32 = 0;
		let transactionResult: InsuranceSystemPaymentResult;
		let vehHealthCur: Float;
		let vehHealthSaved: Float;
		let vehRepairPrice: Int32 = 0;
		let vehRepairPaid: Bool = false;
		let config = this.GetConfig();
		
		summonStateEnum = IntEnum<vehicleSummonState>(value);
		
		//FTLog("Summon State: " + ToString(summonStateEnum));
		
		vehicle = GameInstance.FindEntityByID(this.m_player.GetGame(), this.m_vehicleSummonDataBB.GetEntityID(GetAllBlackboardDefs().VehicleSummonData.SummonedVehicleEntityID)) as VehicleObject;
		
		if !IsDefined(vehicle) {
			return false;
		};
		
		vehicleDBID = vehicle.GetRecordID();
		vehicleRecord = TweakDBInterface.GetVehicleRecord(vehicleDBID);
		vehName = GetLocalizedTextByKey(vehicleRecord.DisplayName());
		
		vehPrice = this.GetVehiclePrice(vehicleDBID);
		//FTLog("price: " + ToString(vehPrice));
		if config.PaidSummonEnabled {
			vehSummonPrice = this.CalcSummonPayment(vehPrice);
		};
		
		vehHealthSaved = this.GetVehHealthPrc(TDBID.ToNumber(vehicleDBID));
		//seems to return health in prc not absolute value
		vehHealthCur = GameInstance.GetStatPoolsSystem(vehicle.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(vehicle.GetEntityID()), gamedataStatPoolType.Health);
		
		if vehHealthSaved < vehHealthCur {
			if config.RepairPriceEnabled {
				vehRepairPrice = this.CalcRepairPayment(vehPrice, vehHealthCur - vehHealthSaved);
				vehSummonPrice += vehRepairPrice;
				//FTLog("Damage prc: " + ToString(vehHealthCur - vehHealthSaved));
				//FTLog("Repair price: " + ToString(vehRepairPrice));
				vehRepairPaid = (vehRepairPrice > 0);
			};
		};
		
		//if IsDefined(this.m_player) && IsDefined(vehicle) {
		//	distance = RoundF(Vector4.Distance(this.m_player.GetWorldPosition(), vehicle.GetWorldPosition()));
		//	FTLog("Distance: " + ToString(distance));
		//};
		
		switch value {
			case vehicleSummonState.Idle:
				//FTLog("Idle: " + vehName);
				break;
			case vehicleSummonState.EnRoute:
				//FTLog("EnRoute: " + vehName);
				this.SetLastSpawnedPlayerVehicleID(vehicleDBID);
				this.UpdateVehHealthMap(TDBID.ToNumber(vehicleDBID), vehHealthCur);
				transactionResult = this.HandleVehicleInsuranceSystemTransaction(vehSummonPrice);
				TANSTAAFLMSG.ShowVehicleSummonedMessage(this.m_player.GetGame(), transactionResult.moneyPaid, transactionResult.debtPaid, transactionResult.debtAcquired, vehRepairPaid);
				return true;
				//break;
			case vehicleSummonState.AlreadySummoned:
				//FTLog("AlreadySummoned: " + vehName);
				break;
			case vehicleSummonState.PathfindingFailed:
				//FTLog("PathfindingFailed: " + vehName);
				break;
			case vehicleSummonState.Arrived:
				//FTLog("Arrived: " + vehName);
				break;
			default:
				break;
		};
		
		return false;
	}
	
	//handle traffic accidents
	public func HandleVehicleBumpEvent(veh: ref<VehicleObject>, evt: ref<VehicleBumpEvent>) {
		let transactionResult: InsuranceSystemPaymentResult;
		let vehBumpPayment: Int32;
		let timePassed: Float;
		let config = this.GetConfig();
		
		if !config.TrafficAccidentFineEnabled {
			this.m_distanceTravelled = 0.0;
			return;
		};
		
		//FTLog("VehicleInsuranceSystem.HandleVehicleBumpEvent: " + GetLocalizedTextByKey(TweakDBInterface.GetVehicleRecord(veh.GetRecordID()).DisplayName()));
		
		timePassed = EngineTime.ToFloat(GameInstance.GetEngineTime(this.m_player.GetGame())) - this.m_lastBumpEvtTime;
		
		if timePassed > VehicleInsuranceSystemConfig.BumpEventPaymentCooldown() {
			vehBumpPayment = this.CalcVehicleBumpPayment(veh, evt);
			if vehBumpPayment > 0 {
				//this.m_bumpsCount += 1;
				this.m_distanceTravelled = 0.0;
				transactionResult = this.HandleVehicleInsuranceSystemTransaction(vehBumpPayment);
				TANSTAAFLMSG.ShowVehicleBumpMessage(this.m_player.GetGame(), transactionResult.moneyPaid, transactionResult.debtAcquired);
				this.m_lastBumpEvtTime = EngineTime.ToFloat(GameInstance.GetEngineTime(this.m_player.GetGame()));
			};
		};
	}
	
	//handle price calculations for different events
	private func GetVehiclePrice(tdbID: TweakDBID) -> Int32 {
		//relying on debug function here, but it's not the way
		//let stringID: String;
		//let left: String;
		//let right: String;
		//
		//stringID = TDBID.ToStringDEBUG(tdbID);
		////FTLog("DBID: " + stringID);
		//if StrSplitLast(stringID, ".", left, right) {
		//	//FTLog("DBID.last: " + right);
		//	return TweakDBInterface.GetValueAssignmentRecord(TDBID.Create("EconomicAssignment." + right)).OverrideValue();
		//};
		//return 0;
		
		//let's go with horsepower and visual tags instead
		let horsepower: Float = 100.0;
		let basePrice: Float = 10000.0;
		let qualityMult: Float = 1.0;
		let finalPrice: Float = 10000.0;
		
		horsepower = TweakDBInterface.GetVehicleRecord(tdbID).VehicleUIData().Horsepower();
		basePrice = horsepower * 100.0;
		
		//now let's take into account visual tags as a hint
		if this.IsPoor(tdbID) {
			qualityMult -= 0.5;
			//FTLog("IsPoor");
		} else {
			if this.IsPremium(tdbID) {
				qualityMult += 2.0;
				//FTLog("IsPremium");
			} else {
				if this.IsSport(tdbID) {
					qualityMult += 1.0;
					//FTLog("IsSport");
				};
			};
		};
		
		//final price is adjusted by quality level
		finalPrice =  basePrice * qualityMult;
		
		//FTLog("Vehicle: " + GetLocalizedTextByKey(TweakDBInterface.GetVehicleRecord(tdbID).DisplayName()) + " Price estimation: " + ToString(RoundMath(finalPrice)));
		
		return RoundMath(finalPrice);
	}
	
	private func IsPoor(tdbID: TweakDBID) -> Bool {
		return TweakDBInterface.GetVehicleRecord(tdbID).VisualTagsContains(n"Poor");
	}
	
	private func IsPremium(tdbID: TweakDBID) -> Bool {
		return TweakDBInterface.GetVehicleRecord(tdbID).VisualTagsContains(n"Premium");
	}
	
	private func IsSport(tdbID: TweakDBID) -> Bool {
		return TweakDBInterface.GetVehicleRecord(tdbID).VisualTagsContains(n"Sport");
	}
	
	private func CalcSummonPayment(vehPrice: Int32) -> Int32 {
		return RoundMath(MaxF(Cast<Float>(vehPrice) * VehicleInsuranceSystemConfig.SummonPricePrc() / 100.0, Cast<Float>(VehicleInsuranceSystemConfig.SummonMinPrice())) * this.GetVehicleSummonPriceMultiplier());
	}
	
	private func CalcRepairPayment(vehPrice: Int32, dmgPrc: Float) -> Int32 {
		return RoundMath(dmgPrc / 100.0 * MaxF(Cast<Float>(vehPrice) * VehicleInsuranceSystemConfig.RepairPricePrc() / 100.0, Cast<Float>(VehicleInsuranceSystemConfig.RepairMinPrice())) * this.GetRepairPriceMultiplier());
	}
	
	//bump not always results in damage, so can't just go with damage event here
	//damage prob needs to be handled by police system and driver license?
	private func CalcVehicleBumpPayment(veh: ref<VehicleObject>, evt: ref<VehicleBumpEvent>) -> Int32 {
		//FTLog("impactVelocityChange: " + ToString(evt.impactVelocityChange));
		//changed the formula so min price is set before velocity adjustment - it allows for better price limit tuning
		return RoundMath((1.0 + evt.impactVelocityChange) * MaxF(Cast<Float>(this.GetVehiclePrice(veh.GetRecordID())) * VehicleInsuranceSystemConfig.BumpPricePrc() / 100.0, Cast<Float>(VehicleInsuranceSystemConfig.BumpMinPrice())) * this.GetTrafficAccidentPriceMultiplier());
	}
	
	//handle insurance system debt
	public func PlayerHasVehicleInsuranceDebt() -> Bool {
		return this.m_vehicleInsuranceDebt > 0;
	}
	
	public func CanPayVehicleInsuranceDebt() -> Bool {
		return this.PlayerHasEnoughMoney(this.m_vehicleInsuranceDebt);
	}
	
	public func PayVehicleInsuranceDebt() -> Int32 {
		let paymentAmt: Int32 = 0;
		
		if this.PlayerHasEnoughMoney(this.m_vehicleInsuranceDebt) {
			paymentAmt = this.m_vehicleInsuranceDebt;
			this.m_vehicleInsuranceDebt = 0;
		} else {
			paymentAmt = this.GetPlayerMoney();
			if paymentAmt > 0 {
				this.m_vehicleInsuranceDebt -= paymentAmt;
			};
		};
		return this.PlayerWithdrawPayment(paymentAmt);
	}
	
	public func HandleVehicleInsuranceSystemTransaction(servicePriceRaw: Int32) -> InsuranceSystemPaymentResult {
		let transactionResult: InsuranceSystemPaymentResult;
		let servicePrice: Int32 = servicePriceRaw;
		
		//first check if the player has any debt with the system
		if this.PlayerHasVehicleInsuranceDebt() {
			//pay the debt if can
			if this.CanPayVehicleInsuranceDebt() {
				transactionResult.debtPaid = this.PayVehicleInsuranceDebt();
			};
		};
		
		//apply subscription discount
		servicePrice = this.ApplyDiscount(servicePrice);
		
		//try to withdraw service price from the player
		transactionResult.moneyPaid = this.PlayerWithdrawPayment(servicePrice);
		
		//check how much was actually withdrawn
		if transactionResult.moneyPaid < servicePrice {
			transactionResult.debtAcquired = servicePrice - transactionResult.moneyPaid;
			this.IncreaseVehicleInsuranceDebt(transactionResult.debtAcquired);
		};
		
		//fill in current system debt amount
		transactionResult.debtTotal = this.GetPlayerVehicleInsuranceDebt();
		
		return transactionResult;
	}
	
	public func GetPlayerVehicleInsuranceDebt() -> Int32 {
		return this.m_vehicleInsuranceDebt;
	}
	
	public func IncreaseVehicleInsuranceDebt(amt: Int32) {
		if amt > 0 {
			this.m_vehicleInsuranceDebt += amt;
		};
	}
	
	public func ClearVehicleInsuranceDebt() {
		this.m_vehicleInsuranceDebt = 0;
	}
	
	public func GetSubscriptionState() -> InsuranceSystemSubscriptionState {
		return this.m_subState;
	}
	
	public func GetSubscriptionPoolForLevel(level: Int32) -> Int32 {
		let rawVal = Cast<Float>(VehicleInsuranceSystemConfig.SubscriptionCost(level)) * 2.0 * VehicleInsuranceSystemConfig.SubscriptionDurationMultiplier();
		return RoundMath(rawVal * (1.0 + VehicleInsuranceSystemConfig.SubscriptionPrc(level) / 100.0));
	}

	//percentage of pool left (0...100%)
	public func GetSubscriptionDurationLeft() -> Float {
		return Cast<Float>(this.m_subState.moneyPool) / Cast<Float>(Max(this.GetSubscriptionPoolForLevel(this.m_subState.level), 1)) * 100.0;
	}
	
	public func CalcSubscriptionCost(level: Int32) -> Int32 {
		return RoundMath(Cast<Float>(VehicleInsuranceSystemConfig.SubscriptionCost(level)) * this.GetInsurancePriceMultiplier());
	}
	
	public func RenewSubscription(level: Int32) -> Void {
		this.m_subState.level = Max(level, 0);
		this.m_subState.moneyPool = Max(this.GetSubscriptionPoolForLevel(this.m_subState.level), 0);
		if this.m_subState.level > 0 {
			this.m_subState.lastKnownLevel = this.m_subState.level;
		};
	}
	
	public func UpdateSubscription() -> Void {
		if this.m_subState.moneyPool <= 0 {
			if this.m_subState.level > 0 {
				//push subscription expired phone notification
				let syst = PhoneExtensionSystem.GetInstance(this.m_player);
				syst.NotifyNewMessageCustom(VehicleInsuranceContactHash(), VehicleInsurancePhoneTexts.ContactName(), VehicleInsurancePhoneTexts.SubExpiredNotification());
			};
			this.m_subState.level = 0;
			this.m_subState.moneyPool = 0;
		};
	}
	
	public func GetDiscountPrc(level: Int32) -> Float {
		return VehicleInsuranceSystemConfig.SubscriptionPrc(level);
	}
	
	private func ApplyDiscount(price: Int32) -> Int32 {
		let servicePrice: Int32 = price;
		let discount: Int32;
		if this.m_subState.level > 0 && this.m_subState.moneyPool > 0 {
			discount = RoundMath(Cast<Float>(servicePrice) * this.GetDiscountPrc(this.m_subState.level) / 100.0);
			discount = Clamp(discount, 0, servicePrice);
			if discount > 0 {
				discount = Min(discount, this.m_subState.moneyPool);
				servicePrice -= discount;
				this.m_subState.moneyPool -= discount;
			};
		};
		this.UpdateSubscription();
		return servicePrice;
	}
	
	public func GetVehicleSummonPriceMultiplier() -> Float {
		let config = this.GetConfig();
		if IsDefined(config) {
			return config.VehicleSummonPriceMultiplier;
		};
		return 1.0;
	}
	
	public func GetRepairPriceMultiplier() -> Float {
		let config = this.GetConfig();
		if IsDefined(config) {
			return config.RepairPriceMultiplier;
		};
		return 1.0;
	}
	
	public func GetTrafficAccidentPriceMultiplier() -> Float {
		let config = this.GetConfig();
		if IsDefined(config) {
			return config.TrafficAccidentPriceMultiplier;
		};
		return 1.0;
	}
	
	public func GetInsurancePriceMultiplier() -> Float {
		let config = this.GetConfig();
		if IsDefined(config) {
			return config.InsurancePriceMultiplier;
		};
		return 1.0;
	}
	
	//handle player inventory money
	private func GetPlayerMoney() -> Int32 {
		return GameInstance.GetTransactionSystem(this.m_player.GetGame()).GetItemQuantity(this.m_player, MarketSystem.Money());
	}
	
	private func PlayerHasEnoughMoney(buyPrice: Int32) -> Bool {
		let tSystem: ref<TransactionSystem>;
		let playerMoney: Int32;
		
		tSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
		playerMoney = tSystem.GetItemQuantity(this.m_player, MarketSystem.Money());
		
		return playerMoney >= buyPrice;
	}
	
	private func PlayerWithdrawPayment(buyPrice: Int32) -> Int32 {
		let tSystem: ref<TransactionSystem>;
		let playerMoney: Int32;
		let moneyPaid: Int32;
		
		tSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
		playerMoney = tSystem.GetItemQuantity(this.m_player, MarketSystem.Money());
		
		if buyPrice > 0 {
			if buyPrice > playerMoney {
				moneyPaid = playerMoney;
			} else {
				moneyPaid = buyPrice;
			};
			//FTLog("Price paid: " + ToString(moneyPaid));
			tSystem.RemoveItem(this.m_player, MarketSystem.Money(), moneyPaid);
			return moneyPaid;
		};
		
		return 0;
	}
}

//@wrapMethod(VehicleObject)
//protected cb func OnGameAttached() -> Bool {
//	let vis: ref<VehicleInsuranceSystem> = VehicleInsuranceSystem.GetInstance(this);
//	let isUnlocked: Bool;
//	
//	wrappedMethod();
//	
//	if this.IsPlayerVehicle() {
//		//FTLog("VehicleObject.OnGameAttached: " + GetLocalizedTextByKey(TweakDBInterface.GetVehicleRecord(this.GetRecordID()).DisplayName()));
//		isUnlocked = GameInstance.GetVehicleSystem(this.GetGame()).IsVehiclePlayerUnlocked(this.GetRecordID());
//		//FTLog("Player unlocked: " + ToString(isUnlocked));
//		if isUnlocked {
//			VehicleInsuranceSystem.GetInstance(this).SetLastSpawnedPlayerVehicleID(this.GetRecordID());
//		};
//	};
//}

//@wrapMethod(VehicleObject)
//protected cb func OnDamageReceived(evt: ref<gameDamageReceivedEvent>) -> Bool {
//	let sourceVeh: ref<VehicleObject> = evt.hitEvent.attackData.GetSource() as VehicleObject;
//	
//	wrappedMethod(evt);
//	
//	if IsDefined(sourceVeh) && sourceVeh.IsPlayerDriver() {
//		FTLog("VehicleObject.OnDamageReceived: " + GetLocalizedTextByKey(TweakDBInterface.GetVehicleRecord(this.GetRecordID()).DisplayName()));
//		
//		FTLog("totalDamageReceived = " + ToString(evt.totalDamageReceived));
//		FTLog("Target = " + evt.hitEvent.target.GetDisplayName());
//		FTLog("Instigator = " + evt.hitEvent.attackData.GetInstigator().GetDisplayName());
//		FTLog("Source = " + evt.hitEvent.attackData.GetSource().GetDisplayName()); //vehicle object here
//		FTLog("Weapon = " + evt.hitEvent.attackData.GetWeapon().GetDisplayName());
//		FTLog("Veh impact force = " + evt.hitEvent.attackData.GetVehicleImpactForce());
//	};
//}

@wrapMethod(VehicleObject)
protected cb func OnVehicleBumpEvent(evt: ref<VehicleBumpEvent>) -> Bool {
	let vis: ref<VehicleInsuranceSystem> = VehicleInsuranceSystem.GetInstance(this);
	
	wrappedMethod(evt);
	
	//FTLog("VehicleObject.OnVehicleBumpEvent: " + GetLocalizedTextByKey(TweakDBInterface.GetVehicleRecord(this.GetRecordID()).DisplayName()));
	//FTLog("hit by: " + GetLocalizedTextByKey(TweakDBInterface.GetVehicleRecord(evt.hitVehicle.GetRecordID()).DisplayName()));

	if this.IsPlayerDriver() {
		//player vehicle was hit by another vehicle... never happens ?!?
		//nope, never happens...
		//FTLog("player vehicle was hit by another vehicle");
	} else {
		//if player is a driver and not hitting owned car
		//added panic driving check because...
		//evt.hitVehicle seems to be instigator while this obj is receiver, but...
		//it seems like if the player vehicle is involved, the player is always considered as an instigator
		//upd: added chasing target check to exclude car chase missions
		if evt.hitVehicle.IsPlayerDriver() && !this.IsPlayerVehicle() {
			if !this.IsPerformingPanicDriving() && !this.IsChasingTarget() && !this.IsInRaceQuest() {
				vis.HandleVehicleBumpEvent(this, evt);
			};
		};
	};
}

@addMethod(VehicleObject)
private func IsInRaceQuest() -> Bool {
	let sys = GameInstance.GetRacingSystem(this.GetGame());
	return sys.IsRaceInProgress() && sys.IsAIVehicleRegistered(this);
}

//@wrapMethod(VehicleComponent)
//private final func RepairVehicle() -> Void {
//	FTLog("VehicleComponent.RepairVehicle");
//	
//	wrappedMethod();
//}

//autorepair on summon doesn't trigger this!
@wrapMethod(VehicleHealthStatPoolListener)
public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
	let vis: ref<VehicleInsuranceSystem> = VehicleInsuranceSystem.GetInstance(this.m_owner);
	let isUnlocked: Bool;
	
	wrappedMethod(oldValue, newValue, percToPoints);
	
	if IsDefined(this.m_owner) && IsDefined(this.m_owner.GetVehicleComponent()) {
		if this.m_owner.IsPlayerVehicle() {
			isUnlocked = GameInstance.GetVehicleSystem(this.m_owner.GetGame()).IsVehiclePlayerUnlocked(this.m_owner.GetRecordID());
			if isUnlocked {
				if RoundMath(newValue * 100.0) != RoundMath(oldValue * 100.0) {
					//FTLog("OnStatPoolValueChanged: " + GetLocalizedTextByKey(TweakDBInterface.GetVehicleRecord(this.m_owner.GetRecordID()).DisplayName()));
					//FTLog("oldValue = " + ToString(oldValue));
					//FTLog("newValue = " + ToString(newValue));
					//FTLog("percToPoints = " + ToString(percToPoints));
					vis.UpdateVehHealthMap(TDBID.ToNumber(this.m_owner.GetRecordID()), newValue);
					//FTLog("Test get: " + vis.GetVehHealthPrc(TDBID.ToNumber(this.m_owner.GetRecordID())));
				};
			};
		};
	};
}

//no summoning if player has debt with the insurance system
@wrapMethod(QuickSlotsManager)
public final func SummonVehicle(force: Bool, type: gamedataVehicleType, vehicle: TweakDBID, spawnOnlyOnValidRoad: Bool) -> Void {
	let vis: ref<VehicleInsuranceSystem> = VehicleInsuranceSystem.GetInstance(this.m_Player);
	
	//FTLog("QuickSlotsManager.SummonVehicle");
	//FTLog("Has debt: " + ToString(vis.PlayerHasVehicleInsuranceDebt()));
	//FTLog("Can pay debt: " + ToString(vis.CanPayVehicleInsuranceDebt()));
	
	if vis.PlayerHasVehicleInsuranceDebt() && !vis.CanPayVehicleInsuranceDebt() {
		TANSTAAFLMSG.ShowUnableToSummonMessage(this.m_Player.GetGame(), vis.GetPlayerVehicleInsuranceDebt());
	} else {
		wrappedMethod(force, type, vehicle, spawnOnlyOnValidRoad);
	};
}

//tracking mounting/unmounting as driver
@wrapMethod(VehicleComponent)
protected cb func OnMountingEvent(evt: ref<MountingEvent>) -> Bool {
	let ret = wrappedMethod(evt);
	
	if IsDefined(this.m_mountedPlayer) {
		let vis: ref<VehicleInsuranceSystem> = VehicleInsuranceSystem.GetInstance(this.m_mountedPlayer);
		vis.OnMountedInDriverSeatChanged(this.m_mountedPlayer.GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicleInDriverSeat), this.GetVehicle());
	};
	
	return ret;
}

@wrapMethod(PlayerPuppet)
protected cb func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Bool {
	let ret = wrappedMethod(evt);
	
	let vis: ref<VehicleInsuranceSystem> = VehicleInsuranceSystem.GetInstance(this);
	vis.OnMountedInDriverSeatChanged(this.GetPlayerStateMachineBlackboard().GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicleInDriverSeat), null);

	return ret;
}

//handle init/uninit of the system
@addField(PlayerPuppet)
private let m_vehicleInsuranceSystem: wref<VehicleInsuranceSystem>;

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    wrappedMethod();

    this.m_vehicleInsuranceSystem = VehicleInsuranceSystem.GetInstance(this);
	this.m_vehicleInsuranceSystem.Init(this);
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
    wrappedMethod();
	
	this.m_vehicleInsuranceSystem.Uninit();
}
