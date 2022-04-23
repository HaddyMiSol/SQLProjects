SELECT  *
From HousingProject..NashvilleHousingData

--Convert SaleDate from Datetime to Date

ALTER TABLE HousingProject..NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE HousingProject..NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
From HousingProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingProject..NashvilleHousingData a
JOIN HousingProject..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingProject..NashvilleHousingData a
JOIN HousingProject..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Split the Property into Address, City 

ALTER TABLE HousingProject..NashvilleHousingData
ADD PropertyHomeAddress Nvarchar(255);

UPDATE HousingProject..NashvilleHousingData
SET PropertyHomeAddress  = PARSENAME(REPLACE(PropertyAddress,',','.'),2)

ALTER TABLE HousingProject..NashvilleHousingData
ADD PropertyCity Nvarchar(255);

UPDATE HousingProject..NashvilleHousingData
SET PropertyCity  = PARSENAME(REPLACE(PropertyAddress,',','.'),1)





--Split the Owner Address into Address, City and State

ALTER TABLE HousingProject..NashvilleHousingData
ADD OwnerHomeAddress Nvarchar(255);

UPDATE HousingProject..NashvilleHousingData
SET OwnerHomeAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE HousingProject..NashvilleHousingData
ADD OwnerCity Nvarchar(255);

UPDATE HousingProject..NashvilleHousingData
SET OwnerCity  = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE HousingProject..NashvilleHousingData
ADD OwnerState Nvarchar(255);

UPDATE HousingProject..NashvilleHousingData
SET OwnerState  = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Change 'Y' to Yes and 'N' to No in the SoldAsVacant Column

SELECT Distinct (SoldAsVacant), Count(SoldAsVacant)
From HousingProject..NashvilleHousingData
Group by SoldAsVacant
Order by 2

Update 
HousingProject..NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END
    
	
--Remove Duplicates

WITH RowNumCTE AS(
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

From HousingProject.dbo.NashvilleHousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



-- Delete Unused Columns


Select *
From HousingProject.dbo.NashvilleHousingData


ALTER TABLE HousingProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
