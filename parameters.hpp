class Params
{
	class BaseLocation
	{
		title = "Base Location";
		values[] = {0, 1};
		texts[] = {"Default", "Random"};
		default = 0;
	};
	class CombatantsPreset
	{
		title = "Combatants";
		values[] = {0, 1, 2};
		texts[] = {"WEST vs EAST", "WEST vs RESISTANCE", "EAST vs RESISTANCE"};
		default = 0;
	};
	class StartCP
	{
		title = "Starting CP";
		values[] = {50, 250, 500, 1000, 2000, 5000, 10000, 1000000};
		default = 500;
	};
	class TargetVotingDuration
	{
		title = "TargetVotingDuration";
		values[] = {15};
		default = 15;
	};
	class AllowAIVoting
	{
		title = "AllowAIVoting";
		values[] = {0, 1};
		default = 0;
	};
	class AnnouncerEnabled
	{
		title = "AnnouncerEnabled";
		values[] = {0, 1};
		default = 1;
	};
	class MusicEnabled
	{
		title = "MusicEnabled";
		values[] = {0, 1};
		default = 1;
	};
	class InitialProgress
	{
		title = "InitialProgress";
		values[] = {0};
		default = 0;
	};
	class FogOfWar
	{
		title = $STR_WL2_param_fog_of_war;
		values[] = {0, 1, 2};
		texts[] = {$STR_DISP_OPT_DISABLED, $STR_WL2_param_fog_of_war_value1, $STR_WL2_param_fog_of_war_value2};
		default = 0;
	};
	class ScanCost
	{
		title = "ScanCost";
		values[] = {350};
		default = 350;
	};
	class FastTravelCostOwned
	{
		title = "FastTravelCostOwned";
		values[] = {25};
		default = 25;
	};
	class FastTravelCostContested
	{
		title = "FastTravelCostContested";
		values[] = {50};
		default = 50;
	};
	class FundsTransferCost
	{
		title = "FundsTransferCost";
		values[] = {500};
		default = 500;
	};
	class TargetResetCost
	{
		title = "TargetResetCost";
		values[] = {2000};
		default = 2000;
	};
	class ScanEnabled
	{
		title = "ScanEnabled";
		values[] = {0,1};
		default = 1;
	};
	class FastTravelEnabled
	{
		title = "FastTravelEnabled";
		values[] = {1};
		default = 1;
	};
	class MaxCP
	{
		title = "MaxCP";
		values[] = {50000};
		default = 50000;
	};
	class DropCost
	{
		title = "DropCost";
		values[] = {25};
		default = 25;
	};
	class DropCost_far
	{
		title = "DropCost_far";
		values[] = {1000};
		default = 1000;
	};
	class Autonomous_limit
	{
		title = "Autonomous_limit";
		values[] = {2};
		default = 2;
	};
	class ArsenalEnabled
	{
		title = "ArsenalEnabled";
		values[] = {0,1};
		default = 1;
	};
	class ArsenalCost
	{
		title = "ArsenalCost";
		values[] = {1000};
		default = 1000;
	};
	class MaxSubordinates
	{
		title = "MaxSubordinates";
		values[] = {3};
		default = 3;
	};
	class AssetLimit
	{
		title = "AssetLimit";
		values[] = {10};
		default = 10;
	};
	class TargetResetTimeout
	{
		title = "TargetResetTimeout";
		values[] = {300};
		default = 300;
	};
	class BaseValue
	{
		title = "BaseValue";
		values[] = {10};
		default = 10;
	};
	class ScanCooldown
	{
		title = "ScanCooldown";
		values[] = {90};
		default = 90;
	};
	class LastLoadoutCost
	{
		title = "LastLoadoutCost";
		values[] = {100};
		default = 100;
	};
	class WreckRemovalTimeout
	{
		title = "WreckRemovalTimeout";
		values[] = {30};
		default = 30;
	};
	class CorpseRemovalTimeout
	{
		title = "CorpseRemovalTimeout";
		values[] = {600};
		default = 600;
	};
	class SavedLoadoutCost
	{
		title = "SavedLoadoutCost";
		values[] = {500};
		default = 500;
	};
	class TimeMultiplier
	{
		title = "TimeMultiplier";
		values[] = {6};
		default = 6;
	};
	class ZoneRestrictionSetting
	{
		title = $STR_A3_mdl_supp_zonerest_name;
		values[] = {0, 1, 2};
		texts[] = {$STR_A3_to_zoneprotection7, $STR_A3_to_zoneprotection9, "Vanilla"};
		default = 2;
	};
	class SavingEnabled
	{
		title = $STR_WL2_param_saving;
		values[] = {0,1};
		texts[] = {$STR_DISP_OPT_ENABLED, $STR_DISP_OPT_DISABLED};
		default = 0;
	};
};