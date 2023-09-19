SELECT * FROM NashvilleHousing


---------------------------------------------------------------------------------
--Tarih Kolonunu Date Format�na �evirelim

UPDATE NashvilleHousing
SET SaleDate =  CONVERT(date, SaleDate) FROM NashvilleHousing
-- Bu kod �al���yor ancak tekrardan tabloya bakt���m�z zaman g�r�yoruz ki bir de�i�klik olmam��, 
--bunun nedeni tablonun SaleDate kolonunun veri tipinin de�i�memesidir.

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date


---------------------------------------------------------------------------------
--PropertyAddress ve Owner Address bilgileri bu hali ile pek kullan�labilir de�il. Eyalet ve �ehir bilgileri 
--bulunmas�na ra�men gruplama yap�lmaz bu haliyle. Bu nedenle adres bilgisini par�alayal�m

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

--G�zlemleyelim
SELECT OwnerAddress, OwnerAddress1, OwnerCity, OwnerState FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

-------------------------------------------------------------------------------------------
--Baz� M�lklerde M�lkiyet sahibi bilgisi Bulunmamaktad�r. Sahibi olan ve olmayan m�lklerin k�yaslanabilmesi i�in
--veri setine bununla ilgili bir kolon ekleyelim

ALTER TABLE NashvilleHousing
ADD IsOwnerExist varchar(10)

UPDATE NashvilleHousing
SET IsOwnerExist = CASE WHEN OwnerName IS NULL
						THEN 'No'
						ELSE 'YES'
				   END


------------------------------------------------------------------------------------------
--SolsAsVacant Kolonundaki kay�tlar� tekille�tirelim

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
--Veri Setinde PropertyAddres bilgisi bo� olup ParcelID bilgisi dolu olan kay�tlar bulunmaktad�r.
--Habluki bu iki bilgi birebir e�le�mektedir. Veri setinde ayn� ParcelID olan kay�t�n PropertyAdress
--bilgisi kullan�larak bo� kay�tlar doldurulabilir

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
--Verisetinde bir�ok gereksiz bilgi bulunmaktad�r.Ancak yinede bunlar� verisetinden kald�rmak sak�ncal� olabilir. 
--Bu hali ile verisetinden istenilen bilgiler al�narak Wiew yada ge�ici tablolar olu�turuabilir.

