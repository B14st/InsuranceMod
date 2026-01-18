module TANSTAAFLPart1Messages
import TANSTAAFLPart1Configs.TANSTAAFLMSGConfig
import TANSTAAFLPart1Localizable.TANSTAAFLMSGTexts

public class TANSTAAFLMSG {
	public static func ShowVehicleBumpMessage(gi: GameInstance, moneyPaid: Int32, debtAcquired: Int32) {
		let onscreenMsg: SimpleScreenMessage;
	
		onscreenMsg.isShown = true;
		onscreenMsg.duration = TANSTAAFLMSGConfig.MessageDuration();
		onscreenMsg.type = SimpleMessageType.Money;
		
		if moneyPaid > 0 {
			onscreenMsg.message = TANSTAAFLMSGTexts.VehicleBumpPaidMessage() + ToString(moneyPaid);
		} else {
			onscreenMsg.message = TANSTAAFLMSGTexts.VehicleBumpNoMoneyMessage();
		};
		
		if debtAcquired > 0 {
			onscreenMsg.duration += TANSTAAFLMSGConfig.MessageDuration();
			onscreenMsg.message += "\n" + TANSTAAFLMSGTexts.VehInsuranceDebtAcquiredMessage() + ToString(debtAcquired);
		};
	
		GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(onscreenMsg), true);
	}
	
	public static func ShowFastTravelPaidMessage(gi: GameInstance, moneyPaid: Int32) {
		let onscreenMsg: SimpleScreenMessage;
	
		onscreenMsg.isShown = true;
		onscreenMsg.duration = TANSTAAFLMSGConfig.MessageDuration();
		onscreenMsg.message = TANSTAAFLMSGTexts.FastTravelPaidMessage() + ToString(moneyPaid);
		onscreenMsg.type = SimpleMessageType.Money;
	
		GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(onscreenMsg), true);
	}
	
	public static func ShowVehicleSummonedMessage(gi: GameInstance, moneyPaid: Int32, debtPaid: Int32, debtAcquired: Int32, repairPaid: Bool) {
		let onscreenMsg: SimpleScreenMessage;
	
		onscreenMsg.isShown = true;
		onscreenMsg.duration = TANSTAAFLMSGConfig.MessageDuration();
		onscreenMsg.type = SimpleMessageType.Money;
		
		if moneyPaid > 0 {
			onscreenMsg.message = TANSTAAFLMSGTexts.VehDispatchedPaidMessage() + ToString(moneyPaid);
		} else {
			onscreenMsg.message = TANSTAAFLMSGTexts.VehDispatchedFreeMessage();
		};
		
		if repairPaid {
			onscreenMsg.duration += TANSTAAFLMSGConfig.MessageDuration();
			onscreenMsg.message += "\n" + TANSTAAFLMSGTexts.VehInsuranceIncludedRepairsMessage();
		};
		
		if debtPaid > 0 {
			onscreenMsg.duration += TANSTAAFLMSGConfig.MessageDuration();
			onscreenMsg.message += "\n" + TANSTAAFLMSGTexts.VehInsuranceDebtPaidMessage() + ToString(debtPaid);
		};
		
		if debtAcquired > 0 {
			onscreenMsg.duration += TANSTAAFLMSGConfig.MessageDuration();
			onscreenMsg.message += "\n" + TANSTAAFLMSGTexts.VehInsuranceDebtAcquiredMessage() + ToString(debtAcquired);
		};
	
		GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(onscreenMsg), true);
	}
	
	public static func ShowVehicleDebtPaidMessage(gi: GameInstance, moneyAmt: Int32) {
		let onscreenMsg: SimpleScreenMessage;
	
		onscreenMsg.isShown = true;
		onscreenMsg.duration = TANSTAAFLMSGConfig.MessageDuration();
		onscreenMsg.message = TANSTAAFLMSGTexts.VehInsuranceDebtPaidMessage() + ToString(moneyAmt);
		onscreenMsg.type = SimpleMessageType.Money;
	
		GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(onscreenMsg), true);
	}
	
	public static func ShowVehicleDebtMessage(gi: GameInstance, moneyAmt: Int32) {
		let onscreenMsg: SimpleScreenMessage;
	
		onscreenMsg.isShown = true;
		onscreenMsg.duration = TANSTAAFLMSGConfig.MessageDuration() * 2.0; //two lines
		onscreenMsg.message = TANSTAAFLMSGTexts.VehInsuranceDebtMessage() + ToString(moneyAmt) + "\n" + TANSTAAFLMSGTexts.VehInsurancePayYorDebtMessage();
		onscreenMsg.type = SimpleMessageType.Money;
	
		GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(onscreenMsg), true);
	}
	
	public static func ShowUnableToSummonMessage(gi: GameInstance, debtAmt: Int32) {
		let onscreenMsg: SimpleScreenMessage;
	
		onscreenMsg.isShown = true;
		onscreenMsg.duration = TANSTAAFLMSGConfig.MessageDuration();
		onscreenMsg.message = TANSTAAFLMSGTexts.VehUnableToDispatchMessage();
		onscreenMsg.type = SimpleMessageType.Money;
		
		if debtAmt > 0 {
			onscreenMsg.duration += TANSTAAFLMSGConfig.MessageDuration() * 2.0; //two lines
			onscreenMsg.message += "\n" + TANSTAAFLMSGTexts.VehInsuranceDebtMessage() + ToString(debtAmt) + "\n" + TANSTAAFLMSGTexts.VehInsurancePayYorDebtMessage();
		};
	
		GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(onscreenMsg), true);
	}
}
