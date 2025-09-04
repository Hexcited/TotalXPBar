-- Allow radio buttons within UIDropDownMenu.
hooksecurefunc("UIDropDownMenu_AddButton", function(ButtonInfo, Level)
	if ( UIDROPDOWNMENU_OPEN_MENU and not ButtonInfo.notCheckable ) then
		local ListFrame = _G["DropDownList"..(Level or 1)]
		local ListFrameIndex = (ListFrame) and ListFrame.numButtons or 1
		local Radio = _G[ListFrame:GetName().."Button"..ListFrameIndex.."Check"]

		if ( ButtonInfo.disabled or (ButtonInfo.isRadio and not ButtonInfo.checked) ) then
			Radio:SetDesaturated(true)
			Radio:SetAlpha(.25)
		else
			Radio:SetDesaturated(false)
			Radio:SetAlpha(1)
		end

		if ( ButtonInfo.isRadio ) then
			Radio:SetTexture("Interface\\Buttons\\UI-RadioButton")
			Radio:Show()

			if ( ButtonInfo.checked ) then
				Radio:SetTexCoord(.25, .5, 0, 1)
			else
				Radio:SetTexCoord(0, .25, 0, 1)
			end
		else
			Radio:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
			Radio:SetTexCoord(0, 1, 0, 1)
		end
	end
end)