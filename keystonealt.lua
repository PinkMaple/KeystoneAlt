

function WeeklyReset() 
    -- Work in progress

    if KeystoneAltDB.debug then
        print("<KeystoneAlt>: Weekly reset!")
    end

    for i = 1, #KeystoneAltDB.characters do
        KeystoneAltDB.characters[i].keystone_level = 0;
         if KeystoneAltDB.characters[i].weekly_activities ~= nil and #KeystoneAltDB.characters[i].weekly_activities > 0 then
            for j = 1, #KeystoneAltDB.characters[i].weekly_activities do
                if KeystoneAltDB.characters[i].weekly_activities[j].progress > 0 then
                    KeystoneAltDB.characters[i].has_vault = true;
                end
            end
         end
    end

end

function UpdatePlayerKeystone(player_name)

    if KeystoneAltDB.debug then
        print("<KeystoneAlt>: Updating keystone");
    end 

    local class_name, class_filename, classID = UnitClass("player");

    local calender_time = C_DateAndTime.GetCurrentCalendarTime();

    local keystone_map_id = C_MythicPlus.GetOwnedKeystoneMapID();
    local keystone_level = C_MythicPlus.GetOwnedKeystoneLevel();
    local keystone_map_name = nil
    if keystone_map_id ~= nil then 
        keystone_map_name = GetRealZoneText(keystone_map_id);
    end

    local has_vault = C_WeeklyRewards.HasAvailableRewards();
    local weekly_activities = C_WeeklyRewards.GetActivities(); -- TODO() Investigate what is here and how best parse it for each character!;

    --for i_a = 1, #weekly_activities do 
        --print(weekly_activities[i_a].index .. ": " ..  weekly_activities[i_a].type .. "(type), " ..weekly_activities[i_a].threshold .. "(threshold), " .. weekly_activities[i_a].progress .. "(progress), " .. weekly_activities[i_a].level .. "level")
    --end 

    for i = 1, #KeystoneAltDB.characters do
        if KeystoneAltDB.characters[i].name == player_name then

            KeystoneAltDB.characters[i].last_update = calender_time;

            KeystoneAltDB.characters[i].classID = KeystoneAltDB.characters[i].classID or classID or 0;
            KeystoneAltDB.characters[i].class_name = KeystoneAltDB.characters[i].class_name or class_name or "";
            KeystoneAltDB.characters[i].class_filename = KeystoneAltDB.characters[i].class_filename or class_filename or "";

            KeystoneAltDB.characters[i].keystone_map_id = keystone_map_id or KeystoneAltDB.characters[i].keystone_map_id or 0;
            KeystoneAltDB.characters[i].keystone_level = keystone_level or KeystoneAltDB.characters[i].keystone_level or 0;
            KeystoneAltDB.characters[i].keystone_map_name = keystone_map_name or KeystoneAltDB.characters[i].keystone_map_name or "";

            KeystoneAltDB.characters[i].weekly_activities = weekly_activities;
            KeystoneAltDB.characters[i].has_vault = has_vault or false;

            
            return;
        end
    end
    
    table.insert(KeystoneAltDB.characters, {
        name = player_name,
        last_update = calender_time,

        classID = classID or 0,
        class_name = class_name or "",
        class_filename = class_filename or "",

        keystone_map_id = keystone_map_id or 0,
        keystone_level = keystone_level or 0,
        keystone_map_name = keystone_map_name or "",
        has_vault = has_vault or false,
        weekly_activities = weekly_activities,
    })
end




local keystoneAltFrame = CreateFrame("Frame", "KeystoneAltFrame", UIParent, "BasicFrameTemplateWithInset");
keystoneAltFrame:SetSize(700, 400);
keystoneAltFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
keystoneAltFrame.TitleBg:SetHeight(30);
keystoneAltFrame.title = keystoneAltFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
keystoneAltFrame.title:SetPoint("TOPLEFT", keystoneAltFrame.TitleBg, "TOPLEFT", 5, -3);
keystoneAltFrame.title:SetText("KeystoneAlt");
keystoneAltFrame:EnableMouse(true);
keystoneAltFrame:SetMovable(true);
keystoneAltFrame:SetToplevel(true);
keystoneAltFrame:RegisterForDrag("LeftButton");
keystoneAltFrame:RegisterEvent("ADDON_LOADED");
keystoneAltFrame:RegisterEvent("PLAYER_LOGOUT");
keystoneAltFrame:RegisterEvent("BAG_UPDATE");
keystoneAltFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end);
keystoneAltFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end);

local player_name = UnitName("player");

keystoneAltFrame:SetScript("OnEvent", function(self, event, arg1) 
    if event == "ADDON_LOADED" and arg1  == "KeystoneAlt" then
         if KeystoneAltDB == nil then
            KeystoneAltDB = {}
        end

        if KeystoneAltDB.characters == nil then
            KeystoneAltDB.characters = {}
        end

        if KeystoneAltDB.version == nil then
            KeystoneAltDB.version = 0;
        end
        if KeystoneAltDB.debug == nil then 
            KeystoneAltDB.debug = false;
        end

        local weekly_reset_timer = C_DateAndTime.GetWeeklyResetStartTime();

        if KeystoneAltDB.weekly_reset_timer == nil then
            KeystoneAltDB.weekly_reset_timer = weekly_reset_timer;
        elseif KeystoneAltDB.weekly_reset_timer < weekly_reset_timer then
            WeeklyReset();
            KeystoneAltDB.weekly_reset_timer = weekly_reset_timer;
        end

        

        --UpdatePlayerKeystone(player_name);

        for i = 1, #KeystoneAltDB.characters do 

            local rPerc, gPerc, bPerc, argbHex = GetClassColor(KeystoneAltDB.characters[i].class_filename);
            local class_color_hex = "ffffffff";

            if argbHex ~= nil then
                class_color_hex = argbHex
            end

            local y = -20 - i * 18;

            if i % 2 == 0 then
                keystoneAltFrame[i .. "_line"] = keystoneAltFrame:CreateTexture();
                keystoneAltFrame[i .. "_line"]:SetPoint("TOPLEFT", keystoneAltFrame, "TOPLEFT", 8, y+2);
                keystoneAltFrame[i .. "_line"]:SetSize(700 - 16, 18);
                keystoneAltFrame[i .. "_line"]:SetColorTexture(1,1,0.8,0.1);
            end 

            local classname = KeystoneAltDB.characters[i].class_name or "";
            classname = string.gsub(classname, " ", "");

            keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_class_icon"] = keystoneAltFrame:CreateTexture();
            keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_class_icon"]:SetPoint("TOPLEFT", keystoneAltFrame, "TOPLEFT", 15, y);
            keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_class_icon"]:SetTexture("interface/icons/classicon_" .. string.lower(classname));
            --keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_class_icon"]:SetTexture(625999);
            keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_class_icon"]:SetSize(16, 16);

            keystoneAltFrame[KeystoneAltDB.characters[i].name] = keystoneAltFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            keystoneAltFrame[KeystoneAltDB.characters[i].name]:SetPoint("TOPLEFT", keystoneAltFrame, "TOPLEFT", 35, y);
            
            keystoneAltFrame[KeystoneAltDB.characters[i].name]:SetText("|c" .. class_color_hex .. KeystoneAltDB.characters[i].name);

            keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_keystone"] = keystoneAltFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_keystone"]:SetPoint("TOPLEFT", keystoneAltFrame, "TOPLEFT", 145, y);
            --keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_keystone"]:SetText(KeystoneAltDB.characters[i].keystone_map_name .. " +" .. KeystoneAltDB.characters[i].keystone_level)

            keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_vault"] = keystoneAltFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_vault"]:SetPoint("TOPLEFT", keystoneAltFrame, "TOPLEFT", 405, y);

            if KeystoneAltDB.debug then
                print("<KeystoneAlt>: Successfully loaded!");
            end

        end
    elseif event == "PLAYER_LOGOUT" then
        --UpdatePlayerKeystone(player_name);
    elseif event == "BAG_UPDATE" then
        UpdatePlayerKeystone(player_name);
    end
end)



keystoneAltFrame:Hide()




SLASH_KEYSTONEALT1 = '/ksa'
function SlashCmdList.KEYSTONEALT(msg, editbox)
    if msg == 'reload' then
        UpdatePlayerKeystone(player_name);
    elseif msg == "clear" then
        KeystoneAltDB = {}
        KeystoneAltDB.characters = {}
        KeystoneAltDB.version = 0;
        KeystoneAltDB.weekly_reset_timer = C_DateAndTime.GetWeeklyResetStartTime();

        print("KeystoneAlt data cleared (reload required)");
    elseif msg == "debug" then
        KeystoneAltDB.debug = not KeystoneAltDB.debug;
        if KeystoneAltDB.debug then
            print("<KeystoneAlt>: Debug on");
        else
            print("<KeystoneAlt>: Debug off");
        end
    else
        UpdatePlayerKeystone(player_name);

        for i = 1, #KeystoneAltDB.characters do
            --local classname = KeystoneAltDB.characters[i].class_name or "";
            if KeystoneAltDB.characters[i].keystone_level == nil or KeystoneAltDB.characters[i].keystone_level == 0 then
                local text_color = "FF7A7A7A";
                keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_keystone"]:SetText("|c".. text_color .."No keystone")
            else 
                keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_keystone"]:SetText(KeystoneAltDB.characters[i].keystone_map_name .. " +" .. KeystoneAltDB.characters[i].keystone_level)
            end

            if KeystoneAltDB.characters[i].weekly_activities ~= nil and #KeystoneAltDB.characters[i].weekly_activities > 0 then

                --print(#KeystoneAltDB.characters[i].weekly_activities)

                local vault_text = ""
                
                if KeystoneAltDB.characters[i].has_vault then
                    vault_text = "Has available vault!";
                else
                    vault_text = "Vault (";
                    for j = 1, #KeystoneAltDB.characters[i].weekly_activities do
                        if KeystoneAltDB.characters[i].weekly_activities[j].type == 1 then
                            if KeystoneAltDB.characters[i].weekly_activities[j].progress == 0 then
                                local vault_color = "FF7A7A7A";
                                vault_text = "|c" .. vault_color .. vault_text;
                                break;
                            end
                        end
                    end

                    local not_first = false;
                    for j = 1, #KeystoneAltDB.characters[i].weekly_activities do
                        if KeystoneAltDB.characters[i].weekly_activities[j].type == 1 then
                            if not_first then
                                vault_text = vault_text .. ",";
                            end
                            if KeystoneAltDB.characters[i].weekly_activities[j].progress >= KeystoneAltDB.characters[i].weekly_activities[j].threshold then
                                if KeystoneAltDB.characters[i].weekly_activities[j].level == 0 then vault_text = vault_text .. " m0";
                                else vault_text = vault_text .. " +" .. KeystoneAltDB.characters[i].weekly_activities[j].level; end
                            else
                                vault_text = vault_text .. " " .. KeystoneAltDB.characters[i].weekly_activities[j].progress .. "/" .. KeystoneAltDB.characters[i].weekly_activities[j].threshold;
                            end
                            not_first = true;
                        end
                    end
                    vault_text = vault_text .. ")";
                end
                
                --local vault_text = "+" .. KeystoneAltDB.characters[i].weekly_activities[1].level .. ", +" .. KeystoneAltDB.characters[i].weekly_activities[2].level .. ", +".. KeystoneAltDB.characters[i].weekly_activities[3].level;
                keystoneAltFrame[KeystoneAltDB.characters[i].name .. "_vault"]:SetText(vault_text);

            end

        end

        keystoneAltFrame:Show();
    end
    --print("Hello World")
end


