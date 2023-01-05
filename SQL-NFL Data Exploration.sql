/*

All data was web scrapped and cleaned in excel, it covers the 2021 season for all NFL Teams, QBs, WRs, and RBs who
played in 6 or more games.  It includes fantasy points based on standard scoring as a weighted metric for production.
Five tables: WR stats, RB stats, QB stats, team stats, and contract AAV (average annual value).

*/


Select *
From NFLProject..QBStats

Select *
From NFLProject..WRStats

Select *
From NFLProject..RBStats

Select *
From NFLProject..TeamStats

Select *
From NFLProject..ContractAAV

 
--Populatinig player pay in QBStats, WRStats, and RBStats then adding columns and updating table for data

Select qb.Player,
ca.AAV
From NFLProject..QBStats qb
	Join ContractAAV ca
		on qb.Player = ca.Player

Select rb.Player,
ca.AAV
From NFLProject..RBStats rb
	JOIN ContractAAV ca
		on rb.Player = ca.Player

Select wr.Player,
ca.AAV
From NFLProject..WRStats wr
	JOIN ContractAAV ca
		on wr.Player = ca.Player



Alter Table QBStats
Add AAV int

Alter Table WRStats
Add AAV int

Alter Table RBStats
Add AAV int


Update QBStats
Set AAV = ca.AAV
From NFLProject..QBStats qb
	JOIN ContractAAV ca
		on qb.Player = ca.Player

Update WRStats
Set AAV = ca.AAV
From NFLProject..WRStats wr
	JOIN ContractAAV ca
		on wr.Player = ca.Player

Update RBStats
Set AAV = ca.AAV
From NFLProject..RBStats rb
	JOIN ContractAAV ca
		on rb.Player = ca.Player



-------------------------------------------
--Looking at production (FPTS) and contract AAV relative to production.

Select Player,
FPTS,
ContractAAV,
ContractAAV/FPTS AS PayPerFPT
From NFLProject..QBStats
--Diving by a fraction will greatly skew results
Where FPTS >=1
Order by PayPerFPT Desc


Select Player,
FPTS,
AAV,
AAV/FPTS AS PayPerFPT
From NFLProject..RBStats
Where FPTS >=1 
Order by PayPerFPT Desc

Select Player,
FPTS,
AAV,
AAV/FPTS AS PayPerFPT
From NFLProject..WRStats
Where FPTS >=1
Order by PayPerFPT Desc


--Adding data to tables

Alter Table QBStats
Add PayPerFPT int

Alter Table RBStats
Add PayPerFPT int

Alter Table WRStats
Add PayPerFPT int


Update QBStats
Set PayPerFPT = AAV/FPTS
Where FPTS >=1


Update RBStats
Set PayPerFPT = AAV/FPTS
Where FPTS >=1


Update WRStats
Set PayPerFPT = AAV/FPTS
Where FPTS >=1

---------------------------------------------------------

--Looking at QB rush production and attmepts to asses injury risk level (RB by far is the most often injured position)


Select Player,
RshATT,
RshYDS
From NFLProject..QBStats
Order by RshATT DESC


Select player,
((RshYDS/10)+([RUSH TD]*6))/FPTS AS RshFPTSPercent
From NFLProject..QBStats
Order by Player


Select player,
((RshYDS/10)+([RUSH TD]*6)) as RshFPTS
From NFLProject..QBStats 
Order by 2 Desc




--Adding columns and updating for percent of rush fantasy points and total rush fantasy points

Alter Table QBStats
Add RshFPTSPercent Float

Alter Table QBStats
Add RshFPTS Float


Update QBStats
Set RshFPTSPercent = ((RshYDS/10)+([RUSH TD]*6))/FPTS
From NFLProject..QBStats 


Update QBStats
Set RshFPTS = ((RshYDS/10)+([RUSH TD]*6))
From NFLProject..QBStats
 

---------------------------------------
--Looking at team success and QB production

Select qb.Player,
tm.Team,
qb.FPTS,
tm.PCT,
tm.PF
From NFLProject..QBStats qb
	JOIN TeamStats tm
		on qb.Team = tm.Team
Order by 3 Desc


select *
From NFLProject..TeamStats
--Adding team win percent, wins, and points scored to QB and points scored to WR and RB

Alter Table QBStats
Add WinPercent Float

Alter Table QBStats
Add Wins Float

Alter Table QBStats
Add TeamPoints Float

Alter Table RBStats
Add TeamPoints Float

Alter Table WRStats
Add TeamPoints Float

Update QBStats
Set WinPercent = tm.PCT
From NFLProject..QBStats qb
	JOIN TeamStats tm
		on qb.Team = tm.Team


Update QBStats
Set Wins = tm.W
From NFLProject..QBStats qb
	JOIN TeamStats tm
		on qb.Team = tm.Team


Update QBStats
Set TeamPoints = tm.PF
From NFLProject..QBStats qb
	JOIN TeamStats tm
		on qb.Team = tm.Team

Update RBStats
Set TeamPoints = tm.PF
From NFLProject..RBStats rb
	JOIN TeamStats tm
		on rb.Team = tm.Team

Update WRStats
Set TeamPoints = tm.PF
From NFLProject..WRStats wr
	JOIN TeamStats tm
		on wr.Team = tm.Team


-----------------------------------------	
--Looking at total points scored and percent of team's total points

Select Player,
FPTS,
(TD*6)+ ([RUSH TD]*6) As PntsScored,
((TD*6)+ ([RUSH TD]*6))/TeamPoints As PercentTeamPnts
From NFLProject..QBStats
Order by PntsScored Desc



Select Player,
(([Rush TD]*6) + ([Rec TD] * 6)) AS PntsScored,
(([Rush TD]*6) + ([Rec TD] * 6))/Teampoints AS PercentTeamPoints
From NFLProject..RBStats
Order by PntsScored Desc


Select Player,
FPTS,
(TD*6)+ ([RUSH TD]*6) As PntsScored,
((TD*6)+ ([RUSH TD]*6))/TeamPoints As PercentTeamPnts
From NFLProject..WRStats
Order by PntsScored Desc



--Adding data to position tables

Alter Table QBStats
Add PntsScored float

Alter Table QBStats 
Add PercentTeamPnts float

Alter Table RBStats 
Add PntsScored float

Alter Table RBStats 
Add PercentTeamPnts float

Alter Table WRStats 
Add PntsScored float

Alter Table WRStats 
Add PercentTeamPnts float



Update QBStats
SET PercentTeamPnts = ((TD*6)+ ([RUSH TD]*6))/TeamPoints

Update QBStats
SET PntsScored = ((TD*6)+ ([RUSH TD]*6))

Update RBStats
SET PercentTeamPnts = (([Rush TD]*6) + ([Rec TD] * 6))/TeamPoints


Update RBStats
SET PntsScored = ([Rush TD]*6) + ([Rec TD] * 6)


Update WRStats
SET PercentTeamPnts = ((TD*6)+ ([RUSH TD]*6))/TeamPoints


Update WRStats
SET PntsScored = (TD*6)+ ([RUSH TD]*6)



-------------------------------------------
--Looking at distribution of production min, max, and quartiles


Select Distinct
	PERCENTILE_CONT(0.25) WITHIN GROUP(Order by FPTS) OVER() AS LowerQrtl,
	PERCENTILE_CONT(0.5) WITHIN GROUP(Order by FPTS) OVER() AS Median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(Order by FPTS) OVER() AS UpperQrtl
From NFLProject..QBStats


Select Distinct
	MIN(FPTS) AS Minimum,
	MAX(FPTS) as Maximum
From NFLProject..QBStats


Select Distinct
	PERCENTILE_CONT(0.25) WITHIN GROUP(Order by FPTS) OVER() AS LowerQrtl,
	PERCENTILE_CONT(0.5) WITHIN GROUP(Order by FPTS) OVER() AS Median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(Order by FPTS) OVER() AS UpperQrtl
From NFLProject..RBStats


Select Distinct
	MIN(FPTS) AS Minimum,
	MAX(FPTS) as Maximum
From NFLProject..RBStats


Select Distinct
	PERCENTILE_CONT(0.25) WITHIN GROUP(Order by FPTS) OVER() AS LowerQrtl,
	PERCENTILE_CONT(0.5) WITHIN GROUP(Order by FPTS) OVER() AS Median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(Order by FPTS) OVER() AS UpperQrtl
From NFLProject..WRStats


Select Distinct
	MIN(FPTS) AS Minimum,
	MAX(FPTS) as Maximum
From NFLProject..WRStats


---Looking at distrbution of top 50%

Select Distinct
	PERCENTILE_CONT(0.25) WITHIN GROUP(Order by FPTS) OVER() AS LowerQrtl,
	PERCENTILE_CONT(0.5) WITHIN GROUP(Order by FPTS) OVER() AS Median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(Order by FPTS) OVER() AS UpperQrtl
From NFLProject..QBStats
Where FPTS > 202.68


Select Distinct
	MAX(FPTS) as Maximum
From NFLProject..QBStats
Where FPTS > 202.68



Select Distinct
	PERCENTILE_CONT(0.25) WITHIN GROUP(Order by FPTS) OVER() AS LowerQrtl,
	PERCENTILE_CONT(0.5) WITHIN GROUP(Order by FPTS) OVER() AS Median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(Order by FPTS) OVER() AS UpperQrtl
From NFLProject..WRStats
Where FPTS > 49.5



Select Distinct
	MAX(FPTS) as Maximum
From NFLProject..WRStats
Where FPTS > 49.5




Select Distinct
	PERCENTILE_CONT(0.25) WITHIN GROUP(Order by FPTS) OVER() AS LowerQrtl,
	PERCENTILE_CONT(0.5) WITHIN GROUP(Order by FPTS) OVER() AS Median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(Order by FPTS) OVER() AS UpperQrtl
From NFLProject..RBStats
Where FPTS > 49.4

Select Distinct
	MAX(FPTS) as Maximum
From NFLProject..RBStats
Where FPTS >= 49.4



--Looking at production and team success, bottom 50% is tier 4 and tops 50% distribution separates tiers 1-3


Select Player,
Team,
WinPercent,
FPTS,
PayPerFPT,
	CASE WHEN  FPTS >= 327.4 THEN 'Tier 1'
		 WHEN  FPTS >= 284.35 THEN 'Tier 2'
		 WHEN  FPTS >= 230.62 THEN 'Tier 3'
		 ELSE 'Tier 4' 
		 END As ProductionKPI
From NFLProject..QBStats
Order by ProductionKPI Asc



Select Player,
Team,
TMSuccess,
FPTS,
PayPerFPT,
	CASE WHEN  FPTS >= 172.15 THEN 'Tier 1'
		 WHEN  FPTS >= 112.6 THEN 'Tier 2'
		 WHEN  FPTS >= 85 THEN 'Tier 3'
		 ELSE 'Tier 4' 
		 END As ProductionKPI
From NFLProject..RBStats
Order by ProductionKPI Asc



Select Player,
Team,
TMSuccess,
FPTS,
PayPerFPT,
	CASE WHEN  FPTS >= 172.15 THEN 'Tier 1'
		 WHEN  FPTS >= 112.6 THEN 'Tier 2'
		 WHEN  FPTS >= 85 THEN 'Tier 3'
		 ELSE 'Tier 4' 
		 END As ProductionKPI
From NFLProject..WRStats
Order by ProductionKPI Asc


--Looking at distribution of WR targets, RB attempts and production




Select Distinct
	PERCENTILE_CONT(0.25) WITHIN GROUP(Order by TGTS) OVER() AS LowerQrtl,
	PERCENTILE_CONT(0.5) WITHIN GROUP(Order by TGTS) OVER() AS Median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(Order by TGTS) OVER() AS UpperQrtl
From NFLProject..WRStats

Select Distinct
	PERCENTILE_CONT(0.25) WITHIN GROUP(Order by [RUSH ATT]) OVER() AS LowerQrtl,
	PERCENTILE_CONT(0.5) WITHIN GROUP(Order by [RUSH ATT]) OVER() AS Median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(Order by [RUSH ATT]) OVER() AS UpperQrtl
From NFLProject..RBStats



--Looking at the ranking of the top 50%

Select Player,
TGTS,
[PCT Caught],
FPTS,
	Rank() OVER(Order by FPTS Desc) Rank
from NFLProject..WRStats
WHERE TGTS >= 49 --target median
Order by Rank Asc



Select Player,
[Rush ATT],
[Rush YDS],
[Rush AVG]
FPTS,
	Rank() OVER(Order by FPTS Desc) Rank
from NFLProject..RBStats
WHERE [Rush ATT] >= 67 --target median
Order by Rank Asc

