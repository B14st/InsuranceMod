module FastTravelPaymentMod
import TANSTAAFLPart1Messages.*
import TANSTAAFLPart1Configs.FastTravelPaymentConfig
import TANSTAAFLPart1ModSettings.FastTravelUserConfig

public class FastTravelPaymentCalc {
	private let m_player: wref<PlayerPuppet>;
	private let m_fastTravelBB: wref<IBlackboard>;
	private let m_lastCalcPayment: Int32;
	private let m_loadingScreenCallbackID: ref<CallbackHandle>;
	private let m_config: ref<FastTravelUserConfig>;
	
	private let scheduleMSG: Bool;
	
	public func Init(player: ref<PlayerPuppet>) {
		this.m_player = player;
		this.m_fastTravelBB = GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().FastTRavelSystem);

		FTLog("FastTravelPaymentCalc.Init");
		
		this.m_loadingScreenCallbackID = this.m_fastTravelBB.RegisterListenerBool(GetAllBlackboardDefs().FastTRavelSystem.FastTravelLoadingScreenFinished, this, n"OnLoadingScreenFinished");
	}

	public func Uninit() {
		FTLog("FastTravelPaymentCalc.Uninit");
		
		this.m_fastTravelBB.UnregisterListenerBool(GetAllBlackboardDefs().FastTRavelSystem.FastTravelLoadingScreenFinished, this.m_loadingScreenCallbackID);
	}

	public func GetConfig() -> ref<FastTravelUserConfig> {
		if this.m_config == null {
			this.m_config = new FastTravelUserConfig();
			ModSettings.RegisterListenerToClass(this.m_config);
		};
		return this.m_config;
	}
	
	public func GetGlobalPriceMultiplier() -> Float {
		let config = this.GetConfig();
		if IsDefined(config) {
			return config.FastTravelGlobalPriceMultiplier;
		};
		return 1.0;
	}
	
	public func CalcPayment(distance: Float) -> Int32 {
		//FTLog("distance: " + ToString(distance));
		//FTLog("cost per meter: " + ToString(FastTravelPaymentConfig.CostPerMeter()));
		this.m_lastCalcPayment = RoundMath(distance * FastTravelPaymentConfig.CostPerMeter() * this.GetGlobalPriceMultiplier());
		return this.m_lastCalcPayment;
	}
	
	public func PlayerHasEnoughMoney(distance: Float) -> Bool {
		let buyPrice: Int32;
		let playerMoney: Int32;
		let tSystem: ref<TransactionSystem>;
		
		tSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
		playerMoney = tSystem.GetItemQuantity(this.m_player, MarketSystem.Money());
		buyPrice = this.CalcPayment(distance);
		
		return playerMoney >= buyPrice;
	}
	
	public func PlayerWithdrawPayment(distance: Float) {
		let buyPrice: Int32;
		let tSystem: ref<TransactionSystem>;
		
		tSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
		buyPrice = this.CalcPayment(distance);
		
		if buyPrice > 0 {
			tSystem.RemoveItem(this.m_player, MarketSystem.Money(), buyPrice);
			this.scheduleMSG = true;
		};
	}
	
	public func GetLastCalcPayment() -> Int32 {
		return this.m_lastCalcPayment;
	}
	
	protected cb func OnLoadingScreenFinished(value: Bool) -> Bool {
		if value && this.scheduleMSG {
			TANSTAAFLMSG.ShowFastTravelPaidMessage(this.m_player.GetGame(), this.m_lastCalcPayment);
			this.scheduleMSG = false;
		};
	}
}

@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
    let player: wref<GameObject> = menu.GetPlayer();
	let ftPaymentCalc: ref<FastTravelPaymentCalc> = GetPlayer(player.GetGame()).GetFastTravelPaymentCalc();
	let config = ftPaymentCalc.GetConfig();
	let distance: Float;
    let fastTravelmappin: ref<FastTravelMappin>;
    //let pointData: ref<FastTravelPointData>;
    //let titleStr: String;
	let descStr: String;
	
	wrappedMethod(data, menu);
	
	fastTravelmappin = Deref(data).mappin as FastTravelMappin;
	if config.FTModEnabled && IsDefined(ftPaymentCalc) && IsDefined(fastTravelmappin) {
		//FTLog("Player World Pos: " + ToString(GetPlayer(GetGameInstance()).GetWorldPosition()));
		//FTLog("Mappin World Pos: " + ToString(fastTravelmappin.GetWorldPosition()));
		//FTLog("Mappin Player Dist: " + ToString(fastTravelmappin.GetDistanceToPlayer()));
		//FTLog("Travel Payment: " + ToString(ftPaymentCalc.CalcPayment(fastTravelmappin.GetDistanceToPlayer())));
		//pointData = fastTravelmappin.GetPointData();
        //titleStr = Deref(data).isCollection ? GetLocalizedText("UI-MappinTypes-FastTravelDescription") : GetLocalizedText(pointData.GetPointDisplayName());
		//titleStr = titleStr + ": \u{20ac}$" + ToString(ftPaymentCalc.CalcPayment(fastTravelmappin.GetDistanceToPlayer()));
		//inkTextRef.SetText(this.m_titleText, titleStr);
		distance = fastTravelmappin.GetDistanceToPlayer();
		descStr = GetLocalizedText("UI-MappinTypes-FastTravel");
		descStr += ": \u{20ac}$" + ToString(ftPaymentCalc.CalcPayment(distance));
		inkTextRef.SetText(this.m_descText, descStr);
		if Deref(data).fastTravelEnabled {
			if !ftPaymentCalc.PlayerHasEnoughMoney(distance) {
				inkWidgetRef.SetVisible(this.m_inputInteractContainer, false);
				inkWidgetRef.Get(this.m_descText).BindProperty(n"tintColor", n"MainColors.Red");
			} else {
				inkWidgetRef.Get(this.m_descText).BindProperty(n"tintColor", n"MainColors.Green");
			};
		};
	};
}

@wrapMethod(WorldMapMenuGameController)
private final func FastTravel() -> Void {
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerMainGameObject();
	let ftPaymentCalc: ref<FastTravelPaymentCalc> = GetPlayer(player.GetGame()).GetFastTravelPaymentCalc();
	let config = ftPaymentCalc.GetConfig();
	let distance: Float;
    let mappin: ref<FastTravelMappin>;

    mappin = this.selectedMappin.GetMappin() as FastTravelMappin;
	
	if !config.FTModEnabled || !IsDefined(ftPaymentCalc) || !IsDefined(mappin) {
		wrappedMethod();
	} else {
		distance = mappin.GetDistanceToPlayer();
		if ftPaymentCalc.PlayerHasEnoughMoney(distance) {
			wrappedMethod();
			ftPaymentCalc.PlayerWithdrawPayment(distance);
		} else {
			GameInstance.GetAudioSystem(this.m_player.GetGame()).Play(n"ui_menu_item_crafting_fail");
		};
	};
}

@addField(PlayerPuppet)
private let m_fastTravelPaymentCalc: ref<FastTravelPaymentCalc>;

@addMethod(PlayerPuppet)
public func GetFastTravelPaymentCalc() -> ref<FastTravelPaymentCalc> {
	return this.m_fastTravelPaymentCalc;
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    wrappedMethod();

    this.m_fastTravelPaymentCalc = new FastTravelPaymentCalc();
	this.m_fastTravelPaymentCalc.Init(this);
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
    wrappedMethod();

	this.m_fastTravelPaymentCalc.Uninit();
    this.m_fastTravelPaymentCalc = null;
}
