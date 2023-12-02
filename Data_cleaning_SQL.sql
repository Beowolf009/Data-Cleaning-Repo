/*

Cleaning Data in SQL Queries

*/

-------------------------------------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------------------------

 --Standardize Date format

 ---------------------------------------------------------------------------------------------

 select SaleDateConverted, Convert(Date,SaleDate)
    from PortfolioProject.dbo.HousingData

     --updating column with converetd values
UPDATE PortfolioProject.dbo.HousingData
Set SaleDate = convert(Date, SaleDate);

 --adding new column
Alter table PortfolioProject.dbo.HousingData
add SaleDateConverted Date;

 --updating column with converetd values
UPDATE PortfolioProject.dbo.HousingData
Set SaleDateConverted = convert(Date, SaleDate)

-------------------------------------------------------------------

--populate Propery Address Data before we populate them

------------------------------------------------------------------

select *
 from Portfolioproject.dbo.HousingData
-- where PropertyAddress is null
order by ParcelID

-- Select rows where PropertyAddress is null and there is a non-null PropertyAddress for the same ParcelID
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
 from Portfolioproject.dbo.HousingData a
join Portfolioproject.dbo.HousingData b
    on a.ParcelID = b.ParcelID
    and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

-- Update rows with null PropertyAddress by filling them with non-null values from another row with the same ParcelID
update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
    from Portfolioproject.dbo.HousingData a
    join Portfolioproject.dbo.HousingData b
        on a.ParcelID = b.ParcelID
        and a.[UniqueID] <> b.[UniqueID]

-------------------------------------------------------------------------------

--Breaking out address into individual columns (adress, city, state)
------------------------------------------------------------------------------

select PropertyAddress
 from Portfolioproject.dbo.HousingData
-- where PropertyAddress is null
--order by ParcelID

--doing it the hard way without parsename
SELECT
    substring(propertyaddress, 1, charindex(',', PropertyAddress) - 1) as Address
    ,substring(propertyaddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
        from PortfolioProject.dbo.HousingData
    
 --adding new column
Alter table PortfolioProject.dbo.HousingData
    add PropertySplitAddress NVARCHAR(255);

 --updating column with converetd values
UPDATE PortfolioProject.dbo.HousingData
    Set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', PropertyAddress) - 1)

 --adding new column
Alter table PortfolioProject.dbo.HousingData
    add PropertySplitCity nvarchar(255);

 --updating column with converetd values
UPDATE PortfolioProject.dbo.HousingData
Set PropertySplitCity = substring(propertyaddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))


SELECT OwnerAddress
    from Portfolioproject.dbo.HousingData

 --parsename function to replace periods with commas
SELECT PARSENAME(replace(OwnerAddress, ',', '.') ,3) 
       ,PARSENAME(replace(OwnerAddress, ',', '.') ,2)
       ,PARSENAME(replace(OwnerAddress, ',', '.') ,1)
    from Portfolioproject.dbo.HousingData

 --creating colum for owner address
Alter table PortfolioProject.dbo.HousingData
    add OwnerSplitAddress NVARCHAR(255);

 --updating column with owner address
UPDATE PortfolioProject.dbo.HousingData
    Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') ,3)

 --creating colum for owner city
Alter table PortfolioProject.dbo.HousingData
    add OwnerSplitCity nvarchar(255);

 --updating column with owner city
UPDATE PortfolioProject.dbo.HousingData
    Set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.') ,2)

 --creating colum for owner state
Alter table PortfolioProject.dbo.HousingData
    add OwnerSplitState nvarchar(255);

 --updating column with owner state
UPDATE PortfolioProject.dbo.HousingData
    Set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.') ,1)

--my data set is newer, has many more null files
SELECT * 
    from Portfolioproject.dbo.HousingData
    where ownersplitaddress is not null

 ---------------------------------------------------------------------------------------------

 --change Y and N to Yes and No in "sold as Vacant" field

 --------------------------------------------------------------------------------------------

SELECT * 
    from Portfolioproject.dbo.HousingData
--showing the count the Y and N
 select distinct(SoldAsVacant), COUNT(SoldAsVacant)
    from PortfolioProject.dbo.HousingData
        group by SoldAsVacant
        order by 2



SELECT Soldasvacant
, CASE when soldAsVacant ='Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'N'
       ELSE SoldAsVacant
       End

from PortfolioProject.dbo.HousingData

update PortfolioProject.dbo.HousingData
SET sOLDaSVacant = CASE when soldAsVacant ='Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       End

-----------------------------------------------------------------------------------------------------

--remove duplicate rows--

----------------------------------------------------------------------------
--create function--
WITH RowNumCTE AS (
SELECT *,
ROW_NUMber() over (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
                    UniqueID
                    ) row_num


from PortfolioProject.dbo.HousingData
--order by parcelID
)

--delete duplicates--
DELETE
    From RowNumCTE
    WHERE row_num > 1
    
    


--show sort of all duplicates--
SELECT * 
    From RowNumCTE
        where row_num > 1
        ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------

--Delete Unused columns we reorganized--

--------------------------------------------------------------------------------------

SELECT *
    From PortfolioProject.dbo.HOUsingdata

Alter TABLE PortfolioProject.dbo.HOUsingdata
    DROP Column 
        OwnerAddress,
        TaxDistrict,
        PropertyAddress

Alter TABLE PortfolioProject.dbo.HOUsingdata
    DROP Column 
        SaleDate





