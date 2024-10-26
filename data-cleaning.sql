
SELECT *
FROM portfolioProject.dbo.nashvilleHousing;


-- Standardize Date Format. Change SaleDate
SELECT SaleDate, CONVERT(date,SaleDate)
FROM portfolioProject.dbo.nashvilleHousing;

UPDATE nashvilleHousing
SET SaleDate = CONVERT(date,SaleDate);

ALTER TABLE nashvilleHousing 
ALTER COLUMN SaleDate DATE;


-- Populate PropertyAddress
SELECT PropertyAddress
FROM portfolioProject.dbo.nashvilleHousing;

SELECT *
FROM portfolioProject.dbo.nashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioProject.dbo.nashvilleHousing a
-- Join the exact table to itself. Where the ParcelID is the same but its not the same row, because of the UniqueID
JOIN portfolioProject.dbo.nashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioProject.dbo.nashvilleHousing a
JOIN portfolioProject.dbo.nashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- Seperate address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM portfolioProject.dbo.nashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM portfolioProject.dbo.nashvilleHousing;

ALTER TABLE nashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE nashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM portfolioProject.dbo.nashvilleHousing;


-- Modify OwnerAddress
SELECT OwnerAddress
FROM portfolioProject.dbo.nashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM portfolioProject.dbo.nashvilleHousing;

ALTER TABLE nashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE nashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE nashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-- Change Y and N to Yes and No in SoldAsVacant field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioProject.dbo.nashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM portfolioProject.dbo.nashvilleHousing;

UPDATE nashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;


-- Remove duplicates
WITH rowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM portfolioProject.dbo.nashvilleHousing
--ORDER BY ParcelID
)
--DELETE
--FROM rowNumCTE
--WHERE row_num > 1
SELECT *
FROM rowNumCTE
WHERE row_num > 1
ORDER BY ParcelID;


-- Delete unused columns
SELECT *
FROM portfolioProject.dbo.nashvilleHousing;

ALTER TABLE portfolioProject.dbo.nashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress;
