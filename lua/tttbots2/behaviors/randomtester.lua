---@class BRandomTester
TTTBots.Behaviors.RandomTester = {}

local lib = TTTBots.Lib
local STATUS = TTTBots.STATUS

local RandomTester = TTTBots.Behaviors.RandomTester
RandomTester.Name = "RandomTester"
RandomTester.Description = "Use the Random Tester equipment."
RandomTester.Interruptible = false
RandomTester.WeaponClasses = { "weapon_ttt_randomtest" }

function RandomTester.HasRandomTester(bot)
    for _, class in ipairs(RandomTester.WeaponClasses) do
        if bot:HasWeapon(class) then return true end
    end
    return false
end

function RandomTester.GetRandomTester(bot)
    for _, class in ipairs(RandomTester.WeaponClasses) do
        local wep = bot:GetWeapon(class)
        if IsValid(wep) then return wep end
    end
end

function RandomTester.Validate(bot)
    if not TTTBots.Match.IsRoundActive() then return false end
    return RandomTester.HasRandomTester(bot)
end

function RandomTester.OnStart(bot)
    bot.randomTesterStartTime = CurTime()
    return STATUS.RUNNING
end

function RandomTester.OnRunning(bot)
    local inventory, loco = bot:BotInventory(), bot:BotLocomotor()
    if not (inventory and loco) then return STATUS.FAILURE end

    local tester = RandomTester.GetRandomTester(bot)
    if not tester then return STATUS.FAILURE end

    -- Equip the tester
    inventory:PauseAutoSwitch()
    bot:SetActiveWeapon(tester)
    loco:SetGoal() -- stop moving

    -- Wait a short time before using
    if not bot.randomTesterStartTime then
        bot.randomTesterStartTime = CurTime()
        return STATUS.RUNNING
    end

    if CurTime() - bot.randomTesterStartTime > 2 then
        -- Randomly choose M1 or M2
        local loco = bot:BotLocomotor()
        bot.randomTesterStartTime = CurTime()
        if math.random() < 0.4 then
            print("RandomTester: Using M1")
            loco:StartAttack()
            return STATUS.SUCCESS
        else
            print("RandomTester: Using M2")
            loco:StartAttack2()
        end
    end

    return STATUS.RUNNING
end

function RandomTester.OnSuccess(bot)
    inventory:ResumeAutoSwitch()
end

function RandomTester.OnFailure(bot)
end

function RandomTester.OnEnd(bot)
    bot.randomTesterStartTime = nil
    local inventory, loco = bot:BotInventory(), bot:BotLocomotor()
    if not (inventory and loco) then return end
    loco:SetHalt(false)
end