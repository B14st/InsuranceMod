module VehicleInsurancePhone

import VehicleInsuranceMod.*
import PhoneExtension.DataStructures.*
import PhoneExtension.Classes.*
import PhoneExtension.System.*
import TANSTAAFLPart1Localizable.VehicleInsurancePhoneTexts
import TANSTAAFLPart1Configs.VehicleInsuranceSystemConfig
import TANSTAAFLPart1Configs.VehicleInsurancePhoneConfig

public static func VehicleInsuranceContactHash() -> Int32 = 45705702

//ugly but fast method to map dialog options
enum VehicleInsuranceOperation {
	GreetingLine = 0,
	ActiveSubStatusReport = 1,
	ExpiredSubStatusReport = 2,
	NoSubStatusReport = 3,
	SubRenewPaymentData = 4,
	DebtPaymentData = 5,
	FailureNoMoney = 6,
	SubRenewSuccess = 7,
	SubStatusRequest = 8,
	SubRenewRequest = 9,
	SubRenewYes = 10,
	PayDebtRequest = 11,
	PayDebtYes = 12,
	GenericCancel = 13,
	SubRenewPaymentDataWithDebt = 14,
	DebtPaymentSuccess = 15,
	SafeDrivingGift = 16,
	MAX = 17,
}

public class VehicleInsurancePhoneEventsListener extends PhoneEventsListener {
	private let m_player: wref<PlayerPuppet>;
	private let m_messengerController: wref<MessengerDialogViewController>;
	private let m_messageTree: array<CustomMessageEntry>;
	private let m_typingDelay : Float = 2.0;
	
	public func Init(player: ref<PlayerPuppet>) -> Void {
		this.m_player = player;
		ArrayClear(this.m_messageTree);
		ArrayResize(this.m_messageTree, EnumInt(VehicleInsuranceOperation.MAX));
		//bot messages
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.GreetingLine)].text = VehicleInsurancePhoneTexts.GreetingLine();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.GreetingLine)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.ActiveSubStatusReport)].text = VehicleInsurancePhoneTexts.ActiveSubStatusReport();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.ActiveSubStatusReport)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.ExpiredSubStatusReport)].text = VehicleInsurancePhoneTexts.ExpiredSubStatusReport();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.ExpiredSubStatusReport)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.NoSubStatusReport)].text = VehicleInsurancePhoneTexts.NoSubStatusReport();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.NoSubStatusReport)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewPaymentData)].text = VehicleInsurancePhoneTexts.SubRenewPaymentData();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewPaymentData)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewPaymentDataWithDebt)].text = VehicleInsurancePhoneTexts.SubRenewPaymentDataWithDebt();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewPaymentDataWithDebt)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.DebtPaymentData)].text = VehicleInsurancePhoneTexts.DebtPaymentData();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.DebtPaymentData)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.FailureNoMoney)].text = VehicleInsurancePhoneTexts.FailureNoMoney();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.FailureNoMoney)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewSuccess)].text = VehicleInsurancePhoneTexts.SubRenewSuccess();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewSuccess)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.DebtPaymentSuccess)].text = VehicleInsurancePhoneTexts.DebtPaymentSuccess();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.DebtPaymentSuccess)].type = MessageViewType.Received;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SafeDrivingGift)].text = VehicleInsurancePhoneTexts.SafeDrivingGift();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SafeDrivingGift)].type = MessageViewType.Received;
		//player answers
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubStatusRequest)].text = VehicleInsurancePhoneTexts.SubStatusRequest();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubStatusRequest)].type = MessageViewType.Sent;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewRequest)].text = VehicleInsurancePhoneTexts.SubRenewRequest();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewRequest)].type = MessageViewType.Sent;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewYes)].text = VehicleInsurancePhoneTexts.SubRenewYes();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.SubRenewYes)].type = MessageViewType.Sent;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.PayDebtRequest)].text = VehicleInsurancePhoneTexts.PayDebtRequest();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.PayDebtRequest)].type = MessageViewType.Sent;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.PayDebtYes)].text = VehicleInsurancePhoneTexts.PayDebtYes();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.PayDebtYes)].type = MessageViewType.Sent;
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.GenericCancel)].text = VehicleInsurancePhoneTexts.GenericCancel();
		this.m_messageTree[EnumInt(VehicleInsuranceOperation.GenericCancel)].type = MessageViewType.Sent;
	}

	//contact unique identifier
	public func GetContactHash() -> Int32 = VehicleInsuranceContactHash()
	
	//contact localized name to display
	public func GetContactLocalizedName() -> String = VehicleInsurancePhoneTexts.ContactName()
	
	public func GetContactData(isText: Bool) -> ref<ContactData> {
		let system = VehicleInsuranceSystem.GetInstance(this.m_player);
		
		let contactData: ref<ContactData>;
		contactData = new ContactData();
		contactData.hash = this.GetContactHash();
		contactData.localizedName = this.GetContactLocalizedName();
		contactData.contactId = s"VehicleInsuranceSystem";
		contactData.id = s"VISYS";
		contactData.avatarID = t"PhoneAvatars.Avatar_Unknown";
		contactData.questRelated = true;
		contactData.isCallable = false;
		if isText { //for text messenger
			contactData.type = MessengerContactType.SingleThread;
			//preview line for text messenger - using greeting line text
			contactData.lastMesssagePreview = this.m_messageTree[EnumInt(VehicleInsuranceOperation.GreetingLine)].text;
		} else { //for phone dialer
			contactData.type = MessengerContactType.Contact;
		};
		contactData.messagesCount = 1;
		contactData.unreadMessegeCount = 1;
		ArrayInsert(contactData.unreadMessages, 0, 1);
		contactData.hasMessages = true;
		contactData.playerIsLastSender = false;
		contactData.playerCanReply = true;
		
		return contactData;
	}
	
	public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
		//save controller reference for dialog updates
		this.m_messengerController = messengerController;
		let system = VehicleInsuranceSystem.GetInstance(this.m_player);
		if system.m_presentMessagePending {
			system.m_presentMessagePending = false;
			//safe driving gift message
			this.HandleGiftMessage();
			//there is a bug with the first click action not working if coming to sms view
			//from notification pop up: isPressed is false in OnAction callback
			//something else is consuming the "click" action before it's processed?
			//methods call sequence is a full spaghetti to trace...
			//note: might be related to holding F to exit the car?
		} else {
			//basic greeting line
			this.PushMessage(EnumInt(VehicleInsuranceOperation.GreetingLine), false);
		};
		//scrollbar position
		this.m_messengerController.m_scrollController.SetScrollPosition(1.00);
		return true;
	}
	
	public func ActivateReply(messageID: Int32) -> Void {
		this.m_messengerController.ClearRepliesCustom(); //cleanup replies
		this.PushMessage(messageID, false); //last reply becomes last message
		//handle reply actions and build new messages and replies
		if messageID == EnumInt(VehicleInsuranceOperation.SubStatusRequest) {
			this.HandleSubStatusRequest();
			return;
		};
		if messageID == EnumInt(VehicleInsuranceOperation.SubRenewRequest) {
			this.HandleSubRenewRequest();
			return;
		};
		if messageID == EnumInt(VehicleInsuranceOperation.SubRenewYes) {
			this.HandleSubRenew();
			return;
		};
		if messageID == EnumInt(VehicleInsuranceOperation.PayDebtRequest) {
			this.HandlePayDebtRequest();
			return;
		};
		if messageID == EnumInt(VehicleInsuranceOperation.PayDebtYes) {
			this.HandlePayDebt();
			return;
		};
		if messageID == EnumInt(VehicleInsuranceOperation.GenericCancel) {
			this.HandleGenericCancel();
			return;
		};
	}
	
	// handle gift message
	private func HandleGiftMessage() -> Void {
		this.m_giftMoney = VehicleInsuranceSystemConfig.SafeDriveGiftMoney();
		let tSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
		tSystem.GiveItem(this.m_player, MarketSystem.Money(), this.m_giftMoney);
		this.PushMessage(EnumInt(VehicleInsuranceOperation.SafeDrivingGift), false);
	}
	
	// handle vehicle insurance system requests
	
	private func HandleSubStatusRequest() -> Void {
		//set up and withdraw request price
		this.m_lastOpCost = VehicleInsurancePhoneConfig.BaseOperationCost();
		this.WithdrawPayment(this.m_lastOpCost);
		//check subscription status
		let system = VehicleInsuranceSystem.GetInstance(this.m_messengerController.m_playerObject);
		let subState = system.GetSubscriptionState();
		let hasSub = (subState.level > 0);
		let hadSub = (subState.lastKnownLevel > 0);
		//set up debt value
		this.m_debt = system.GetPlayerVehicleInsuranceDebt();
		//handle sub status
		if hasSub { //active
			this.m_duration = system.GetSubscriptionDurationLeft();
			this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.ActiveSubStatusReport));
			return;
		};
		if hadSub { //expired
			this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.ExpiredSubStatusReport));
			return;
		};
		//never had a sub before
		this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.NoSubStatusReport));
	}
	
	private func HandleSubRenewRequest() -> Void {
		let system = VehicleInsuranceSystem.GetInstance(this.m_messengerController.m_playerObject);
		let subState = system.GetSubscriptionState();
		let debt = system.GetPlayerVehicleInsuranceDebt();
		let hadSub = (subState.lastKnownLevel > 0);
		let hasDebt = (debt > 0);
		let subCost = system.CalcSubscriptionCost(subState.lastKnownLevel);
		let serviceCost = RoundMath(Cast<Float>(subCost + debt) * VehicleInsurancePhoneConfig.ServicePercentage() / 100.0) + VehicleInsurancePhoneConfig.BaseOperationCost();
		let totalCost = subCost + debt + serviceCost;
		
		if hadSub { //should always be true if got here, but just in case
			this.m_subCost = subCost;
			this.m_lastOpCost = serviceCost;
			this.m_totalCost = totalCost;
			if hasDebt {
				this.m_debt = debt;
				this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.SubRenewPaymentDataWithDebt));
			} else {
				this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.SubRenewPaymentData));
			};
			return;
		};
		//shouldn't get here, but just in case: if no prev sub, just output the sub status
		this.HandleSubStatusRequest();
	}
	
	private func HandleSubRenew() -> Void {
		let system = VehicleInsuranceSystem.GetInstance(this.m_messengerController.m_playerObject);
		let subState = system.GetSubscriptionState();
		//this.m_totalCost should have final price set since HandleSubRenewRequest call
		let hasFunds = system.PlayerHasEnoughMoney(this.m_totalCost);
		
		if !hasFunds { //has no money
			this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.FailureNoMoney));
			return;
		};
		//has money for resubbing: withdraw payment
		system.PlayerWithdrawPayment(this.m_totalCost);
		//renew subscription
		system.RenewSubscription(subState.lastKnownLevel);
		//it's either a resub or a resub with debt, in any case it means player did cover their debt value, so clearing it up
		system.ClearVehicleInsuranceDebt();
		this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.SubRenewSuccess));
	}
	
	private func HandlePayDebtRequest() -> Void {
		let system = VehicleInsuranceSystem.GetInstance(this.m_messengerController.m_playerObject);
		let debt = system.GetPlayerVehicleInsuranceDebt();
		let hasDebt = (debt > 0);
		let serviceCost = RoundMath(Cast<Float>(debt) * VehicleInsurancePhoneConfig.ServicePercentage() / 100.0) + VehicleInsurancePhoneConfig.BaseOperationCost();
		let totalCost = debt + serviceCost;
		
		if hasDebt { //should always be true if got here, but just in case
			this.m_debt = debt;
			this.m_lastOpCost = serviceCost;
			this.m_totalCost = totalCost;
			this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.DebtPaymentData));
			return;
		};
		//shouldn't get here, but just in case: if no prev sub, just output the sub status
		this.HandleSubStatusRequest();
	}
	
	private func HandlePayDebt() -> Void {
		let system = VehicleInsuranceSystem.GetInstance(this.m_messengerController.m_playerObject);
		//this.m_totalCost should have final price set since HandlePayDebtRequest call
		let hasFunds = system.PlayerHasEnoughMoney(this.m_totalCost);
		
		if !hasFunds { //has no money
			this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.FailureNoMoney));
			return;
		};
		//has money for paying the debt: withdraw payment
		system.PlayerWithdrawPayment(this.m_totalCost);
		//clear the debt
		system.ClearVehicleInsuranceDebt();
		this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.DebtPaymentSuccess));
	}
	
	private func HandleGenericCancel() -> Void {
		//just push the greeting line
		this.TryPushDelayedMessage(this.m_typingDelay, EnumInt(VehicleInsuranceOperation.GreetingLine));
	}
	
	//handle payments
	
	private func WithdrawPayment(buyPrice: Int32) -> Int32 {
		let system = VehicleInsuranceSystem.GetInstance(this.m_messengerController.m_playerObject);
		return system.PlayerWithdrawPayment(buyPrice);
	}
	
	//fill in costs (yeah, not the best way, but oh well...)
	
	private let m_lastOpCost: Int32;
	private let m_lastMoneyRequired: Int32;
	private let m_subCost: Int32;
	private let m_totalCost: Int32;
	private let m_duration: Float;
	private let m_debt: Int32;
	private let m_giftMoney: Int32;
	
	private func GetTextWithParams(index: Int32) -> String {
		let msgText = this.m_messageTree[index].text;
		if index == EnumInt(VehicleInsuranceOperation.ActiveSubStatusReport) {
			let durationTxT = s"< 1";
			if (this.m_duration > 0.9) {
				durationTxT = ToString(RoundMath(this.m_duration));
			};
			msgText = StrReplace(msgText, "{DURATION}", durationTxT);
			msgText = StrReplace(msgText, "{DEBT}", ToString(this.m_debt));
			msgText = StrReplace(msgText, "{COST}", ToString(this.m_lastOpCost));
			return msgText;
		};
		if index == EnumInt(VehicleInsuranceOperation.ExpiredSubStatusReport) {
			msgText = StrReplace(msgText, "{DEBT}", ToString(this.m_debt));
			msgText = StrReplace(msgText, "{COST}", ToString(this.m_lastOpCost));
			return msgText;
		};
		if index == EnumInt(VehicleInsuranceOperation.NoSubStatusReport) {
			msgText = StrReplace(msgText, "{DEBT}", ToString(this.m_debt));
			msgText = StrReplace(msgText, "{COST}", ToString(this.m_lastOpCost));
			return msgText;
		};
		if index == EnumInt(VehicleInsuranceOperation.SubRenewPaymentData) {
			msgText = StrReplace(msgText, "{TOTALCOST}", ToString(this.m_totalCost));
			msgText = StrReplace(msgText, "{SUBCOST}", ToString(this.m_subCost));
			msgText = StrReplace(msgText, "{COST}", ToString(this.m_lastOpCost));
			return msgText;
		};
		if index == EnumInt(VehicleInsuranceOperation.SubRenewPaymentDataWithDebt) {
			msgText = StrReplace(msgText, "{TOTALCOST}", ToString(this.m_totalCost));
			msgText = StrReplace(msgText, "{SUBCOST}", ToString(this.m_subCost));
			msgText = StrReplace(msgText, "{DEBT}", ToString(this.m_debt));
			msgText = StrReplace(msgText, "{COST}", ToString(this.m_lastOpCost));
			return msgText;
		};
		if index == EnumInt(VehicleInsuranceOperation.DebtPaymentData) {
			msgText = StrReplace(msgText, "{TOTALCOST}", ToString(this.m_totalCost));
			msgText = StrReplace(msgText, "{DEBT}", ToString(this.m_debt));
			msgText = StrReplace(msgText, "{COST}", ToString(this.m_lastOpCost));
			return msgText;
		};
		if index == EnumInt(VehicleInsuranceOperation.SafeDrivingGift) {
			msgText = StrReplace(msgText, "{GIFT}", ToString(this.m_giftMoney));
			return msgText;
		};
		return msgText;
	}
	
	//push messages and decide on replies based on messages
	
	private func PushMessage(index: Int32, playSound: Bool) {
		let system = VehicleInsuranceSystem.GetInstance(this.m_messengerController.m_playerObject);
		let subState = system.GetSubscriptionState();
		let debt = system.GetPlayerVehicleInsuranceDebt();
		let hadSub = (subState.lastKnownLevel > 0);
		let hasDebt = (debt > 0);
		this.m_messengerController.PushMessageCustom(this.GetTextWithParams(index), this.m_messageTree[index].type, this.GetContactLocalizedName(), playSound);
		if index == EnumInt(VehicleInsuranceOperation.GreetingLine) {
			this.PushReply(EnumInt(VehicleInsuranceOperation.SubStatusRequest), true);
			return;
		};
		if index == EnumInt(VehicleInsuranceOperation.ActiveSubStatusReport) ||
			index == EnumInt(VehicleInsuranceOperation.ExpiredSubStatusReport) {
			this.PushReply(EnumInt(VehicleInsuranceOperation.SubRenewRequest), true);
			if hasDebt {
				this.PushReply(EnumInt(VehicleInsuranceOperation.PayDebtRequest), false);
			};
			return;
		};
		if index == EnumInt(VehicleInsuranceOperation.NoSubStatusReport) {
			if hasDebt {
				this.PushReply(EnumInt(VehicleInsuranceOperation.PayDebtRequest), true);
			};
			return;
		};
		if index == EnumInt(VehicleInsuranceOperation.SubRenewPaymentData) ||
			index == EnumInt(VehicleInsuranceOperation.SubRenewPaymentDataWithDebt) {
			this.PushReply(EnumInt(VehicleInsuranceOperation.SubRenewYes), true);
			this.PushReply(EnumInt(VehicleInsuranceOperation.GenericCancel), false);
			return;
		};
		if index == EnumInt(VehicleInsuranceOperation.DebtPaymentData) {
			this.PushReply(EnumInt(VehicleInsuranceOperation.PayDebtYes), true);
			this.PushReply(EnumInt(VehicleInsuranceOperation.GenericCancel), false);
			return;
		};
	}
	
	private func PushReply(index: Int32, isSelected: Bool) {
		this.m_messengerController.PushReplyCustom(index, this.m_messageTree[index].text, this.m_messageTree[index].quest, isSelected, this.m_messengerController.m_hasFocus);
	}
	
	//delayed replies with typing animation
	
	private func TryPushDelayedMessage(delay: Float, messageID: Int32) -> Void {
		if !this.PushDelayedMessage(delay, messageID) {
			this.PushMessage(messageID, true);
		};
	}
	
	private func PushDelayedMessage(delay: Float, messageID: Int32) -> Bool {
		if IsDefined(this.m_messengerController.m_delaySystem) && this.m_typingDelay > 0.0 {
			this.m_messengerController.PlayDotsAnimationCustom(this.GetContactLocalizedName());
			this.AddTypingDelay(this.m_messengerController.m_delaySystem, delay, messageID);
			return true;
		} else {
			return false;
		};
	}
	
	private func OnDelayedTypingEnd(messageID: Int32) -> Void {
		this.m_messengerController.StopDotsAnimation();
		this.PushMessage(messageID, true);
	}
}

//add new contact to phone system on initialize

@addField(NewHudPhoneGameController)
private let m_vehicleInsuranceContact: ref<VehicleInsurancePhoneEventsListener>;

@wrapMethod(NewHudPhoneGameController)
protected cb func OnInitialize() -> Bool {
	let ret: Bool = wrappedMethod();
	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
	if !IsDefined(this.m_vehicleInsuranceContact) {
		this.m_vehicleInsuranceContact = new VehicleInsurancePhoneEventsListener();
		this.m_vehicleInsuranceContact.Init(this.GetPlayerControlledObject() as PlayerPuppet);
	};
	syst.Register(this.m_vehicleInsuranceContact);
	return ret;
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnUninitialize() -> Bool {
	let ret: Bool = wrappedMethod();
	let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
	syst.Unregister(this.m_vehicleInsuranceContact);
	return ret;
}

//testing stuff
//public class TestGlobalInputListener {
//	private let m_player: wref<PlayerPuppet>;
//	
//	public func Init(player: ref<PlayerPuppet>) -> Void {
//		FTLog("TestGlobalInputListener.Init");
//		this.m_player = player;
//	}
//	
//	public func Uninit() -> Void {
//		FTLog("TestGlobalInputListener.Uninit");
//		this.m_player = null;
//	}
//	
//	protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
//		if ListenerAction.IsAction(action, n"restore_default_settings") && ListenerAction.IsButtonJustReleased(action) {
//			FTLog("TestGlobalInputListener.OnAction");
//			let syst = PhoneExtensionSystem.GetInstance(this.m_player);
//			syst.NotifyNewMessageCustom(VehicleInsuranceContactHash(), VehicleInsurancePhoneTexts.ContactName(), VehicleInsurancePhoneTexts.SubExpiredNotification());
//		};
//	}
//}
//
//@addField(PlayerPuppet)
//private let m_testInput: ref<TestGlobalInputListener>;
//
//@wrapMethod(PlayerPuppet)
//protected cb func OnGameAttached() -> Bool {
//    wrappedMethod();
//
//    this.m_testInput = new TestGlobalInputListener();
//	this.m_testInput.Init(this);
//    this.RegisterInputListener(this.m_testInput);
//}
//
//@wrapMethod(PlayerPuppet)
//protected cb func OnDetach() -> Bool {
//    wrappedMethod();
//
//    this.UnregisterInputListener(this.m_testInput);
//	this.m_testInput.Uninit();
//	this.m_testInput = null;
//}
