--おとり人形
function c7165085.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7165085.target)
	e1:SetOperation(c7165085.activate)
	c:RegisterEffect(e1)
end
function c7165085.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
function c7165085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c7165085.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c7165085.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,c7165085.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
end
function c7165085.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then return end
	Duel.ConfirmCards(tp,tc)
	if tc:IsType(TYPE_TRAP) then
		local te=tc:GetActivateEffect()
		local tep=tc:GetControler()
		if not te then
			Duel.Destroy(tc,REASON_EFFECT)
		else
			local condition=te:GetCondition()
			local cost=te:GetCost()
			local target=te:GetTarget()
			local operation=te:GetOperation()
			if te:GetCode()==EVENT_FREE_CHAIN and not tc:IsStatus(STATUS_SET_TURN)
				and (not condition or condition(te,tep,eg,ep,ev,re,r,rp))
				and (not cost or cost(te,tep,eg,ep,ev,re,r,rp,0))
				and (not target or target(te,tep,eg,ep,ev,re,r,rp,0)) then
				Duel.ClearTargetCard()
				e:SetProperty(te:GetProperty())
				Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
				Duel.Hint(HINT_CARD,1,tc:GetOriginalCode())
				Duel.ChangePosition(tc,POS_FACEUP)
				tc:CancelToGrave(false)
				tc:CreateEffectRelation(te)
				if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
				if target then target(te,tep,eg,ep,ev,re,r,rp,1) end
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				local tg=g:GetFirst()
				while tg do
					tg:CreateEffectRelation(te)
					tg=g:GetNext()
				end
				operation(te,tep,eg,ep,ev,re,r,rp)
				tc:ReleaseEffectRelation(te)
				tg=g:GetFirst()
				while tg do
					tg:ReleaseEffectRelation(te)
					tg=g:GetNext()
				end
			else
				Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:CancelToGrave()
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
	end
end
