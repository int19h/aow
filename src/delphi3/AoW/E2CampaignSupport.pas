unit E2CampaignSupport;

{ Original campaign access routines, 0040BBB8, 0040BDE4 and 0040BF1C. }

interface

uses Engine, AoWE, AoWVideoDlg;

function GetCampaignScenario(Campaign: TWMCampaign; Index: Integer): TWMCampaignScenario;
procedure SelectCampaignPath(Campaign: TWMCampaign; Index: Integer);

implementation

function GetCampaignScenario(Campaign: TWMCampaign; Index: Integer): TWMCampaignScenario;
begin
  Result := TWMCampaignScenario(Campaign.FScenarios.GetScenario(Index));
end;

procedure SelectCampaignPath(Campaign: TWMCampaign; Index: Integer);
begin
  if (Index >= 0) and (Index < 3) then
  begin
    Campaign.FState := 2;
    Campaign.FPage := 0;
    Campaign.SelectNextScenario(Campaign.FScenarios.IndexOfID(
      GetCampaignScenario(Campaign, Campaign.FCurrentScenarioID).FPaths[Index]));
    if GetCampaignScenario(Campaign, Campaign.FNextScenarioID).FPaths[3] = -1 then
      GetCampaignScenario(Campaign, Campaign.FNextScenarioID).FPaths[3] :=
        GetCampaignScenario(Campaign, Campaign.FCurrentScenarioID).FPaths[3];
  end;
end;

end.
