--Cleaning Data in SQL Queries


SELECT * 
FROM Housing;

-- StandardizedDate Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Housing;

--This one did not work. Need to alter table to add new column, the set it as date
--Update Housing
--SET SaleDate = CONVERT(Date, SaleDate);

Alter Table Housing
Add SaleDateConverted Date

Update Housing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted
FROM Housing;

-----------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM Housing
--WHERE PropertyAddress is null;
ORDER By ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ];

---------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Housing
--WHERE PropertyAddress is null;
--ORDER By ParcelID;

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address, --This separated address from city minus the comma
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM Housing

--create 2 new columns
Alter Table Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
SET PropertySplitAddress =SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

Alter Table Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

SELECT *
FROM Housing;


--now we have to split the ownerAddress

SELECT *
FROM Housing;

SELECT
PARSENAME (REPLACE(OwnerAddress, ',','.'),3),
PARSENAME (REPLACE(OwnerAddress, ',','.'),2),
PARSENAME (REPLACE(OwnerAddress, ',','.'),1)
FROM Housing;

Alter Table Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
SET OwnerSplitAddress =PARSENAME (REPLACE(OwnerAddress, ',','.'),3);

Alter Table Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'),2);

Alter Table Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
SET OwnerSplitState =PARSENAME (REPLACE(OwnerAddress, ',','.'),1);



---------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, Count(SoldAsVacant)
FROM Housing
Group by SoldAsVacant
order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END



-------------------------------------------------------------------------------
--Remove Duplicates Using CTE
--CTE creates a temp table
WITH RowNumCTE as (
SELECT *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
		ORDER BY UniqueID
		) ROW_Num
FROM Housing
--ORDER By ParcelID
)
/*DELETE
FROM RowNumCTE
WHERE ROW_Num >1*/

SELECT *
FROM RowNumCTE
WHERE ROW_Num >1

----------------------------------------------------------------------------------
--Delete Unused Columns

SELECT*
FROM Housing

ALTER TABLE Housing
DROP COLUMN PropertyAddress, OwnerAddress

