// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: engine.gsc

////////////////////////////////////////////////////////////////////////

// Engine wrappers / risky calls isolated here

giveArmorPlates(amount)
{
    if (!custom_scripts\framework\sources\core\shared::isWarzone())
        return 0;

    if (!level.enablePlateRewards)
        return 0;

    if (!isDefined(self) || !isAlive(self))
        return 0;

    if (!isDefined(amount) || amount <= 0)
        return 0;

    given = 0;

    for (i = 0; i < amount; i++)
    {
        if (!isAlive(self))
            return given;

        self _encstr_8331245636CB3BEB9417AAA00397416342DF4DDB4A12D7F86A3B21400FF318B33BC2E86C62AA::
            br_forcegivecustompickupitem(self, "_encstr_82A813C6133837A275F7C7F3EB903B4F8078BECB69", 1, 1, 0);

        given++;
        wait 0.12;
    }

    return given;
}