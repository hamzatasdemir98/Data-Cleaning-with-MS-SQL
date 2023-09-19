/*
DATA CLEANING PROJECT
*/

SELECT * FROM NashvilleHousing

---------------------------------------------------------------------------------
--Conver the type of SaleDate to date

UPDATE NashvilleHousing
SET SaleDate =  CONVERT(date, SaleDate) FROM NashvilleHousing
--This code works, but when we look at the table again, we see that there has been no change.
--This is because the data type of the SaleDate column of the table has not changed.

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date


---------------------------------------------------------------------------------
--PropertyAddress and Owner Address information is not usable in its current state. Although state and city information
--is available, grouping is not possible. Therefore, let's break down the address information

ALTER TABLE NashvilleHousing
ADD OwnerState varchar(100)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE NashvilleHousing
ADD OwnerCity varchar(100)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerAddress1 varchar(100)

UPDATE NashvilleHousing
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--Lets observe
SELECT OwnerAddress, OwnerAddress1, OwnerCity, OwnerState FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

-------------------------------------------------------------------------------------------
--There is no owner information on some properties. 
--Let's add a column to the data set so that owned and unowned properties can be compared.

ALTER TABLE NashvilleHousing
ADD IsOwnerExist varchar(10)

UPDATE NashvilleHousing
SET IsOwnerExist = CASE WHEN OwnerName IS NULL
						THEN 'No'
						ELSE 'YES'
				   END


------------------------------------------------------------------------------------------
--Let's deduplicate the records in the SolsAsVacant Column

SELECT SoldAsVacant, COUNT(SoldAsVacant) 
FROM NashvilleHousing
GROUP BY SoldAsVacant

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N'
						THEN 'No'
						WHEN SoldAsVacant = 'Y'
						THEN 'Yes'
						ELSE SoldAsVacant
				   END


-------------------------------------------------------------------------------------------
--There are records in the Data Set with empty PropertyAddres information and full ParcelID information.
--However, these two information match exactly. Empty records can be filled by using 
--the PropertyAddress information of the record with the same ParcelID in the data set.

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
From NashvilleHousing A
JOIN NashvilleHousing B
on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From NashvilleHousing A
JOIN NashvilleHousing B
on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


Update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From NashvilleHousing A
JOIN NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

----------------------------------------------------------------------------------------

