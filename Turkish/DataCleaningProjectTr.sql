SELECT * FROM NashvilleHousing


---------------------------------------------------------------------------------
--Tarih Kolonunu Date Formatýna Çevirelim

UPDATE NashvilleHousing
SET SaleDate =  CONVERT(date, SaleDate) FROM NashvilleHousing
-- Bu kod çalýþýyor ancak tekrardan tabloya baktýðýmýz zaman görüyoruz ki bir deðiþklik olmamýþ, 
--bunun nedeni tablonun SaleDate kolonunun veri tipinin deðiþmemesidir.

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date


---------------------------------------------------------------------------------
--PropertyAddress ve Owner Address bilgileri bu hali ile pek kullanýlabilir deðil. Eyalet ve þehir bilgileri 
--bulunmasýna raðmen gruplama yapýlmaz bu haliyle. Bu nedenle adres bilgisini parçalayalým

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

--Gözlemleyelim
SELECT OwnerAddress, OwnerAddress1, OwnerCity, OwnerState FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

-------------------------------------------------------------------------------------------
--Bazý Mülklerde Mülkiyet sahibi bilgisi Bulunmamaktadýr. Sahibi olan ve olmayan mülklerin kýyaslanabilmesi için
--veri setine bununla ilgili bir kolon ekleyelim

ALTER TABLE NashvilleHousing
ADD IsOwnerExist varchar(10)

UPDATE NashvilleHousing
SET IsOwnerExist = CASE WHEN OwnerName IS NULL
						THEN 'No'
						ELSE 'YES'
				   END


------------------------------------------------------------------------------------------
--SolsAsVacant Kolonundaki kayýtlarý tekilleþtirelim

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
--Veri Setinde PropertyAddres bilgisi boþ olup ParcelID bilgisi dolu olan kayýtlar bulunmaktadýr.
--Habluki bu iki bilgi birebir eþleþmektedir. Veri setinde ayný ParcelID olan kayýtýn PropertyAdress
--bilgisi kullanýlarak boþ kayýtlar doldurulabilir

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
--Verisetinde birçok gereksiz bilgi bulunmaktadýr.Ancak yinede bunlarý verisetinden kaldýrmak sakýncalý olabilir. 
--Bu hali ile verisetinden istenilen bilgiler alýnarak Wiew yada geçici tablolar oluþturuabilir.

