-- CLEANING DATA IN SQL

--Looking at Dataset

Select *
From NashvilleData..Nashville

--Changinng DateTime to Date


Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleData..Nashville

Update Nashville
SET SaleDate = CONVERT(Date,SaleDate)
--Query was stated as successful, however SaleDate still in DateTime
--Will add new column instead for Date

Alter Table Nashville
Add SaleDateConverted Date;

Update Nashville
SET SaleDateConverted = CONVERT(Date,SaleDate)



--Seeing how I might fill nulls in Property address

Select *
From NashvilleData..Nashville
oRDER BY Address1 Desc


--Self join to see if nulls can be populated with ParcelID

Select nshA.ParcelID,
nshA.PropertyAddress,
nshA.ParcelID,
nshB.PropertyAddress
From NashvilleData..Nashville nshA
JOIN NashvilleData..Nashville nshB
	on nshA.ParcelID = nshB.ParcelID
	AND nshA.[UniqueID ] <> nshB.[UniqueID ]
Where nshA.PropertyAddress is null

--Using ISNULL to populate

Select nshA.ParcelID,
nshA.PropertyAddress,
nshA.ParcelID,
nshB.PropertyAddress,
ISNULL(nshA.PropertyAddress, nshB.PropertyAddress)
From NashvilleData..Nashville nshA
JOIN NashvilleData..Nashville nshB
	on nshA.ParcelID = nshB.ParcelID
	AND nshA.[UniqueID ] <> nshB.[UniqueID ]
Where nshA.PropertyAddress is null

Update nshA
SET PropertyAddress = ISNULL(nshA.PropertyAddress, nshB.PropertyAddress)
From NashvilleData..Nashville nshA
JOIN NashvilleData..Nashville nshB
	on nshA.ParcelID = nshB.ParcelID
	AND nshA.[UniqueID ] <> nshB.[UniqueID ]
Where nshA.PropertyAddress is null

Select PropertyAddress
From NashvilleData..Nashville
Where PropertyAddress is null

--Successfully populated PropertyAddress

--Using subtrings to separate PropertyAddress into Address, City

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From NashvilleData..Nashville

--Adding 2 new columns for address and city
Alter Table Nashville
Add Address1 Nvarchar(255);

Alter Table Nashville
Add City Nvarchar(255);

Update Nashville
Set Address1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Update Nashville
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--Using PARSENAME to separate OwnerAddress Address, City, State

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleData..Nashville

Alter Table Nashville
Add OwnerAddress1 Nvarchar(255);

Alter Table Nashville
Add OwnerCity Nvarchar(255);

Alter Table Nashville
Add OwnerState Nvarchar(255);

Update Nashville
Set OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Update Nashville
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update Nashville
Set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Changing Y and N to Yes and No in SoldAsVacant

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleData..Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant ='N' THEN 'No' 
		 ELSE SoldAsVacant
		 END
From NashvilleData..Nashville

Update Nashville
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant ='N' THEN 'No' 
						 ELSE SoldAsVacant
						 END


--Removing duplicates

WITH row_num_CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
				 ) row_num
From NashvilleData..Nashville
)
DELETE
From row_num_CTE
WHERE row_num > 1

--------------------------------
--REMOVING UNECESSARY COLUMNS

ALTER TABLE NashvilleData..Nashville
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate


Select *
FROM NashvilleData..Nashville

--Looking at average sale price per city

UPDATE NashvilleData..Nashville

Select City,
AVG(SalePrice)
FROM NashvilleData..Nashville
GROUP BY City