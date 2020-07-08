-------------------------
--- BadgerStockMarket ---
-------------------------

-- CODE --
--[[
CREATE TABLE IF NOT EXISTS user_stock_data (
	id INTEGER(11) AUTO_INCREMENT PRIMARY KEY, 
	identifier VARCHAR(50), 
	stockAbbrev VARCHAR(16),
	ownCount INTEGER(16)
);

CREATE TABLE IF NOT EXISTS stock_purchase_data (
	id INTEGER(11) AUTO_INCREMENT PRIMARY KEY,
	identifier VARCHAR(50),
	purchasedPrice INTEGER(32),
	stockAbbrev VARCHAR(16),
	isOwned BIT(1)
);
]]--
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
RegisterNetEvent("BadgerStocks:Buy")
AddEventHandler("BadgerStocks:Buy", function(data, cb)
    -- This is the buy stock thing 
    local src = source;
    local xPlayer = ESX.GetPlayerFromId(src);
    local stockAbbrev = data.stock;
    local costPer = data.cost;
    if (xPlayer.getMoney() >= costPer) then 
        -- They can buy it 
        if (GetStockCount(src) < GetAllowedCount(src)) then 
            -- They can buy another one of it 
            BuyStock(src, stockAbbrev, 1, costPer);
            xPlayer.setMoney( (xPlayer.getMoney() - costPer) );
            TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='buy'>SUCCESS: Purchased a stock of " .. stockAbbrev .. "</span>");
            TriggerEvent("BadgerStocks:SetupDataID", src);
            --cb('ok');
        else 
            -- They already have the max number of stocks they are allowed 
            TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='error'>ERROR: You already have the max number of stocks you " .. 
                "are allowed to own...</span>");
        end
    else 
        -- They do not have enough money to afford this 
        TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='error'>ERROR: You do not have enough money to afford this...</span>");
    end
end)
function GetAllowedCount(src) 
    local curCount = 0;
    for key, value in pairs(Config.maxStocksOwned) do 
        if value > curCount then 
            -- Check if they have access 
            if IsPlayerAceAllowed(src, key) then 
                curCount = value;
            end
        end
    end
    return curCount;
end
RegisterNetEvent("BadgerStocks:SetupData")
AddEventHandler("BadgerStocks:SetupData", function()
    local src = source;
    local data = GetStockPurchaseData(src);
    TriggerClientEvent("BadgerStocks:SendData", src, data);
end)
RegisterNetEvent("BadgerStocks:SetupDataID")
AddEventHandler("BadgerStocks:SetupDataID", function(src)
    local data = GetStockPurchaseData(src);
    TriggerClientEvent("BadgerStocks:SendData", src, data);
end)
RegisterNetEvent("BadgerStocks:Sell")
AddEventHandler("BadgerStocks:Sell", function(data, cb)
    -- This is the sell stock thing 
    local src = source;
    local xPlayer = ESX.GetPlayerFromId(src);
    local stockAbbrev = data.stock;
    local costPer = data.cost;
    if HasStockOwned(src, stockAbbrev, 1) then 
        -- They own it, sell it 
        SellStock(src, stockAbbrev, 1, costPer);
        xPlayer.setMoney(xPlayer.getMoney() + costPer);
        TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='sell'>SUCCESS: Sold a stock of " .. stockAbbrev .. "</span>");
        TriggerEvent("BadgerStocks:SetupDataID", src);
        --cb('ok');
    else 
        -- They do not own this stock 
        TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='error'>ERROR: You do not own any of this stock...</span>");
    end 
end)
MySQL.ready(function()
    function BuyStock(src, stockAbbrev, amount, pricePer)
        local ids = ExtractIdentifiers(src);
        local steam = ids.steam;
        if (HasStockOwned(src, stockAbbrev, 1)) then 
            -- They own, increase their own count
            local  sql = "UPDATE `user_stock_data` SET ownCount = (ownCount + @amt) WHERE `identifier` = @steam AND `stockAbbrev` = @stock";
            MySQL.Async.execute(sql, {['@amt'] = amount, ['@steam'] = steam, ['@stock'] = stockAbbrev});
        else
            -- They don't have an owned stock of this, insert 
            local  sql = "INSERT INTO `user_stock_data` VALUES (0, @steam, @stock, @amt)";
            MySQL.Async.execute(sql, {['@amt'] = amount, ['@steam'] = steam, ['@stock'] = stockAbbrev});
        end
        i = 0;
        while i < amount do 
            MySQL.Async.execute("INSERT INTO `stock_purchase_data` VALUES (0, @steam, @purch, @stock, 1)", {
                ['@steam'] = steam,
                ['@purch'] = pricePer,
                ['@stock'] = stockAbbrev
            });
            i = i + 1;
        end 
    end 
    function SellStock(src, stockAbbrev, amount, pricePer)
        local ids = ExtractIdentifiers(src);
        local steam = ids.steam;
        if (HasStockOwned(src, stockAbbrev, amount)) then 
            -- They have enough of this stock, sell it
            local sql = "SELECT ownCount FROM user_stock_data WHERE identifier = @steam AND stockAbbrev = @abbrev";
            local countSQL = MySQL.Sync.fetchAll(sql, {['@steam'] = steam, ['@abbrev'] = stockAbbrev});
            local count = countSQL[1].ownCount;
            if count == amount then 
                MySQL.Async.execute("DELETE FROM `user_stock_data` WHERE `identifier` = @steam AND `stockAbbrev` = @stock", {
                    ['@steam'] = steam,
                    ['@stock'] = stockAbbrev
                }); 
                MySQL.Async.execute("UPDATE `stock_purchase_data` SET isOwned = 0 WHERE `identifier` = @steam AND `stockAbbrev` = @stock", {
                    ['@steam'] = steam,
                    ['@stock'] = stockAbbrev
                });
            else 
                -- Execute async, update their isOwned data for the stock_purchase_data that has least price:
                local row = MySQL.Sync.fetchAll("SELECT `id` FROM `stock_purchase_data` WHERE `isOwned` = 1 AND `identifier` = @steam AND stockAbbrev = @stock ORDER BY `purchasedPrice` DESC", {
                    ['@steam'] = steam,
                    ['@stock'] = stockAbbrev
                });
                local updated = 0;
                for i = 1, #row do 
                    local id = row[i].id;
                    if (updated < amount) then 
                        -- Set it as not owned any more 
                        MySQL.Sync.execute("UPDATE `stock_purchase_data` SET `isOwned` = 0 WHERE `id` = @id", {
                            ['@id'] = id;
                        });
                        updated = updated + 1;
                    end
                end
            end 
            -- Update it, they have more than amount
            MySQL.Async.execute("UPDATE `user_stock_data` SET `ownCount` = @own WHERE stockAbbrev = @stock AND identifier = @steam", {
                ['@own'] = (count - amount),
                ['@steam'] = steam,
                ['@stock'] = stockAbbrev
            });
        else
            -- They do not have enough of this stock to sell 
        end
    end 
    function HasStockOwned(src, stockAbbrev, amount) 
        local ids = ExtractIdentifiers(src);
        local steam = ids.steam;
        local sql = "SELECT COUNT(*) FROM user_stock_data WHERE identifier = @steam AND stockAbbrev = @abbrev";
        local count = MySQL.Sync.fetchScalar(sql, {['@steam'] = steam, ['@abbrev'] = stockAbbrev});
        if count > 0 then 
            return true;
        end
        return false;
    end 
    function GetStockCount(src)
        local ids = ExtractIdentifiers(src);
        local steam = ids.steam;
        local sql = "SELECT stockAbbrev, ownCount FROM user_stock_data WHERE identifier = @steam AND ownCount > 0";
        local stocks = MySQL.Sync.fetchAll(sql, {['@steam'] = steam});
        local count = 0;
        for i = 1, #stocks do 
            local abbrev = stocks[i].stockAbbrev;
            local owns = stocks[i].ownCount;
            count = count + owns; 
        end
        return count;
    end
    function GetStocks(src)
        local ids = ExtractIdentifiers(src);
        local steam = ids.steam;
        local sql = "SELECT stockAbbrev, ownCount FROM user_stock_data WHERE identifier = @steam AND ownCount > 0";
        local stocks = MySQL.Sync.fetchAll(sql, {['@steam'] = steam});
        local stockData = {}
        for i = 1, #stocks do 
            local abbrev = stocks[i].stockAbbrev;
            local owns = stocks[i].ownCount;
            if stockData[abbrev] == nil then 
                stockData[abbrev] = owns;
            else
                stockData[abbrev] = stockData[abbrev] + owns; 
            end 
        end
        return stockData;
    end
    function GetStockPurchaseData(src)
        local ids = ExtractIdentifiers(src);
        local steam = ids.steam;
        local sql = "SELECT id, stockAbbrev, purchasedPrice FROM stock_purchase_data WHERE identifier = @steam AND isOwned = 1 ORDER BY "
        .. "`id` DESC"; 
        local stockData = {}
        local stockDatas = MySQL.Sync.fetchAll(sql, {['@steam'] = steam});
        for i = 1, #stockDatas do 
            local id = stockDatas[i].id;
            local abbrev = stockDatas[i].stockAbbrev;
            local pricePurch = stockDatas[i].purchasedPrice; 
            table.insert(stockData, {id, abbrev, pricePurch}); 
        end
        local data = {}
        local sorter = {}
        for i = 1, #stockData do 
            if (data[stockData[i][2] .. "-" .. stockData[i][3]] == nil) then 
                -- Set it up 
                local count = 1;
                for j = 1, #stockData do 
                    if (j ~= i) and (stockData[j][2] == stockData[i][2]) and (stockData[j][3] == stockData[j][3]) then 
                        -- They are another of this type, increase the count 
                        count = count + 1;
                    end
                end 
                data[stockData[i][2] .. "-" .. stockData[i][3]] = {stockData[i][1], stockData[i][2], stockData[i][3], count};
                table.insert(sorter, stockData[i][2] .. "-" .. stockData[i][3])
            end
        end 
        return {data, sorter};
    end
    RegisterNetEvent('BadgerStockMarket:Server:GetMaxStocks')
    AddEventHandler('BadgerStockMarket:Server:GetMaxStocks', function()
        local src = source;
        local curAmt = 0;
        for permission, amount in pairs(Config.maxStocksOwned) do 
            if IsPlayerAceAllowed(src, permission) then 
                if amount >= curAmt then 
                    curAmt = amount;
                end
            end
        end
        TriggerClientEvent('BadgerStockMarket:Client:SetMaxStocksOwned', src, curAmt)
    end)
    RegisterNetEvent('BadgerStockMarket:Server:GetStockHTML')
    AddEventHandler('BadgerStockMarket:Server:GetStockHTML', function()
        local stockData = {}
        local src = source;
        for stockName, stockInfo in pairs(Config.stocks) do
            local stockLink = stockInfo['link']; 
            local stockTags = stockInfo['tags'];
            local data = nil;
            PerformHttpRequest(tostring(stockLink), function(errorCode, resultData, resultHeaders)
            data = {data=resultData, code=errorCode, headers=resultHeaders};
            end)
            while data == nil do 
            Wait(0);
            end
            if data.data ~= nil then 
                stockData[stockName] = {
                    data = data.data,
                    link = stockLink,
                    tags = stockTags,
                };
            end
        end
        TriggerClientEvent('BadgerStockMarket:Client:GetStockData', src, stockData);
    end)
    function ExtractIdentifiers(src)
        local identifiers = {
            steam = "",
            ip = "",
            discord = "",
            license = "",
            xbl = "",
            live = ""
        }

        --Loop over all identifiers
        for i = 0, GetNumPlayerIdentifiers(src) - 1 do
            local id = GetPlayerIdentifier(src, i)

            --Convert it to a nice table.
            if string.find(id, "steam") then
                identifiers.steam = id
            elseif string.find(id, "ip") then
                identifiers.ip = id
            elseif string.find(id, "discord") then
                identifiers.discord = id
            elseif string.find(id, "license") then
                identifiers.license = id
            elseif string.find(id, "xbl") then
                identifiers.xbl = id
            elseif string.find(id, "live") then
                identifiers.live = id
            end
        end

        return identifiers
    end
end);