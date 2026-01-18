module VehicleInsuranceWeb
import BrowserExtension.DataStructures.*
import BrowserExtension.Classes.*
import BrowserExtension.System.*
import VehicleInsuranceMod.*
import TANSTAAFLPart1Localizable.VehicleInsuranceWebTexts
import TANSTAAFLPart1Configs.VehicleInsuranceSystemConfig

public class VehicleInsuranceSiteListener extends BrowserEventsListener {
	private let mainPageAddr: String = "NETdir://vehicle.insurance";
	private let debtAddr: String = "NETdir://vehicle.insurance/debt";
	private let manageAddr: String = "NETdir://vehicle.insurance/manage";
	private let buyAddr: String = "NETdir://vehicle.insurance/buy";
	private let aboutAddr: String = "NETdir://vehicle.insurance/about";
	
	private let m_subLevelClicked: Int32 = 0;
	
    private func TextColor() -> HDRColor = new HDRColor(0.368627, 0.964706, 1.0, 1.0)
    private func EDColor() -> HDRColor = new HDRColor(1.1192, 0.8441, 0.2565, 1.0)
    private func NumbersColor() -> HDRColor = new HDRColor(1.1761, 0.3809, 0.3476, 1.0)
	
	private func HeaderFont() -> String = s"base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily"
	private func TextFont() -> String = s"base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily"
	
	private func FontSizeHeader() -> Int32 = 180
	private func FontSizeNormal() -> Int32 = 80
	private func FontSizeSmall() -> Int32 = 60
	
	private func FontStyleHeader() -> CName = n"Bold"
	private func FontStyleText() -> CName = n"Regular"
	private func FontStyleNumbers() -> CName = n"Semi-Bold"
	
	public func Init(logic: ref<BrowserGameController>) {
		super.Init(logic);
		
		this.m_siteData.address = this.mainPageAddr;
		this.m_siteData.shortName = VehicleInsuranceWebTexts.LOGO();
		//this.m_siteData.iconAtlasPath = r"base\\gameplay\\gui\\world\\internet\\templates\\atlases\\icons_atlas.inkatlas";
		//this.m_siteData.iconTexturePart = n"zetatech1";
		this.m_siteData.iconAtlasPath = r"base\\gameplay\\gui\\world\\internet\\templates\\atlases\\autoinsicon.inkatlas";
		this.m_siteData.iconTexturePart = n"icon";
		
		FTLog("VehicleInsuranceSiteListener.Init");
	}
	
	public func Uninit() {
		super.Uninit();
		
		FTLog("VehicleInsuranceSiteListener.Uninit");
	}
	
	public func GetWebPage(address: String) -> ref<inkCompoundWidget> {
		let system = VehicleInsuranceSystem.GetInstance(this.m_deviceObject);
		let subState = system.GetSubscriptionState();
		let canvas = new inkCanvas();
		
		let size = this.m_deviceLogicController.GetRootCompoundWidget().GetSize();
		
		//main panel
		let vPanel = new inkVerticalPanel();
		vPanel.SetMargin(new inkMargin(0.0, 100.0, 0.0, 0.0));
		vPanel.SetAnchor(inkEAnchor.TopCenter);
		vPanel.SetAnchorPoint(0.5, 0.0);
		vPanel.SetFitToContent(true);
		vPanel.SetChildMargin(new inkMargin(40.0, 20.0, 0.0, 0.0));
		vPanel.Reparent(canvas);
		
		//common site header
		let header = new inkText();
		header.SetText(VehicleInsuranceWebTexts.LOGO());
		header.SetFontFamily(this.HeaderFont());
		header.SetFontStyle(this.FontStyleHeader());
		header.SetFontSize(this.FontSizeHeader());
		header.SetTintColor(this.TextColor());
		header.Reparent(vPanel);
			
		if Equals(address, this.mainPageAddr) {
			let debt = system.GetPlayerVehicleInsuranceDebt();
			let level = subState.level;
			let discount = RoundMath(system.GetDiscountPrc(level));
			//let pool = subState.moneyPool;
			let subDurationLeft = RoundMath(system.GetSubscriptionDurationLeft());
			//LogChannel(n"DEBUG", "Sub lvl = " + level);
			//LogChannel(n"DEBUG", "Pool = " + subState.moneyPool);
			//LogChannel(n"DEBUG", "Max pool = " + Max(VehicleInsuranceSystemConfig.SubscriptionPool(level), 1));
			
			let vBox1 = new inkVerticalPanel();
			vBox1.SetFitToContent(true);
			vBox1.Reparent(vPanel);
			
			let subStatusText = new inkText();
			subStatusText.SetText(VehicleInsuranceWebTexts.SubscriptionStatus());
			subStatusText.SetFontFamily(this.TextFont());
			subStatusText.SetFontStyle(this.FontStyleHeader());
			subStatusText.SetFontSize(this.FontSizeNormal());
			subStatusText.SetTintColor(this.TextColor());
			subStatusText.Reparent(vBox1);
			
			let hBox1 = new inkHorizontalPanel();
			hBox1.SetFitToContent(true);
			hBox1.Reparent(vBox1);
			let hBox2 = new inkHorizontalPanel();
			hBox2.SetFitToContent(true);
			hBox2.Reparent(vBox1);
			let hBox3 = new inkHorizontalPanel();
			hBox3.SetFitToContent(true);
			hBox3.Reparent(vBox1);
			let hBox4 = new inkHorizontalPanel();
			hBox4.SetFitToContent(true);
			hBox4.Reparent(vBox1);
			
			let txt0 = new inkText();
			txt0.SetText(s"    " + VehicleInsuranceWebTexts.Debt() + ": ");
			txt0.SetFontFamily(this.TextFont());
			txt0.SetFontStyle(this.FontStyleText());
			txt0.SetFontSize(this.FontSizeSmall());
			txt0.SetTintColor(this.TextColor());
			txt0.Reparent(hBox1);
			let txt1 = new inkText();
			txt1.SetText(s"\u{20ac}$ ");
			txt1.SetFontFamily(this.TextFont());
			txt1.SetFontStyle(this.FontStyleText());
			txt1.SetFontSize(this.FontSizeSmall());
			txt1.SetTintColor(this.EDColor());
			txt1.Reparent(hBox1);
			let txt2 = new inkText();
			txt2.SetText(s"\(debt)");
			txt2.SetFontFamily(this.TextFont());
			txt2.SetFontStyle(this.FontStyleNumbers());
			txt2.SetFontSize(this.FontSizeSmall());
			txt2.SetTintColor(this.NumbersColor());
			txt2.Reparent(hBox1);
			
			let txt3 = new inkText();
			txt3.SetText(s"    " + VehicleInsuranceWebTexts.SubscriptionLevel() + ": ");
			txt3.SetFontFamily(this.TextFont());
			txt3.SetFontStyle(this.FontStyleText());
			txt3.SetFontSize(this.FontSizeSmall());
			txt3.SetTintColor(this.TextColor());
			txt3.Reparent(hBox2);
			let txt4 = new inkText();
			txt4.SetText(s"\(level)");
			txt4.SetFontFamily(this.TextFont());
			txt4.SetFontStyle(this.FontStyleNumbers());
			txt4.SetFontSize(this.FontSizeSmall());
			txt4.SetTintColor(this.NumbersColor());
			txt4.Reparent(hBox2);
			
			let txt5 = new inkText();
			txt5.SetText(s"    " + VehicleInsuranceWebTexts.Discount() + ": ");
			txt5.SetFontFamily(this.TextFont());
			txt5.SetFontStyle(this.FontStyleText());
			txt5.SetFontSize(this.FontSizeSmall());
			txt5.SetTintColor(this.TextColor());
			txt5.Reparent(hBox3);
			let txt6 = new inkText();
			txt6.SetText(s"\(discount)%");
			txt6.SetFontFamily(this.TextFont());
			txt6.SetFontStyle(this.FontStyleNumbers());
			txt6.SetFontSize(this.FontSizeSmall());
			txt6.SetTintColor(this.NumbersColor());
			txt6.Reparent(hBox3);
			
			let txt7 = new inkText();
			//txt7.SetText(s"    " + VehicleInsuranceWebTexts.MoneyPool() + ": ");
			txt7.SetText(s"    " + VehicleInsuranceWebTexts.SubDurationLeft() + ": ");
			txt7.SetFontFamily(this.TextFont());
			txt7.SetFontStyle(this.FontStyleText());
			txt7.SetFontSize(this.FontSizeSmall());
			txt7.SetTintColor(this.TextColor());
			txt7.Reparent(hBox4);
			//let txt8 = new inkText();
			//txt8.SetText(s"\u{20ac}$ ");
			//txt8.SetFontFamily(this.TextFont());
			//txt8.SetFontStyle(this.FontStyleText());
			//txt8.SetFontSize(this.FontSizeSmall());
			//txt8.SetTintColor(this.EDColor());
			//txt8.Reparent(hBox4);
			let txt9 = new inkText();
			let poolTxt = s"\(subDurationLeft)" + "%";
			if subDurationLeft < 1 && subState.moneyPool > 0 {
				poolTxt = s"< 1%";
			};
			txt9.SetText(poolTxt);
			//txt9.SetText(s"\(pool)");
			txt9.SetFontFamily(this.TextFont());
			txt9.SetFontStyle(this.FontStyleNumbers());
			txt9.SetFontSize(this.FontSizeSmall());
			txt9.SetTintColor(this.NumbersColor());
			txt9.Reparent(hBox4);
			
			if system.PlayerHasVehicleInsuranceDebt() {
				let payDebtText = new inkText();
				payDebtText.AttachController(new AddressLinkController());
				(payDebtText.GetController() as AddressLinkController).m_linkAddress = this.debtAddr;
				payDebtText.SetText(VehicleInsuranceWebTexts.PayDebt());
				payDebtText.SetFontFamily(this.TextFont());
				payDebtText.SetFontStyle(this.FontStyleHeader());
				payDebtText.SetFontSize(this.FontSizeNormal());
				payDebtText.SetTintColor(this.TextColor());
				payDebtText.SetInteractive(true);
				payDebtText.RegisterToCallback(n"OnRelease", this, n"OnGenericLinkClicked");
				payDebtText.Reparent(vPanel);
			} else {
				let manageSubText = new inkText();
				manageSubText.AttachController(new AddressLinkController());
				(manageSubText.GetController() as AddressLinkController).m_linkAddress = this.manageAddr;
				manageSubText.SetText(VehicleInsuranceWebTexts.ManageSubscription());
				manageSubText.SetFontFamily(this.TextFont());
				manageSubText.SetFontStyle(this.FontStyleHeader());
				manageSubText.SetFontSize(this.FontSizeNormal());
				manageSubText.SetTintColor(this.TextColor());
				manageSubText.SetInteractive(true);
				manageSubText.RegisterToCallback(n"OnRelease", this, n"OnGenericLinkClicked");
				manageSubText.Reparent(vPanel);
			};
			
			let aboutText = new inkText();
			aboutText.AttachController(new AddressLinkController());
			(aboutText.GetController() as AddressLinkController).m_linkAddress = this.aboutAddr;
			aboutText.SetText(VehicleInsuranceWebTexts.About());
			aboutText.SetFontFamily(this.TextFont());
			aboutText.SetFontStyle(this.FontStyleHeader());
			aboutText.SetFontSize(this.FontSizeNormal());
			aboutText.SetTintColor(this.TextColor());
			aboutText.SetInteractive(true);
			aboutText.RegisterToCallback(n"OnRelease", this, n"OnGenericLinkClicked");
			aboutText.Reparent(vPanel);
			
			return canvas;
		};
		if Equals(address, this.debtAddr) {
			let debt = system.GetPlayerVehicleInsuranceDebt();
			let hBox1 = new inkHorizontalPanel();
			hBox1.SetFitToContent(true);
			hBox1.Reparent(vPanel);
			let txt1 = new inkText();
			txt1.SetText(VehicleInsuranceWebTexts.DebtInfo());
			txt1.SetFontFamily(this.TextFont());
			txt1.SetFontStyle(this.FontStyleText());
			txt1.SetFontSize(this.FontSizeNormal());
			txt1.SetTintColor(this.TextColor());
			txt1.Reparent(hBox1);
			let txt2 = new inkText();
			txt2.SetText(s"\u{20ac}$ ");
			txt2.SetFontFamily(this.TextFont());
			txt2.SetFontStyle(this.FontStyleText());
			txt2.SetFontSize(this.FontSizeNormal());
			txt2.SetTintColor(this.EDColor());
			txt2.Reparent(hBox1);
			let txt3 = new inkText();
			txt3.SetText(s"\(debt)");
			txt3.SetFontFamily(this.TextFont());
			txt3.SetFontStyle(this.FontStyleNumbers());
			txt3.SetFontSize(this.FontSizeNormal());
			txt3.SetTintColor(this.NumbersColor());
			txt3.Reparent(hBox1);
			
			let confirmText = this.BuildConfirmTransactionText();
			confirmText.AttachController(new AddressLinkController());
			confirmText.SetInteractive(true);
			confirmText.RegisterToCallback(n"OnRelease", this, n"OnConfirmPayDebtClicked");
			confirmText.Reparent(vPanel);
			
			let backText = new inkText();
			backText.AttachController(new AddressLinkController());
			(backText.GetController() as AddressLinkController).m_linkAddress = this.mainPageAddr;
			backText.SetText(VehicleInsuranceWebTexts.Back());
			backText.SetFontFamily(this.TextFont());
			backText.SetFontStyle(this.FontStyleHeader());
			backText.SetFontSize(this.FontSizeNormal());
			backText.SetTintColor(this.TextColor());
			backText.SetInteractive(true);
			backText.RegisterToCallback(n"OnRelease", this, n"OnGenericLinkClicked");
			backText.Reparent(vPanel);
			
			return canvas;
		};
		if Equals(address, this.manageAddr) {
			this.m_subLevelClicked = 0;
			let i = 0;
			while i < VehicleInsuranceSystemConfig.MaxSubscriptionLevel() {
				i += 1;
				let hBox1 = this.BuildOfferText(i);
				//hBox1.SetName(StringToName(s"\(i)"));
				hBox1.AttachController(new AddressLinkController());
				(hBox1.GetController() as AddressLinkController).m_offerIndex = i;
				hBox1.SetInteractive(true);
				hBox1.RegisterToCallback(n"OnRelease", this, n"OnBuySubClicked");
				hBox1.Reparent(vPanel);
			};
			
			let backText = new inkText();
			backText.AttachController(new AddressLinkController());
			(backText.GetController() as AddressLinkController).m_linkAddress = this.mainPageAddr;
			backText.SetText(VehicleInsuranceWebTexts.Back());
			backText.SetFontFamily(this.TextFont());
			backText.SetFontStyle(this.FontStyleHeader());
			backText.SetFontSize(this.FontSizeNormal());
			backText.SetTintColor(this.TextColor());
			backText.SetInteractive(true);
			backText.RegisterToCallback(n"OnRelease", this, n"OnGenericLinkClicked");
			backText.Reparent(vPanel);
			
			return canvas;
		};
		if Equals(address, this.buyAddr) {
			let hBox1 = this.BuildOfferText(this.m_subLevelClicked);
			hBox1.Reparent(vPanel);
			
			let level = this.m_subLevelClicked;
			let price = system.CalcSubscriptionCost(level);
			if price > 0 && system.PlayerHasEnoughMoney(price) {
				let confirmText = this.BuildConfirmTransactionText();
				confirmText.AttachController(new AddressLinkController());
				confirmText.SetInteractive(true);
				confirmText.RegisterToCallback(n"OnRelease", this, n"OnConfirmBuyClicked");
				confirmText.Reparent(vPanel);
			
				let backText = new inkText();
				backText.AttachController(new AddressLinkController());
				(backText.GetController() as AddressLinkController).m_linkAddress = this.manageAddr;
				backText.SetText(VehicleInsuranceWebTexts.Back());
				backText.SetFontFamily(this.TextFont());
				backText.SetFontStyle(this.FontStyleHeader());
				backText.SetFontSize(this.FontSizeNormal());
				backText.SetTintColor(this.TextColor());
				backText.SetInteractive(true);
				backText.RegisterToCallback(n"OnRelease", this, n"OnGenericLinkClicked");
				backText.Reparent(vPanel);
			} else {
				let noMoneyText = new inkText();
				noMoneyText.AttachController(new AddressLinkController());
				(noMoneyText.GetController() as AddressLinkController).m_linkAddress = this.manageAddr;
				noMoneyText.SetText(VehicleInsuranceWebTexts.NoMoney());
				noMoneyText.SetFontFamily(this.TextFont());
				noMoneyText.SetFontStyle(this.FontStyleHeader());
				noMoneyText.SetFontSize(this.FontSizeNormal());
				noMoneyText.SetTintColor(this.TextColor());
				noMoneyText.SetInteractive(true);
				noMoneyText.RegisterToCallback(n"OnRelease", this, n"OnGenericLinkClicked");
				noMoneyText.Reparent(vPanel);
			};
			
			return canvas;
		};
		if Equals(address, this.aboutAddr) {
			let aboutText = new inkText();
			//aboutText.SetSize(new Vector2(size.X - 160.0, size.Y - 250.0));
			//aboutText.SetSizeRule(inkESizeRule.Fixed);
			//aboutText.SetOverflowPolicy(textOverflowPolicy.AdjustToSize);
			aboutText.SetWrapping(true, size.X * 0.8, textWrappingPolicy.Default);
			aboutText.SetFontFamily(this.TextFont());
			aboutText.SetFontStyle(this.FontStyleText());
			aboutText.SetFontSize(this.FontSizeSmall());
			aboutText.SetTintColor(this.TextColor());
			aboutText.SetText(VehicleInsuranceWebTexts.AboutText());
			aboutText.Reparent(vPanel);
			
			let backText = new inkText();
			backText.AttachController(new AddressLinkController());
			(backText.GetController() as AddressLinkController).m_linkAddress = this.mainPageAddr;
			backText.SetText(VehicleInsuranceWebTexts.Back());
			backText.SetFontFamily(this.TextFont());
			backText.SetFontStyle(this.FontStyleHeader());
			backText.SetFontSize(this.FontSizeNormal());
			backText.SetTintColor(this.TextColor());
			backText.SetInteractive(true);
			backText.RegisterToCallback(n"OnRelease", this, n"OnGenericLinkClicked");
			backText.Reparent(vPanel);
			
			return canvas;
		};
		
		return canvas;
	}
	
	protected func BuildConfirmTransactionText() -> ref<inkText> {
		let confirmText = new inkText();
		confirmText.SetText(VehicleInsuranceWebTexts.ConfirmTransaction());
		confirmText.SetFontFamily(this.TextFont());
		confirmText.SetFontStyle(this.FontStyleHeader());
		confirmText.SetFontSize(this.FontSizeNormal());
		confirmText.SetTintColor(this.TextColor());
		return confirmText;
	}
	
	protected func BuildOfferText(level: Int32) -> ref<inkHorizontalPanel> {
		let system = VehicleInsuranceSystem.GetInstance(this.m_deviceObject);
		let discount = RoundMath(system.GetDiscountPrc(level));
		let price = system.CalcSubscriptionCost(level);
		let hBox1 = new inkHorizontalPanel();
		hBox1.SetFitToContent(true);
		let txt1 = new inkText();
		txt1.SetText(VehicleInsuranceWebTexts.Level() + s": ");
		txt1.SetFontFamily(this.TextFont());
		txt1.SetFontStyle(this.FontStyleText());
		txt1.SetFontSize(this.FontSizeNormal());
		txt1.SetTintColor(this.TextColor());
		txt1.Reparent(hBox1);
		let txt2 = new inkText();
		txt2.SetText(s"\(level)");
		txt2.SetFontFamily(this.TextFont());
		txt2.SetFontStyle(this.FontStyleNumbers());
		txt2.SetFontSize(this.FontSizeNormal());
		txt2.SetTintColor(this.NumbersColor());
		txt2.Reparent(hBox1);
		let txt3 = new inkText();
		txt3.SetText(s"; " + VehicleInsuranceWebTexts.Discount() + ": ");
		txt3.SetFontFamily(this.TextFont());
		txt3.SetFontStyle(this.FontStyleText());
		txt3.SetFontSize(this.FontSizeNormal());
		txt3.SetTintColor(this.TextColor());
		txt3.Reparent(hBox1);
		let txt4 = new inkText();
		txt4.SetText(s"\(discount)%");
		txt4.SetFontFamily(this.TextFont());
		txt4.SetFontStyle(this.FontStyleNumbers());
		txt4.SetFontSize(this.FontSizeNormal());
		txt4.SetTintColor(this.NumbersColor());
		txt4.Reparent(hBox1);
		let txt5 = new inkText();
		txt5.SetText(s"; " + VehicleInsuranceWebTexts.Price() + ": ");
		txt5.SetFontFamily(this.TextFont());
		txt5.SetFontStyle(this.FontStyleText());
		txt5.SetFontSize(this.FontSizeNormal());
		txt5.SetTintColor(this.TextColor());
		txt5.Reparent(hBox1);
		let txt6 = new inkText();
		txt6.SetText(s"\u{20ac}$ ");
		txt6.SetFontFamily(this.TextFont());
		txt6.SetFontStyle(this.FontStyleText());
		txt6.SetFontSize(this.FontSizeNormal());
		txt6.SetTintColor(this.EDColor());
		txt6.Reparent(hBox1);
		let txt7 = new inkText();
		txt7.SetText(s"\(price)");
		txt7.SetFontFamily(this.TextFont());
		txt7.SetFontStyle(this.FontStyleNumbers());
		txt7.SetFontSize(this.FontSizeNormal());
		txt7.SetTintColor(this.NumbersColor());
		txt7.Reparent(hBox1);
		return hBox1;
	}
	
	protected cb func OnGenericLinkClicked(evt: ref<inkPointerEvent>) -> Bool {
		if evt.IsAction(n"click") {
			evt.Consume();
			let addr = (evt.GetCurrentTarget().GetController() as AddressLinkController).m_linkAddress;
			if !Equals(addr, s"") {
				this.m_deviceLogicController.LoadPageByAddress(addr);
			} else {
				this.m_deviceLogicController.LoadPageByAddress(this.mainPageAddr);
			};
		};
	}
	
	protected cb func OnBuySubClicked(evt: ref<inkPointerEvent>) -> Bool {
		if evt.IsAction(n"click") {
			evt.Consume();
			//this.m_subLevelClicked = StringToInt(NameToString(evt.GetCurrentTarget().GetName()), 0);
			this.m_subLevelClicked = (evt.GetCurrentTarget().GetController() as AddressLinkController).m_offerIndex;
			//LogChannel(n"DEBUG", "Sub lvl clicked = " + this.m_subLevelClicked);
			if this.m_subLevelClicked > 0 && this.m_subLevelClicked <= VehicleInsuranceSystemConfig.MaxSubscriptionLevel() {
				this.m_deviceLogicController.LoadPageByAddress(this.buyAddr);
			} else {
				this.m_deviceLogicController.LoadPageByAddress(this.mainPageAddr);
			};
		};
	}
	
	protected cb func OnConfirmBuyClicked(evt: ref<inkPointerEvent>) -> Bool {
		if evt.IsAction(n"click") {
			evt.Consume();
			let system = VehicleInsuranceSystem.GetInstance(this.m_deviceObject);
			let level = this.m_subLevelClicked;
			let price = system.CalcSubscriptionCost(level);
			if price > 0 && system.PlayerHasEnoughMoney(price) {
				system.PlayerWithdrawPayment(price);
				system.RenewSubscription(level);
			};
			this.m_deviceLogicController.LoadPageByAddress(this.mainPageAddr);
		};
	}
	
	protected cb func OnConfirmPayDebtClicked(evt: ref<inkPointerEvent>) -> Bool {
		if evt.IsAction(n"click") {
			evt.Consume();
			let system = VehicleInsuranceSystem.GetInstance(this.m_deviceObject);
			if system.PlayerHasVehicleInsuranceDebt() {
				system.PayVehicleInsuranceDebt();
			};
			this.m_deviceLogicController.LoadPageByAddress(this.mainPageAddr);
		};
	}
}

public class AddressLinkController extends inkLogicController {
    private func HoverColor() -> HDRColor = new HDRColor(1.00, 1.00, 1.00, 0.00)
	
	private let m_defaultColor: HDRColor;
	private let m_hoverColor: HDRColor;

	private let m_childDefaultColors: array<HDRColor>;
	
	public let m_linkAddress: String;
	public let m_offerIndex: Int32;
	
    protected cb func OnInitialize() {
		let widget: ref<inkWidget> = this.GetRootWidget();
		this.m_hoverColor = this.HoverColor();
		this.RegisterToCallback(n"OnEnter", this, n"OnEnterCallback");
		this.RegisterToCallback(n"OnLeave", this, n"OnLeaveCallback");
		//this.RegisterToCallback(n"OnPress", this, n"OnPressCallback");
		//this.RegisterToCallback(n"OnRelease", this, n"OnReleaseCallback");
	}

    protected cb func OnEnterCallback(evt: ref<inkPointerEvent>) -> Bool {
		let widget: ref<inkWidget> = this.GetRootWidget();
		this.m_defaultColor = widget.GetTintColor();
		widget.SetTintColor(this.m_hoverColor);
		ArrayClear(this.m_childDefaultColors);
		let compWidget = widget as inkCompoundWidget;
		if IsDefined(compWidget) {
			let i = 0;
			while i < compWidget.GetNumChildren() {
				let child = compWidget.GetWidgetByIndex(i);
				ArrayPush(this.m_childDefaultColors, child.GetTintColor());
				child.SetTintColor(this.m_hoverColor);
				i += 1;
			};
		};
    }

    protected cb func OnLeaveCallback(evt: ref<inkPointerEvent>) -> Bool {
		let widget: ref<inkWidget> = this.GetRootWidget();
		widget.SetTintColor(this.m_defaultColor);
		let compWidget = widget as inkCompoundWidget;
		if IsDefined(compWidget) {
			let i = 0;
			while i < compWidget.GetNumChildren() {
				let child = compWidget.GetWidgetByIndex(i);
				child.SetTintColor(this.m_childDefaultColors[i]);
				i += 1;
			};
		};
    }

    //protected cb func OnPressCallback(evt: ref<inkPointerEvent>) -> Bool {
    //}
	//
    //protected cb func OnReleaseCallback(evt: ref<inkPointerEvent>) -> Bool {
    //}
}

@addField(BrowserGameController)
private let m_vehicleInsuranceSiteListener: ref<VehicleInsuranceSiteListener>;

@wrapMethod(BrowserGameController)
protected cb func OnInitialize() -> Bool {
    let ret: Bool = wrappedMethod();

    this.m_vehicleInsuranceSiteListener = new VehicleInsuranceSiteListener();
	this.m_vehicleInsuranceSiteListener.Init(this);

	return ret;
}

@wrapMethod(BrowserGameController)
protected cb func OnUninitialize() -> Bool {
    let ret: Bool = wrappedMethod();

	this.m_vehicleInsuranceSiteListener.Uninit();
    this.m_vehicleInsuranceSiteListener = null;

	return ret;
}
