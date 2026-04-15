// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: stim.gsc

////////////////////////////////////////////////////////////////////////

// Stim system
//
// Goal:
// - Manual stim use should trigger the custom boost effect.
// - If another stim is used while the current effect is active,
//   the old effect is cancelled immediately and replaced by a fresh one.
// - The newest stim always overrides the current active boost.
// - Kill rewards should safely give stim back into inventory.
//
// IMPORTANT:
// - Reading adrenaline ammo directly is safe.
// - Direct equipment write paths for "equip_adrenaline" may spam errors on some builds.
// - Clean stim inventory refill path found for this build:
//   self scripts\mp\equipment::incrementequipmentslotammo("secondary", amount);
//
// Notes:
// - We do NOT lock stim ammo during the active effect.
// - We do NOT restore stim ammo after the effect.
// - The game handles stim inventory naturally when the player uses stim.

////////////////////////////////////////////////////////////////////////

// Shared stim equipment token
getStimEquipmentName()
{
    return "equip_adrenaline";
}

////////////////////////////////////////////////////////////////////////

// Optional read helper
getStimAmmo()
{
    if (!isDefined(self) || !isAlive(self))
        return 0;

    ammo = self scripts\mp\equipment::getequipmentammo(getStimEquipmentName());

    if (!isDefined(ammo))
        return 0;

    if (ammo < 0)
        return 0;

    return ammo;
}

////////////////////////////////////////////////////////////////////////

// Clean stim inventory grant
//
// Uses the clean slot-based tactical refill path.
// On this build, "secondary" is the stim/tactical slot.
//
// Return:
// 0  = no stim added
// >0 = amount of stim added
tryGiveStimAmmo(amount)
{
    if (!isDefined(self) || !isAlive(self))
        return 0;

    if (!isDefined(amount) || amount <= 0)
        return 0;

    equip = getStimEquipmentName();

    current = self scripts\mp\equipment::getequipmentammo(equip);
    max = self scripts\mp\equipment::getequipmentmaxammo(equip);

    if (!isDefined(current) || current < 0)
        current = 0;

    if (!isDefined(max) || max <= 0)
        return 0;

    if (current >= max)
        return 0;

    self scripts\mp\equipment::incrementequipmentslotammo("secondary", amount);

    new = self scripts\mp\equipment::getequipmentammo(equip);

    if (!isDefined(new) || new < current)
        return 0;

    return (new - current);
}

////////////////////////////////////////////////////////////////////////

// Reward-triggered stim
//
// This gives stim back into inventory.
// It does NOT directly trigger the boost effect.
//
// Return:
// 0  = no stim added
// >0 = amount of stim added
giveStimReward(amount)
{
    if (!isDefined(self) || !isAlive(self))
        return 0;

    if (!isDefined(amount) || amount <= 0)
        return 0;

    if (amount > 2)
        amount = 2;

    return self tryGiveStimAmmo(amount);
}

////////////////////////////////////////////////////////////////////////

// Stim manager
//
// Listens for every real force_regeneration event from manual stim use.
// Each new event cancels the currently active boost and starts a fresh one.
//
// If a boost was already active, the new worker is marked as refreshed.
stimBoost()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_stimBoost");
    level endon("game_ended");

    self.stimActive = false;

    for (;;)
    {
        self waittill("force_regeneration");

        if (!isDefined(self) || !isAlive(self))
            continue;

        refreshed = isDefined(self.stimActive) && self.stimActive;

        // Cancel current boost and replace it with a fresh one
        self notify("stop_activeStimBoost");

        if (isAlive(self))
            self setmovespeedscale(1);

        wait 0.01;

        self thread runStimBoost(refreshed);
    }
}

////////////////////////////////////////////////////////////////////////

// Active boost worker
//
// This thread runs the actual stim effect.
// If another stim is used while this effect is active, the manager sends
// "stop_activeStimBoost", ends this worker, and starts a fresh one.
//
// Param:
// refreshed = true if this boost started by overriding an already-active boost
runStimBoost(refreshed)
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_stimBoost");
    self endon("stop_activeStimBoost");
    level endon("game_ended");

    self.stimActive = true;

    if (!isDefined(refreshed))
        refreshed = false;

    // Framework-owned live config
    base = 1.05;
    duration = 10;
    decay = 0.1;

    if (isDefined(level.frameworkStimSpeed))
        base = level.frameworkStimSpeed;
    else
        base = getDvarFloat("stim_boost_speed");

    if (isDefined(level.frameworkStimDuration))
        duration = level.frameworkStimDuration;
    else
        duration = getDvarInt("stim_boost_duration");

    if (isDefined(level.frameworkStimDecay))
        decay = level.frameworkStimDecay;
    else
        decay = getDvarFloat("stim_boost_decay");

    // Safe fallback defaults
    if (!isDefined(base) || base <= 0)
        base = 1.05;

    if (!isDefined(duration) || duration <= 0)
        duration = 10;

    if (!isDefined(decay) || decay < 0)
        decay = 0.1;

    // Final clamps
    if (base < 1.0)
        base = 1.0;

    if (duration < 1)
        duration = 1;

    if (decay < 0)
        decay = 0;

    speed = base;
    finishedNormally = false;

    self playsound("breach_warning_beep_01");

    if (refreshed)
        self custom_scripts\framework\sources\core\ui::prefixPrintBold("^5Stim Boost » Refreshed");
    else
        self custom_scripts\framework\sources\core\ui::prefixPrintBold("^3Stim Boost » Applied");

    // Full boost phase
    for (i = 0; i < duration; i++)
    {
        if (!isAlive(self))
            break;

        self setmovespeedscale(speed);
        wait 0.25;
    }

    // Decay phase
    if (isAlive(self))
    {
        self playsound("breach_warning_beep_01");
        self custom_scripts\framework\sources\core\ui::prefixPrintBold("^2Stim Boost » Active");

        currentSpeed = speed;

        for (i = 0; i < 12; i++)
        {
            if (!isAlive(self))
                break;

            currentSpeed = currentSpeed - decay;

            if (currentSpeed < 1.0)
                currentSpeed = 1.0;

            self setmovespeedscale(currentSpeed);
            wait 0.25;
        }

        finishedNormally = true;
    }

    if (isDefined(self) && isAlive(self))
    {
        self setmovespeedscale(1);

        if (finishedNormally)
        {
            self playsound("breach_warning_beep_01");
            self custom_scripts\framework\sources\core\ui::prefixPrintBold("^1Stim Boost » Finished");
        }
    }

    self.stimActive = false;
}