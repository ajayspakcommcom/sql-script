
USE [BSV_IVF]
GO
/****** Object:  User [BSV_IVF]    Script Date: 20-04-2024 11:04:14 ******/
CREATE USER [BSV_IVF] FOR LOGIN [BSV_IVF] WITH DEFAULT_SCHEMA=[BSV_IVF]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [BSV_IVF]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [BSV_IVF]
GO
ALTER ROLE [db_datareader] ADD MEMBER [BSV_IVF]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [BSV_IVF]
GO
/****** Object:  Schema [BSV_IVF]    Script Date: 20-04-2024 11:04:15 ******/
CREATE SCHEMA [BSV_IVF]
GO
/****** Object:  Schema [hae]    Script Date: 20-04-2024 11:04:16 ******/
CREATE SCHEMA [hae]
GO
/****** Object:  StoredProcedure [BSV_IVF].[EUSP_GET_COMPETITION_REPORT_FOR_EXCEL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec EUSP_GET_COMPETITION_REPORT_FOR_EXCEL 08,2023
CREATE PROCEDURE [BSV_IVF].[EUSP_GET_COMPETITION_REPORT_FOR_EXCEL]   
( 
    @month int, 
    @year int 
) 
 AS   
 BEGIN   
  
     declare @dateAddedFor smallDateTime     
    set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))   
  
select bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,    
  
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,    
  
-- e.empid,     
  
e.firstName as KamName, e.Designation,     
  

  
c.CENTRENAME as centreName,  c.DoctorName, 
com.centerId as centerId,        
  
    bsv_ivf.getCompetationTotalforHospitalAndBrand(centerId, 1, @month, @year) as 'FOLIGRAF',   
  
    bsv_ivf.getCompetationTotalforHospitalAndBrand(centerId, 2, @month, @year) as 'HUMOG',   
  
    bsv_ivf.getCompetationTotalforHospitalAndBrand(centerId, 3, @month, @year) as 'ASPORELIX',   
  
    bsv_ivf.getCompetationTotalforHospitalAndBrand(centerId, 4, @month, @year) as 'R-HUCOG',   
  
    bsv_ivf.getCompetationTotalforHospitalAndBrand(centerId, 5, @month, @year) as 'FOLICULIN',   
  
    bsv_ivf.getCompetationTotalforHospitalAndBrand(centerId, 6, @month, @year) as 'AGOTRIG',   
  
    bsv_ivf.getCompetationTotalforHospitalAndBrand(centerId, 7, @month, @year) as 'MIDYDROGEN',   
  
     case com.isApproved                        
  
                    when 1 then 'Pending'                        
  
                    when 0 then 'Approved'                        
  
                    when 2 then 'Rejected'                    
  
                end as statusText,    
  
bsv_ivf.getEMPInfo(com.approvedBy) AS ApprovedBy,    
  
isNull(com.approvedOn, '') as ApprovedOn,    
  
bsv_ivf.getEMPInfo(com.rejectedBy) AS RejectedBy,    
  
 com.rejectedOn,    
  
-- com.rejectComments,    
  
com.competitionAddedFor     
  
from tblCompetitions com   
  
inner join tblcustomers c on c.customerID = com.centerId   
  
inner join tblEmployees e on e.empid = com.empId    
  
where    
  
1 = 1   
  
-- and e.empId = 61   
  
 and  competitionAddedFor = @dateAddedFor    
  
-- and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)     
  
group by e.empid, e.firstName, e.Designation,     
  
c.CENTRENAME,  c.DoctorName, com.centerId, com.isApproved,   
  
com.approvedBy, com.approvedOn, com.rejectedBy, com.rejectedOn, com.competitionAddedFor    
  
   
  
 order by e.firstName ASC   
  
   
  
   
  
   
  
END   
  

  

GO
/****** Object:  StoredProcedure [BSV_IVF].[spBusinessSummary]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- spBusinessSummary 01,2024
CREATE procedure [BSV_IVF].[spBusinessSummary]  
 (
    @month int,
    @year int
)
AS  
 
BEGIN  
   declare @dateAddedFor smallDateTime    
    set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))  
  
 
SELECT   
 
bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,   
 
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,   
 
-- e.empid,    
 
e.firstName as KamName, e.Designation,    
 
  
 
CENTRENAME, DoctorName, CITY,  hospitalId,                   
/* 
 
 
 
*/ 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 1, @month, @year) as '[FOLIGRAF 900 IU/1.5 ML PEN]', 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 2, @month, @year) as '[FOLIGRAF 1200 IU/2 ML PEN] ', 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 3, @month, @year) as '[FOLIGRAF 450 IU/0.75 ML PEN]', 
            BSV_IVF.getActualsTargetAchieved(hospitalID, 1) as [FOLIGRAF PEN],                  
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 4, @month, @year) as [FOLIGRAF 1200 IU LYO MULTIDOSE],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 5, @month, @year) as [Foligraf 150 iu],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 6, @month, @year) as [Foligraf 150 iu PFS],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 7, @month, @year) as [Foligraf 225 PFS],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 8, @month, @year) as [Foligraf 300 PFS],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 9, @month, @year) as [Foligraf 75 iu],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 10, @month, @year) as [Foligraf 75 iu PFS],       
            BSV_IVF.getActualsTargetAchieved(hospitalID, 2) as [FOLIGRAF (LYO/PFS)],     
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 11, @month, @year) as [HP Humog 150 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 12, @month, @year) as [HP Humog 75 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 13, @month, @year) as [HuMoG  225 IU BP (Freeze Dried)],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 14, @month, @year) as [Humog 150 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 15, @month, @year) as [Humog 75 iu],  
            BSV_IVF.getActualsTargetAchieved(hospitalID, 3) as [HUMOG LYO],   
  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 16, @month, @year) as [Humog HD 1200 IU Liquid],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 17, @month, @year) as [Humog HD 600 IU Liquid],  
            BSV_IVF.getActualsTargetAchieved(hospitalID, 4) as [HUMOG LIQ (MD/PFS)],                   
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 18, @month, @year) as [ASPORELIX],  
            -- BSV_IVF.getActualsTargetAchieved(hospitalID, 5) as [ASPORELIX],                   
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 19, @month, @year) as [r – Hucog 6500 i.u. /0.5 ml],  
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 6) as [R-HUCOG],                   
 
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 20, @month, @year) as [Foliculin 150 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 21, @month, @year) as [Foliculin 75 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 22, @month, @year) as [HP Foliculin 150 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 23, @month, @year) as [HP Foliculin 75 iu],  
            BSV_IVF.getActualsTargetAchieved(hospitalID, 7) as [FOLICULIN],                   
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 24, @month, @year) as [Agotrig 0.1mg/ml in PFS TFD],  
            -- BSV_IVF.getActualsTargetAchieved(hospitalID, 8) as 'AGOTRIG',                  
 
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 25, @month, @year) as [Dydrogesterone 10mg],  
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 9) as MIDYDROGEN ,                 
 
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 38, @month, @year) as [SPRIMEO],  
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 10) as SPRIMEO,                 
 
            ha.isApproved, accountName,    
 
            case ha.isApproved                         
 
                when 1 then 'Pending'                         
 
when 0 then 'Approved'                         
 
                when 2 then 'Rejected'               
 
            end as statusText,                     
 
            case ha.isApproved                         
 
                when 1 then 0                         
 
                when 0 then 1                         
 
                when 2 then 2                     
 
            end as sortOrder,  
 
            bsv_ivf.getEMPInfo(ha.approvedBy) AS ApprovedBy,   
 
            isNull(ha.approvedOn, '') as ApprovedOn,   
 
            bsv_ivf.getEMPInfo(ha.rejectedBy) AS RejectedBy,     
 
            ha.rejectedOn,   
 
            -- ha.rejectComments,   
 
            ha.ActualEnteredFor                  
 
            from TblHospitalactuals HA           
 
            inner join tblEmployees e on ha.empID = e.empID  
 
            INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                               
 
            INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                                
 
            left OUTER JOIN tblAccount a on a.accountID = c.accountID         
 
            WHERE 1 = 1                     
 
              and ActualEnteredFor = @dateAddedFor                       
 
            -- and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                        
 
            AND HA.isDisabled = 0                   
 
            group by CENTRENAME, DoctorName, CITY, hospitalId  , ha.isApproved, accountName,  
 
            e.empId,        ha.approvedBy   , ha.ApprovedOn   , ha.rejectedBy,   ha.rejectedOn,  
 
            firstName, Designation  
 
            -- , ha.rejectComments  
 
            , ha.ActualEnteredFor       
 
            order by e.firstName ASC    
 
  
 
  
 
END  

GO
/****** Object:  StoredProcedure [BSV_IVF].[spCompetitionSummary]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--declare   @EmpId int=null,   @StartDate datetime='2023-08-01',  @EndDate datetime='2023-08-31'          
--exec BSV_IVF.spCompetitionSummary  null,'2024-01-01','2024-01-31'          
CREATE proc [BSV_IVF].[spCompetitionSummary]  
(  
  @EmpId int=null,          
 @StartDate datetime=null,          
 @EndDate datetime=null          
)  
as  
Begin  
declare @fromdate datetime=null          
 declare @todate datetime=null          
 if (@startDate is not null)          
  begin          
   set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')          
  end          
  if (@EndDate is not null)          
  begin          
   set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')          
  end          
    
  
DECLARE @columns NVARCHAR(MAX),@columns2 NVARCHAR(MAX), @sql NVARCHAR(MAX);  
SET @columns = N'';  
SET @columns2 = N'';  
SELECT @columns += N', p.' + QUOTENAME(Name)  
  FROM (SELECT CONCAT(sg.brandName,'_', cs.[name]) as name from tblSkuGroup sg  
 inner join BSV_IVF.tblBrandcompetitorSKUs cs on sg.brandId=cs.brandId  
where sg.IsDisabled=0 and cs.isDisabled=0  
group by CONCAT(sg.brandName,'_', cs.[name])) AS x;  

SELECT @columns2 += N', ' + (Name)  
  FROM (SELECT CONCAT('isnull([', sg.brandName,'_', cs.[name],'],0) as [',sg.brandName,'_', cs.[name],']' ) as name from tblSkuGroup sg  
 inner join BSV_IVF.tblBrandcompetitorSKUs cs on sg.brandId=cs.brandId  
where sg.IsDisabled=0 and cs.isDisabled=0  
group by CONCAT('isnull([', sg.brandName,'_', cs.[name],'],0) as [',sg.brandName,'_', cs.[name],']' )
) AS x;  

--print @columns2
  
SET @sql = N'  
SELECT ZBM,RBM,KAM,Designation,CENTRENAME,DoctorName,code,statusText,ApprovedBy,ApprovedDate,
RejectedBy,RejectedDate,competitionAddedFor,accountName,comments
,' + STUFF(@columns2, 1, 2, '') + '  
FROM  
(  
  SELECT 
  bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,
  e.empid,e.firstname as KAM,e.Designation,c.CENTRENAME,c.DoctorName,c.code
  ,isnull(ea.firstname,'''') as ApprovedBy,isNull(com.approvedOn, '''') as ApprovedDate
  ,isnull(er.firstname,'''') as RejectedBy,isNull(com.rejectedOn, '''') as RejectedDate
  ,case com.isApproved when 1 then ''Pending''
					  when 0 then ''Approved''                        
                      when 2 then ''Rejected''
                end as statusText
  ,com.competitionAddedFor,a.accountName,isnull( convert(varchar(100),com.comments),'''') as Comments
  
  ,CONCAT(sg.brandName,''_'', cs.[name]) as CompBrand, isnull(com.businessValue,0)  as businessValue
  from BSV_IVF.tblCompetitions com  
		inner join BSV_IVF.tblBrandcompetitorSKUs cs on com.CompetitionSkuId=cs.competitorId  
			inner join tblSkuGroup sg on cs.brandId=sg.brandId  
		inner join BSV_IVF.tblEmployees e on com.empid=e.empid  
		inner join tblCustomers c on com.centerid=c.customerid  
			left join tblAccount a on c.accountid=a.accountID
		left outer join BSV_IVF.tblEmployees ea on com.approvedby=ea.empid  
		left outer join BSV_IVF.tblEmployees er on com.rejectedBy=er.empid  
where sg.IsDisabled=0 and cs.isDisabled=0  
	and com.competitionAddedFor>=''' + CONVERT(varchar, @fromdate, 120) +'''
	and com.competitionAddedFor<= ''' + CONVERT(varchar, @todate, 120) +'''
) AS j  
PIVOT  
(  
  SUM(businessValue) FOR CompBrand IN ('  
  + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '')  
  + ')  
) AS p
order by competitionAddedFor;';  
--PRINT @sql;  

EXEC sp_executesql @sql;  
End
GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_add_update_BUSINESS_TRACKER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--    
/*   
    USP_add_update_BUSINESS_TRACKER   
    24, 31, 2, 2023, 7,9,25, 99, 1, 0, "27-12-2022"   
*/    
--------------------------------------------       
-- CREATED BY: GURU SINGH       
-- CREATED DATE: 24-SEP-2022       
--------------------------------------------       
CREATE PROCEDURE [BSV_IVF].[USP_add_update_BUSINESS_TRACKER]       
(   
    @empId int,   
    @hospitalId int,   
    @month int,   
    @year int,   
    @brandId int,   
    @brandGroupId int,   
    @skuId int,   
    @rate FLOAT,   
    @qty int,   
    @isContractApplicable bit  
)   
AS       
SET NOCOUNT on;      
        BEGIN     
            declare @actualEnteredFor smallDateTime    
            set  @actualEnteredFor = (DATEFROMPARTS (@Year, @Month, 1))    
            if exists (select  
             1 from tblhospitalActuals WHERE empId = @empId and brandId = @brandId    
                    and brandGroupId = @brandGroupId and skuId = @skuId and ActualEnteredFor = @actualEnteredFor)   
                BEGIN   
                    -- disable the record  
                    UPDATE tblhospitalActuals set   
                        isDisabled = 1  
                    WHERE empId = @empId and brandId = @brandId    
                    and brandGroupId = @brandGroupId and skuId = @skuId 
                    and ActualEnteredFor = @actualEnteredFor  AND hospitalId = @hospitalId
                    -- insert a new record, this way we'll keep a record of past entry  
                    INSERT into tblhospitalActuals (empId, hospitalId, ActualEnteredFor, brandId, brandGroupId, skuId,    
                    rate, qty, isContractApplicable, isDisabled, finalStatus)   
                    VALUES(@empId, @hospitalId, @actualEnteredFor, @brandId, @brandGroupId, @skuId,    
                    @rate, @qty, @isContractApplicable, 0, 1)   
                    select 'true' as sucess, 'record updated sucessfully' as msg   
                END   
            ELSE   
                BEGIN   
                    INSERT into tblhospitalActuals (empId, hospitalId, ActualEnteredFor, brandId, brandGroupId, skuId,    
                    rate, qty, isContractApplicable, isDisabled, finalStatus)   
                    VALUES(@empId, @hospitalId, @actualEnteredFor, @brandId, @brandGroupId, @skuId,    
                    @rate, @qty, @isContractApplicable, 0, 1)   
                    select 'true' as sucess, 'record added sucessfully' as msg   
                END   
        END     
SET NOCOUNT OFF;     
  
/*  
select * from tblhospitalActuals where   
brandId = 1    
                    and brandGroupId = 1 and skuId = 1 and ActualEnteredFor = '2022-11-01'  
*/

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_add_update_BUSINESS_TRACKERv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--    

/*   

    USP_add_update_BUSINESS_TRACKER   

    24, 31, 2, 2023, 7,9,25, 99, 1, 0, "27-12-2022"   

*/    

--------------------------------------------       

-- CREATED BY: GURU SINGH       

-- CREATED DATE: 24-SEP-2022       

--------------------------------------------       

CREATE PROCEDURE [BSV_IVF].[USP_add_update_BUSINESS_TRACKERv1]       

(   

    @empId int,   

    @hospitalId int,   

    @month int,   

    @year int,   

    @brandId int,   

    @brandGroupId int,   

    @skuId int,   

    @rate FLOAT,   

    @qty int,   

    @isContractApplicable bit  

)   

AS       

SET NOCOUNT on;      

        BEGIN     

            declare @actualEnteredFor smallDateTime    

            set  @actualEnteredFor = (DATEFROMPARTS (@Year, @Month, 1))    

            if exists (select  

             1 from tblhospitalActuals WHERE empId = @empId and brandId = @brandId    

                    and brandGroupId = @brandGroupId and skuId = @skuId and ActualEnteredFor = @actualEnteredFor)   

                BEGIN   

                    -- disable the record  

                    UPDATE tblhospitalActuals set   

                        isDisabled = 1  

                    WHERE empId = @empId and brandId = @brandId    

                    and brandGroupId = @brandGroupId and skuId = @skuId 

                    and ActualEnteredFor = @actualEnteredFor  AND hospitalId = @hospitalId

                    -- insert a new record, this way we'll keep a record of past entry  

                    INSERT into tblhospitalActuals (empId, hospitalId, ActualEnteredFor, brandId, brandGroupId, skuId,    

                    rate, qty, isContractApplicable, isDisabled, finalStatus)   

                    VALUES(@empId, @hospitalId, @actualEnteredFor, @brandId, @brandGroupId, @skuId,    

                    @rate, @qty, @isContractApplicable, 0, 1)   

                    select 'true' as sucess, 'record updated sucessfully' as msg   

                END   

            ELSE   

                BEGIN   

                    INSERT into tblhospitalActuals (empId, hospitalId, ActualEnteredFor, brandId, brandGroupId, skuId,    

                    rate, qty, isContractApplicable, isDisabled, finalStatus)   

                    VALUES(@empId, @hospitalId, @actualEnteredFor, @brandId, @brandGroupId, @skuId,    

                    @rate, @qty, @isContractApplicable, 0, 1)   

                    select 'true' as sucess, 'record added sucessfully' as msg   

                END   

        END     

SET NOCOUNT OFF;     

  

/*  

select * from tblhospitalActuals where   

brandId = 1    

                    and brandGroupId = 1 and skuId = 1 and ActualEnteredFor = '2022-11-01'  

*/

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ADD_UPDATE_CHAIN_ACCOUNT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
USP_ADD_UPDATE_CHAIN_ACCOUNT null, 'ajay', 0
*/ 
------------------------------- 
-- CREATED BY: GURU SINGH 
-- CREATED DATE: 26-NOV-2022 
------------------------------- 
CREATE PROCEDURE [BSV_IVF].[USP_ADD_UPDATE_CHAIN_ACCOUNT]  
(
    @accountID INT = null,
    @name NVARCHAR(100),
    @isDisabled BIT

)
AS   
SET NOCOUNT ON;   
        
            IF @accountID is NULL 
                BEGIN
                    insert into tblChainAccountType (name, isDisabled)
                    VALUES (@name, @isDisabled)
                    select 'true' as sucess, 'record created successfully' as msg
                END
            ELSE
                BEGIN   
                    UPDATE tblChainAccountType
                        SET name = @name, 
                            isDisabled = @isDisabled
                    where accountid = @accountId
                    select 'true' as sucess, 'record updated successfully' as msg
                END
SET NOCOUNT OFF;   

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ADD_UPDATE_CUSTSOMER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
USP_ADD_UPDATE_CUSTSOMER  
    55, 'code', 'DoctorN1ame', 1, 1, '12345', 'mobile',  
                    'email', 'CENTRENAME', 'Address1', 'Address2', 'LocalArea', 'City',  
                    1, 'PinCode', 'ChemistMapped', 1, 1 , 1 , 3, '18-Dec-2022'
*/  
-------------------------------  
-- CREATED DATE: 26-NOV-2022  
-- CREATED BY: GURU SINGH  
-------------------------------  
CREATE PROCEDURE [BSV_IVF].[USP_ADD_UPDATE_CUSTSOMER]   
(    
  
    @customerId INT = NULL,  
    @code NVARCHAR(10),  
    @DoctorName NVARCHAR(100),  
    @visitId int,  
    @SpecialtyID int,  
    @DoctorUniqueCode NVARCHAR(100),  
    @mobile NVARCHAR(20),  
    @email NVARCHAR(20),  
    @CENTRENAME NVARCHAR(100),  
    @Address1 NVARCHAR(500),  
    @Address2 NVARCHAR(200),  
    @LocalArea NVARCHAR(200),  
    @City NVARCHAR(200),  
    @StateID INT,  
    @PinCode  NVARCHAR(20),  
    @ChemistMapped NVARCHAR(200),  
    @isDisabled bit,  
    @chainID int , 
    @chainAccountTypeId INT,
    @isRateContractApplicable smallInt,
    @contractEndDate smallDateTime

)    
AS    
SET NOCOUNT ON;    
        if (@customerId IS NULL)   
            BEGIN  
                declare @hospitalId int;
                -- INSERT  
                --select * from tblCustomers  
                INSERT INTO tblCustomers (  
                    code, DoctorName, visitId, SpecialtyID, DoctorUniqueCode, mobile,  
                    email, CENTRENAME, Address1, Address2, LocalArea, City,  
                    StateID, PinCode, ChemistMapped, isDisabled, chainID, chainAccountTypeId  
                    )  
                VALUES (@code, @DoctorName, @visitId, @SpecialtyID, @DoctorUniqueCode, @mobile,  
                    @email, @CENTRENAME, @Address1, @Address2, @LocalArea, @City,  
                    @StateID, @PinCode, @ChemistMapped, @isDisabled, @chainID, @chainAccountTypeId)  

                set @hospitalId = @@IDENTITY;

                if (@isRateContractApplicable = 0) 
                    BEGIN
                        insert into TblHospitalsContracts (hospitalId, contractEndDate, isContractSubmitted)
                        values (@hospitalId, @contractEndDate, 1)
                    END

                select 'true' as [sucess], 'USer added sucessfully' as msg  
            END  
        ELSE  
            BEGIN    
                -- UPDATE  
                    UPDATE tblCustomers SET  
                        code = @code,  
                        DoctorName = @DoctorName,  
                        visitId = @visitId,  
                        SpecialtyID = @SpecialtyID,  
                        DoctorUniqueCode = @DoctorUniqueCode,  
                        email = @email,  
                        mobile = @mobile,  
                        CENTRENAME = @CENTRENAME,  
                        Address1 = @Address1,  
                        Address2 = @Address2,  
                        LocalArea = @LocalArea,  
                        City = @City,  
                        StateID = @StateID,  
                        PinCode = @PinCode,  
                        ChemistMapped = @ChemistMapped,  
                        chainID = @chainID,  
                        isDisabled = @isDisabled , 
                        chainAccountTypeId = @chainAccountTypeId 
                    where customerId = @customerId  

                     if (@isRateContractApplicable = 5) 
                    BEGIN
                        if exists (select 1 from TblHospitalsContracts where hospitalId = @customerId)
                           BEGIN
                                UPDATE TblHospitalsContracts set 
                                        contractEndDate = @contractEndDate
                                where hospitalId = @customerId
                            END 
                        else
                            BEGIN
                                 insert into TblHospitalsContracts (hospitalId, contractEndDate, isContractSubmitted)
                                values (@customerId, @contractEndDate, 1)
                            END
                        
                    END
                    select 'true' as [sucess], 'USer updated sucessfully' as msg  
            END  
SET NOCOUNT OFF; 


/*
 select * from TblHospitalsContracts where hospitalId = 54
 */

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ADD_UPDATE_MARKET_INSIGHT_BY_KAM]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------    
-- CREATED BY: GURU SINGH    
-- CREATED DATE: 16-FEB-2023    
-------------------------------------------    
CREATE PROCEDURE [BSV_IVF].[USP_ADD_UPDATE_MARKET_INSIGHT_BY_KAM]    
(    
    @insightId INT = NULL,    
    @empId INT  = NULL,    
    @centreId INT  = NULL,    
    @month int  = NULL,       
    @year int   = NULL,     
    @answerOne BIT = NULL,    
    @AnswerTwo NVARCHAR(50) = NULL,    
    @answerThreeRFSH NVARCHAR(50) = NULL,    
    @answerThreeHMG NVARCHAR(50) = NULL,    
    @answerFourRHCG NVARCHAR(50) = NULL,    
    @answerFourAgonistL NVARCHAR(50) = NULL,    
    @answerFourAgonistT NVARCHAR(50) = NULL,    
    @answerFourRHCGTriptorelin NVARCHAR(50) = NULL,    
    @answerFourRHCGLeuprolide NVARCHAR(50) = NULL,    
    @answerProgesterone NVARCHAR(50) = NULL,    
    @answerFiveDydrogesterone NVARCHAR(50) = NULL,    
    @answerFiveCombination NVARCHAR(50) = NULL,  
    @answerFourUHCG    NVARCHAR(50) = NULL  
        
)    
AS    
    SET NOCOUNT ON;    
     declare @addedFor date      
     set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))  
     declare @newInsightID  int;

     if not exists (select 1 from tblMarketInsights where empid = @empId and centreId = @centreId and addedFor = @addedFor) 
        BEGIN
            set @newInsightID = null
        END
    ELSE
        BEGIN
            select  @newInsightID = insightId FROM tblMarketInsights where empid = @empId and centreId = @centreId and addedFor = @addedFor
        END

    if @newInsightID is null    
        begin    
            declare @newmarkingId int
            INSERT INTO tblMarketInsights (empId, centreId, addedFor,     
                    answerOne, AnswerTwo, answerThreeRFSH ,answerThreeHMG,    
                    answerFourRHCG, answerFourAgonistL, answerFourAgonistT ,answerFourRHCGTriptorelin, answerFourRHCGLeuprolide,    
                    answerProgesterone, answerFiveDydrogesterone, answerFiveCombination, answerFourUHCG, finalstatus, createddate)    
            VALUES (@empId, @centreId, @addedFor,     
                    @answerOne, @AnswerTwo, @answerThreeRFSH ,@answerThreeHMG,    
                    @answerFourRHCG, @answerFourAgonistL, @answerFourAgonistT, @answerFourRHCGTriptorelin, @answerFourRHCGLeuprolide,    
                    @answerProgesterone, @answerFiveDydrogesterone, @answerFiveCombination, @answerFourUHCG, 1, GETDATE())    
            set @newmarkingId = @@IDENTITY;
                if exists (select 1 from TblHospitalsPotentials where empid = @empId and hospitalId = @centreId and PotentialEnteredFor = @addedFor)
                    BEGIN
                            declare @infCycle int;
                            select @infCycle = IVFCycle from TblHospitalsPotentials  where empid = @empId and hospitalId = @centreId and PotentialEnteredFor = @addedFor
                            update tblMarketInsights set  AnswerTwo = @infCycle  where   insightId = @newmarkingId   
                            select * from tblMarketInsights
                    END
        end    
    else    
        begin    
            update tblMarketInsights set    
                    empId = empId,     
                    centreId = @centreId,     
                    answerOne = @answerOne,     
                    AnswerTwo = @AnswerTwo,     
                    answerThreeRFSH  = @answerThreeRFSH,    
                    answerThreeHMG = @answerThreeHMG,    
                    answerFourRHCG = @answerFourRHCG,     
                    answerFourAgonistL = @answerFourAgonistL,     
                    answerFourAgonistT  = @answerFourAgonistT,    
                    answerFourRHCGTriptorelin = @answerFourRHCGTriptorelin,     
                    answerFourRHCGLeuprolide = @answerFourRHCGLeuprolide,    
                    answerProgesterone = @answerProgesterone,     
                    answerFiveDydrogesterone = @answerFiveDydrogesterone,     
                    answerFiveCombination = @answerFiveCombination,   
                    answerFourUHCG = @answerFourUHCG,  
                    isApproved = 1, 
                    finalstatus = 1 
            where insightId = @newInsightID    
        end     
            
    SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ADD_UPDATE_MARKET_INSIGHT_BY_KAMv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------    

-- CREATED BY: GURU SINGH    

-- CREATED DATE: 16-FEB-2023    

-------------------------------------------    

CREATE PROCEDURE [BSV_IVF].[USP_ADD_UPDATE_MARKET_INSIGHT_BY_KAMv1]    

(    

    @insightId INT = NULL,    

    @empId INT  = NULL,    

    @centreId INT  = NULL,    

    @month int  = NULL,       

    @year int   = NULL,     

    @answerOne BIT = NULL,    

    @AnswerTwo NVARCHAR(50) = NULL,    

    @answerThreeRFSH NVARCHAR(50) = NULL,    

    @answerThreeHMG NVARCHAR(50) = NULL,    

    @answerFourRHCG NVARCHAR(50) = NULL,    

    @answerFourAgonistL NVARCHAR(50) = NULL,    

    @answerFourAgonistT NVARCHAR(50) = NULL,    

    @answerFourRHCGTriptorelin NVARCHAR(50) = NULL,    

    @answerFourRHCGLeuprolide NVARCHAR(50) = NULL,    

    @answerProgesterone NVARCHAR(50) = NULL,    

    @answerFiveDydrogesterone NVARCHAR(50) = NULL,    

    @answerFiveCombination NVARCHAR(50) = NULL,  

    @answerFourUHCG    NVARCHAR(50) = NULL  

        

)    

AS    

    SET NOCOUNT ON;    

     declare @addedFor date      

     set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))  

     declare @newInsightID  int;



     if not exists (select 1 from tblMarketInsights where empid = @empId and centreId = @centreId and addedFor = @addedFor) 

        BEGIN

            set @newInsightID = null

        END

    ELSE

        BEGIN

            select  @newInsightID = insightId FROM tblMarketInsights where empid = @empId and centreId = @centreId and addedFor = @addedFor

        END



    if @newInsightID is null    

        begin    

            declare @newmarkingId int

            INSERT INTO tblMarketInsights (empId, centreId, addedFor,     

                    answerOne, AnswerTwo, answerThreeRFSH ,answerThreeHMG,    

                    answerFourRHCG, answerFourAgonistL, answerFourAgonistT ,answerFourRHCGTriptorelin, answerFourRHCGLeuprolide,    

                    answerProgesterone, answerFiveDydrogesterone, answerFiveCombination, answerFourUHCG, finalstatus, createddate)    

            VALUES (@empId, @centreId, @addedFor,     

                    @answerOne, @AnswerTwo, @answerThreeRFSH ,@answerThreeHMG,    

                    @answerFourRHCG, @answerFourAgonistL, @answerFourAgonistT, @answerFourRHCGTriptorelin, @answerFourRHCGLeuprolide,    

                    @answerProgesterone, @answerFiveDydrogesterone, @answerFiveCombination, @answerFourUHCG, 1, GETDATE())    

            set @newmarkingId = @@IDENTITY;

                if exists (select 1 from TblHospitalsPotentials where empid = @empId and hospitalId = @centreId and PotentialEnteredFor = @addedFor)

                    BEGIN

                            declare @infCycle int;

                            select @infCycle = IVFCycle from TblHospitalsPotentials  where empid = @empId and hospitalId = @centreId and PotentialEnteredFor = @addedFor

                            update tblMarketInsights set  AnswerTwo = @infCycle  where   insightId = @newmarkingId   

                            select * from tblMarketInsights

                    END

        end    

    else    

        begin    

            update tblMarketInsights set    

                    empId = empId,     

                    centreId = @centreId,     

                    answerOne = @answerOne,     

                    AnswerTwo = @AnswerTwo,     

                    answerThreeRFSH  = @answerThreeRFSH,    

                    answerThreeHMG = @answerThreeHMG,    

                    answerFourRHCG = @answerFourRHCG,     

                    answerFourAgonistL = @answerFourAgonistL,     

                    answerFourAgonistT  = @answerFourAgonistT,    

                    answerFourRHCGTriptorelin = @answerFourRHCGTriptorelin,     

                    answerFourRHCGLeuprolide = @answerFourRHCGLeuprolide,    

                    answerProgesterone = @answerProgesterone,     

   answerFiveDydrogesterone = @answerFiveDydrogesterone,     

                    answerFiveCombination = @answerFiveCombination,   

                    answerFourUHCG = @answerFourUHCG,  

                    isApproved = 1, 

                    finalstatus = 1 

            where insightId = @newInsightID    

        end     

            

    SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ADD_UPDATE_SKU_COMPETITION]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [BSV_IVF].[USP_ADD_UPDATE_SKU_COMPETITION] (    
    @empId int,    
    @centerId int,    
    @brandId int,    
    @skuId int,    
    @month int,     
    @year int ,   
    @value float,  
    @comments ntext = null  
)    
AS    
    BEGIN    
        declare @competitionAddedFor smallDateTime    
        set  @competitionAddedFor = (DATEFROMPARTS (@Year, @Month, 1))    
        if Exists (    
                select 1 from tblCompetitions    
                where     
                centerId = @centerId AND    
                brandId = @brandId AND    
                competitionSkuId = @skuId and competitionAddedFor = @competitionAddedFor   
        )    
            BEGIN    
                UPDATE tblCompetitions    
                set     
                    businessValue = @value,  
                    comments = @comments, 
                    isApproved = 1,
                    status = 1
                where     
                    centerId = @centerId AND    
                    brandId = @brandId AND    
                    competitionSkuId = @skuId and competitionAddedFor = @competitionAddedFor   
   
                select 'true' as success, 'record updated successfully' as msg    
            END    
        else    
            BEGIN    
                INSERT into tblCompetitions (empId, centerId, brandId,     
                CompetitionSkuId, competitionAddedFor,     
                businessValue, comments, status)    
                VALUES (    
                    @empId, @centerId, @brandId,    
                    @skuId, @competitionAddedFor,    
                    @value, @comments, 1    
                )    
                select 'true' as success, 'record inserted successfully' as msg    
            END    
                
                
    END   
   
   
   -- alter table tblCompetitions add businessValue FLOAT 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ADD_UPDATE_SKU_COMPETITIONv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [BSV_IVF].[USP_ADD_UPDATE_SKU_COMPETITIONv1] (    

    @empId int,    

    @centerId int,    

    @brandId int,    

    @skuId int,    

    @month int,     

    @year int ,   

    @value float,  

    @comments ntext = null  

)    

AS    

    BEGIN    

        declare @competitionAddedFor smallDateTime    

        set  @competitionAddedFor = (DATEFROMPARTS (@Year, @Month, 1))    

        if Exists (    

                select 1 from tblCompetitions    

                where     

                centerId = @centerId AND    

                brandId = @brandId AND    

                competitionSkuId = @skuId and competitionAddedFor = @competitionAddedFor   

        )    

            BEGIN    

                UPDATE tblCompetitions    

                set     

                    businessValue = @value,  

                    comments = @comments, 

                    isApproved = 1,

                    status = 1

                where     

                    centerId = @centerId AND    

                    brandId = @brandId AND    

                    competitionSkuId = @skuId and competitionAddedFor = @competitionAddedFor   

   

                select 'true' as success, 'record updated successfully' as msg    

            END    

        else    

            BEGIN    

                INSERT into tblCompetitions (empId, centerId, brandId,     

                CompetitionSkuId, competitionAddedFor,     

                businessValue, comments, status)    

                VALUES (    

                    @empId, @centerId, @brandId,    

                    @skuId, @competitionAddedFor,    

                    @value, @comments, 1    

                )    

                select 'true' as success, 'record inserted successfully' as msg    

            END    

                

                

    END   

   

   

   -- alter table tblCompetitions add businessValue FLOAT 

GO
/****** Object:  StoredProcedure [BSV_IVF].[usp_all_CCM_report]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BSV_IVF].[usp_all_CCM_report]  
        as  
        BEGIN 
        
            SELECT  
        -- top 10  
        -- count(*) 
        [BSV_IVF].[getMyZBMInfo](e.EmpID) as zBM, 
        [BSV_IVF].[getMyRBMInfo](e.EmpID) as RBM, 
        e.EmpID,  
        e.firstname,  
        e.Designation 
        
        --top 100 1 
        ,c.customerId 
        ,DoctorName, c.mobile, c.email,    CENTRENAME, Address1, Address2, localarea,  
        city,  
        S.StateName,  
        PinCode, DoctorUniqueCode 
        ,ST.name as Specialty, VT.NAME as visitType, A.accountName 
        from tblcustomers C 
        INNER JOIN tblState S ON S.STATEID = C.StateID -- 8368  
        INNER JOIN tblSpecialtyType ST ON ST.specialtyId = C.SpecialtyId -- 8352 
        INNER JOIN tblVisitType VT ON VT.VISITiD = C.visitId -- 8352 
        left OUTER JOIN tblAccount A ON A.ACCOUNTID = C.accountID -- 5239 
        inner join tblEmpHospitals eh on eh.hospitalId = c.customerId -- 5747 
        inner join tblEmployees e on e.empId = eh.empId and e.isDisabled = 0 -- 5627 
        where customerId > 30 and c.isdisabled = 0 and c.SpecialtyId in (2)
        
        
        
        END 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_BUSINESS_TRACKER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_BUSINESS_TRACKER_DETAILS 38, 11, 2022 
  -------------------------------        
   -- CREATED BY: GURU SINGH        
   -- CREATED DATE: 26-NOV-2022        
   -------------------------------        
   CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_BUSINESS_TRACKER]    
   (  
       @customerId int, 
       @month int, 
       @year int, 
       @rbmId int  
   )            
    AS            
        SET NOCOUNT ON;                    
            BEGIN                      
                declare @actualEnteredFor smallDateTime  
                -- set  @actualEnteredFor = (DATEFROMPARTS (@Year, @Month, 1))  
                set  @actualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  
                 
                update tblhospitalActuals  
                    set isApproved = 0, 
                        approvedBy = @rbmId, 
                        approvedOn = GETDATE() 
                where hospitalId = @customerId  
                and ActualEnteredFor = @actualEnteredFor and isDisabled = 0   
                select 'true' as success, 'record approved sucessfully' as msg        
            END          
        SET NOCOUNT OFF; 

        -- select DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  

        -- select * from tblhospitalActuals  
        --         where ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0) and isDisabled = 0  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_BUSINESS_TRACKER_BY_HOSPITALID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_RBM_BUSINESS_LIST_FOR_APPROVAL 24     
--------------------------------------------          
-- CREATED BY: GURU SINGH          
-- CREATED DATE: 24-SEP-2022          
--------------------------------------------          
CREATE  PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_BUSINESS_TRACKER_BY_HOSPITALID]          
(      
    @customerId int,     
    @rbmId int,    
    @mode smallInt,    
    @rejectReason NVARCHAR(1000)       
)      
AS          
SET NOCOUNT on;         
        BEGIN       
        declare @desination NVARCHAR(3)  
        select top 1 @desination  = Designation from tblemployees where empID = @rbmId  
        if UPPER(@desination) = 'RBM'  
            BEGIN  
                update tblhospitalActuals     
                    set isApproved = @mode,     
                        approvedBy = @rbmId,     
                        approvedOn = GETDATE(),  
                        ZBMApproved = 1      
                    where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)      
                    -- where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)      
                    if (@mode = 2)    
                    BEGIN    
                        update tblhospitalActuals                  
                            set rejectedBy = @rbmId,                      
                                rejectedOn = GETDATE(),    
                                rejectComments = @rejectReason,    
                                approvedBy = NULL,                     
                                approvedOn = NULL,  
                                ZBMApproved = null,  
                                finalSTATUS = 2                          
                        where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)      
                        -- where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)      
                    END     
            END  
        ELSE  
            BEGIN  
                update tblhospitalActuals     
                    set isApproved = @mode,     
                        approvedBy = @rbmId,     
                        approvedOn = GETDATE(),  
                        ZBMApproved = @mode,  
                        finalSTATUS = 0       
                    where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)      
                    -- where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)      
                    if (@mode = 2)    
                    BEGIN    
                        update tblhospitalActuals                  
                            set rejectedBy = @rbmId,                      
                                rejectedOn = GETDATE(),    
                                rejectComments = @rejectReason,    
                                approvedBy = NULL,                     
                                approvedOn = NULL,  
                                finalSTATUS = 2                         
                        where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)      
                        -- where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)      
                    END     
            END  
        END     
SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_BUSINESS_TRACKER_BY_HOSPITALIDv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_RBM_BUSINESS_LIST_FOR_APPROVAL 24     



--------------------------------------------          



-- CREATED BY: GURU SINGH          



-- CREATED DATE: 24-SEP-2022          



--------------------------------------------          



CREATE  PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_BUSINESS_TRACKER_BY_HOSPITALIDv1]          



(      



    @customerId int,     



    @rbmId int,    



    @mode smallInt,    



    @rejectReason NVARCHAR(1000)       



)      



AS          



SET NOCOUNT on;         



        BEGIN       



        declare @desination NVARCHAR(3)  



        select top 1 @desination  = Designation from tblemployees where empID = @rbmId  



        if UPPER(@desination) = 'RBM'  



            BEGIN  



                update tblhospitalActuals     



                    set isApproved = @mode,     



                        approvedBy = @rbmId,     



                        approvedOn = GETDATE(),  



                        ZBMApproved = 1      



                    --where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)      --for feb



                    where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  --for jan     



                    if (@mode = 2)    



                    BEGIN    



                        update tblhospitalActuals                  



                            set rejectedBy = @rbmId,                      



                                rejectedOn = GETDATE(),    



                                rejectComments = @rejectReason,    



                                approvedBy = NULL,                     



                                approvedOn = NULL,  



                                ZBMApproved = null,  



                                finalSTATUS = 2                          



                        --where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)      --for feb  



                         where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)   --for jan   



                    END     



            END  



        ELSE  



            BEGIN  



                update tblhospitalActuals     



                    set isApproved = @mode,     



                        approvedBy = @rbmId,     



                        approvedOn = GETDATE(),  



                        ZBMApproved = @mode,  



                        finalSTATUS = 0       



                   -- where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)    --for feb  



                    where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  --for jan    



                    if (@mode = 2)    



                    BEGIN    



                        update tblhospitalActuals                  



                            set rejectedBy = @rbmId,                      



                                rejectedOn = GETDATE(),    



                                rejectComments = @rejectReason,    



                                approvedBy = NULL,                     



                                approvedOn = NULL,  



                                finalSTATUS = 2                         



                        --where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)    --for feb  



                        where hospitalId = @customerId and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)    -- for jan  



                    END     



            END  



        END     



SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_COMPETITION]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_APPROVE_CUSTOMER_COMPETITION 61, 12, 2022, 52    
 ------------------------------------------------   
 -- CREATED BY: GURU SINGH   
 -- CREATED DATE: 13-DEC-2022   
 ------------------------------------------------   
 CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_COMPETITION]   
 (    
    @hospitalId int,        
    @month int,    
    @year int ,    
    @rbmId Int, 
    @mode smallInt, 
    @rejectReason NVARCHAR(1000)        
) AS       
    SET NOCOUNT ON;           
        DECLARE @competitionId int     
         declare @competitionAddedFor smallDateTime   
            set  @competitionAddedFor = (DATEFROMPARTS (@year, @month, 1))   

                -- check if its rbmId is belong to rbm or zbm
                -- if rbm then execute the exisiting logic
                -- if zbm then update zbm related fields
            declare @desination NVARCHAR(3)
            select top 1 @desination  = Designation from tblemployees where empID = @rbmId
            if UPPER(@desination) = 'RBM'
                BEGIN
                    update tblCompetitions               
                        set 
                        isApproved = @mode,                   
                        approvedBy = @rbmId,                   
                        approvedOn = GETDATE(),
                        isZBMApproved = 1 
                    where centerId = @hospitalId and competitionAddedFor =  @competitionAddedFor 
                    if (@mode = 2) 
                    BEGIN 
                        update tblCompetitions               
                            set rejectedBy = @rbmId,                   
                                rejectedOn = GETDATE(), 
                                rejectComments = @rejectReason,  
                                approvedBy = NULL,                   
                                approvedOn = NULL,
                                isZBMApproved = null,
                                STATUS = 2  
                        where centerId = @hospitalId and competitionAddedFor =  @competitionAddedFor  
                    END      
                END
            ELSE  -- ZBM
                BEGIN
                    update tblCompetitions               
                        set 
                        ZBMId = @rbmId,                   
                        ZBMApprovedOn = GETDATE(),
                        isZBMApproved = @mode,
                        isApproved = @mode,
                         STATUS = 0  
                    where centerId = @hospitalId and competitionAddedFor =  @competitionAddedFor
                    if (@mode = 2) 
                    BEGIN 
                        update tblCompetitions               
                            set rejectedBy = @rbmId,                   
                                rejectedOn = GETDATE(), 
                                rejectComments = @rejectReason,  
                                approvedBy = NULL,                   
                                approvedOn = NULL,
                                STATUS = 2 
                        where centerId = @hospitalId and competitionAddedFor =  @competitionAddedFor  
                    END     
                END

                       
                select 'true' as success, 'record approved sucessfully' as msg        
        SET NOCOUNT OFF;  

 -- SELECT TOP 1 * FROM tblCompetitions

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_COMPETITIONv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_APPROVE_CUSTOMER_COMPETITION 61, 12, 2022, 52    

 ------------------------------------------------   

 -- CREATED BY: GURU SINGH   

 -- CREATED DATE: 13-DEC-2022   

 ------------------------------------------------   

 CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_COMPETITIONv1]   

 (    

    @hospitalId int,        

    @month int,    

    @year int ,    

    @rbmId Int, 

    @mode smallInt, 

    @rejectReason NVARCHAR(1000)        

) AS       

    SET NOCOUNT ON;           

        DECLARE @competitionId int     

         declare @competitionAddedFor smallDateTime   

            set  @competitionAddedFor = (DATEFROMPARTS (@year, @month, 1))   



                -- check if its rbmId is belong to rbm or zbm

                -- if rbm then execute the exisiting logic

                -- if zbm then update zbm related fields

            declare @desination NVARCHAR(3)

            select top 1 @desination  = Designation from tblemployees where empID = @rbmId

            if UPPER(@desination) = 'RBM'

                BEGIN

                    update tblCompetitions               

                        set 

                        isApproved = @mode,                   

                        approvedBy = @rbmId,                   

                        approvedOn = GETDATE(),

                        isZBMApproved = 1 

                    where centerId = @hospitalId and competitionAddedFor =  @competitionAddedFor 

                    if (@mode = 2) 

                    BEGIN 

                        update tblCompetitions               

                            set rejectedBy = @rbmId,                   

                                rejectedOn = GETDATE(), 

                                rejectComments = @rejectReason,  

                                approvedBy = NULL,                   

                                approvedOn = NULL,

                                isZBMApproved = null,

                                STATUS = 2  

                        where centerId = @hospitalId and competitionAddedFor =  @competitionAddedFor  

                    END      

                END

            ELSE  -- ZBM

                BEGIN

                    update tblCompetitions               

                        set 

                        ZBMId = @rbmId,                   

                        ZBMApprovedOn = GETDATE(),

                        isZBMApproved = @mode,

                        isApproved = @mode,

                         STATUS = 0  

                    where centerId = @hospitalId and competitionAddedFor =  @competitionAddedFor

                    if (@mode = 2) 

                    BEGIN 

                        update tblCompetitions               

                            set rejectedBy = @rbmId,                   

                                rejectedOn = GETDATE(), 

                                rejectComments = @rejectReason,  

                                approvedBy = NULL,                   

                                approvedOn = NULL,

                                STATUS = 2 

                        where centerId = @hospitalId and competitionAddedFor =  @competitionAddedFor  

                    END     

                END



                       

                select 'true' as success, 'record approved sucessfully' as msg        

        SET NOCOUNT OFF;  



 -- SELECT TOP 1 * FROM tblCompetitions

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_MARKET_INSIGHT_BY_RBM]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------
-- CREATED BY: GURU SINGH
-- CREATED DATE: 16-FEB-2023
-------------------------------------------
CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_MARKET_INSIGHT_BY_RBM]
(
    @insightId int,
    @rbmId Int,
    @mode smallInt,
    @rejectReason NVARCHAR(1000)  
    
)
AS
    SET NOCOUNT ON;
     declare @desination NVARCHAR(3)
     select top 1 @desination  = Designation from tblemployees where empID = @rbmId
     if UPPER(@desination) = 'RBM'
        BEGIN
            update tblMarketInsights
                set isApproved = @mode,
                    ApprovedBy = @rbmId,
                    ApprovedOn = GETDATE(),
                    rejectComments = null,
                    ZBMApproved = 1 
            where insightId = @insightId
            if (@mode = 2)
            BEGIN
                update tblMarketInsights              
                    set rejectedBy = @rbmId,                  
                        rejectedOn = GETDATE(),
                        rejectComments = @rejectReason,
                        ApprovedBy = null,
                        ApprovedOn = null,
                        ZBMApproved = null,
                        finalSTATUS = 2  
                where insightId = @insightId
            END   
        END
    ELSE
        BEGIN
            update tblMarketInsights
                set 
                    ZBMId = @rbmId,                   
                    ZBMApprovedOn = GETDATE(),
                    ZBMApproved = @mode,
                    isApproved = @mode,
                    rejectComments = null,
                    finalSTATUS = 0  
            where insightId = @insightId
            if (@mode = 2)
            BEGIN
                update tblMarketInsights              
                    set rejectedBy = @rbmId,                   
                        rejectedOn = GETDATE(), 
                        rejectComments = @rejectReason,  
                        approvedBy = NULL,                   
                        approvedOn = NULL,
                       finalSTATUS = 2 
                where insightId = @insightId
            END
        END
        select 'true' as success, 'record updated sucessfully' as msg 
    SET NOCOUNT OFF;


    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_MARKET_INSIGHT_BY_RBMv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------

-- CREATED BY: GURU SINGH

-- CREATED DATE: 16-FEB-2023

-------------------------------------------

CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_MARKET_INSIGHT_BY_RBMv1]

(

    @insightId int,

    @rbmId Int,

    @mode smallInt,

    @rejectReason NVARCHAR(1000)  

    

)

AS

    SET NOCOUNT ON;

     declare @desination NVARCHAR(3)

     select top 1 @desination  = Designation from tblemployees where empID = @rbmId

     if UPPER(@desination) = 'RBM'

        BEGIN

            update tblMarketInsights

                set isApproved = @mode,

                    ApprovedBy = @rbmId,

                    ApprovedOn = GETDATE(),

                    rejectComments = null,

                    ZBMApproved = 1 

            where insightId = @insightId

            if (@mode = 2)

            BEGIN

                update tblMarketInsights              

                    set rejectedBy = @rbmId,                  

                        rejectedOn = GETDATE(),

                        rejectComments = @rejectReason,

                        ApprovedBy = null,

                        ApprovedOn = null,

                        ZBMApproved = null,

                        finalSTATUS = 2  

                where insightId = @insightId

            END   

        END

    ELSE

        BEGIN

            update tblMarketInsights

                set 

                    ZBMId = @rbmId,                   

                    ZBMApprovedOn = GETDATE(),

                    ZBMApproved = @mode,

                    isApproved = @mode,

                    rejectComments = null,

                    finalSTATUS = 0  

            where insightId = @insightId

            if (@mode = 2)

            BEGIN

                update tblMarketInsights              

                    set rejectedBy = @rbmId,                   

                        rejectedOn = GETDATE(), 

                        rejectComments = @rejectReason,  

                        approvedBy = NULL,                   

                        approvedOn = NULL,

                       finalSTATUS = 2 

                where insightId = @insightId

            END

        END

        select 'true' as success, 'record updated sucessfully' as msg 

    SET NOCOUNT OFF;





    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_MasterData]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_APPROVE_CUSTOMER_POTENTIALS 24, 31, 24 
------------------------------------------------
-- CREATED BY: GURU SINGH
-- CREATED DATE: 13-DEC-2022
------------------------------------------------
CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_MasterData]
(
    @customerId int,
    @rbmId Int
    
)
AS
    SET NOCOUNT ON;
         UPDATE tblCustomers
            SET isApproved = 0,
                approvedBy = @rbmId,
                approvedOn = GETDATE()
        WHERE customerId = @customerId
        select 'true' as success, 'record approved sucessfully' as msg 
    SET NOCOUNT OFF;
    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_POTENTIALS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- USP_APPROVE_CUSTOMER_POTENTIALS 24, 31, 24 
------------------------------------------------
-- CREATED BY: GURU SINGH
-- CREATED DATE: 13-DEC-2022
------------------------------------------------
CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_POTENTIALS]
(
    @kamId int,  
    @hospitalId int ,
    @rbmId Int
    
)
AS
    SET NOCOUNT ON;
        DECLARE @potentialId int
         SELECT top 1 @potentialId = potentialID FROM TblHospitalsPotentials WHERE empId = @kamId and hospitalId = @hospitalId  
            order by potentialId desc  
        update TblHospitalsPotentials
            set isApproved = 0,
                approvedBy = @rbmId,
                approvedOn = GETDATE()
        where potentialID = @potentialId
        select 'true' as success, 'record approved sucessfully' as msg 
    SET NOCOUNT OFF;
    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_POTENTIALS_BY_POTENTIALID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_APPROVE_CUSTOMER_POTENTIALS 24, 31, 24     
 ------------------------------------------------    
 -- CREATED BY: GURU SINGH    
 -- CREATED DATE: 13-DEC-2022    
 ------------------------------------------------    
 CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_POTENTIALS_BY_POTENTIALID]    
 (       
    @potentialId int,        
    @rbmId Int,  
    @mode smallInt,  
    @rejectReason NVARCHAR(1000)           
)    
AS        
    SET NOCOUNT ON;            
        declare @desination NVARCHAR(3) 
        select top 1 @desination  = Designation from tblemployees where empID = @rbmId 
        if UPPER(@desination) = 'RBM' 
            BEGIN 
                UPDATE TblHospitalsPotentials                
                    set isApproved = @mode,                    
                    approvedBy = @rbmId,                    
                    approvedOn = GETDATE(), 
                    rejectComments = null,   
                    ZBMApproved = 1             
                where potentialID = @potentialId    
                if (@mode = 2)  
                BEGIN  
                    update TblHospitalsPotentials                
                        set rejectedBy = @rbmId,                    
                            rejectedOn = GETDATE(),  
                            rejectComments = @rejectReason,   
                            approvedBy = NULL,                    
                            approvedOn = NULL , 
                            ZBMApproved = null, 
                            finalSTATUS = 2             
                    where potentialID = @potentialId    
                END    
            END  
        ELSE 
            BEGIN 
                UPDATE TblHospitalsPotentials                
                set  
                -- isApproved = @mode,                    
                -- approvedBy = @rbmId,                    
                -- approvedOn = GETDATE()            
                    ZBMId = @rbmId,                    
                    ZBMApprovedOn = GETDATE(), 
                    rejectComments = null,   
                    ZBMApproved = @mode, 
                    isApproved = @mode, 
                    finalSTATUS = 0 
            where potentialID = @potentialId    
            if (@mode = 2)  
            BEGIN  
                update TblHospitalsPotentials                
                    set rejectedBy = @rbmId,                    
                        rejectedOn = GETDATE(),  
                        rejectComments = @rejectReason,   
                        approvedBy = NULL,                    
                        approvedOn = NULL, 
                       finalSTATUS = 2             
                where potentialID = @potentialId    
            END    
            END 
 
                 
        select 'true' as success, 'record approved sucessfully' as msg         
    SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_POTENTIALS_BY_POTENTIALIDv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_APPROVE_CUSTOMER_POTENTIALS 24, 31, 24     

 ------------------------------------------------    

 -- CREATED BY: GURU SINGH    

 -- CREATED DATE: 13-DEC-2022    

 ------------------------------------------------    

 CREATE PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_POTENTIALS_BY_POTENTIALIDv1]    

 (       

    @potentialId int,        

    @rbmId Int,  

    @mode smallInt,  

    @rejectReason NVARCHAR(1000)           

)    

AS        

    SET NOCOUNT ON;            

        declare @desination NVARCHAR(3) 

        select top 1 @desination  = Designation from tblemployees where empID = @rbmId 

        if UPPER(@desination) = 'RBM' 

            BEGIN 

                UPDATE TblHospitalsPotentials                

                    set isApproved = @mode,                    

                    approvedBy = @rbmId,                    

                    approvedOn = GETDATE(), 

                    rejectComments = null,   

                    ZBMApproved = 1             

                where potentialID = @potentialId    

                if (@mode = 2)  

                BEGIN  

                    update TblHospitalsPotentials                

                        set rejectedBy = @rbmId,                    

                            rejectedOn = GETDATE(),  

                            rejectComments = @rejectReason,   

                            approvedBy = NULL,                    

                            approvedOn = NULL , 

                            ZBMApproved = null, 

                            finalSTATUS = 2             

                    where potentialID = @potentialId    

                END    

            END  

        ELSE 

            BEGIN 

                UPDATE TblHospitalsPotentials                

                set  

                -- isApproved = @mode,                    

                -- approvedBy = @rbmId,                    

                -- approvedOn = GETDATE()            

                    ZBMId = @rbmId,                    

                    ZBMApprovedOn = GETDATE(), 

                    rejectComments = null,   

                    ZBMApproved = @mode, 

                    isApproved = @mode, 

                    finalSTATUS = 0 

            where potentialID = @potentialId    

            if (@mode = 2)  

            BEGIN  

                update TblHospitalsPotentials                

                    set rejectedBy = @rbmId,                    

                        rejectedOn = GETDATE(),  

                        rejectComments = @rejectReason,   

                        approvedBy = NULL,                    

                        approvedOn = NULL, 

                       finalSTATUS = 2             

                where potentialID = @potentialId    

            END    

            END 

 

                 

        select 'true' as success, 'record approved sucessfully' as msg         

    SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_APPROVE_CUSTOMER_RATE_CONTRACT_BY_CATID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_APPROVE_CUSTOMER_RATE_CONTRACT_BY_CATID 24 
--------------------------------------------      
-- CREATED BY: GURU SINGH      
-- CREATED DATE: 24-SEP-2022      
--------------------------------------------      
CREATE  PROCEDURE [BSV_IVF].[USP_APPROVE_CUSTOMER_RATE_CONTRACT_BY_CATID]      
(  
    @CATID int, 
    @ZbmId int 
)  
AS      
SET NOCOUNT on;     
        BEGIN   
        update tblChainAccountType 
        set isApproved = 0, 
            approvedBy = @ZbmId, 
            approvedOn = GETDATE() 
        where ACCOUNTID = @CATID 
        declare @CustomerAccountId int
        select @CustomerAccountId = customerAccountID from tblChainAccountType where accountID = @CATID
        --select * from tblCustomers where accountID = 1025
        update tblCustomers set chainAccountTypeId = @CATID where accountID = @CustomerAccountId
 
        END 
SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSV_ADD_UPDATE_SKU]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------  
-- CREATED BY: GURU SINGH  
-- CREATED DATE: 24-SEP-2022  
--------------------------------------------  
CREATE PROCEDURE [BSV_IVF].[USP_BSV_ADD_UPDATE_SKU]  
(
    @medID int = null,
    @brandId int,
    @brandGroupId int, 
    @medicineName nvarchar(200),
    @isDisabled bit,
    @Price FLOAT
)
AS  
SET NOCOUNT on; 
    if (@medID is null) 
        BEGIN
            insert into tblSkus (brandId, brandGroupId, medicineName, isDisabled, Price)
            values (@brandId, @brandGroupId, @medicineName, @isDisabled, @Price)
            select 'true' as sucess, 'SKU created sucessfully' as msg
        END
    ELSE
        BEGIN
            update tblSkus SET
                brandId = @brandId,
                brandGroupId = @brandGroupId,
                medicineName = @medicineName,
                isDisabled =  @isDisabled,
                Price = @Price
            where medID = @medID
            select 'true' as sucess, 'SKU updated sucessfully' as msg
        END
SET NOCOUNT OFF;  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSV_GET_MASTER_DATA]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
   
--------------------------------------------   
-- CREATED BY: GURU SINGH   
-- CREATED DATE: 24-SEP-2022   
--------------------------------------------   
CREATE PROCEDURE [BSV_IVF].[USP_BSV_GET_MASTER_DATA]   
AS   
SET NOCOUNT on;  
    SELECT stateId, stateName FROM tblState  WHERE isDisabled = 0 ORDER BY statename ASC   
    SELECT chainId, Name FROM tblChainStatus  WHERE isDisabled = 0 ORDER BY Name ASC   
    SELECT VisitID, Name FROM tblVisitType  WHERE isDisabled = 0 ORDER BY Name ASC   
    SELECT SpecialtyID, Name FROM tblSpecialtyType  WHERE isDisabled = 0 ORDER BY Name ASC   
    SELECT accountId, Name  FROM tblChainAccountType WHERE isDisabled = 0 ORDER BY Name ASC   
SET NOCOUNT OFF;   

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSV_GET_PERSON_ADD]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BSV_IVF].[USP_BSV_GET_PERSON_ADD] 
@Id int,
@FirstName nvarchar(255),
@LastName nvarchar(255),
@Age int
AS
	INSERT INTO Persons (Id, FirstName, LastName, Age)
	VALUES (@Id, @FirstName, @LastName, @Age)

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSV_GET_PERSON_LIST]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BSV_IVF].[USP_BSV_GET_PERSON_LIST]
AS
 select * from Persons
GO;

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSV_GET_SKU_LIST]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------  
-- CREATED BY: GURU SINGH  
-- CREATED DATE: 24-SEP-2022  
--------------------------------------------  
CREATE PROCEDURE [BSV_IVF].[USP_BSV_GET_SKU_LIST]  
AS  
SET NOCOUNT on; 
        BEGIN
           SELECT medID as SkuId, S.brandId, sg.brandName, S.brandGroupId, bg.groupName,  medicineName, price FROM tblSKUs S 
           INNER JOIN tblSkuGroup SG ON sg.brandId = s.brandId
           INNER JOIN tblBrandGroups BG ON s.brandGroupId = bg.brandGroupId
           where s.isDisabled = 0
        END
SET NOCOUNT OFF;  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSV_GET_SKU_MASTER_DATA]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------  
-- CREATED BY: GURU SINGH  
-- CREATED DATE: 24-SEP-2022  
--------------------------------------------  
create PROCEDURE [BSV_IVF].[USP_BSV_GET_SKU_MASTER_DATA]  
AS  
SET NOCOUNT on; 
    SELECT brandId, brandName FROM tblSkuGroup  WHERE isDisabled = 0 ORDER BY sortOrder ASC  
    SELECT brandGroupID, brandId, groupName FROM tblBrandGroups where isDisabled = 0 order by brandGroupId ASC
SET NOCOUNT OFF;  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSVIVF_GET_POTENTIALS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------  
 -- CREATED BY: GURU SINGH  
 -- CREATED DATE: 24-SEP-2022  
 --------------------------------------------  
CREATE PROCEDURE [BSV_IVF].[USP_BSVIVF_GET_POTENTIALS]
(  
    @hospitalId int = null,  
    @empId INT = NULL,
    @startDate smallDateTime = null,
    @endDate smallDateTime = null 
)  
AS  
SET NOCOUNT ON;  
   -- SELECT sum(CAST(IUICycle AS INT)) as IUICycle, sum(CAST(IVFCycle AS INT)) as IVFCycle FROM tblhospitalsPotentials 
    SELECT  * FROM tblhospitalsPotentials 
SET NOCOUNT OFF;  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSVIVF_REPORT_GET_BUSINESS_TRACKER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
--------------------------------------------   
 -- CREATED BY: GURU SINGH   
 -- CREATED DATE: 24-SEP-2022   
 --------------------------------------------   
 -- exec USP_BSVIVF_REPORT_GET_RCAgreement null, 999, null, null 
CREATE PROCEDURE [BSV_IVF].[USP_BSVIVF_REPORT_GET_BUSINESS_TRACKER]  
(   
    @hospitalId int = null,   
    @empId INT = null, 
    @startDate smallDateTime = null, 
    @endDate smallDateTime = null  
)   
AS   
SET NOCOUNT ON;   
 
select isNull(sum(rate*qty),0) as TotalSalesVAlue, g.brandId, isNull(sum(qty),0) totalUnit, g.brandName
from tblhospitalActuals a 
RIGHT join tblSkuGroup g on g.brandId = a.brandId 
group by g.brandId, g.brandName 

 
SET NOCOUNT OFF;   
 
 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSVIVF_REPORT_GET_BUSINESS_TRACKER_All_reports]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------  
 -- CREATED BY: GURU SINGH  
 -- CREATED DATE: 24-SEP-2022  
 --------------------------------------------  
 -- exec USP_BSVIVF_REPORT_GET_RCAgreement null, 999, null, null
CREATE PROCEDURE [BSV_IVF].[USP_BSVIVF_REPORT_GET_BUSINESS_TRACKER_All_reports] 
(  
    @hospitalId int = null,  
    @empId INT = null,
    @startDate smallDateTime = null,
    @endDate smallDateTime = null 
)  
AS  
SET NOCOUNT ON;  


select s.medicineName, isNull(round(sum(rate*qty),2),0) as TotalSalesVAlue, isNull(Qty,0) as Qty , 
isNull(a.brandId, 0) as brandId, g.brandName, ABS(CHECKSUM(NewId())) % 25 as Targets
from tblhospitalActuals a
RIGHT OUTER JOIN tblSKUs s on s.medID = a.skuId
inner join tblSkuGroup g on g.brandId = s.brandId
GROUP by  s.medicineName, qty, a.brandId , g.brandName
ORDER BY TotalSalesVAlue DESC

-- OLD QUERY 

-- select s.medicineName, round(sum(rate*qty),2) as TotalSalesVAlue, Qty , 
-- a.brandId, g.brandName,
-- ABS(CHECKSUM(NewId())) % 25 as Targets 
-- from tblhospitalActuals a
-- inner join tblSKUs s on s.medID = a.skuId
-- inner join tblSkuGroup g on g.brandId = a.brandId

-- GROUP by  s.medID, s.medicineName, qty, a.brandId, g.brandName


SET NOCOUNT OFF;  



GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_BSVIVF_REPORT_GET_RCAgreement]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------  
 -- CREATED BY: GURU SINGH  
 -- CREATED DATE: 24-SEP-2022  
 --------------------------------------------  
 -- exec USP_BSVIVF_REPORT_GET_RCAgreement null, 999, null, null
CREATE PROCEDURE [BSV_IVF].[USP_BSVIVF_REPORT_GET_RCAgreement] 
(  
    @hospitalId int = null,  
    @empId INT = null,
    @startDate smallDateTime = null,
    @endDate smallDateTime = null 
)  
AS  
SET NOCOUNT ON;  


CREATE TABLE #empHierarchy
(
    levels smallInt,
    EmpID INT,
    ParentId int
)
CREATE TABLE #tmpEmployee
(
    EmpID INT,
    ParentId int,
    EmpNumber NVARCHAR(200),
    FIRSTName nvarchar(200),
    Designation nvarchar(200),
    DesignationID int,
    zoneId int
);
;WITH     
        RecursiveCte     
        AS     
        (     
            SELECT 1 as Level, H1.EmpID, H1.ParentId     
                FROM tblHierarchy H1     
                WHERE H1.isdisabled = 0 and (@empid = 999 or ParentID = @empid)     
            UNION ALL     
                SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId     
                FROM tblHierarchy H2     
                    INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID and h2.isDisabled = 0     
        )     
    insert into #empHierarchy     
        (levels, EmpID, ParentId )     
    SELECT Level, EmpID, ParentId     
    FROM RecursiveCte r     
    ;     
  --  select * from #empHierarchy
    INSERT into #tmpEmployee     
        (EmpID, ParentId, EmpNumber, FIRSTName, Designation, DesignationID, zoneId)     
            select e.EmpID, ParentID, e.EmpNumber, e.firstName, e.Designation, e.DesignationID, e.ZoneID     
            from #empHierarchy r     
            INNER join tblEmployees e on r.empID = e.EmpID 
             where e.isDisabled = 0 and ParentId <> -1
  
   -- select * from #tmpEmployee  
        SELECT  e.ParentId as rbmId,      
            ee.firstName as RBM
           , count(h.hospitalId) as hospitalCount, 
             (
             select count(*) from tblEmpHospitals eh
                inner join tblhospitalSCONTRACTS hc on hc.hospitalID = eh.hospitalId and hc.contractEndDate > GETDATE()
            where empID in (select empID from tblHierarchy where parentID in (e.ParentId))
         ) as contract 
            FROM #tmpEmployee e
            INNER join tblEmployees ee on ee.EmpID = e.ParentId   
            RIGHT JOIN tblEmpHospitals eh on eh.empId = e.empId
            LEFT join tblhospitals h on h.hospitalId = eh.hospitalId
            group by  e.ParentId, ee.firstName
            order by ee.firstName ASC
        

        DROP TABLE #empHierarchy 
        DROP TABLE #tmpEmployee 
SET NOCOUNT OFF;  



GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_CHECK_IF_POTENTIAL_EXISTS_IF_NOT_ADD_ONE]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_CHECK_IF_POTENTIAL_EXISTS_IF_NOT_ADD_ONE 52
--------------------------------------------     
-- CREATED BY: GURU SINGH     
-- CREATED DATE: 24-SEP-2022     
--------------------------------------------     
CREATE PROCEDURE [BSV_IVF].[USP_CHECK_IF_POTENTIAL_EXISTS_IF_NOT_ADD_ONE]     
( 
    @parentId int
) 
AS     
SET NOCOUNT on;    
        BEGIN  
        DECLARE @empId int,
                @hospitalId int;

        DECLARE _CURSOR CURSOR READ_ONLY FOR
           select hospitalId, EmpID from tblEmpHospitals where empID in (select empId from tblHierarchy where parentID = @parentId)
            OPEN  _CURSOR    
           FETCH NEXT FROM _CURSOR INTO
                @hospitalId, @empId
            WHILE @@FETCH_STATUS = 0
            BEGIN        
               
                    if not exists (select top 1 * from tblhospitalsPotentials where 
                            PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) 
                            and empId  = @empId and hospitalId = @hospitalId
                    )
                        BEGIN
                            INSERT INTO tblhospitalsPotentials (empId, hospitalId, IUICycle, IVFCycle, FreshPickUps, SelftCycle, DonorCycles, AgonistCycles, IsActive, PotentialEnteredFor, frozenTransfers, Antagonistcycles)
                            select top 1 empId, hospitalId, IUICycle, IVFCycle, FreshPickUps, SelftCycle, DonorCycles, AgonistCycles, 0, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) , frozenTransfers, Antagonistcycles from tblhospitalsPotentials where 
                            empId  = @empId and hospitalId = @hospitalId order by potentialId DESC
                        END
                
                 PRINT @empId
                 print @hospitalId
                -- FETCH _CURSOR INTO  @empId
                FETCH NEXT FROM _CURSOR INTO
                     @hospitalId, @empId
            END
            CLOSE   _CURSOR
            DEALLOCATE  _CURSOR
        end
set NOCOUNT off;


GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_CREATE_RBM_RATE_CONTRACT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
 
USP_CREATE_RBM_RATE_CONTRACT 'sinedic', '12-Jan-2023', 1025, 52, 5 
select * from tblchainAccountType 
 
*/ 
--------------------------------------------        
-- CREATED BY: GURU SINGH        
-- CREATED DATE: 24-SEP-2022        
--------------------------------------------     
CREATE PROCEDURE [BSV_IVF].[USP_CREATE_RBM_RATE_CONTRACT] 
    ( 
    @contractDoc NVARCHAR(500), 
    @expiryDate DATE, 
    @CustomerAccountId int, 
    @rbmId int, 
    @accountId int,
    @startDate Date

) 
as 
set nocount on; 
BEGIN 
    -- set @accountId = null; 
    if @accountId = 0       
        BEGIN 
             
            INSERT INTO tblchainAccountType 
                (contractDoc, expiryDate, rbmId, customerAccountID, startDate) 
            VALUES 
                (@contractDoc, @expiryDate, @rbmId, @CustomerAccountId, @startDate) 
            select @@IDENTITY as outCome; 
        END             
    ELSE                
        BEGIN 
            update tblchainAccountType                     
            set contractDoc = @contractDoc,               
                expiryDate = @expiryDate,
                startDate = @startDate     
            where accountID = @accountId 
        END 
end 
set nocount off;      


GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_DELETE_CHAIN_ACCOUNT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
USP_DELETE_CHAIN_ACCOUNT 1
*/ 
------------------------------- 
-- CREATED BY: GURU SINGH 
-- CREATED DATE: 26-NOV-2022 
------------------------------- 
CREATE PROCEDURE [BSV_IVF].[USP_DELETE_CHAIN_ACCOUNT]  
(
    @accountId int
)
AS   
SET NOCOUNT ON;   
        UPDATE tblChainAccountType
            SET isDisabled = 1
        where accountid = @accountId
SET NOCOUNT OFF;   






GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_DELETE_CUSTSOMER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 ------------------------------- 
 -- CREATED BY: GURU SINGH 
 -- CREATED DATE: 26-NOV-2022 
 ------------------------------- 
CREATE PROCEDURE [BSV_IVF].[USP_DELETE_CUSTSOMER]  
    (        
        @customerId INT  
    )   
    AS   
    SET NOCOUNT ON;       
        BEGIN       
            -- UPDATE         
            UPDATE tblCustomers SET            
                isDisabled = 1         
            where customerId = @customerId     
        END 
    SET NOCOUNT OFF;   

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_DELETE_SKU]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------  
-- CREATED BY: GURU SINGH  
-- CREATED DATE: 24-SEP-2022  
--------------------------------------------  
create PROCEDURE [BSV_IVF].[USP_DELETE_SKU]  
(
    @skuId int
)
AS  
SET NOCOUNT on; 
        BEGIN
          update tblSKUs SET
            isDisabled = 1
          where medID = @skuId
        END
SET NOCOUNT OFF;  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ETL_CHECK_AND_INSERT_Account]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [BSV_IVF].[USP_ETL_CHECK_AND_INSERT_Account]
(
    @AccountName NVARCHAR(50)
)
as
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tblAccount WHERE AccountName = TRIM(@AccountName))
            BEGIN
                INSERT INTO tblAccount (AccountName, isactive)
                VALUES (TRIM(@AccountName), 0)
            END
    END

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ETL_CHECK_AND_INSERT_SPECIALTYTYPE]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BSV_IVF].[USP_ETL_CHECK_AND_INSERT_SPECIALTYTYPE]
(
    @Name NVARCHAR(50)
)
as
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tblSpecialtyType WHERE NAME = TRIM(@Name))
            BEGIN
                INSERT INTO tblSpecialtyType (Name, isDisabled)
                VALUES (TRIM(@Name), 0)
            END
    END

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_ETL_CHECK_AND_INSERT_VISITTYPE]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [BSV_IVF].[USP_ETL_CHECK_AND_INSERT_VISITTYPE]
(
    @Name NVARCHAR(50)
)
as
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM tblVisitType WHERE NAME = TRIM(@Name))
            BEGIN
                INSERT INTO tblVisitType (Name, isDisabled)
                VALUES (TRIM(@Name), 0)
            END
    END

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ADD_UPDATE_CENTER_POTENTIAL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MY_CENTER_LIST 24     
--------------------------------------------       
-- CREATED BY: GURU SINGH       
-- CREATED DATE: 24-SEP-2022       
--------------------------------------------       
CREATE PROCEDURE [BSV_IVF].[USP_GET_ADD_UPDATE_CENTER_POTENTIAL]       
(     
    @empId int,    
    @hospitalId int,    
    @IUICycle  int,    
    @IVFCycle int,    
    @FreshPickUps int,    
    @SelftCycle int,    
    @DonorCycles int,    
    @AgonistCycles int,    
    @frozenTransfers  int,    
    @Antagonistcycles int,    
    @Month int,     
    @Year int, 
    @visitID tinyint = null    
)     
AS       
SET NOCOUNT on;      
        BEGIN     
        declare @PotentialEnteredFor smallDateTime    
        set  @PotentialEnteredFor = (DATEFROMPARTS (@Year, @Month, 1))    
    
            IF NOT EXISTS (SELECT 1 FROM TblHospitalsPotentials WHERE empId = @empId and hospitalId = @hospitalId and PotentialEnteredFor = @PotentialEnteredFor)    
                BEGIN    
                    INSERT INTO TblHospitalsPotentials (empId, hospitalId, IUICycle,  IVFCycle, FreshPickUps, SelftCycle,     
                        DonorCycles, AgonistCycles, IsActive, PotentialEnteredFor,  frozenTransfers, Antagonistcycles, visitID, finalstatus)    
                    VALUES (@empId, @hospitalId, @IUICycle,  @IVFCycle, @FreshPickUps, @SelftCycle,     
                        @DonorCycles, @AgonistCycles, 0, @PotentialEnteredFor,  @frozenTransfers, @Antagonistcycles, @visitID, 1)    
                        select 'true' as sucess, 'Potentials created sucessfully' as msg   
                END    
            ELSE    
                BEGIN    
                    UPDATE  TblHospitalsPotentials SET    
                        IUICycle = @IUICycle,      
                        IVFCycle = @IVFCycle,     
                        FreshPickUps = @FreshPickUps,     
                        SelftCycle = @SelftCycle,     
                        DonorCycles = @DonorCycles,     
                        AgonistCycles = @AgonistCycles,    
                        frozenTransfers = @frozenTransfers,     
                        Antagonistcycles = @Antagonistcycles,  
                        isApproved = 1, 
                        finalstatus = 1 ,
                        visitID = @visitID       
                    WHERE empId = @empId and hospitalId = @hospitalId and PotentialEnteredFor = @PotentialEnteredFor    
                     select 'true' as sucess, 'Potentials updated sucessfully' as msg   
                END    
        END     
SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ADD_UPDATE_CENTER_POTENTIALv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MY_CENTER_LIST 24     

--------------------------------------------       

-- CREATED BY: GURU SINGH       

-- CREATED DATE: 24-SEP-2022       

--------------------------------------------       

CREATE PROCEDURE [BSV_IVF].[USP_GET_ADD_UPDATE_CENTER_POTENTIALv1]       

(     

    @empId int,    

    @hospitalId int,    

    @IUICycle  int,    

    @IVFCycle int,    

    @FreshPickUps int,    

    @SelftCycle int,    

    @DonorCycles int,    

    @AgonistCycles int,    

    @frozenTransfers  int,    

    @Antagonistcycles int,    

    @Month int,     

    @Year int, 

    @visitID tinyint = null    

)     

AS       

SET NOCOUNT on;      

        BEGIN     

        declare @PotentialEnteredFor smallDateTime    

        set  @PotentialEnteredFor = (DATEFROMPARTS (@Year, @Month, 1))    

    

            IF NOT EXISTS (SELECT 1 FROM TblHospitalsPotentials WHERE empId = @empId and hospitalId = @hospitalId and PotentialEnteredFor = @PotentialEnteredFor)    

                BEGIN    

                    INSERT INTO TblHospitalsPotentials (empId, hospitalId, IUICycle,  IVFCycle, FreshPickUps, SelftCycle,     

                        DonorCycles, AgonistCycles, IsActive, PotentialEnteredFor,  frozenTransfers, Antagonistcycles, visitID, finalstatus)    

                    VALUES (@empId, @hospitalId, @IUICycle,  @IVFCycle, @FreshPickUps, @SelftCycle,     

                        @DonorCycles, @AgonistCycles, 0, @PotentialEnteredFor,  @frozenTransfers, @Antagonistcycles, @visitID, 1)    

                        select 'true' as sucess, 'Potentials created sucessfully' as msg   

                END    

            ELSE    

                BEGIN    

                    UPDATE  TblHospitalsPotentials SET    

                        IUICycle = @IUICycle,      

                        IVFCycle = @IVFCycle,     

                        FreshPickUps = @FreshPickUps,     

                        SelftCycle = @SelftCycle,     

                        DonorCycles = @DonorCycles,     

                        AgonistCycles = @AgonistCycles,    

                        frozenTransfers = @frozenTransfers,     

                        Antagonistcycles = @Antagonistcycles,  

                        isApproved = 1, 

                        finalstatus = 1 ,

                        visitID = @visitID       

                    WHERE empId = @empId and hospitalId = @hospitalId and PotentialEnteredFor = @PotentialEnteredFor    

                     select 'true' as sucess, 'Potentials updated sucessfully' as msg   

                END    

        END     

SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ALL_SKU_BUSINESS_TRACKER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_ALL_SKU_BUSINESS_TRACKER 
--------------------------------------------    
-- CREATED BY: GURU SINGH    
-- CREATED DATE: 24-SEP-2022    
--------------------------------------------    
CREATE PROCEDURE [BSV_IVF].[USP_GET_ALL_SKU_BUSINESS_TRACKER]    
AS    
SET NOCOUNT on;   
        BEGIN  
            SELECT sg.brandId, sg.brandName, bg.brandGroupId, bg.groupName, s.medid, s.medicineName, s.Price    
            FROM tblSKUs s 
            INNER JOIN tblbrandGroups bg ON bg.brandGroupId = s.brandGroupId
            INNER JOIN tblSkuGroup sg ON s.brandId = sg.brandId
            WHERE s.isDisabled = 0
            ORDER BY sg.SORTORDER asc 
        END  
SET NOCOUNT OFF;  


GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_BUSINESS_REPORT_EMPLOYEE]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec USP_GET_BUSINESS_REPORT_EMPLOYEE 325,'2023-08-01','2023-08-31'
CREATE procedure [BSV_IVF].[USP_GET_BUSINESS_REPORT_EMPLOYEE]    
 (  
    @Empid int,
	@StartDate datetime=null,
	@EndDate datetime=null     
)  
AS    
   
BEGIN    
   	declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end

 
   
SELECT     
   
bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,     
   
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,     
   
-- e.empid,      
   
e.firstName as KamName, e.Designation,      
   
    
   
CENTRENAME, DoctorName, CITY,  hospitalId,                     
  
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 1,@empid,@StartDate,@enddate) as '[FOLIGRAF 900 IU/1.5 ML PEN]',   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 2,@empid,@StartDate,@enddate) as '[FOLIGRAF 1200 IU/2 ML PEN] ',   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 3,@empid,@StartDate,@enddate) as '[FOLIGRAF 450 IU/0.75 ML PEN]',   
            BSV_IVF.getActualsTargetAchieved(hospitalID, 1) as [FOLIGRAF PEN],                    
   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 4, @empid,@StartDate,@enddate) as [FOLIGRAF 1200 IU LYO MULTIDOSE],                     
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 5, @empid,@StartDate,@enddate) as [Foligraf 150 iu],                     
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 6, @empid,@StartDate,@enddate) as [Foligraf 150 iu PFS],                     
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 7, @empid,@StartDate,@enddate) as [Foligraf 225 PFS],                     
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 8, @empid,@StartDate,@enddate) as [Foligraf 300 PFS],                     
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 9, @empid,@StartDate,@enddate) as [Foligraf 75 iu],                     
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 10, @empid,@StartDate,@enddate) as [Foligraf 75 iu PFS],         
            BSV_IVF.getActualsTargetAchieved(hospitalID, 2) as [FOLIGRAF (LYO/PFS)],       
   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 11, @empid,@StartDate,@enddate) as [HP Humog 150 iu],    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 12, @empid,@StartDate,@enddate) as [HP Humog 75 iu],    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 13, @empid,@StartDate,@enddate) as [HuMoG  225 IU BP (Freeze Dried)],    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 14, @empid,@StartDate,@enddate) as [Humog 150 iu],    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 15, @empid,@StartDate,@enddate) as [Humog 75 iu],    
            BSV_IVF.getActualsTargetAchieved(hospitalID, 3) as [HUMOG LYO],     
    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 16, @empid,@StartDate,@enddate) as [Humog HD 1200 IU Liquid],    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 17, @empid,@StartDate,@enddate) as [Humog HD 600 IU Liquid],    
            BSV_IVF.getActualsTargetAchieved(hospitalID, 4) as [HUMOG LIQ (MD/PFS)],                     
   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 18, @empid,@StartDate,@enddate) as [ASPORELIX],    
            -- BSV_IVF.getActualsTargetAchieved(hospitalID, 5) as [ASPORELIX],                     
   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 19, @empid,@StartDate,@enddate) as [r – Hucog 6500 i.u. /0.5 ml],    
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 6) as [R-HUCOG],                     
   
   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 20, @empid,@StartDate,@enddate) as [Foliculin 150 iu],    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 21, @empid,@StartDate,@enddate) as [Foliculin 75 iu],    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 22, @empid,@StartDate,@enddate) as [HP Foliculin 150 iu],    
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 23, @empid,@StartDate,@enddate) as [HP Foliculin 75 iu],    
            BSV_IVF.getActualsTargetAchieved(hospitalID, 7) as [FOLICULIN],                     
   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 24, @empid,@StartDate,@enddate) as [Agotrig 0.1mg/ml in PFS TFD],    
            -- BSV_IVF.getActualsTargetAchieved(hospitalID, 8) as 'AGOTRIG',           
   
   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 25, @empid,@StartDate,@enddate) as [Dydrogesterone 10mg],    
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 9) as MIDYDROGEN ,                   
   
   
            BSV_IVF.getActualsTargetAchieved_SKU_Employee(hospitalID, 38, @empid,@StartDate,@enddate) as [SPRIMEO],    
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 10) as SPRIMEO,                   
   
            ha.isApproved, accountName,      
   
            case ha.isApproved                           
   
                when 1 then 'Pending'                           
   
when 0 then 'Approved'                           
   
                when 2 then 'Rejected'                 
   
            end as statusText,                       
   
            case ha.isApproved                           
   
                when 1 then 0                           
   
                when 0 then 1                           
   
                when 2 then 2                       
   
            end as sortOrder,    
   
            bsv_ivf.getEMPInfo(ha.approvedBy) AS ApprovedBy,     
   
            isNull(ha.approvedOn, '') as ApprovedOn,     
   
            bsv_ivf.getEMPInfo(ha.rejectedBy) AS RejectedBy,       
   
            ha.rejectedOn,     
   
            -- ha.rejectComments,     
   
            ha.ActualEnteredFor                    
   
            from TblHospitalactuals HA             
   
            inner join tblEmployees e on ha.empID = e.empID    
   
            INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                                 
   
            INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                                  
   
            left OUTER JOIN tblAccount a on a.accountID = c.accountID           
   
            WHERE 1 = 1                       
				and e.empid=@empid
              --and ActualEnteredFor = @dateAddedFor   
			  and (@fromdate is null or ha.ActualEnteredFor>=@fromdate)
		and (@todate is null or ha.ActualEnteredFor<=@todate)
   
            AND HA.isDisabled = 0                     
   
            group by CENTRENAME, DoctorName, CITY, hospitalId  , ha.isApproved, accountName,    
   
            e.empId,        ha.approvedBy   , ha.ApprovedOn   , ha.rejectedBy,   ha.rejectedOn,    
   
            firstName, Designation    
   
            -- , ha.rejectComments    
   
            , ha.ActualEnteredFor         
   
            order by e.firstName ASC      
   
    
   
    
   
END 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_BUSINESS_REPORT_FOR_EXCEL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_BUSINESS_REPORT_FOR_EXCEL 01,2024
CREATE procedure [BSV_IVF].[USP_GET_BUSINESS_REPORT_FOR_EXCEL]  
 (
    @month int,
    @year int
)
AS  
 
BEGIN  
   declare @dateAddedFor smallDateTime    
    set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))  
  
 
SELECT   
 
bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,   
 
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,   
 
-- e.empid,    
 
e.firstName as KamName, e.Designation,    
 
  
 
CENTRENAME, DoctorName, CITY,  hospitalId,                   
/* 
 
 
 
*/ 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 1, @month, @year) as '[FOLIGRAF 900 IU/1.5 ML PEN]', 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 2, @month, @year) as '[FOLIGRAF 1200 IU/2 ML PEN] ', 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 3, @month, @year) as '[FOLIGRAF 450 IU/0.75 ML PEN]', 
            BSV_IVF.getActualsTargetAchieved(hospitalID, 1) as [FOLIGRAF PEN],                  
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 4, @month, @year) as [FOLIGRAF 1200 IU LYO MULTIDOSE],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 5, @month, @year) as [Foligraf 150 iu],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 6, @month, @year) as [Foligraf 150 iu PFS],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 7, @month, @year) as [Foligraf 225 PFS],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 8, @month, @year) as [Foligraf 300 PFS],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 9, @month, @year) as [Foligraf 75 iu],                   
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 10, @month, @year) as [Foligraf 75 iu PFS],       
            BSV_IVF.getActualsTargetAchieved(hospitalID, 2) as [FOLIGRAF (LYO/PFS)],     
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 11, @month, @year) as [HP Humog 150 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 12, @month, @year) as [HP Humog 75 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 13, @month, @year) as [HuMoG  225 IU BP (Freeze Dried)],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 14, @month, @year) as [Humog 150 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 15, @month, @year) as [Humog 75 iu],  
            BSV_IVF.getActualsTargetAchieved(hospitalID, 3) as [HUMOG LYO],   
  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 16, @month, @year) as [Humog HD 1200 IU Liquid],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 17, @month, @year) as [Humog HD 600 IU Liquid],  
            BSV_IVF.getActualsTargetAchieved(hospitalID, 4) as [HUMOG LIQ (MD/PFS)],                   
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 18, @month, @year) as [ASPORELIX],  
            -- BSV_IVF.getActualsTargetAchieved(hospitalID, 5) as [ASPORELIX],                   
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 19, @month, @year) as [r – Hucog 6500 i.u. /0.5 ml],  
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 6) as [R-HUCOG],                   
 
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 20, @month, @year) as [Foliculin 150 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 21, @month, @year) as [Foliculin 75 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 22, @month, @year) as [HP Foliculin 150 iu],  
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 23, @month, @year) as [HP Foliculin 75 iu],  
            BSV_IVF.getActualsTargetAchieved(hospitalID, 7) as [FOLICULIN],                   
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 24, @month, @year) as [Agotrig 0.1mg/ml in PFS TFD],  
            -- BSV_IVF.getActualsTargetAchieved(hospitalID, 8) as 'AGOTRIG',                  
 
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 25, @month, @year) as [Dydrogesterone 10mg],  
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 9) as MIDYDROGEN ,                 
 
 
            BSV_IVF.getActualsTargetAchieved_SKU(hospitalID, 38, @month, @year) as [SPRIMEO],  
            --BSV_IVF.getActualsTargetAchieved(hospitalID, 10) as SPRIMEO,                 
 
            ha.isApproved, accountName,    
 
            case ha.isApproved                         
 
                when 1 then 'Pending'                         
 
when 0 then 'Approved'                         
 
                when 2 then 'Rejected'               
 
            end as statusText,                     
 
            case ha.isApproved                         
 
                when 1 then 0                         
 
                when 0 then 1                         
 
                when 2 then 2                     
 
            end as sortOrder,  
 
            bsv_ivf.getEMPInfo(ha.approvedBy) AS ApprovedBy,   
 
            isNull(ha.approvedOn, '') as ApprovedOn,   
 
            bsv_ivf.getEMPInfo(ha.rejectedBy) AS RejectedBy,     
 
            ha.rejectedOn,   
 
            -- ha.rejectComments,   
 
            ha.ActualEnteredFor                  
 
            from TblHospitalactuals HA           
 
            inner join tblEmployees e on ha.empID = e.empID  
 
            INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                               
 
            INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                                
 
            left OUTER JOIN tblAccount a on a.accountID = c.accountID         
 
            WHERE 1 = 1                     
 
              and ActualEnteredFor = @dateAddedFor                       
 
            -- and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                        
 
            AND HA.isDisabled = 0                   
 
            group by CENTRENAME, DoctorName, CITY, hospitalId  , ha.isApproved, accountName,  
 
            e.empId,        ha.approvedBy   , ha.ApprovedOn   , ha.rejectedBy,   ha.rejectedOn,  
 
            firstName, Designation  
 
            -- , ha.rejectComments  
 
            , ha.ActualEnteredFor       
 
            order by e.firstName ASC    
 
  
 
  
 
END  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_BUSINESS_TRACKER_DETAILS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_BUSINESS_TRACKER_DETAILS 31, 11, 2022
  -------------------------------       
   -- CREATED BY: GURU SINGH       
   -- CREATED DATE: 26-NOV-2022       
   -------------------------------       
   CREATE PROCEDURE [BSV_IVF].[USP_GET_BUSINESS_TRACKER_DETAILS]   
   ( 
       @customerId int,
       @month int,
       @year int 
   )           
    AS           
        SET NOCOUNT ON;                   
            BEGIN                     
                declare @actualEnteredFor smallDateTime 
                set  @actualEnteredFor = (DATEFROMPARTS (@Year, @Month, 1)) 
                select * from tblhospitalActuals where hospitalId = @customerId 
                and ActualEnteredFor = @actualEnteredFor and isDisabled = 0         
            END         
        SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_CENTERLIST_FOR_RBM_V1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_CENTERLIST_FOR_RBM_V1 52     
--------------------------------------------           
-- CREATED BY: GURU SINGH           
-- CREATED DATE: 24-SEP-2022           
--------------------------------------------        
CREATE PROCEDURE [BSV_IVF].[USP_GET_CENTERLIST_FOR_RBM_V1]       
(         
  @parentID int     
  )     
  as         
    -- set nocount on;             
      BEGIN                 
        SELECT   
        -- top 10                    
            a.accountName, a.accountId as aid,       
            case   
              when cat.isApproved = 1 then 'Approval Pending'   
              when cat.isApproved = 0 then 'Approved'   
              when cat.expiryDate < getdate() then 'Expired'   
              when cat.accountID is null then 'No Contract'   
            end as RateContractStatus,  
            case   
              when cat.isApproved = 1 then 0   
              when cat.isApproved = 0 then 1
              when cat.expiryDate < getdate() then 3   
              when cat.accountID is null then 4
            end as sortOrder, 
            isNull(cat.accountID, 0) as CatAccountId,   
            (select count(*) from TblContractDetails where isdisabled = 0 and chainAccountTypeId = cat.accountID) as SKUDetails,   
            c.* from tblCustomers C                  
            INNER JOIN tblEmpHospitals eh ON EH.hospitalId = c.customerId                
            INNER JOIN tblHierarchy H ON EH.EmpID = H.EmpID                 
            INNER JOIN tblaccount a on c.accountID = a.accountID     
            left join tblchainAccountType cat on cat.customerAccountID = c.accountID and  cat.isDisabled = 0           
            WHERE c.isdisabled = 0 and h.parentID = @parentID  and c.specialtyId in (2)     
            order by sortOrder ASC               
        END         
    -- set nocount off; 
 
 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_CHAIN_ACCOUNT_DETAILS_BY_ID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
USP_GET_CHAIN_ACCOUNT_DETAILS_BY_ID 1
*/ 
------------------------------- 
-- CREATED BY: GURU SINGH 
-- CREATED DATE: 26-NOV-2022 
------------------------------- 
CREATE PROCEDURE [BSV_IVF].[USP_GET_CHAIN_ACCOUNT_DETAILS_BY_ID]  
(
    @accountId int
)
AS   
SET NOCOUNT ON;   
       select *
         from tblChainAccountType ca
        where accountid = @accountId
SET NOCOUNT OFF;   





GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_CHAIN_ACCOUNT_LIST]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*   USP_GET_CHAIN_ACCOUNT_LIST  */   
-------------------------------   
-- CREATED BY: GURU SINGH   
-- CREATED DATE: 26-NOV-2022   
-------------------------------   
CREATE PROCEDURE [BSV_IVF].[USP_GET_CHAIN_ACCOUNT_LIST]    
AS     
    SET NOCOUNT ON;            
        select ca.accountID, ca.name,           
            CASE              
                WHEN ca.isDisabled = 0 THEN 'Yes'
                    ELSE 'No'          
            END as isDisabled           
        from tblChainAccountType ca              
        left outer join TblContractDetails cd on ca.accountID = cd.chainAccountTypeId          
        where ca.isDisabled = 0             
        group by ca.name, ca.isDisabled, ca.accountID  
    SET NOCOUNT OFF;        

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_COMPETITION_LIST_FOR_RBM]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_COMPETITION_LIST_FOR_RBM 61    
CREATE   PROCEDURE [BSV_IVF].[USP_GET_COMPETITION_LIST_FOR_RBM] (          
    @KamId int         
)          
AS          
    BEGIN          
       -- declare @competitionAddedFor smallDateTime          
        -- set  @competitionAddedFor = (DATEFROMPARTS (@Year, @Month, 1))          
        select centerId, c.CENTRENAME, c.DoctorName, c.City, c.SpecialtyId, st.name,       
            month(com.competitionAddedFor) as month, Year(com.competitionAddedFor) as year, com.isApproved,     
            accountName,     
            case com.isApproved    
                when 1 then 'Pending'    
                when 0 then 'Approved'    
                when 2 then 'Rejected'    
            end as statusText,    
            case com.isApproved    
                when 1 then 0    
                when 0 then 1    
                when 2 then 2    
            end as sortOrder    
        from tblCompetitions com         
        inner join tblCustomers c on com.centerID = c.customerId         
        left outer join tblAccount a on a.accountID = c.accountID     
        inner join tblSpecialtyType st on st.SpecialtyId = c.SpecialtyId         
        where      
        1 = 1     
       and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)     
       --  and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)     
        and empID = @KamId -- and com.isApproved = 1        
        GROUP by centerId, c.CENTRENAME, c.DoctorName, c.City, c.SpecialtyId, st.name ,       
        month(com.competitionAddedFor), Year(com.competitionAddedFor), com.isApproved , accountName       
        order by sortOrder ASC    
         
   
         
   
      select sg.brandName, bcs.name, com.CompetitionId, com.CompetitionSkuId, centerId, c.CENTRENAME, c.DoctorName, c.City,     
        month(com.competitionAddedFor) as month, Year(com.competitionAddedFor) as year, com.isApproved,    
          case com.isApproved    
                when 1 then 'Pending'    
                when 0 then 'Approved'    
                when 2 then 'Rejected'    
            end as statusText,    
            case com.isApproved    
                when 1 then 0    
                when 0 then 1    
                when 2 then 2    
            end as sortOrder,    
      com.businessValue   
        from tblCompetitions com    
        inner join tblSkuGroup sg on sg.brandId = com.brandId   
        inner join tblBrandcompetitorSKUs bcs on bcs.competitorId = com.CompetitionSkuId   
         inner join tblCustomers c on com.centerID = c.customerId         
        where      
       bcs.isDisabled = 0   
       and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)     
       -- and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)     
        and empID = @KamId   
           
   
    END    
   
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_COMPETITION_LIST_FOR_RBMv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_COMPETITION_LIST_FOR_RBM 61    



CREATE   PROCEDURE [BSV_IVF].[USP_GET_COMPETITION_LIST_FOR_RBMv1] (          
    @KamId int         
)          

AS          

    BEGIN          

       -- declare @competitionAddedFor smallDateTime          

        -- set  @competitionAddedFor = (DATEFROMPARTS (@Year, @Month, 1))          

        select centerId, c.CENTRENAME, c.DoctorName, c.City, c.SpecialtyId, st.name,       

            month(com.competitionAddedFor) as month, Year(com.competitionAddedFor) as year, com.isApproved,     

            accountName,     

            case com.isApproved    



                when 1 then 'Pending'    



                when 0 then 'Approved'    



                when 2 then 'Rejected'    



            end as statusText,    



            case com.isApproved    



                when 1 then 0    



                when 0 then 1    



                when 2 then 2    



            end as sortOrder    



        from tblCompetitions com         



        inner join tblCustomers c on com.centerID = c.customerId         



        left outer join tblAccount a on a.accountID = c.accountID     



        inner join tblSpecialtyType st on st.SpecialtyId = c.SpecialtyId         



        where      



        1 = 1     



      -- and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)     



        and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)     



        and empID = @KamId -- and com.isApproved = 1        



        GROUP by centerId, c.CENTRENAME, c.DoctorName, c.City, c.SpecialtyId, st.name ,       



        month(com.competitionAddedFor), Year(com.competitionAddedFor), com.isApproved , accountName       



        order by sortOrder ASC    



         



   



         



   



      select sg.brandName, bcs.name, com.CompetitionId, com.CompetitionSkuId, centerId, c.CENTRENAME, c.DoctorName, c.City,     



        month(com.competitionAddedFor) as month, Year(com.competitionAddedFor) as year, com.isApproved,    



          case com.isApproved    



                when 1 then 'Pending'    



                when 0 then 'Approved'    



                when 2 then 'Rejected'    



            end as statusText,    



            case com.isApproved    



                when 1 then 0    



                when 0 then 1    



                when 2 then 2    



            end as sortOrder,    



      com.businessValue   



        from tblCompetitions com    



        inner join tblSkuGroup sg on sg.brandId = com.brandId   



        inner join tblBrandcompetitorSKUs bcs on bcs.competitorId = com.CompetitionSkuId   



         inner join tblCustomers c on com.centerID = c.customerId         



        where      



       bcs.isDisabled = 0   



       --and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)     



        and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)     



        and empID = @KamId   



           



   



    END    



   

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_COMPETITION_LIST_FOR_ZBM]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_COMPETITION_LIST_FOR_ZBM 61     
CREATE   PROCEDURE [BSV_IVF].[USP_GET_COMPETITION_LIST_FOR_ZBM] (            
    @KamId int           
)            
AS            
    BEGIN            
       -- declare @competitionAddedFor smallDateTime            
        -- set  @competitionAddedFor = (DATEFROMPARTS (@Year, @Month, 1))            
        select centerId, c.CENTRENAME, c.DoctorName, c.City, c.SpecialtyId, st.name,         
            month(com.competitionAddedFor) as month, Year(com.competitionAddedFor) as year, isnull(com.isZBMApproved, 1) as isApproved,       
            accountName,       
            -- case com.isApproved      
            --     when 1 then 'Pending'      
            --     when 0 then 'Approved'      
            --     when 2 then 'Rejected'      
            -- end as RBMstatusText,      
            case com.isZBMApproved      
                when 1 then 'Pending'      
                when 0 then 'Approved'      
                when 2 then 'Rejected'      
            end as statusText,     
            case com.isZBMApproved      
                when 1 then 0      
                when 0 then 1      
                when 2 then 2      
            end as sortOrder      
        from tblCompetitions com           
        inner join tblCustomers c on com.centerID = c.customerId           
         left outer JOIN tblAccount a on a.accountID = c.accountID       
        inner join tblSpecialtyType st on st.SpecialtyId = c.SpecialtyId           
        where        
        1 = 1       
        and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)       
        -- and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)       
        and empID = @KamId and com.isApproved <> 1      
        GROUP by centerId, c.CENTRENAME, c.DoctorName, c.City, c.SpecialtyId, st.name ,         
        month(com.competitionAddedFor), Year(com.competitionAddedFor), com.isApproved , accountName , com.isZBMApproved        
        order by sortOrder ASC      
           
    
    
           
     
      select sg.brandName, bcs.name, com.CompetitionId, com.CompetitionSkuId, centerId, c.CENTRENAME, c.DoctorName, c.City,       
        month(com.competitionAddedFor) as month, Year(com.competitionAddedFor) as year, com.isApproved,      
          case com.isZBMApproved      
                when 1 then 'Pending'      
                when 0 then 'Approved'      
                when 2 then 'Rejected'      
            end as statusText,      
            case com.isZBMApproved      
                when 1 then 0      
                when 0 then 1      
                when 2 then 2      
            end as sortOrder,      
      com.businessValue     
        from tblCompetitions com      
        inner join tblSkuGroup sg on sg.brandId = com.brandId     
        inner join tblBrandcompetitorSKUs bcs on bcs.competitorId = com.CompetitionSkuId     
         inner join tblCustomers c on com.centerID = c.customerId           
        where        
       bcs.isDisabled = 0     
        and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)       
        -- and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)       
        and empID = @KamId and com.isApproved <> 1     
    
    END 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_COMPETITION_LIST_FOR_ZBMv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_COMPETITION_LIST_FOR_ZBM 61     



CREATE   PROCEDURE [BSV_IVF].[USP_GET_COMPETITION_LIST_FOR_ZBMv1] (            



    @KamId int           



)            



AS            



    BEGIN            



       -- declare @competitionAddedFor smallDateTime            



        -- set  @competitionAddedFor = (DATEFROMPARTS (@Year, @Month, 1))            



        select centerId, c.CENTRENAME, c.DoctorName, c.City, c.SpecialtyId, st.name,         



            month(com.competitionAddedFor) as month, Year(com.competitionAddedFor) as year, isnull(com.isZBMApproved, 1) as isApproved,       



            accountName,       



            -- case com.isApproved      



            --     when 1 then 'Pending'      



            --     when 0 then 'Approved'      



            --     when 2 then 'Rejected'      



            -- end as RBMstatusText,      



            case com.isZBMApproved      



                when 1 then 'Pending'      



                when 0 then 'Approved'      



                when 2 then 'Rejected'      



            end as statusText,     



            case com.isZBMApproved      



                when 1 then 0      



                when 0 then 1      



                when 2 then 2      



            end as sortOrder      



        from tblCompetitions com           



        inner join tblCustomers c on com.centerID = c.customerId           



         left outer JOIN tblAccount a on a.accountID = c.accountID       



        inner join tblSpecialtyType st on st.SpecialtyId = c.SpecialtyId           



        where        



        1 = 1       



        --and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)       



        and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)       



        and empID = @KamId and com.isApproved <> 1      



        GROUP by centerId, c.CENTRENAME, c.DoctorName, c.City, c.SpecialtyId, st.name ,         



        month(com.competitionAddedFor), Year(com.competitionAddedFor), com.isApproved , accountName , com.isZBMApproved        



        order by sortOrder ASC      



           



    



    



           



     



      select sg.brandName, bcs.name, com.CompetitionId, com.CompetitionSkuId, centerId, c.CENTRENAME, c.DoctorName, c.City,       



        month(com.competitionAddedFor) as month, Year(com.competitionAddedFor) as year, com.isApproved,      



          case com.isZBMApproved      



                when 1 then 'Pending'      



                when 0 then 'Approved'      



                when 2 then 'Rejected'      



            end as statusText,      



            case com.isZBMApproved      



                when 1 then 0      



                when 0 then 1      



                when 2 then 2      



            end as sortOrder,      



      com.businessValue     



        from tblCompetitions com      



        inner join tblSkuGroup sg on sg.brandId = com.brandId     



        inner join tblBrandcompetitorSKUs bcs on bcs.competitorId = com.CompetitionSkuId     



         inner join tblCustomers c on com.centerID = c.customerId           



        where        



       bcs.isDisabled = 0     



       -- and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)       



        and  competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)       



        and empID = @KamId and com.isApproved <> 1     



    



    END 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_COMPETITION_REPORT_EMPLOYEE]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  exec USP_GET_COMPETITION_REPORT_EMPLOYEE 325,'2023-01-01','2023-08-31'  
CREATE PROCEDURE [BSV_IVF].[USP_GET_COMPETITION_REPORT_EMPLOYEE]     
(   
    @Empid int,
	@StartDate datetime=null,
	@EndDate datetime=null     
)   
 AS     
 BEGIN     
    
    -- declare @dateAddedFor smallDateTime       
    --set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))     

	declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end

    
select bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,      
    
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,      
e.firstName as KamName, e.Designation,       
c.CENTRENAME as centreName,  c.DoctorName,   
com.centerId as centerId,          
    
    bsv_ivf.getCompetationTotalforHospitalAndBrand_Employee(centerId, 1, @empid, @startdate,@enddate) as 'FOLIGRAF', 
    bsv_ivf.getCompetationTotalforHospitalAndBrand_Employee(centerId, 2, @empid, @startdate,@enddate) as 'HUMOG',     
    bsv_ivf.getCompetationTotalforHospitalAndBrand_Employee(centerId, 3, @empid, @startdate,@enddate) as 'ASPORELIX', 
    bsv_ivf.getCompetationTotalforHospitalAndBrand_Employee(centerId, 4, @empid, @startdate,@enddate) as 'R-HUCOG',   
    bsv_ivf.getCompetationTotalforHospitalAndBrand_Employee(centerId, 5, @empid, @startdate,@enddate) as 'FOLICULIN', 
    bsv_ivf.getCompetationTotalforHospitalAndBrand_Employee(centerId, 6, @empid, @startdate,@enddate) as 'AGOTRIG',   
    bsv_ivf.getCompetationTotalforHospitalAndBrand_Employee(centerId, 7, @empid, @startdate,@enddate) as 'MIDYDROGEN',     
    
     case com.isApproved                          
    
                    when 1 then 'Pending'                          
    
                    when 0 then 'Approved'                          
    
                    when 2 then 'Rejected'                      
    
                end as statusText,      
    
bsv_ivf.getEMPInfo(com.approvedBy) AS ApprovedBy,      
    
isNull(com.approvedOn, '') as ApprovedOn,      
    
bsv_ivf.getEMPInfo(com.rejectedBy) AS RejectedBy,      
    
 com.rejectedOn,      
    
-- com.rejectComments,      
    
com.competitionAddedFor       
    
from tblCompetitions com     
    
inner join tblcustomers c on c.customerID = com.centerId     
    
inner join tblEmployees e on e.empid = com.empId      
    
where      
    
1 = 1     
    
 --and  competitionAddedFor = @dateAddedFor      
    and com.empid=@Empid	
		and (@fromdate is null or com.competitionAddedFor>=@fromdate)
		and (@todate is null or com.competitionAddedFor<=@todate)
group by e.empid, e.firstName, e.Designation,       
    
c.CENTRENAME,  c.DoctorName, com.centerId, com.isApproved,     
    
com.approvedBy, com.approvedOn, com.rejectedBy, com.rejectedOn, com.competitionAddedFor      
    
     
    
 order by e.firstName ASC     
    
     
    
     
    
     
    
END     
    
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_CONTRACT_DETAILS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/*  
USP_GET_CONTRACT_DETAILS 0 
*/  

-------------------------------  
-- CREATED BY: GURU SINGH  
-- CREATED DATE: 26-NOV-2022  
-------------------------------  
CREATE PROCEDURE [BSV_IVF].[USP_GET_CONTRACT_DETAILS]   
(    
  
    @chainAccountTypeId INT 
)    
AS    
SET NOCOUNT ON;    
        if @chainAccountTypeId = 0
            begin
                select 'Standard Rate' as RateType, brandId, brandGroupId, price as SkuPrice, medId from tblSKUs where isDisabled = 0 
            end
        else
            begin
                SELECT 'contract Rate' as RateType, BrandId, brandGroupId, medId, Price as SkuPrice 
                    FROM TblContractDetails WHERE chainAccountTypeId = @chainAccountTypeId and isDisabled = 0 
            end
       

SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_CUSTSOMER_DETAILS_BY_ID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_GET_CUSTSOMER_DETAILS_BY_ID 54
 -------------------------------  
 -- CREATED BY: GURU SINGH  
 -- CREATED DATE: 26-NOV-2022  
 -------------------------------  
 CREATE PROCEDURE [BSV_IVF].[USP_GET_CUSTSOMER_DETAILS_BY_ID]  
    (        
     @customerId INT   
    )    
    AS    
    SET NOCOUNT ON;        
        BEGIN            
        SELECT c.*, 
            case  
                when hc.contractEndDate is null then 'NO'
                else 'YES' 
                end as isContractApplicable,
                convert(nvarchar(20), hc.contractEndDate, 106) as contractEndDate
            FROM tblCustomers c
            left outer join TblHospitalsContracts hc on hc.hospitalId = c.customerId and contractEndDate >= GETDATE()      
            WHERE customerId = @customerId      
        END  
    SET NOCOUNT OFF; 


GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_CUSTSOMER_LIST]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_CUSTSOMER_LIST 74     
  -------------------------------            
   -- CREATED BY: GURU SINGH            
   -- CREATED DATE: 26-NOV-2022            
   -------------------------------            
   CREATE PROCEDURE [BSV_IVF].[USP_GET_CUSTSOMER_LIST]        
   (      
       @empId int      
   )                
    AS                
        SET NOCOUNT ON;                        
            BEGIN                          
                SELECT 
                ISNULL(C.CENTRENAME, '-NA-') AS CENTRENAME,
                C.city,  C.DoctorName, c.mobile, c.email, c.address1,  c.Address2, c.City, c.PinCode ,
                -- C.*, 
                s.stateName,    
                '' as ChainStatusName,    
                vt.name as VisitType, st.name as specialtyType ,     
                case      
                    when   isApproved = 1 then 'No'     
                    when isApproved  = 0   then 'Yes'     
                end as IsApproved ,   
                ISNULL(a.accountName, '-NA-') AS accountName
                FROM tblCustomers c     
                    LEFT OUTER join tblAccount a on a.accountID = c.accountID      
                    inner join tblEmpHospitals eh on c.customerId = eh.hospitalId                        
                    inner join tblstate s   on s.stateID = c.stateID                     
--                   inner join tblChainStatus cs on cs.chainID = c.chainID        
                    inner join tblVisitType vt on vt.visitId = c.visitId        
                    inner join tblSpecialtyType st on st.specialtyId = c.specialtyId        
                    where c.isDisabled = 0     and eh.EmpID = @empId      
                    ORDER BY c.centrename asc                     
            END              
        SET NOCOUNT OFF;    
 
 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_EMPLOYEE_BASED_ON_DESIGNATION]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_EMPLOYEE_BASED_ON_DESIGNATION 'rbm'
-------------------------------------------
-- CREATED BY: GURU SINGH
-- CREATED DATE: 10-Mar-2023
-------------------------------------------
CREATE PROCEDURE [BSV_IVF].[USP_GET_EMPLOYEE_BASED_ON_DESIGNATION]
(
    @desingnation nvarchar(100) = null
)
AS
    BEGIN
        select h.ParentID, e.* from tblEmployees e
        inner join tblHierarchy h on h.empID = e.empID
        where e.isDisabled = 0 

        and Designation = @desingnation or @desingnation is NULL
        and e.empId > 60
        order by e.empID ASC
    END



GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_Employee_Business]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [USP_GET_Employee_Business] 837,'2023-03-05','2023-03-05'
Create proc [BSV_IVF].[USP_GET_Employee_Business]
(
	@Empid int,
	@StartDate datetime=null,
	@EndDate datetime=null
)
as
Begin

	declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end

	
	Select bg.groupName as BrandGroupName,b.brandName, s.medicinename,h.DoctorName,ha.* 
	from tblCustomers h
		inner join tblhospitalActuals ha on h.customerId=ha.hospitalid
			left outer join tblBrandGroups bg on ha.brandgroupid=bg.brandgroupid
			left outer join tblSkuGroup b on ha.brandId=b.brandId
			left outer join BSV_IVF.tblSKUs s on ha.skuid=s.medid
	where ha.empid=@Empid	
		and (@fromdate is null or ha.createdDate>=@fromdate)
		and (@todate is null or ha.CreatedDate<=@todate)
End

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_EMPLOYEE_CUSTOMER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [BSV_IVF].[USP_GET_EMPLOYEE_CUSTOMER]
as
Begin
Select bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,          
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,          
e.firstname as Employee,e.designation, case when e.isDisabled=0 then 'Active' else 'InActive' end as EmployeeStatus,
isnull(c.CENTRENAME,'') as CentreName,isnull( c.DoctorName,'') as DoctorName, isnull(c.Code,'') as Code
,case when c.isDisabled=0 then 'Active' else 'InActive' end as CentreStatus,isnull( a.accountname,'') as AccountName
,isnull(st.[name],'') as  Specialty
from tblEmployees e
	left outer join tblEmpHospitals eh on e.empid=eh.empid
		left outer join tblCustomers c on eh.hospitalid=c.customerid
			left outer join tblAccount a on c.accountid=a.accountid
			left outer join tblSpecialtyType st on c.SpecialtyId=st.SpecialtyId
order by e.firstName,c.CENTRENAME
End
	

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_Employee_Potentials]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [USP_GET_Employee_Potentials] 837,'2023-03-05','2023-03-05'
CREATE proc [BSV_IVF].[USP_GET_Employee_Potentials]
(
	@Empid int,
	@StartDate datetime=null,
	@EndDate datetime=null
)
as
Begin

	declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end

	--select @StartDate,@EndDate,@fromdate,@todate
	Select * 
	from tblCustomers h
	inner join TblHospitalsPotentials hp on h.customerId=hp.hospitalid
	where hp.empid=@Empid
		and (@fromdate is null or hp.createdDate>=@fromdate)
		and (@todate is null or hp.CreatedDate<=@todate)
End

GO
/****** Object:  StoredProcedure [BSV_IVF].[usp_get_EmployeeDetails_By_ID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure  [BSV_IVF].[usp_get_EmployeeDetails_By_ID] ( 
    @empId int 
) 
as 
    begin 
        select * from tblEmployees where empID = @empId and isDisabled = 0 
    end

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_GET_CENTER_POTENTIAL_DETAILS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MY_CENTER_LIST 24  
--------------------------------------------    
-- CREATED BY: GURU SINGH    
-- CREATED DATE: 24-SEP-2022    
--------------------------------------------    
CREATE PROCEDURE [BSV_IVF].[USP_GET_GET_CENTER_POTENTIAL_DETAILS]    
(  
    @empId int, 
    @hospitalId int 
)  
AS    
SET NOCOUNT on;   
        BEGIN  
 
            SELECT top 1 * FROM TblHospitalsPotentials WHERE empId = @empId and hospitalId = @hospitalId 
            order by potentialId desc 
        END  
SET NOCOUNT OFF;    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_MARKET_INSIGHT_REPORT_EMPLOYEE]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MARKET_INSIGHT_REPORT_FOR_EXCEL 1, 2023    
CREATE PROCEDURE [BSV_IVF].[USP_GET_MARKET_INSIGHT_REPORT_EMPLOYEE]       
    (    
        @Empid int,
	@StartDate datetime=null,
	@EndDate datetime=null     
    )    
AS      
BEGIN      
    declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end

     
select       
    bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,        
    bsv_ivf.getMyRBMInfo(e.empid) AS RBM,        
    -- e.empid,         
    e.firstName as KamName, e.Designation,         
    -- c.customerId,         
    c.CENTRENAME as centreName,  c.DoctorName,        
    c.customerId,         
    case       
    when hp.answerone = 1 then 'Yes'      
    else 'No'      
    end as 'Practice Obstetrics',      
    (   
        select top 1 ivfcycle from TblHospitalsPotentials where HOSPITALID = c.customerId  
		--and PotentialEnteredFor = @dateAddedFor 
		and  empid=@Empid	
		and (@fromdate is null or PotentialEnteredFor>=@fromdate)
		and (@todate is null or PotentialEnteredFor<=@todate)
		and isActive = 0    
    ) as 'Fresh Stimulated Cycles',   
    -- hp.AnswerTwo as 'Fresh Stimulated Cycles',      
    -- hpp.IVFCycle as 'Fresh Stimulated Cycles',      
    hp.answerThreeRFSH as 'RFSH %',      
    hp.answerThreeHMG as 'HMG %',      
    hp.answerProgesterone as 'Progesterone %',      
    hp.answerFiveDydrogesterone as 'Dydrogesterone %',      
    hp.answerFiveCombination as 'Combination %',      
    hp.answerFourRHCG as 'RHCG %',      
    hp.answerFourUHCG as 'UHCG %',      
    hp.answerFourAgonistL as 'Agonist-Leuprolide %',      
    hp.answerFourAgonistT as 'Agonist-Triptorelin %',      
    hp.answerFourRHCGTriptorelin as 'Dual Trigger (R-HCG + Triptorelin) %',      
    hp.answerFourRHCGLeuprolide as 'Dual Trigger (R-HCG + Leuprolide) %',      
    case HP.isApproved            
        when 1 then 'Pending'            
        when 0 then 'Approved'            
        when 2 then 'Rejected'            
    end as statusText,            
    bsv_ivf.getEMPInfo(hp.approvedBy) AS ApprovedBy,       
    isNull(hp.approvedOn, '') as ApprovedOn,       
    bsv_ivf.getEMPInfo(hp.rejectedBy) AS RejectedBy,       
    hp.rejectedOn, hp.rejectComments, addedFor      
    from tblMarketInsights HP            
    INNER JOIN tblCustomers C ON C.CustomerID = hp.centreId     
     -- INNER JOIN TblHospitalsPotentials HPp ON HpP.HOSPITALID = hp.CENTREID  and PotentialEnteredFor = @dateAddedFor and hpp.isActive = 0    
    left outer JOIN tblAccount a on a.accountID = c.accountID         
    INNER join tblEmployees e on e.empid = hp.empId         
    where 1 = 1         
    and hp.isActive = 0     
    --and addedFor = @dateAddedFor            
     and  e.empid=@Empid	
		and (@fromdate is null or hp.addedFor>=@fromdate)
		and (@todate is null or hp.addedFor<=@todate)
    order by e.firstName ASC      
       END     
    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_MARKET_INSIGHT_REPORT_FOR_EXCEL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MARKET_INSIGHT_REPORT_FOR_EXCEL 1, 2023  
CREATE PROCEDURE [BSV_IVF].[USP_GET_MARKET_INSIGHT_REPORT_FOR_EXCEL]     
    (  
        @month int,  
        @year int  
    )  
AS    
    BEGIN    
    declare @dateAddedFor smallDateTime      
    set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))    
   
select     
    bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,      
    bsv_ivf.getMyRBMInfo(e.empid) AS RBM,      
    -- e.empid,       
    e.firstName as KamName, e.Designation,       
    -- c.customerId,       
    c.CENTRENAME as centreName,  c.DoctorName,      
    c.customerId,       
    case     
    when hp.answerone = 1 then 'Yes'    
    else 'No'    
    end as 'Practice Obstetrics',    
    ( 
        select top 1 ivfcycle from TblHospitalsPotentials where HOSPITALID = c.customerId  and PotentialEnteredFor = @dateAddedFor and isActive = 0  
    ) as 'Fresh Stimulated Cycles', 
    -- hp.AnswerTwo as 'Fresh Stimulated Cycles',    
    -- hpp.IVFCycle as 'Fresh Stimulated Cycles',    
    hp.answerThreeRFSH as 'RFSH %',    
    hp.answerThreeHMG as 'HMG %',    
    hp.answerProgesterone as 'Progesterone %',    
    hp.answerFiveDydrogesterone as 'Dydrogesterone %',    
    hp.answerFiveCombination as 'Combination %',    
    hp.answerFourRHCG as 'RHCG %',    
    hp.answerFourUHCG as 'UHCG %',    
    hp.answerFourAgonistL as 'Agonist-Leuprolide %',    
    hp.answerFourAgonistT as 'Agonist-Triptorelin %',    
    hp.answerFourRHCGTriptorelin as 'Dual Trigger (R-HCG + Triptorelin) %',    
    hp.answerFourRHCGLeuprolide as 'Dual Trigger (R-HCG + Leuprolide) %',    
    case HP.isApproved          
        when 1 then 'Pending'          
        when 0 then 'Approved'          
        when 2 then 'Rejected'          
    end as statusText,          
    bsv_ivf.getEMPInfo(hp.approvedBy) AS ApprovedBy,     
    isNull(hp.approvedOn, '') as ApprovedOn,     
    bsv_ivf.getEMPInfo(hp.rejectedBy) AS RejectedBy,     
    hp.rejectedOn, hp.rejectComments, addedFor    
    from tblMarketInsights HP          
    INNER JOIN tblCustomers C ON C.CustomerID = hp.centreId   
     -- INNER JOIN TblHospitalsPotentials HPp ON HpP.HOSPITALID = hp.CENTREID  and PotentialEnteredFor = @dateAddedFor and hpp.isActive = 0  
    left outer JOIN tblAccount a on a.accountID = c.accountID       
    INNER join tblEmployees e on e.empid = hp.empId       
    where 1 = 1       
    and hp.isActive = 0   
    and addedFor = @dateAddedFor          
    --  and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)           
    order by e.firstName ASC    
       END   
  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_MY_CENTER_LIST]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MY_CENTER_LIST 325              
  --------------------------------------------                
  -- CREATED BY: GURU SINGH                
  -- CREATED DATE: 24-SEP-2022                
  --------------------------------------------              
  CREATE  PROCEDURE [BSV_IVF].[USP_GET_MY_CENTER_LIST]               
   (                  
       @empId int              
   )              
   AS                
      SET NOCOUNT on;                       
          BEGIN                         
            select         
            mat.insightId,         
            isNull(c.CENTRENAME, '-NA-') as CENTRENAME, c.DoctorName, c.customerId,                  
                --case                      
                 --   -- when cat.contractEndDate > getDate() then 'Yes'                     
                --    --     else 'No'                    
                 --   -- end as ContractStatus,           
                 --   when getDate() between startDate and expiryDate then 'Yes'         
                 --   else 'No'         
                 --   end       
                 'NO' as ContractStatus,           
                    isNull(chainAccountTypeId, 0) as chainAccountTypeId ,                 
                     isnull(a.accountName,'-NA-') as accountName,          
                      --[BSV_IVF].getPotentialStatusforLastMonth(c.customerId) as PotentialStatus,          
                      [BSV_IVF].getPotentialStatusforLastMonthNew(c.customerId) as PotentialStatusNew,          
                    --[BSV_IVF].getBusinessStatusforLastMonth(c.customerId) as BusinessStatus,          
                    [BSV_IVF].getBusinessStatusforLastMonthNEW(c.customerId) as BusinessStatusNEW,          
                   -- [BSV_IVF].getCompetitionStatusforLastMonth(c.customerId) as CompetitionStatus,        
                      [BSV_IVF].getCompetitionStatusforLastMonth_V1(c.customerId) as CompetitionStatusNew,        
                  --  [BSV_IVF].getMarketInsightStatusforLastMonth(c.customerId) as MIStatus,        
                    [BSV_IVF].getMarketInsightStatusforLastMonthNew(c.customerId) as MIStatusNew        
                      from           
             tblCustomers c                          
              --  inner join tblaccount a on  a.accountID = c.accountID               
    -- change the join from inner to left outer join as some hospitals doest have accountid                                                                
            left outer join tblaccount a on  a.accountID = c.accountID                                                                        
           inner join tblEmpHospitals eh on c.customerId = eh.hospitalId                          
         --   left outer join tblchainAccountType cat on cat.customerAccountID = c.accountID         
    left outer join tblMarketInsights mat on mat.centreId = c.customerId  and mat.isActive = 0    and addedfor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)       
           -- left outer join TblHospitalsContracts hc on hc.hospitalId = c.customerId                         
            inner join tblSpecialtyType st on st.specialtyId = c.specialtyId and st.specialtyId in (2)                       
            where eh.EmpID = @empId and c.isdisabled = 0                      
   order by c.customerid  
        END              
    SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_MY_CENTER_LISTV1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MY_CENTER_LIST 76          

  --------------------------------------------            

  -- CREATED BY: GURU SINGH            

  -- CREATED DATE: 24-SEP-2022            

  --------------------------------------------          

  CREATE  PROCEDURE [BSV_IVF].[USP_GET_MY_CENTER_LISTV1]           

   (              

       @empId int          

   )          

   AS            

      SET NOCOUNT on;                   

          BEGIN                     

            select     

            mat.insightId,     

            isNull(c.CENTRENAME, '-NA-') as CENTRENAME, c.DoctorName, c.customerId,              

                --case                  

                 --   -- when cat.contractEndDate > getDate() then 'Yes'                 

                --    --     else 'No'                

                 --   -- end as ContractStatus,       

                 --   when getDate() between startDate and expiryDate then 'Yes'     

                 --   else 'No'     

                 --   end   

                 'NO' as ContractStatus,       

                    isNull(chainAccountTypeId, 0) as chainAccountTypeId ,             

                    a.accountName,      

                      --[BSV_IVF].getPotentialStatusforLastMonth(c.customerId) as PotentialStatus,      

                      [BSV_IVF].getPotentialStatusforLastMonthNewv1(c.customerId) as PotentialStatusNew,      

                    --[BSV_IVF].getBusinessStatusforLastMonth(c.customerId) as BusinessStatus,      

                    [BSV_IVF].getBusinessStatusforLastMonthNEWv1(c.customerId) as BusinessStatusNEW,      

                   -- [BSV_IVF].getCompetitionStatusforLastMonth(c.customerId) as CompetitionStatus,    

                      [BSV_IVF].getCompetitionStatusforLastMonth_V2(c.customerId) as CompetitionStatusNew,    

                  --  [BSV_IVF].getMarketInsightStatusforLastMonth(c.customerId) as MIStatus,    

                    [BSV_IVF].getMarketInsightStatusforLastMonthNewv1(c.customerId) as MIStatusNew    

                      from       

             tblCustomers c                      

              --  inner join tblaccount a on  a.accountID = c.accountID           

		  -- change the join from inner to left outer join as some hospitals doest have accountid                                                            

            left outer join tblaccount a on  a.accountID = c.accountID                                                                    

           inner join tblEmpHospitals eh on c.customerId = eh.hospitalId                      

         --   left outer join tblchainAccountType cat on cat.customerAccountID = c.accountID     

  		left outer join tblMarketInsights mat on mat.centreId = c.customerId  and mat.isActive = 0    
		--and addedfor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)   
		and addedfor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)   

           -- left outer join TblHospitalsContracts hc on hc.hospitalId = c.customerId                     

            inner join tblSpecialtyType st on st.specialtyId = c.specialtyId and st.specialtyId in (2)                   

            where eh.EmpID = @empId and c.isdisabled = 0                  

        END          

    SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_MY_TEAM_MEMBERS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_GET_MY_TEAM_MEMBERS 47  
 -------------------------------   
 -- CREATED BY: GURU SINGH   
 -- CREATED DATE: 26-NOV-2022   
 -------------------------------   
 CREATE PROCEDURE [BSV_IVF].[USP_GET_MY_TEAM_MEMBERS]   
  (     
       @empId int  
    )  
       AS      
       BEGIN         
        set NOCOUNT on;  
 
 
CREATE TABLE #empHierarchy 
( 
    levels smallInt, 
    EmpID INT, 
    ParentId int 
) 
             
;WITH 
    RecursiveCte 
    AS 
    ( 
        SELECT 1 as Level, H1.EmpID, H1.ParentId 
            FROM tblHierarchy H1 
            WHERE (@empid is null or ParentID = @empid) 
        UNION ALL 
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId 
            FROM tblHierarchy H2 
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID 
    ) 
            insert into #empHierarchy 
                (levels, EmpID, ParentId ) 
            SELECT Level, EmpID, ParentId 
            FROM RecursiveCte r 
            ; 
 
                          
                         select e.empID, firstName, e.MobileNumber, email, EmpNumber, hoCode, designation, 
                                      s.StateName,              DOJ  from tblEmployees e         
                              inner join tblState s on s.stateID = e.StateID            
                                where e.empID in (select EmpID from #empHierarchy) 
                                order by designation         
        set NOCOUNT OFF;      
        END    
 
 
 
 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_POTENTIAL_REPORT_EMPLOYEE]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--  exec USP_GET_POTENTIAL_REPORT_EMPLOYEE 325,'2023-01-01','2023-08-29'  
CREATE PROCEDURE [BSV_IVF].[USP_GET_POTENTIAL_REPORT_EMPLOYEE]        
(     
    @Empid int,
	@StartDate datetime=null,
	@EndDate datetime=null     
)     
      
as        
      
begin        

	declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end


    -- declare @dateAddedFor smallDateTime         
    --set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))       
        
      
    select         
      
bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,        
      
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,        
      
-- e.empid,         
      
e.firstName as KamName, e.Designation,         
      
        
      
c.CENTRENAME as centreName,  c.DoctorName,       
c.customerId,      
      
hp.IUICycle, IVFCycle, hp.FreshPickUps, hp.SelftCycle, hp.DonorCycles, hp.AgonistCycles, hp.frozenTransfers, hp.Antagonistcycles,        
      
hp.isApproved,         
      
bsv_ivf.getEMPInfo(hp.approvedBy) AS ApprovedBy,        
      
isNull(hp.approvedOn, '') as ApprovedOn,        
      
bsv_ivf.getEMPInfo(hp.rejectedBy) AS RejectedBy,        
      
hp.rejectedOn, hp.rejectComments, hp.PotentialEnteredFor,         
      
-- hp.visitId,        
      
 vt.name as visiType,        
      
        
      
case HP.isApproved                             
      
    when 1 then 'Pending'                             
      
    when 0 then 'Approved'                             
      
    when 2 then 'Rejected'                         
      
end as RBMStaus, e.HQName,c.City as CustomerCity         
      
from tblEmployees e        
      
inner join TblHospitalsPotentials hp on hp.empId = e.EmpID        
      
inner join tblcustomers c on c.customerID = hp.hospitalId        
      
INNER join tblVisitType vt on vt.visitId = hp.visitID        
      
where  1 = 1        
   and  e.empid=@Empid	
		and (@fromdate is null or hp.PotentialEnteredFor>=@fromdate)
		and (@todate is null or hp.PotentialEnteredFor<=@todate)
 --and hp.PotentialEnteredFor = @dateAddedFor          
      
-- and hp.PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)          
      
-- and e.EmpID = 63        
      
and hp.isactive = 0        
      
and e.isdisabled = 0         
      
order by e.firstName,c.CENTRENAME,c.DoctorName     asc  
-- order by c.CENTRENAME,  c.DoctorName, c.customerId ASC    
      
        
      
end 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_POTENTIAL_REPORT_FOR_EXCEL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  exec USP_GET_POTENTIAL_REPORT_FOR_EXCEL 6,2023
CREATE PROCEDURE [BSV_IVF].[USP_GET_POTENTIAL_REPORT_FOR_EXCEL]      
(   
    @month int,   
    @year int   
)   
    
as      
    
begin      
     declare @dateAddedFor smallDateTime       
    set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))     
      
    
    select       
    
bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,      
    
bsv_ivf.getMyRBMInfo(e.empid) AS RBM,      
    
-- e.empid,       
    
e.firstName as KamName, e.Designation,       
    
      
    
c.CENTRENAME as centreName,  c.DoctorName,     
c.customerId,    
    
hp.IUICycle, IVFCycle, hp.FreshPickUps, hp.SelftCycle, hp.DonorCycles, hp.AgonistCycles, hp.frozenTransfers, hp.Antagonistcycles,      
    
hp.isApproved,       
    
bsv_ivf.getEMPInfo(hp.approvedBy) AS ApprovedBy,      
    
isNull(hp.approvedOn, '') as ApprovedOn,      
    
bsv_ivf.getEMPInfo(hp.rejectedBy) AS RejectedBy,      
    
hp.rejectedOn, hp.rejectComments, hp.PotentialEnteredFor,       
    
-- hp.visitId,      
    
 vt.name as visiType,      
    
      
    
case HP.isApproved                           
    
    when 1 then 'Pending'                           
    
    when 0 then 'Approved'                           
    
    when 2 then 'Rejected'                       
    
end as RBMStaus, e.HQName,c.City as CustomerCity       
    
from tblEmployees e      
    
inner join TblHospitalsPotentials hp on hp.empId = e.EmpID      
    
inner join tblcustomers c on c.customerID = hp.hospitalId      
    
INNER join tblVisitType vt on vt.visitId = hp.visitID      
    
where  1 = 1      
    
 and hp.PotentialEnteredFor = @dateAddedFor        
    
-- and hp.PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)        
    
-- and e.EmpID = 63      
    
and hp.isactive = 0      
    
and e.isdisabled = 0       
    
order by e.firstName,c.CENTRENAME,c.DoctorName     asc
-- order by c.CENTRENAME,  c.DoctorName, c.customerId ASC  
    
      
    
end 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_RBM_BUSINESS_LIST_FOR_APPROVAL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------             
-- CREATED BY: GURU SINGH             
-- CREATED DATE: 24-SEP-2022             
--------------------------------------------             
CREATE  PROCEDURE [BSV_IVF].[USP_GET_RBM_BUSINESS_LIST_FOR_APPROVAL]             
    (             
        @KamId int        
    )         
AS             
SET NOCOUNT on;                    
    BEGIN                                                  
        SELECT CENTRENAME, DoctorName, CITY,  hospitalId,                
            BSV_IVF.getActualsTargetAchieved(hospitalID, 1) as brandGroup1,               
            BSV_IVF.getActualsTargetAchieved(hospitalID, 2) as brandGroup2,                
            BSV_IVF.getActualsTargetAchieved(hospitalID, 3) as brandGroup3,
            BSV_IVF.getActualsTargetAchieved(hospitalID, 4) as brandGroup4,                
            BSV_IVF.getActualsTargetAchieved(hospitalID, 5) as brandGroup5,                
            BSV_IVF.getActualsTargetAchieved(hospitalID, 6) as brandGroup6,                
            BSV_IVF.getActualsTargetAchieved(hospitalID, 7) as brandGroup7,                
            BSV_IVF.getActualsTargetAchieved(hospitalID, 8) as brandGroup8,                
            BSV_IVF.getActualsTargetAchieved(hospitalID, 9) as brandGroup9 ,              
            BSV_IVF.getActualsTargetAchieved(hospitalID, 10) as brandGroup10,              
            ha.isApproved, accountName, 
            case ha.isApproved                      
                when 1 then 'Pending'                      
                when 0 then 'Approved'                      
                when 2 then 'Rejected'            
            end as statusText,                  
            case ha.isApproved                      
                when 1 then 0                      
                when 0 then 1                      
                when 2 then 2                  
            end as sortOrder               
            from TblHospitalactuals HA               
            INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                            
            INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                             
            left OUTER JOIN tblAccount a on a.accountID = c.accountID      
            WHERE 1 = 1                  
            and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                     
            -- and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                     
            and empId =  @KamId   AND HA.isDisabled = 0                
            group by CENTRENAME, DoctorName, CITY, hospitalId  , ha.isApproved, accountName                  
            order by sortOrder asc                   
            
            -- for graphs                          
                select     ha.actualId, c.CENTRENAME, c.DoctorName, c.City,                    
                ha.empId, ha.hospitalId, ha.brandId, sg.brandName, ha.brandGroupId, BG.groupName, ha.skuId, s.medicineName,                   
                ha.rate, ha.qty                  
                from TblHospitalactuals HA                            
                INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                            
                INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                            
                INNER join tblSkuGroup sg on sg.brandId = ha.brandId                           
                INNER JOIN tblSKUs s on s.medID = ha.skuId                    
                WHERE empId =  @KamId     AND HA.isDisabled = 0                
                AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                     
                -- AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                     
                order by ha.actualId                                   
                
                select    ha.brandId, sg.brandName, s.medicineName,                   
                --ha.empId, ha.hospitalId, ha.brandId, sg.brandName, ha.brandGroupId, BG.groupName, ha.skuId, s.medicineName,                   
                ROUND(sum(ha.rate* ha.qty), 2) as TotalSalesValue                   
                from TblHospitalactuals HA                            
                INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                   
                INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                            
                INNER join tblSkuGroup sg on sg.brandId = ha.brandId             
                INNER JOIN tblSKUs s on s.medID = ha.skuId                    
                WHERE empId =  @KamId    AND HA.isDisabled = 0                
                AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                     
                -- AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                     
                group by ha.brandId, sg.brandName, s.medicineName                       
    END        
SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_RBM_BUSINESS_LIST_FOR_APPROVALv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------             

-- CREATED BY: GURU SINGH             

-- CREATED DATE: 24-SEP-2022             

--------------------------------------------             

CREATE  PROCEDURE [BSV_IVF].[USP_GET_RBM_BUSINESS_LIST_FOR_APPROVALv1]             

    (             

        @KamId int        

    )         

AS             

SET NOCOUNT on;                    

    BEGIN                                                  

        SELECT CENTRENAME, DoctorName, CITY,  hospitalId,                

            BSV_IVF.getActualsTargetAchieved(hospitalID, 1) as brandGroup1,               

            BSV_IVF.getActualsTargetAchieved(hospitalID, 2) as brandGroup2,                

            BSV_IVF.getActualsTargetAchieved(hospitalID, 3) as brandGroup3,

            BSV_IVF.getActualsTargetAchieved(hospitalID, 4) as brandGroup4,                

            BSV_IVF.getActualsTargetAchieved(hospitalID, 5) as brandGroup5,                

            BSV_IVF.getActualsTargetAchieved(hospitalID, 6) as brandGroup6,                

            BSV_IVF.getActualsTargetAchieved(hospitalID, 7) as brandGroup7,                

            BSV_IVF.getActualsTargetAchieved(hospitalID, 8) as brandGroup8,                

            BSV_IVF.getActualsTargetAchieved(hospitalID, 9) as brandGroup9 ,              

            BSV_IVF.getActualsTargetAchieved(hospitalID, 10) as brandGroup10,              

            ha.isApproved, accountName, 

            case ha.isApproved                      

                when 1 then 'Pending'                      

                when 0 then 'Approved'                      

                when 2 then 'Rejected'            

            end as statusText,                  

            case ha.isApproved                      

                when 1 then 0                      

                when 0 then 1                      

                when 2 then 2                  

            end as sortOrder               

            from TblHospitalactuals HA               

            INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                            

            INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                             

            left OUTER JOIN tblAccount a on a.accountID = c.accountID      

            WHERE 1 = 1                  

           -- and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)  --for feb                   

             and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  -- for jan                   

            and empId =  @KamId   AND HA.isDisabled = 0                

            group by CENTRENAME, DoctorName, CITY, hospitalId  , ha.isApproved, accountName                  

            order by sortOrder asc                   

            

            -- for graphs                          

                select     ha.actualId, c.CENTRENAME, c.DoctorName, c.City,                    

                ha.empId, ha.hospitalId, ha.brandId, sg.brandName, ha.brandGroupId, BG.groupName, ha.skuId, s.medicineName,                   

                ha.rate, ha.qty                  

                from TblHospitalactuals HA                            

                INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                            

                INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                            

                INNER join tblSkuGroup sg on sg.brandId = ha.brandId                           

                INNER JOIN tblSKUs s on s.medID = ha.skuId                    

                WHERE empId =  @KamId     AND HA.isDisabled = 0                

                --AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)   --for feb                  

                 AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  --for jan                   

           order by ha.actualId                                   

                

                select    ha.brandId, sg.brandName, s.medicineName,                   

                --ha.empId, ha.hospitalId, ha.brandId, sg.brandName, ha.brandGroupId, BG.groupName, ha.skuId, s.medicineName,                   

                ROUND(sum(ha.rate* ha.qty), 2) as TotalSalesValue                   

                from TblHospitalactuals HA                            

                INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                   

                INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                            

                INNER join tblSkuGroup sg on sg.brandId = ha.brandId             

                INNER JOIN tblSKUs s on s.medID = ha.skuId                    

                WHERE empId =  @KamId    AND HA.isDisabled = 0                

                --AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)  --for feb                   

                 AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)   --for jan                  

                group by ha.brandId, sg.brandName, s.medicineName                       

    END        

SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_RBM_MarketInsights_LIST_FOR_APPROVAL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_RBM_POTENTIAL_LIST_FOR_APPROVAL 24     
--------------------------------------------          
-- CREATED BY: GURU SINGH          
-- CREATED DATE: 24-SEP-2022          
--------------------------------------------          
CREATE PROCEDURE [BSV_IVF].[USP_GET_RBM_MarketInsights_LIST_FOR_APPROVAL]          
(      
    @KamId int     
)      
AS          
SET NOCOUNT on;         
        BEGIN       
     
    select accountName, CENTRENAME, DoctorName, CITY,      
            case HP.isApproved     
                when 1 then 'Pending'     
                when 0 then 'Approved'     
                when 2 then 'Rejected'     
            end as statusText,     
            case HP.isApproved     
                when 1 then 0     
                when 0 then 1     
                when 2 then 2     
            end as sortOrder, HP.*     
    
            from tblMarketInsights HP     
            INNER JOIN tblCustomers C ON C.CustomerID = hp.centreId     
            left outer JOIN tblAccount a on a.accountID = c.accountID     
    where 1 = 1     
    and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)      
    -- and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)      
    and empId =  @KamId     
     order by sortOrder ASC     
     
        END     
SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_RBM_MarketInsights_LIST_FOR_APPROVALv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_RBM_POTENTIAL_LIST_FOR_APPROVAL 24     

--------------------------------------------          

-- CREATED BY: GURU SINGH          

-- CREATED DATE: 24-SEP-2022          

--------------------------------------------          

CREATE PROCEDURE [BSV_IVF].[USP_GET_RBM_MarketInsights_LIST_FOR_APPROVALv1]          

(      

    @KamId int     

)      

AS          

SET NOCOUNT on;         

        BEGIN       

     

    select accountName, CENTRENAME, DoctorName, CITY,      

            case HP.isApproved     

                when 1 then 'Pending'     

                when 0 then 'Approved'     

                when 2 then 'Rejected'     

            end as statusText,     

            case HP.isApproved     

                when 1 then 0     

                when 0 then 1     

                when 2 then 2     

            end as sortOrder, HP.*     

    

            from tblMarketInsights HP     

            INNER JOIN tblCustomers C ON C.CustomerID = hp.centreId     

            left outer JOIN tblAccount a on a.accountID = c.accountID     

    where 1 = 1     

   -- and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)  --for feb     

     and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0) -- for jan     

    and empId =  @KamId     

     order by sortOrder ASC     

     

        END     

SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_RBM_POTENTIAL_LIST_FOR_APPROVAL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
     -- USP_GET_RBM_POTENTIAL_LIST_FOR_APPROVAL 24    
     --------------------------------------------         
     -- CREATED BY: GURU SINGH         
     -- CREATED DATE: 24-SEP-2022         
     --------------------------------------------         
     CREATE PROCEDURE [BSV_IVF].[USP_GET_RBM_POTENTIAL_LIST_FOR_APPROVAL]         
        (         
            @KamId int    
        )     
        AS         
    SET NOCOUNT on;                
        BEGIN              
            select 
                accountName, CENTRENAME, DoctorName, CITY,                 
                case HP.isApproved                    
                    when 1 then 'Pending'                    
                    when 0 then 'Approved'                    
                    when 2 then 'Rejected'                
                end as statusText,                
                case HP.isApproved                    
                    when 1 then 0                    
                    when 0 then 1                    
                    when 2 then 2                
                end as sortOrder, HP.*                   
            from tblhospitalsPotentials HP                
            INNER JOIN tblCustomers C ON C.CustomerID = hp.hospitalId                
            left OUTER JOIN tblAccount a on a.accountID = c.accountID        
            where 1 = 1        
            and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)         
            -- and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)         
            and empId =  @KamId         
            order by sortOrder ASC                
        END    
    SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_RBM_POTENTIAL_LIST_FOR_APPROVALv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
     -- USP_GET_RBM_POTENTIAL_LIST_FOR_APPROVAL 24    

     --------------------------------------------         

     -- CREATED BY: GURU SINGH         

     -- CREATED DATE: 24-SEP-2022         

     --------------------------------------------         

     CREATE PROCEDURE [BSV_IVF].[USP_GET_RBM_POTENTIAL_LIST_FOR_APPROVALv1]         

        (         

            @KamId int    

        )     

        AS         

    SET NOCOUNT on;                

        BEGIN              

            select 

                accountName, CENTRENAME, DoctorName, CITY,                 

                case HP.isApproved                    

                    when 1 then 'Pending'                    

                    when 0 then 'Approved'                    

                    when 2 then 'Rejected'                

                end as statusText,                

                case HP.isApproved                    

                    when 1 then 0                    

                    when 0 then 1                    

                    when 2 then 2                

                end as sortOrder, HP.*                   

            from tblhospitalsPotentials HP                

            INNER JOIN tblCustomers C ON C.CustomerID = hp.hospitalId                

            left OUTER JOIN tblAccount a on a.accountID = c.accountID        

            where 1 = 1        

            --and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)     --for feb    

             and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)         --for jan

            and empId =  @KamId         

            order by sortOrder ASC                

        END    

    SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_SKU_COMPETITION_DETAILS_BY_CENTER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    /*



    USP_GET_SKU_COMPETITION_DETAILS_BY_CENTER 973, 4, 2023

    select *  from tblPortalConfig WHERE code= 'COMPETITION'



    */





CREATE PROCEDURE [BSV_IVF].[USP_GET_SKU_COMPETITION_DETAILS_BY_CENTER] (  

    @centerId int,   

    @Month int,   

    @Year int  

)  

AS  

    BEGIN  

        declare @competitionAddedFor smallDateTime  

        declare @lastDate smallDateTime  

        declare @interval int

        set  @competitionAddedFor = (DATEFROMPARTS (@Year, @Month, 1))  



        IF EXISTS (SELECT 1 FROM tblCompetitions  

                WHERE   

                    centerId = @centerId and competitionAddedFor = @competitionAddedFor )

            BEGIN

                SELECT * FROM tblCompetitions  

                WHERE   

                centerId = @centerId and competitionAddedFor = @competitionAddedFor 

            END

        ELSE -- USER WILL ENTER THE DATA EVERY MONTH, 

            BEGIN

			---	print '6ftgyuhn' 

                set  @competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  

			--		print @competitionAddedFor
                select @lastDate = lastDate , @interval = interval  from tblPortalConfig WHERE code= 'COMPETITION'

                -- select month(@lastDate), @interval, @competitionAddedFor, (month(@competitionAddedFor) - month(@lastDate))

                if ( (month(@competitionAddedFor) - month(@lastDate)) > @interval)

                    BEGIN

                        update tblPortalConfig

                            set lastDate = @competitionAddedFor

                        WHERE code= 'COMPETITION'
                    END
                ELSE
                    BEGIN
                        SELECT * FROM tblCompetitions  
                        WHERE   
                            centerId = @centerId and competitionAddedFor = @competitionAddedFor 
                    END
            END
    END 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_SKU_DETAILS_BY_ID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------  
-- CREATED BY: GURU SINGH  
-- CREATED DATE: 24-SEP-2022  
--------------------------------------------  
create PROCEDURE [BSV_IVF].[USP_GET_SKU_DETAILS_BY_ID]  
(
    @skuId int
)
AS  
SET NOCOUNT on; 
        BEGIN
          SELECT medID as SkuId, S.brandId, sg.brandName, S.brandGroupId, bg.groupName,  medicineName, price FROM tblSKUs S  
           INNER JOIN tblSkuGroup SG ON sg.brandId = s.brandId 
           INNER JOIN tblBrandGroups BG ON s.brandGroupId = bg.brandGroupId 
           where medID = @skuId
        END
SET NOCOUNT OFF;  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_VIEW_PERFORMANCE_FOR_CENTER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_VIEW_PERFORMANCE_FOR_CENTER 966 
------------------------------------------------ 
-- CREATED BY: GURU SINGH 
-- CREATED DATE: 13-DEC-2022 
------------------------------------------------ 
CREATE PROCEDURE [BSV_IVF].[USP_GET_VIEW_PERFORMANCE_FOR_CENTER] 
( 
    @centerId int 
) 
AS 
set NOCOUNT on; 


CREATE TABLE #tmpCenterList 
( 
    accountId Int, 
    centerID INT
) 
    declare @accountID int 
    select @accountID = accountID from tblcustomers  c where c.customerId = @centerId 
    insert into #tmpCenterList (accountId, centerID)
    select accountID, customerId from tblcustomers  c where c.accountID = @accountID
 /*
accountId	centerID
1488	    692
1488	    1121
 */
    -- select * from #tmpCenterList
    
    select customerId, accountID, st.name as SpecialtyName, CENTRENAME, doctorName, mobile, email, city, ch.name, s.stateName from tblcustomers c 
    INNER join tblChainStatus ch on ch.chainId = c.chainId 
    INNER join tblState S on c.stateID = s.stateId 
    inner join tblSpecialtyType st on st.SpecialtyId = c.SpecialtyId 
    where c.customerId in (select centerID from #tmpCenterList)

 select 
    sum(convert(int, IUICycle)) as IUICycle, sum(convert(int, IVFCycle)) as IVFCycle
    , sum(FreshPickUps) as FreshPickUps, sum(frozenTransfers) as frozenTransfers
    , sum(SelftCycle) as  SelftCycle
    , sum(DonorCycles) as DonorCycles
    , sum(AgonistCycles) as AgonistCycles
    , sum(Antagonistcycles) as Antagonistcycles
    from tblhospitalsPotentials where hospitalId in 
    (select centerID from #tmpCenterList) and isActive = 0 and isApproved = 0
    

    if exists (select 1 from tblChainAccountType where customerAccountID = @accountID and expiryDate >= GETDATE() and isApproved = 0)    
        BEGIN

            select 'contract Rate' as RateType, BrandId, brandGroupId, medId, Price as SkuPrice
            from TblContractDetails where  
            price > 0 and 
            chainAccountTypeId in (select accountID from tblChainAccountType where customerAccountID = @accountID and expiryDate >= GETDATE() and isApproved = 0)
            -- USP_GET_VIEW_PERFORMANCE_FOR_CENTER_v1 1121
        END
    ELSE    
        BEGIN
            select 'Standard Rate' as RateType, brandId, brandGroupId, price as SkuPrice, medId from tblSKUs where isDisabled = 0  
        END
    

 drop table #tmpCenterList
set NOCOUNT off; 
 
 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_VIEW_PERFORMANCE_FOR_CENTER_v1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_VIEW_PERFORMANCE_FOR_CENTER 966 

------------------------------------------------ 

-- CREATED BY: GURU SINGH 

-- CREATED DATE: 13-DEC-2022 

------------------------------------------------ 

CREATE PROCEDURE [BSV_IVF].[USP_GET_VIEW_PERFORMANCE_FOR_CENTER_v1] 

( 

    @centerId int,

    @month int = NULL,

    @year int = NULL

) 

AS 

set NOCOUNT on; 

            declare @selectedMonthYear smallDateTime  

            if (@month is NULL)

                BEGIN

                    set  @selectedMonthYear =  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)

                END

            ELSE

                BEGIN

                    set  @selectedMonthYear = (DATEFROMPARTS (@Year, @Month, 1))  

                END



CREATE TABLE #tmpCenterList 

( 

    accountId Int, 

    centerID INT

) 

    declare @accountID int 

    select @accountID = accountID from tblcustomers  c where c.customerId = @centerId 

    insert into #tmpCenterList (accountId, centerID)

    select accountID, customerId from tblcustomers  c where c.accountID = @accountID

 /*

accountId	centerID

1488	    692

1488	    1121

 */

--     select * from #tmpCenterList

    

    select customerId, accountID, st.name as SpecialtyName, CENTRENAME, doctorName, mobile, email, city, ch.name, s.stateName from tblcustomers c 

    INNER join tblChainStatus ch on ch.chainId = c.chainId 

    INNER join tblState S on c.stateID = s.stateId 

    inner join tblSpecialtyType st on st.SpecialtyId = c.SpecialtyId 

    where c.customerId in (select centerID from #tmpCenterList)
	and c.isdisabled = 0


 select 

    sum(convert(int, IUICycle)) as IUICycle, sum(convert(int, IVFCycle)) as IVFCycle

    , sum(FreshPickUps) as FreshPickUps, sum(frozenTransfers) as frozenTransfers

    , sum(SelftCycle) as  SelftCycle

    , sum(DonorCycles) as DonorCycles

    , sum(AgonistCycles) as AgonistCycles

    , sum(Antagonistcycles) as Antagonistcycles

    from tblhospitalsPotentials where hospitalId in 

    (select centerID from #tmpCenterList) and isActive = 0 and isApproved = 0

    



if exists (select 1 from tblChainAccountType where customerAccountID = @accountID and expiryDate >= GETDATE() and isApproved = 0)    

    BEGIN



        select 'contract Rate' as RateType, BrandId, brandGroupId, medId, Price as SkuPrice

        from TblContractDetails where  

        price > 0 and 

        chainAccountTypeId in (select accountID from tblChainAccountType where customerAccountID = @accountID and expiryDate >= GETDATE() and isApproved = 0)

        END

ELSE    

    BEGIN

        select 'Standard Rate' as RateType, brandId, brandGroupId, price as SkuPrice, medId from tblSKUs where isDisabled = 0  

    END





select ha.brandId, sg.brandName, ha.brandGroupId, bg.groupName

--, ha.skuId, s.medicineName

, sum(qty) totalQty,  FORMAT(sum (rate * Qty)/1000,'N2') as totalValue

from tblhospitalActuals ha

inner join tblSkuGroup sg on sg.brandId = ha.brandId

INNER join tblBrandGroups bg on bg.brandGroupId = ha.brandGroupId

inner join tblSKUs s on s.medID = ha.skuId

where  ha.isDisabled = 0 

and rate > 0

and ActualEnteredFor = @selectedMonthYear 

and hospitalId in (select centerID from #tmpCenterList)

and isApproved = 0

group by ha.brandId, sg.brandName, ha.brandGroupId, bg.groupName





select c.brandId, sg.brandname

-- , c.CompetitionSkuId, bck.name

, sum(c.businessValue) as TotalBusinessValue

from tblCompetitions c 

inner join tblBrandcompetitorSKUs bck on c.CompetitionSkuId = bck.competitorId

inner join tblSkuGroup sg on sg.brandId = c.brandId

where isApproved = 0 

and competitionAddedFor = @selectedMonthYear 

and centerId in (select centerID from #tmpCenterList)

GROUP by c.brandId, sg.brandname

-- , c.CompetitionSkuId, bck.name







-- USP_GET_VIEW_PERFORMANCE_FOR_CENTER_v1 1121





 drop table #tmpCenterList

set NOCOUNT off; 

 


GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ZBM_BUSINESS_LIST_FOR_APPROVAL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_GET_ZBM_BUSINESS_LIST_FOR_APPROVAL 61
 --------------------------------------------               
    -- CREATED BY: GURU SINGH               
    -- CREATED DATE: 24-SEP-2022               
--------------------------------------------              
CREATE  PROCEDURE [BSV_IVF].[USP_GET_ZBM_BUSINESS_LIST_FOR_APPROVAL]               
    (               
            @KamId int          
    )           
AS               
    SET NOCOUNT on;                      
        BEGIN                                                        
            SELECT CENTRENAME, DoctorName, CITY,  hospitalId,                  
                BSV_IVF.getActualsTargetAchieved(hospitalID, 1) as brandGroup1,                 
                BSV_IVF.getActualsTargetAchieved(hospitalID, 2) as brandGroup2,                  
                BSV_IVF.getActualsTargetAchieved(hospitalID, 3) as brandGroup3,                  
                BSV_IVF.getActualsTargetAchieved(hospitalID, 4) as brandGroup4,                  
                BSV_IVF.getActualsTargetAchieved(hospitalID, 5) as brandGroup5,                  
                BSV_IVF.getActualsTargetAchieved(hospitalID, 6) as brandGroup6,                  
                BSV_IVF.getActualsTargetAchieved(hospitalID, 7) as brandGroup7,                  
                BSV_IVF.getActualsTargetAchieved(hospitalID, 8) as brandGroup8,                  
                BSV_IVF.getActualsTargetAchieved(hospitalID, 9) as brandGroup9 ,                
                BSV_IVF.getActualsTargetAchieved(hospitalID, 10) as brandGroup10,                
                ha.ZBMApproved, accountName, 
                case ha.ZBMApproved                        
                    when 1 then 'Pending'                        
                    when 0 then 'Approved'                        
                    when 2 then 'Rejected'                    
                end as statusText,                    
                case ha.ZBMApproved                        
                    when 1 then 0                        
                    when 0 then 1                        
                    when 2 then 2                   
                end as sortOrder                 
            from TblHospitalactuals HA                              
            INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                              
            INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId
            left outer JOIN tblAccount a on a.accountID = c.accountID                    
        WHERE 1 = 1                    
        and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                       
        -- and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                       
        and empId =  @KamId   AND HA.isDisabled = 0                 
        group by CENTRENAME, DoctorName, CITY, hospitalId, ha.ZBMApproved, accountName                    
        order by sortOrder asc        
        
        -- for graphs                              
        
        select     
            ha.actualId, c.CENTRENAME, c.DoctorName, c.City,                      
            ha.empId, ha.hospitalId, ha.brandId, sg.brandName, 
            ha.brandGroupId, BG.groupName, ha.skuId, s.medicineName,
            ha.rate, ha.qty                    
        from TblHospitalactuals HA                              
        INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                              
        INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                              
        INNER join tblSkuGroup sg on sg.brandId = ha.brandId                             
        INNER JOIN tblSKUs s on s.medID = ha.skuId                      
        WHERE empId =  @KamId     AND HA.isDisabled = 0                 
        AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                       
        -- AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                       
        order by ha.actualId                                         
        
        select    ha.brandId, sg.brandName, s.medicineName,                     
                --ha.empId, ha.hospitalId, ha.brandId, sg.brandName, ha.brandGroupId, BG.groupName, ha.skuId, s.medicineName,                     
                ROUND(sum(ha.rate* ha.qty), 2) as TotalSalesValue                 
        from TblHospitalactuals HA                              
        INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                              
        INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                              
        INNER join tblSkuGroup sg on sg.brandId = ha.brandId                             
        INNER JOIN tblSKUs s on s.medID = ha.skuId                      
        WHERE empId =  @KamId   AND HA.isDisabled = 0                 
        AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                       
        -- AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                       
        group by ha.brandId, sg.brandName, s.medicineName                         
    END          
SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ZBM_BUSINESS_LIST_FOR_APPROVALv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_GET_ZBM_BUSINESS_LIST_FOR_APPROVAL 61

 --------------------------------------------               

    -- CREATED BY: GURU SINGH               

    -- CREATED DATE: 24-SEP-2022               

--------------------------------------------              

CREATE  PROCEDURE [BSV_IVF].[USP_GET_ZBM_BUSINESS_LIST_FOR_APPROVALv1]               

    (               

            @KamId int          

    )           

AS               

    SET NOCOUNT on;                      

        BEGIN                                                        

            SELECT CENTRENAME, DoctorName, CITY,  hospitalId,                  

                BSV_IVF.getActualsTargetAchieved(hospitalID, 1) as brandGroup1,                 

                BSV_IVF.getActualsTargetAchieved(hospitalID, 2) as brandGroup2,                  

                BSV_IVF.getActualsTargetAchieved(hospitalID, 3) as brandGroup3,                  

                BSV_IVF.getActualsTargetAchieved(hospitalID, 4) as brandGroup4,                  

                BSV_IVF.getActualsTargetAchieved(hospitalID, 5) as brandGroup5,                  

                BSV_IVF.getActualsTargetAchieved(hospitalID, 6) as brandGroup6,                  

                BSV_IVF.getActualsTargetAchieved(hospitalID, 7) as brandGroup7,                  

                BSV_IVF.getActualsTargetAchieved(hospitalID, 8) as brandGroup8,                  

                BSV_IVF.getActualsTargetAchieved(hospitalID, 9) as brandGroup9 ,                

                BSV_IVF.getActualsTargetAchieved(hospitalID, 10) as brandGroup10,                

                ha.ZBMApproved, accountName, 

                case ha.ZBMApproved                        

                    when 1 then 'Pending'                        

                    when 0 then 'Approved'                        

                    when 2 then 'Rejected'                    

                end as statusText,                    

                case ha.ZBMApproved                        

                    when 1 then 0                        

                    when 0 then 1                        

                    when 2 then 2                   

                end as sortOrder                 

            from TblHospitalactuals HA                              

            INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                              

            INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId

            left outer JOIN tblAccount a on a.accountID = c.accountID                    

        WHERE 1 = 1                    

        --and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)        -- for feb               

         and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)            --for jan           

        and empId =  @KamId   AND HA.isDisabled = 0                 

        group by CENTRENAME, DoctorName, CITY, hospitalId, ha.ZBMApproved, accountName                    

        order by sortOrder asc        

        

        -- for graphs                              

        

        select     

            ha.actualId, c.CENTRENAME, c.DoctorName, c.City,                      

            ha.empId, ha.hospitalId, ha.brandId, sg.brandName, 

            ha.brandGroupId, BG.groupName, ha.skuId, s.medicineName,

            ha.rate, ha.qty                    

        from TblHospitalactuals HA                              

        INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                              

        INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                              

        INNER join tblSkuGroup sg on sg.brandId = ha.brandId                             

        INNER JOIN tblSKUs s on s.medID = ha.skuId                      

        WHERE empId =  @KamId     AND HA.isDisabled = 0                 

        --AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                       --for feb

         AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                       --for jan

        order by ha.actualId                                         

        

        select    ha.brandId, sg.brandName, s.medicineName,                     

                --ha.empId, ha.hospitalId, ha.brandId, sg.brandName, ha.brandGroupId, BG.groupName, ha.skuId, s.medicineName,                     

                ROUND(sum(ha.rate* ha.qty), 2) as TotalSalesValue                 

        from TblHospitalactuals HA                              

        INNER JOIN tblCustomers C ON C.CustomerID = hA.hospitalId                              

        INNER JOIN tblBrandGroups BG ON BG.brandGroupId = HA.brandGroupId                              

        INNER join tblSkuGroup sg on sg.brandId = ha.brandId                             

        INNER JOIN tblSKUs s on s.medID = ha.skuId                      

        WHERE empId =  @KamId   AND HA.isDisabled = 0                 

        --AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                       --for feb

         AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                       --for jan

        group by ha.brandId, sg.brandName, s.medicineName                         

    END          

SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ZBM_MarketInsights_LIST_FOR_APPROVAL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_ZBM_MarketInsights_LIST_FOR_APPROVAL 838       
--------------------------------------------            
-- CREATED BY: GURU SINGH            
-- CREATED DATE: 24-SEP-2022            
--------------------------------------------            
CREATE PROCEDURE [BSV_IVF].[USP_GET_ZBM_MarketInsights_LIST_FOR_APPROVAL]            
(        
    @KamId int       
)        
AS            
SET NOCOUNT on;           
        BEGIN         
       
    select accountName, CENTRENAME, DoctorName, CITY,        
            case HP.ZBMApproved       
                when 1 then 'Pending'       
                when 0 then 'Approved'       
                when 2 then 'Rejected'       
            end as statusText,       
            case HP.ZBMApproved       
                when 1 then 0       
                when 0 then 1       
                when 2 then 2       
            end as sortOrder, HP.*       
      
            from tblMarketInsights HP       
            INNER JOIN tblCustomers C ON C.CustomerID = hp.centreId       
            left outer JOIN tblAccount a on a.accountID = c.accountID       
    where 1 = 1       
     and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)        
   --  and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)        
    and empId =  @KamId    and HP.isApproved <> 1    
     order by sortOrder ASC       
       
        END       
SET NOCOUNT OFF;     
    
-- SELECT TOP 1 * FROM tblMarketInsights 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ZBM_MarketInsights_LIST_FOR_APPROVALv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- USP_GET_ZBM_MarketInsights_LIST_FOR_APPROVAL 838       

--------------------------------------------            

-- CREATED BY: GURU SINGH            

-- CREATED DATE: 24-SEP-2022            

--------------------------------------------            

CREATE PROCEDURE [BSV_IVF].[USP_GET_ZBM_MarketInsights_LIST_FOR_APPROVALv1]            

(        

    @KamId int       

)        

AS            

SET NOCOUNT on;           

        BEGIN         

       

    select accountName, CENTRENAME, DoctorName, CITY,        

            case HP.ZBMApproved       

                when 1 then 'Pending'       

                when 0 then 'Approved'       

                when 2 then 'Rejected'       

            end as statusText,       

            case HP.ZBMApproved       

                when 1 then 0       

                when 0 then 1       

                when 2 then 2       

            end as sortOrder, HP.*       

      

            from tblMarketInsights HP       

            INNER JOIN tblCustomers C ON C.CustomerID = hp.centreId       

            left outer JOIN tblAccount a on a.accountID = c.accountID       

    where 1 = 1       

   --  and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)        -- for feb

     and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  -- for jan      

    and empId =  @KamId    and HP.isApproved <> 1    

     order by sortOrder ASC       

       

        END       

SET NOCOUNT OFF;     

    

-- SELECT TOP 1 * FROM tblMarketInsights 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ZBM_POTENTIAL_LIST_FOR_APPROVAL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_ZBM_POTENTIAL_LIST_FOR_APPROVAL 61       
--------------------------------------------            
-- CREATED BY: GURU SINGH            
-- CREATED DATE: 24-SEP-2022            
--------------------------------------------            
CREATE PROCEDURE [BSV_IVF].[USP_GET_ZBM_POTENTIAL_LIST_FOR_APPROVAL]            
(        
    @KamId int       
)        
AS            
SET NOCOUNT on;           
        BEGIN         
       
    select accountName, CENTRENAME, DoctorName, CITY,        
            case HP.ZBMApproved       
                when 1 then 'Pending'       
                when 0 then 'Approved'       
                when 2 then 'Rejected'       
            end as statusText,       
            case HP.ZBMApproved       
                when 1 then 0       
                when 0 then 1       
                when 2 then 2       
            end as sortOrder, HP.*       
      
            from tblhospitalsPotentials HP       
            INNER JOIN tblCustomers C ON C.CustomerID = hp.hospitalId       
            left OUTER JOIN tblAccount a on a.accountID = c.accountID       
    where 1 = 1       
    and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)        
    -- and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)        
    and empId =  @KamId    and HP.isApproved <> 1     
     order by sortOrder ASC       
       
        END       
SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ZBM_POTENTIAL_LIST_FOR_APPROVALv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_ZBM_POTENTIAL_LIST_FOR_APPROVAL 61       

--------------------------------------------            

-- CREATED BY: GURU SINGH            

-- CREATED DATE: 24-SEP-2022            

--------------------------------------------            

CREATE PROCEDURE [BSV_IVF].[USP_GET_ZBM_POTENTIAL_LIST_FOR_APPROVALv1]            

(        

    @KamId int       

)        

AS            

SET NOCOUNT on;           

        BEGIN         

       

    select accountName, CENTRENAME, DoctorName, CITY,        

            case HP.ZBMApproved       

                when 1 then 'Pending'       

                when 0 then 'Approved'       

                when 2 then 'Rejected'       

            end as statusText,       

            case HP.ZBMApproved       

                when 1 then 0       

                when 0 then 1       

                when 2 then 2       

            end as sortOrder, HP.*       

      

            from tblhospitalsPotentials HP       

            INNER JOIN tblCustomers C ON C.CustomerID = hp.hospitalId       

            left OUTER JOIN tblAccount a on a.accountID = c.accountID       

    where 1 = 1       

    --and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)        --for feb

    and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)        --for jan

    and empId =  @KamId    and HP.isApproved <> 1     

     order by sortOrder ASC       

       

        END       

SET NOCOUNT OFF; 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ZBM_RATE_CONTRACT_LIST_FOR_APPROVAL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- USP_GET_ZBM_RATE_CONTRACT_LIST_FOR_APPROVAL 63   
--------------------------------------------         
-- CREATED BY: GURU SINGH         
-- CREATED DATE: 24-SEP-2022         
--------------------------------------------      
CREATE PROCEDURE [BSV_IVF].[USP_GET_ZBM_RATE_CONTRACT_LIST_FOR_APPROVAL] 
( 
    @parentID int 
) 
as 
BEGIN 
    SELECT 
       --  cat.*, 987654,
        a.accountName, a.accountId as aid, 
        case 
              when cat.isApproved = 1 then 'Approval Pending' 
               when cat.isApproved = 0 then 'Approved' 
              when cat.expiryDate < getdate() then 'Expired' 
              when cat.accountID is null then 'No Contract' 
            end as RateContractStatus, 
        isNull(cat.accountID, 0) as CatAccountId, 
        (select count(*) 
        from TblContractDetails 
        where isdisabled = 0 and chainAccountTypeId = cat.accountID) as SKUDetails, 
        c.* 
    from tblCustomers C 
        INNER JOIN tblEmpHospitals eh ON EH.hospitalId = c.customerId 
        INNER JOIN tblHierarchy H ON EH.EmpID = H.EmpID 
        INNER JOIN tblaccount a on c.accountID = a.accountID 
        inner join tblchainAccountType cat on cat.customerAccountID = c.accountID and cat.isDisabled = 0 
    WHERE c.isdisabled = 0 and h.parentID = @parentID -- and cat.isapproved = 1 
    order by a.accountName ASC 
 
END 
  
 

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_GET_ZBM_RATE_CONTRACT_LIST_FOR_APPROVALv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

-- USP_GET_ZBM_RATE_CONTRACT_LIST_FOR_APPROVAL 63   

--------------------------------------------         

-- CREATED BY: GURU SINGH         

-- CREATED DATE: 24-SEP-2022         

--------------------------------------------      

CREATE PROCEDURE [BSV_IVF].[USP_GET_ZBM_RATE_CONTRACT_LIST_FOR_APPROVALv1] 

( 

    @parentID int 

) 

as 

BEGIN 

    SELECT 

       --  cat.*, 987654,

        a.accountName, a.accountId as aid, 

        case 

              when cat.isApproved = 1 then 'Approval Pending' 

               when cat.isApproved = 0 then 'Approved' 

              when cat.expiryDate < getdate() then 'Expired' 

              when cat.accountID is null then 'No Contract' 

            end as RateContractStatus, 

        isNull(cat.accountID, 0) as CatAccountId, 

        (select count(*) 

        from TblContractDetails 

        where isdisabled = 0 and chainAccountTypeId = cat.accountID) as SKUDetails, 

        c.* 

    from tblCustomers C 

        INNER JOIN tblEmpHospitals eh ON EH.hospitalId = c.customerId 

        INNER JOIN tblHierarchy H ON EH.EmpID = H.EmpID 

        INNER JOIN tblaccount a on c.accountID = a.accountID 

        inner join tblchainAccountType cat on cat.customerAccountID = c.accountID and cat.isDisabled = 0 

    WHERE c.isdisabled = 0 and h.parentID = @parentID -- and cat.isapproved = 1 

    order by a.accountName ASC 

 

END 

  

GO
/****** Object:  StoredProcedure [BSV_IVF].[usp_insert_CUSTOMER_contractRate]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [BSV_IVF].[usp_insert_CUSTOMER_contractRate] (
    @chainAccountTypeId int,
    @brandId int,
    @brandGroupId int,
    @medId int,
    @price FLOAT
)
AS
    BEGIN
            UPDATE TblContractDetails set isdisabled = 1
            WHERE  
                chainAccountTypeId = @chainAccountTypeId and
                brandId = @brandId  and
                brandGroupId = @brandGroupId  and
                medId = @medId

            INSERT INTO TblContractDetails (chainAccountTypeId, brandId, 
                    brandGroupId, medId, price, isDisabled)
                    VALUES (@chainAccountTypeId, @brandId, 
                    @brandGroupId, @medId, @price, 0) 
    END




-- select * from TblContractDetails

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_IUI_CYCLE_CATEGORY]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_IUI_CYCLE_CATEGORY_v1 64, 1, 2023  
------------------------------------  
-- crated by : guru singh  
-- crated date: 15-mar-2023  
------------------------------------  
CREATE PROCEDURE [BSV_IVF].[USP_IUI_CYCLE_CATEGORY]   
(  
    @empId int = null,  
    @month int = NULL,  
    @Year int = null  
)  
AS    
    set nocount on;  
        BEGIN  
        if @month is NULL  
            BEGIN  
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
            END  
        if @Year is NULL  
            BEGIN  
            set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
            END  
CREATE TABLE #empHierarchy   
(   
    levels smallInt,   
    EmpID INT,   
    ParentId int   
)   
;WITH   
    RecursiveCte   
    AS   
    (   
        SELECT 1 as Level, H1.EmpID, H1.ParentId   
            FROM tblHierarchy H1   
            WHERE (@empid is null or ParentID = @empid)   
        UNION ALL   
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId   
            FROM tblHierarchy H2   
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID   
    )   
            insert into #empHierarchy   
                (levels, EmpID, ParentId )   
            SELECT Level, EmpID, ParentId   
            FROM RecursiveCte r   
            ;   
             insert into #empHierarchy   
                (levels, EmpID, ParentId )   
            VALUEs (0, @empId, -1)  
        declare @addedFor DATE  
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))   
        select case  
                when IUICycle = 0 then 'Nill'  
                WHEN IUICycle BETWEEN 1 AND 10 THEN '1 to 10 Cycle'  
                WHEN IUICycle BETWEEN 11 AND 20 THEN '11 to 20 Cycle'  
                WHEN IUICycle BETWEEN 21 AND 30 THEN '21 to 30 Cycle'  
                WHEN IUICycle BETWEEN 31 AND 400 THEN '31 to 40 Cycle'  
                else 'F - more then 40 Cycle'  
            end as Cycle,  
			case  
                when IUICycle = 0 then 0  
                WHEN IUICycle BETWEEN 1 AND 10 THEN 1  
                WHEN IUICycle BETWEEN 11 AND 20 THEN 2  
                WHEN IUICycle BETWEEN 21 AND 30 THEN 3  
                WHEN IUICycle BETWEEN 31 AND 400 THEN 4  
                else 5  
            end as CycleSort,  
			 hospitalId  
        from tblhospitalsPotentials  
        where PotentialEnteredFor = @addedFor  
        and empId in (select empId from #empHierarchy)  
		order by CycleSort asc  
          drop table #empHierarchy   
        END  
    set nocount off;  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_IUI_CYCLE_CATEGORY_v1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------
-- crated by : guru singh
-- crated date: 15-mar-2023
------------------------------------
CREATE PROCEDURE [BSV_IVF].[USP_IUI_CYCLE_CATEGORY_v1] 
(
    @empId int = null,
    @month int = NULL,
    @Year int = null
)
AS  
    set nocount on;
        BEGIN
        if @month is NULL
            BEGIN
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))
            END
        if @Year is NULL
            BEGIN
            set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))
            END

CREATE TABLE #empHierarchy 
( 
    levels smallInt, 
    EmpID INT, 
    ParentId int 
) 
             
;WITH 
    RecursiveCte 
    AS 
    ( 
        SELECT 1 as Level, H1.EmpID, H1.ParentId 
            FROM tblHierarchy H1 
            WHERE (@empid is null or ParentID = @empid) 
        UNION ALL 
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId 
            FROM tblHierarchy H2 
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID 
    ) 
            insert into #empHierarchy 
                (levels, EmpID, ParentId ) 
            SELECT Level, EmpID, ParentId 
            FROM RecursiveCte r 
            ; 
             insert into #empHierarchy 
                (levels, EmpID, ParentId ) 
            VALUEs (0, @empId, -1)

        declare @addedFor DATE
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1)) 
        select case
                when IUICycle = 0 then 'A'
                WHEN IUICycle BETWEEN 1 AND 10 THEN 'B'
                WHEN IUICycle BETWEEN 11 AND 20 THEN 'C'
                WHEN IUICycle BETWEEN 21 AND 30 THEN 'D'
                WHEN IUICycle BETWEEN 31 AND 40 THEN 'E'
                else 'F'
            end as Cycle, hospitalId
        from tblhospitalsPotentials
        where PotentialEnteredFor = @addedFor
        and empId in (select empId from #empHierarchy)


          drop table #empHierarchy 
        END
    set nocount off;




GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_IVF_CYCLE_CATEGORY]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_IVF_CYCLE_CATEGORY 64, 1, 2023  
 ------------------------------------  
 -- crated by : guru singh  
 -- crated date: 15-mar-2023  
 ------------------------------------  
 CREATE PROCEDURE [BSV_IVF].[USP_IVF_CYCLE_CATEGORY]   
 (  
     @empId int = null,  
     @month int = NULL,  
    @Year int = null  
 )  
 AS    
     set nocount on;  
        BEGIN  
         if @month is NULL  
             BEGIN  
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
             END  
        if @Year is NULL  
  
            BEGIN  
             set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
              END  
  
 CREATE TABLE #empHierarchy   
 (   
  
    levels smallInt,   
     EmpID INT,   
     ParentId int   
)   
;WITH   
    RecursiveCte   
    AS   
    (   
        SELECT 1 as Level, H1.EmpID, H1.ParentId   
            FROM tblHierarchy H1   
            WHERE (@empid is null or ParentID = @empid)   
        UNION ALL   
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId   
            FROM tblHierarchy H2   
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID   
    )   
            insert into #empHierarchy   
                (levels, EmpID, ParentId )   
            SELECT Level, EmpID, ParentId   
            FROM RecursiveCte r   
            ;   
             insert into #empHierarchy   
                (levels, EmpID, ParentId )   
            VALUEs (0, @empId, -1)  
        declare @addedFor DATE  
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))   
        select case  
                when IvFCycle = 0 then 'Nill'  
                WHEN IvFCycle BETWEEN 1 AND 10 THEN '1 to 10 Cycle'  
                WHEN IvFCycle BETWEEN 11 AND 20 THEN '11 to 20 Cycle'  
                WHEN IvFCycle BETWEEN 21 AND 30 THEN '21 to 30 Cycle'  
                WHEN IvFCycle BETWEEN 31 AND 400 THEN '31 to 40 Cycle'  
                else 'F more than 40 Cycle'  
            end as Cycle, hospitalId, 
            case  
                when IvFCycle = 0 then 0  
                WHEN IvFCycle BETWEEN 1 AND 10 THEN 1  
                WHEN IvFCycle BETWEEN 11 AND 20 THEN 2  
                WHEN IvFCycle BETWEEN 21 AND 30 THEN 3  
                WHEN IvFCycle BETWEEN 31 AND 400 THEN 4  
                else 5  
            end as CycleSort 
  
        from tblhospitalsPotentials  
        where PotentialEnteredFor = @addedFor  
        and empId in (select empId from #empHierarchy)  
		order by CycleSort asc  
          drop table #empHierarchy   
        END  
    set nocount off;  

GO
/****** Object:  StoredProcedure [BSV_IVF].[usp_list_competitor_SKUs]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [BSV_IVF].[usp_list_competitor_SKUs]
as
set NOCOUNT on;
    select sg.brandId, sg.brandName, bcs.competitorId, bcs.name from tblBrandcompetitorSKUs bcs
    inner join tblSkuGroup sg on bcs.brandId = sg.brandId
    where bcs.isdisabled = 0
    order by sg.brandId asc
set NOCOUNT off;

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_LIST_MARKET_INSIGHT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------
-- CREATED BY: GURU SINGH
-- CREATED DATE: 16-FEB-2023
-------------------------------------------
CREATE PROCEDURE [BSV_IVF].[USP_LIST_MARKET_INSIGHT]
AS
    SET NOCOUNT ON;
        SELECT * FROM tblMarketInsights ORDER BY insightId DESC
    SET NOCOUNT OFF;

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_LIST_MARKET_INSIGHT_BY_INSIGHTID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 exec USP_LIST_MARKET_INSIGHT_BY_INSIGHTID null, 5667; 
 exec USP_LIST_MARKET_INSIGHT_BY_INSIGHTID 5501, 5667 
 */
-------------------------------------------   
-- CREATED BY: GURU SINGH   
-- CREATED DATE: 16-FEB-2023   
-------------------------------------------   
CREATE PROCEDURE [BSV_IVF].[USP_LIST_MARKET_INSIGHT_BY_INSIGHTID]   
(   
    @insightId INT = NULL, 
    @centerId int = null   
)   
AS   
    SET NOCOUNT ON;   
    
 
            
            if exists (select 1 FROM tblMarketInsights WHERE insightId = isnull(@insightId,0))  
                BEGIN   
                    SELECT * FROM tblMarketInsights WHERE insightId = isnull(@insightId,0)  
                END
            ELSE
                BEGIN
                 SELECT top 1 * FROM tblMarketInsights WHERE centreId = isnull(@centerId,0)  
                    ORDER BY insightId DESC
                END

            SELECT top 1 * FROM TblHospitalsPotentials WHERE hospitalId = @centerID  
                        --and empID = @empID  
                    order by potentialId DESC  
  
    SET NOCOUNT OFF;

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_BRANDS_ANALYSIS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_REPORT_BRANDS_ANALYSIS null, NULL, NULL
------------------------------------   
-- crated by : guru singh   
-- crated date: 15-mar-2023   
------------------------------------   
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_BRANDS_ANALYSIS]   
(   
    @empId int = null,  
    @fromDate date = null,
    @toDate date  = null
)   
AS     
set nocount on;     
    BEGIN
        IF @fromDate IS NULL    
        BEGIN
            SET @fromDate = '1-JAN-2023'
        END
        IF @toDate IS NULL    
        BEGIN
            SET @toDate = '31-DEC-2029'
        END


            CREATE TABLE #empHierarchy (levels smallInt, EmpID INT, ParentId int )
            ;WITH    
                RecursiveCte    
                AS    
                (    
                    SELECT 1 as Level, H1.EmpID, H1.ParentId    
                        FROM tblHierarchy H1    
                        WHERE (@empid is null or ParentID = @empid)    
                    UNION ALL    
                    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId    
                        FROM tblHierarchy H2    
                            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID    
                )    
                        insert into #empHierarchy    
                            (levels, EmpID, ParentId )    
                        SELECT Level, EmpID, ParentId    
                        FROM RecursiveCte r    
                        ;    
                        insert into #empHierarchy    
                            (levels, EmpID, ParentId )    
                        VALUEs (0, @empId, -1)   

            -- select count(*) from #empHierarchy  

            -- USP_REPORT_BRANDS_ANALYSIS null, '1-jan-2023', '31-Mar-2023'
            select ha.brandId, sg.groupname as name,  sum(qty) as sumTotalofQty
            -- count(*) as CNT
            from TblHospitalactuals ha  
            INNER JOIN tblBrandGroups sg on sg.brandGroupId = ha.brandGroupId  
            where ha.isApproved = 0  and ha.isDisabled = 0  
            and empId in (select empId from #empHierarchy)   
            and (ActualEnteredFor BETWEEN @fromDate AND @toDate)
            GROUP BY ha.brandId, ha.brandGroupId, sg.groupname 
            order by ha.brandId asc



            select ca.brandId, bcs.name, sum(businessValue) as TotalBusinessValue from tblCompetitions ca 
            inner join tblbrandCompetitorSkus bcs 
                on bcs.brandId = ca.brandId and bcs.competitorId = ca.CompetitionSkuId
            where ca.isApproved = 0  -- and ca.brandId  in (1) and bcs.competitorId in (2, 4, 19)
            and empId in (select empId from #empHierarchy)   
            and (competitionAddedFor BETWEEN @fromDate AND @toDate)
            GROUP by ca.brandId, bcs.name
            order by ca.brandId asc    

         
        

            drop table #empHierarchy    
    END   
set nocount off;   

-- select * from tblBrandGroups where brandId = 6
-- select * from tblBrandcompetitorSKUs where brandId = 6

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_BRANDS_CONSUMPTION]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_REPORT_BRANDS_CONSUMPTION null, NULL, NULL 
------------------------------------    
-- crated by : guru singh    
-- crated date: 15-mar-2023    
------------------------------------    
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_BRANDS_CONSUMPTION]
(    
    -- @empId int = null,   
    -- @fromDate date = null, 
    -- @toDate date  = null 

     @empId int = null, 
     @month int = NULL, 
    @Year int = null 
)    
AS      
set nocount on;      
    BEGIN 
        -- IF @fromDate IS NULL     
        -- BEGIN 
        --     SET @fromDate = '1-JAN-2023' 
        -- END 
        -- IF @toDate IS NULL     
        -- BEGIN 
        --     SET @toDate = '31-DEC-2023' 
        -- END 
   
         if @month is NULL 
             BEGIN 
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)) 
             END 
        if @Year is NULL 
 
            BEGIN 
             set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)) 
              END 
 
 
            CREATE TABLE #empHierarchy (levels smallInt, EmpID INT, ParentId int ) 
            ;WITH     
                RecursiveCte     
                AS     
                (     
                    SELECT 1 as Level, H1.EmpID, H1.ParentId     
                        FROM tblHierarchy H1     
                        WHERE (@empid is null or ParentID = @empid)     
                    UNION ALL     
                    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId     
                        FROM tblHierarchy H2     
                            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID     
                )     
                        insert into #empHierarchy     
                            (levels, EmpID, ParentId )     
                        SELECT Level, EmpID, ParentId     
                        FROM RecursiveCte r     
                        ;     
                        insert into #empHierarchy     
                            (levels, EmpID, ParentId )     
                        VALUEs (0, @empId, -1)    
 



 declare @addedFor DATE 
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))  
    SELECT  
        bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,    
        bsv_ivf.getMyRBMInfo(e.empid) AS RBM,    
        e.firstName as KamName, e.Designation,     
        c.CENTRENAME as centreName,  c.DoctorName,  
        HP.IVFCycle as 'IVF Fresh stimulated Cycles'
        --, hp.hospitalId,
        --c.customerId
        , c.CENTRENAME, c.DoctorName,
         hp.empId
        ,(HP.IVFCycle * 10) as 'Foligraf'
        ,(HP.IVFCycle * 10) as 'Humog'
        ,(HP.IVFCycle * 5) as 'Asporelix'
        ,(HP.IVFCycle * 1) as 'R-Hucog'
        ,(HP.IVFCycle * 1) as 'Agotrig'
        ,(HP.IVFCycle * 30) as 'Midydrogen'
        FROM TblHospitalsPotentials hp
        INNER join tblCustomers c on c.customerID = hp.hospitalId
        INNER join tblEmployees e on e.empId = hp.empId
        WHERE  hp.isActive = 0 
        and  hp.isApproved = 0
       --  and (PotentialEnteredFor BETWEEN @fromDate AND @toDate) 
        and PotentialEnteredFor = @addedFor 
        and hp.empId in (select empId from #empHierarchy)   
         order by hospitalId ASC 
      
      
         
            drop table #empHierarchy     
    END    
set nocount off;    
    
 
--    SELECT * FROM TBLEMPLOYEES WHERE DESIGNATION = 'ADMIN'

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_BRANDS_FOLIGRAF_ANALYSIS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_REPORT_BRANDS_FOLIGRAF_ANALYSIS null, NULL, NULL
------------------------------------   
-- crated by : guru singh   
-- crated date: 15-mar-2023   
------------------------------------   
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_BRANDS_FOLIGRAF_ANALYSIS]   
(   
    @empId int = null,  
    @fromDate date = null,
    @toDate date  = null
)   
AS     
set nocount on;     
    BEGIN
        IF @fromDate IS NULL    
        BEGIN
            SET @fromDate = '1-JAN-2023'
        END
        IF @toDate IS NULL    
        BEGIN
            SET @toDate = '31-DEC-2023'
        END


            CREATE TABLE #empHierarchy (levels smallInt, EmpID INT, ParentId int )
            ;WITH    
                RecursiveCte    
                AS    
                (    
                    SELECT 1 as Level, H1.EmpID, H1.ParentId    
                        FROM tblHierarchy H1    
                        WHERE (@empid is null or ParentID = @empid)    
                    UNION ALL    
                    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId    
                        FROM tblHierarchy H2    
                            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID    
                )    
                        insert into #empHierarchy    
                            (levels, EmpID, ParentId )    
                        SELECT Level, EmpID, ParentId    
                        FROM RecursiveCte r    
                        ;    
                        insert into #empHierarchy    
                            (levels, EmpID, ParentId )    
                        VALUEs (0, @empId, -1)   

            -- select count(*) from #empHierarchy  

            -- USP_REPORT_BRANDS_FOLIGRAF_ANALYSIS null, '1-jan-2023', '31-Mar-2023'
            select sg.groupname as name,  sum(qty) as sumTotalofQty
            -- count(*) as CNT
            from TblHospitalactuals ha  
            INNER JOIN tblBrandGroups sg on sg.brandGroupId = ha.brandGroupId  
            where ha.isApproved = 0  and ha.isDisabled = 0  
            and ha.brandId  = 1 and ha.brandGroupId in (1, 2)
            and empId in (select empId from #empHierarchy)   
            and (ActualEnteredFor BETWEEN @fromDate AND @toDate)
            GROUP BY ha.brandGroupId, sg.groupname 



            select bcs.name, sum(businessValue) as TotalBusinessValue from tblCompetitions ca 
            inner join tblbrandCompetitorSkus bcs 
                on bcs.brandId = ca.brandId and bcs.competitorId = ca.CompetitionSkuId
            where ca.isApproved = 0  and ca.brandId  in (1) and bcs.competitorId in (2, 4, 19)
            and empId in (select empId from #empHierarchy)   
            and (competitionAddedFor BETWEEN @fromDate AND @toDate)
            GROUP by bcs.name
            order by TotalBusinessValue desc    

            select bcs.name, sum(businessValue) as TotalBusinessValue from tblCompetitions ca 
            inner join tblbrandCompetitorSkus bcs 
                on bcs.brandId = ca.brandId and bcs.competitorId = ca.CompetitionSkuId
            where ca.isApproved = 0  and ca.brandId  in (1) and bcs.competitorId in (1, 3, 5)
            and empId in (select empId from #empHierarchy)   
            and (competitionAddedFor BETWEEN @fromDate AND @toDate)
            GROUP by bcs.name
            order by TotalBusinessValue desc    
        

            drop table #empHierarchy    
    END   
set nocount off;   

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_BRANDS_VENNDIAGRAM]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_REPORT_BRANDS_VENNDIAGRAM null, NULL, NULL
------------------------------------   
-- crated by : guru singh   
-- crated date: 15-mar-2023   
------------------------------------   
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_BRANDS_VENNDIAGRAM]   
(   
    @empId int = null,  
    @fromDate date = null,
    @toDate date  = null
)   
AS     
set nocount on;     
    BEGIN
        IF @fromDate IS NULL    
        BEGIN
            SET @fromDate = '1-JAN-2023'
        END
        IF @toDate IS NULL    
        BEGIN
            SET @toDate = '31-DEC-2023'
        END


            CREATE TABLE #empHierarchy (levels smallInt, EmpID INT, ParentId int )
            ;WITH    
                RecursiveCte    
                AS    
                (    
                    SELECT 1 as Level, H1.EmpID, H1.ParentId    
                        FROM tblHierarchy H1    
                        WHERE (@empid is null or ParentID = @empid)    
                    UNION ALL    
                    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId    
                        FROM tblHierarchy H2    
                            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID    
                )    
                        insert into #empHierarchy    
                            (levels, EmpID, ParentId )    
                        SELECT Level, EmpID, ParentId    
                        FROM RecursiveCte r    
                        ;    
                        insert into #empHierarchy    
                            (levels, EmpID, ParentId )    
                        VALUEs (0, @empId, -1)   

            -- select count(*) from #empHierarchy  
            select sg.brandName, count(*) as CNT
            from TblHospitalactuals ha  
            INNER JOIN tblSkuGroup sg on sg.brandID = ha.brandId  
            where ha.isApproved = 0  and ha.isDisabled = 0  
            and empId in (select empId from #empHierarchy)   
            and (ActualEnteredFor BETWEEN @fromDate AND @toDate)
            GROUP BY sg.brandName

-- USP_REPORT_BRANDS_VENNDIAGRAM null, NULL, NULL

            select sg.brandName, hospitalId
            from TblHospitalactuals ha  
            INNER JOIN tblSkuGroup sg on sg.brandID = ha.brandId  
            where ha.isApproved = 0  and ha.isDisabled = 0  
            and empId in (select empId from #empHierarchy)   
            and (ActualEnteredFor BETWEEN @fromDate AND @toDate)
            -- OR (ActualEnteredFor IS NULL AND @fromDate IS NULL AND @toDate IS NULL)
            -- OR (ActualEnteredFor >= @fromDate AND @toDate IS NULL)
            -- OR (ActualEnteredFor <= @toDate AND @fromDate IS NULL)
            order by hospitalId ASC
        
            drop table #empHierarchy    
    END   
set nocount off;   
   

--    SELECT * FROM TBLEMPLOYEES WHERE DESIGNATION = 'ADMIN'

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_HOSPITALCOUNT_BRANDWISE]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_REPORT_HospitalCount_brandWise null, 1, 2023  
------------------------------------  
-- crated by : guru singh  
-- crated date: 15-mar-2023  
------------------------------------  
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_HOSPITALCOUNT_BRANDWISE]  
(  
    @empId int = null,  
    @month int = NULL,  
    @Year int = null  
)  
AS    
    set nocount on;  
        BEGIN  
        if @month is NULL  
            BEGIN  
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
            END  
        if @Year is NULL  
            BEGIN  
            set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
            END  
  
CREATE TABLE #empHierarchy   
(   
    levels smallInt,   
    EmpID INT,   
    ParentId int   
)   
               
;WITH   
    RecursiveCte   
    AS   
    (   
        SELECT 1 as Level, H1.EmpID, H1.ParentId   
            FROM tblHierarchy H1   
            WHERE (@empid is null or ParentID = @empid)   
        UNION ALL   
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId   
            FROM tblHierarchy H2   
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID   
    )   
            insert into #empHierarchy   
                (levels, EmpID, ParentId )   
            SELECT Level, EmpID, ParentId   
            FROM RecursiveCte r   
            ;   
             insert into #empHierarchy   
                (levels, EmpID, ParentId )   
            VALUEs (0, @empId, -1)  
  
 
 -- select count(*) from #empHierarchy 
 
        declare @addedFor DATE  
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))   
       
 
         
            select * 
            from 
            ( 
            select ha.brandId, sg.brandName from TblHospitalactuals ha 
            INNER JOIN tblSkuGroup sg on sg.brandID = ha.brandId 
            where ha.isApproved = 0  and ha.isDisabled = 0 
            and ActualEnteredFor = @addedFor  
            and empId in (select empId from #empHierarchy)  
            ) d 
            pivot 
            ( 
            count(d.brandId) 
            for brandName in (FOLIGRAF,HUMOG,ASPORELIX,[R-HUCOG],FOLICULIN,AGOTRIG,MIDYDROGEN,SPRIMEO) 
            ) piv; 
 
 
  

        SELECT COUNT(*) as totalHospital 
        FROM tblCustomers c 
            INNER JOIN  tblEmpHospitals eh on eh.hospitalId = c.customerId
            INNER JOIN tblSpecialtyType st on st.specialtyId = c.specialtyId and st.specialtyId in (2) 
        WHERE 
            c.isdisabled = 0 and eh.empID in (select EmpID from #empHierarchy )
  

          drop table #empHierarchy   
        END  
    set nocount off;  
  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_MARKET_INSIGHT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_REPORT_MARKET_INSIGHT null, 1, 2023   
------------------------------------   
-- crated by : guru singh   
-- crated date: 15-mar-2023   
------------------------------------   
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_MARKET_INSIGHT]   
(   
    @empId int = null,   
    @month int = NULL,   
    @Year int = null   
)   
AS     
    set nocount on;   
        BEGIN   
        if @month is NULL   
            BEGIN   
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))   
            END   
        if @Year is NULL   
            BEGIN   
            set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))   
            END   
   
CREATE TABLE #empHierarchy    
(    
    levels smallInt,    
    EmpID INT,    
    ParentId int    
)    
                
;WITH    
    RecursiveCte    
    AS    
    (    
        SELECT 1 as Level, H1.EmpID, H1.ParentId    
            FROM tblHierarchy H1    
            WHERE (@empid is null or ParentID = @empid)    
        UNION ALL    
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId    
            FROM tblHierarchy H2    
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID    
    )    
            insert into #empHierarchy    
                (levels, EmpID, ParentId )    
            SELECT Level, EmpID, ParentId    
            FROM RecursiveCte r    
            ;    
             insert into #empHierarchy    
                (levels, EmpID, ParentId )    
            VALUEs (0, @empId, -1)   
   
  
    -- SELECT count(*) from #empHierarchy  
  
        declare @addedFor DATE   
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))    
        
  
   
            SELECT  
                SUM(TRY_CAST(answerFourRHCG AS INT)) as RHCG,  
                SUM(TRY_CAST(answerFourUHCG AS INT)) as UHCG,  
                SUM(TRY_CAST(answerFourAgonistL AS INT)) as AgonistL,  
                SUM(TRY_CAST(answerFourAgonistT AS INT)) as AgonistT,  
                SUM(TRY_CAST(answerFourRHCGTriptorelin AS INT)) as RHCGTriptorelin,  
                SUM(TRY_CAST(answerFourRHCGLeuprolide AS INT)) as RHCGLeuprolide 
            FROM tblMarketInsights 
            WHERE  addedFor = @addedFor  -- 1388 
            AND isApproved = 0 -- 1025 
            AND isActive = 0 -- 991 
            AND empId IN (SELECT empId FROM #empHierarchy)   
 
 
             
            SELECT  
                SUM(TRY_CAST(answerProgesterone AS INT)) as Progesterone, 
                SUM(TRY_CAST(answerFiveDydrogesterone AS INT)) as Dydrogesterone, 
                SUM(TRY_CAST(answerFiveCombination AS INT)) as Combination 
            FROM tblMarketInsights 
            WHERE  addedFor = @addedFor  -- 1388 
            AND isApproved = 0 -- 1025 
            AND isActive = 0 -- 991 
            AND empId IN (SELECT empId FROM #empHierarchy)   
 
 
 
            SELECT  
               SUM(TRY_CAST(answerThreeHMG AS INT)) as [R-FSH], 
                SUM(TRY_CAST(answerThreeRFSH AS INT)) as HMG 
            FROM tblMarketInsights 
            WHERE  addedFor = @addedFor  -- 1388 
            AND isApproved = 0 -- 1025 
            AND isActive = 0 -- 991 
            AND empId IN (SELECT empId FROM #empHierarchy)   
  
   
 
            SELECT  
                COUNT(CASE WHEN answerOne = 0 THEN 1 END) AS Yes_obstetrics, 
                COUNT(CASE WHEN answerOne = 1 THEN 1 END) AS NO_obstetrics 
            FROM tblMarketInsights 
            WHERE  addedFor = @addedFor  -- 1388 
            AND isApproved = 0 -- 1025 
            AND isActive = 0 -- 991 
            AND empId IN (SELECT empId FROM #empHierarchy)   
 
 
    
   
    SELECT  
 HP.IVFCycle , 
TRY_CAST(answerThreeRFSH AS DECIMAL(5, 2) ) AS answerThreeRFSH, 
TRY_CAST(IVFCycle * (TRY_CAST(answerThreeRFSH AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [RFS CONSUMPTION] , 
--ROUND(TRY_CAST(IVFCycle * (TRY_CAST(answerThreeRFSH AS DECIMAL )/100) AS DECIMAL(5, 2)), 0) AS [RFS CONSUMPTION ROUNDOFF] , 
  
TRY_CAST(answerThreeHMG AS DECIMAL ) AS answerThreeHMG  ,
TRY_CAST(IVFCycle * (TRY_CAST(answerThreeHMG AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [HMG CONSUMPTION] , 
-- ROUND(TRY_CAST(IVFCycle * (TRY_CAST(answerThreeHMG AS DECIMAL )/100) AS DECIMAL(5, 2)), 0) AS [HMG CONSUMPTION ROUNDOFF] 

MI.answerProgesterone,
TRY_CAST(IVFCycle * (TRY_CAST(answerProgesterone AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [Progesterone CONSUMPTION],

MI.answerFiveDydrogesterone,
TRY_CAST(IVFCycle * (TRY_CAST(answerFiveDydrogesterone AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [Dydrogesterone CONSUMPTION],

MI.answerFiveCombination,
TRY_CAST(IVFCycle * (TRY_CAST(answerFiveCombination AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [Progesretone+Dydrogesterone CONSUMPTION],

answerFourRHCG,
TRY_CAST(IVFCycle * (TRY_CAST(answerFourRHCG AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [R-HCG CONSUMPTION],
answerFourUHCG,
TRY_CAST(IVFCycle * (TRY_CAST(answerFourUHCG AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [U-HCG CONSUMPTION],
answerFourAgonistL,
TRY_CAST(IVFCycle * (TRY_CAST(answerFourAgonistL AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [Only Agonist-Leuprolide CONSUMPTION],
answerFourAgonistT,
TRY_CAST(IVFCycle * (TRY_CAST(answerFourAgonistT AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [Only Agonist-Triptorelin CONSUMPTION],
answerFourRHCGTriptorelin,
TRY_CAST(IVFCycle * (TRY_CAST(answerFourRHCGTriptorelin AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [Dual Trigger (R-HCG + Triptorelin) CONSUMPTION],
answerFourRHCGLeuprolide,
TRY_CAST(IVFCycle * (TRY_CAST(answerFourRHCGLeuprolide AS DECIMAL )/100) AS DECIMAL(5, 2)) AS [Dual Trigger (R-HCG + Leuprolide) CONSUMPTION]




        FROM tblMarketInsights MI
        INNER JOIN TblHospitalsPotentials HP ON HP.HOSPITALID = MI.CENTREID
        WHERE  
        MI.addedFor = @addedFor 
        AND HP.PotentialEnteredFor = @addedFor  
        AND MI.isApproved = 0  
        AND MI.isActive = 0 
        AND MI.empId IN (SELECT empId FROM #empHierarchy) 

        
 
          drop table #empHierarchy    
        END   
    set nocount off;   
   

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_POTENTIALS_V1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_REPORT_Potentials_v1 null, 1, 2024  
------------------------------------  
-- crated by : guru singh  
-- crated date: 15-mar-2023  
------------------------------------  
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_POTENTIALS_V1]  
(  
    @empId int = null,  
    @month int = NULL,  
    @Year int = null  
)  
AS    
    set nocount on;  
        BEGIN  
        if @month is NULL  
            BEGIN  
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
            END  
        if @Year is NULL  
            BEGIN  
            set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))  
            END  
  
CREATE TABLE #empHierarchy   
(   
    levels smallInt,   
    EmpID INT,   
    ParentId int   
)   
               
;WITH   
    RecursiveCte   
    AS   
    (   
        SELECT 1 as Level, H1.EmpID, H1.ParentId   
            FROM tblHierarchy H1   
            WHERE (@empid is null or ParentID = @empid)   
        UNION ALL   
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId   
            FROM tblHierarchy H2   
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID   
    )   
            insert into #empHierarchy   
                (levels, EmpID, ParentId )   
            SELECT Level, EmpID, ParentId   
            FROM RecursiveCte r   
            ;   
             insert into #empHierarchy   
                (levels, EmpID, ParentId )   
            VALUEs (0, @empId, -1)  
  
 
    -- SELECT count(*) from #empHierarchy 
 
        declare @addedFor DATE  
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))   
       
 
  
            
 
  

            -- SELECT 
            --     COUNT(CASE WHEN answerOne = 0 THEN 1 END) AS Yes_obstetrics,
            --     COUNT(CASE WHEN answerOne = 1 THEN 1 END) AS NO_obstetrics
            -- FROM tblMarketInsights
            -- WHERE  addedFor = @addedFor  -- 1388
            -- AND isApproved = 0 -- 1025
            -- AND isActive = 0 -- 991
            -- AND empId IN (SELECT empId FROM #empHierarchy)  



            SELECT 
                SUM(TRY_CAST(DonorCycles AS INT)) as DonorCycles, 
                SUM(TRY_CAST(SelftCycle AS INT)) as SelfCycle
            FROM TblHospitalsPotentials
            WHERE  1 =1
            AND PotentialEnteredFor = @addedFor  -- 1388
            AND isApproved = 0 -- 1025
            AND isActive = 0 -- 991
            AND empId IN (SELECT empId FROM #empHierarchy) 


            
            SELECT 
                SUM(TRY_CAST(AgonistCycles AS INT)) as AgonistCycles, 
                SUM(TRY_CAST(Antagonistcycles AS INT)) as Antagonistcycles
            FROM TblHospitalsPotentials
            WHERE  1 =1
            AND PotentialEnteredFor = @addedFor  -- 1388
            AND isApproved = 0 -- 1025
            AND isActive = 0 -- 991
            AND empId IN (SELECT empId FROM #empHierarchy) 




   
  
  

          drop table #empHierarchy   
        END  
    set nocount off;  
  
  

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_TOP_15_ACCOUNTS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_REPORT_TOP_15_ACCOUNTS null, 1, 2023    
------------------------------------    
-- crated by : guru singh    
-- crated date: 15-mar-2023    
------------------------------------    
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_TOP_15_ACCOUNTS]    
(    
    @empId int = null,    
    @month int = NULL,    
    @Year int = null    
)    
AS      
    set nocount on;    
        BEGIN    
        if @month is NULL    
            BEGIN    
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))    
            END    
        if @Year is NULL    
            BEGIN    
            set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))    
            END    
CREATE TABLE #empHierarchy     
(     
    levels smallInt,     
    EmpID INT,     
    ParentId int     
)     
;WITH     
    RecursiveCte     
    AS     
    (     
        SELECT 1 as Level, H1.EmpID, H1.ParentId     
            FROM tblHierarchy H1     
            WHERE (@empid is null or ParentID = @empid)     
        UNION ALL     
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId     
            FROM tblHierarchy H2     
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID     
    )     
            insert into #empHierarchy     
                (levels, EmpID, ParentId )     
            SELECT Level, EmpID, ParentId     
            FROM RecursiveCte r     
            ;     
             insert into #empHierarchy     
                (levels, EmpID, ParentId )     
            VALUEs (0, @empId, -1)    
 -- select count(*) from #empHierarchy   
        declare @addedFor DATE    
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))     
            select top 15 hospitalId, c.CENTRENAME,   
                a.accountName, c.DoctorName, c.City, s.StateName,  
                sum(qty) as QtyOrdered  
            from tblhospitalActuals ha  
            inner join tblCustomers c on c.customerId = ha.hospitalId 
            INNER join tblAccount a on a.accountID = c.accountID  
            inner join tblState s on s.stateID = c.StateID  
            where ha.isApproved = 0 and ha.isDisabled = 0  
            and actualenteredFor = @addedFor  
            and empId in (select empId from #empHierarchy)   
			and c.isdisabled=0
            group by hospitalId , c.CENTRENAME,   
            a.accountName, c.DoctorName, c.City, s.StateName  
            order by QtyOrdered desc  
          drop table #empHierarchy     
        END    
    set nocount off;    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_REPORT_TOP_15_ACCOUNTS_22092023]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- USP_REPORT_TOP_15_ACCOUNTS null, 1, 2023    
  
------------------------------------    
  
-- crated by : guru singh    
  
-- crated date: 15-mar-2023    
  
------------------------------------    
  
CREATE PROCEDURE [BSV_IVF].[USP_REPORT_TOP_15_ACCOUNTS_22092023]    
  
(    
  
    @empId int = null,    
  
    @month int = NULL,    
  
    @Year int = null    
  
)    
  
AS      
  
    set nocount on;    
  
        BEGIN    
  
        if @month is NULL    
  
            BEGIN    
  
            set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))    
  
            END    
  
        if @Year is NULL    
  
            BEGIN    
  
            set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))    
  
            END    
  
    
  
CREATE TABLE #empHierarchy     
  
(     
  
    levels smallInt,     
  
    EmpID INT,     
  
    ParentId int     
  
)     
  
                 
  
;WITH     
  
    RecursiveCte     
  
    AS     
  
    (     
  
        SELECT 1 as Level, H1.EmpID, H1.ParentId     
  
            FROM tblHierarchy H1     
  
            WHERE (@empid is null or ParentID = @empid)     
  
        UNION ALL     
  
        SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId     
  
            FROM tblHierarchy H2     
  
                INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID     
  
    )     
  
            insert into #empHierarchy     
  
                (levels, EmpID, ParentId )     
  
            SELECT Level, EmpID, ParentId     
  
            FROM RecursiveCte r     
  
            ;     
  
             insert into #empHierarchy     
  
                (levels, EmpID, ParentId )     
  
            VALUEs (0, @empId, -1)    
  
    
  
   
  
 -- select count(*) from #empHierarchy   
  
   
  
        declare @addedFor DATE    
  
        set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))     
  
         
  
   
  
           
  
            select top 15 hospitalId, c.CENTRENAME,   
  
                a.accountName, c.DoctorName, c.City, s.StateName,  
  
                sum(qty) as QtyOrdered  
  
  
  
            from tblhospitalActuals ha  
  
            inner join tblCustomers c on c.customerId = ha.hospitalId  
  
            INNER join tblAccount a on a.accountID = c.accountID  
  
            inner join tblState s on s.stateID = c.StateID  
  
            where ha.isApproved = 0 and ha.isDisabled = 0  
  
            and actualenteredFor = @addedFor  
  
            and empId in (select empId from #empHierarchy)   
  
            group by hospitalId , c.CENTRENAME,   
  
            a.accountName, c.DoctorName, c.City, s.StateName  
  
            order by QtyOrdered desc  
  
  
  
    
  
    
  
          drop table #empHierarchy     
  
        END    
  
    set nocount off;    
  
    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_Update_Employee_Password]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [BSV_IVF].[USP_Update_Employee_Password]
(
	@EmpID int,
	@Password varchar(50)
)
as
Begin
	update BSV_IVF.tblEmployees set [password]=@password where empid=@Empid
End

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_VALIDATE_TEAM_PROGRESS_REPORT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_VALIDATE_TEAM_PROGRESS_REPORT  null, 3, 2023  
 -----------------------------------------  
 -- CREATED BY: GURU SINGH  
 -- CREATED DATE: 2-APR-2023  
 -----------------------------------------  
 CREATE PROCEDURE [BSV_IVF].[USP_VALIDATE_TEAM_PROGRESS_REPORT]  
 (  
      @empId int = null,     
    @month int = NULL,     
    @Year int = null    
 )  
 AS       
    -- SET NOCOUNT ON;     
        BEGIN    
            if @month is NULL     
                BEGIN     
                set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))     
                END     
            if @Year is NULL     
                BEGIN     
                set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))     
                END     
  
              
            CREATE TABLE #empHierarchy      
            (      
                levels smallInt,      
                EmpID INT,      
                ParentId int      
            )      
                  
            ;WITH      
                RecursiveCte      
                AS      
                (      
                    SELECT 1 as Level, H1.EmpID, H1.ParentId      
                        FROM tblHierarchy H1      
                        WHERE (@empid is null or ParentID = @empid)      
                    UNION ALL      
                    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId      
                        FROM tblHierarchy H2      
                            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID      
                )      
  
            insert into #empHierarchy      
                (levels, EmpID, ParentId )      
            SELECT Level, EmpID, ParentId      
            FROM RecursiveCte r      
            ;      
             insert into #empHierarchy      
                (levels, EmpID, ParentId )      
            VALUEs (0, @empId, -1)     
     
    
             -- SELECT count(*) from #empHierarchy    
    
            declare @addedFor DATE     
            set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))   
  
            select e.empid,  
            bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,   bsv_ivf.getMyRBMInfo(e.empid) AS RBM,    e.FIRSTname, e.designation,   
            (select count(*) from tblcustomers c  
            inner join tblemphospitals eh on c.customerId = eh.hospitalId  
            where empID = e.empid and isdisabled = 0 and SpecialtyId in (2)) as TotalIVFCount   
            from tblemployees e where   
            1 = 1  
            and isdisabled = 0   
            AND empId IN (SELECT empId FROM #empHierarchy)    
        --  and e.EmpID = @empid or @empid is null  
            and designationid in (3)  
            ORDER BY e.FIRSTname    
  
            -- USP_VALIDATE_TEAM_PROGRESS_REPORT  78  
  
            select eh.empID, c.customerId, c.CENTRENAME, c.DoctorName,   
                case   
                when hp.potentialenteredfor is null then 'NO'  
                else 'YES'   
                end as PotentialedEntered  
                from tblCustomers c   
            inner join tblEmpHospitals eh on eh.hospitalID = c.customerId   
            left  join TblHospitalsPotentials hp on hp.hospitalID = c.customerId and hp.potentialenteredfor = @addedFor   
            where c.SpecialtyId in (2) AND c.isdisabled = 0 AND HP.isActive = 0
           --  and eh.EmpID = @empid or @empid is null  
            AND eh.EmpID IN (SELECT empId FROM #empHierarchy)   
            order by customerId ASC  
  
  
            select   
             eh.empID, c.customerId, c.CENTRENAME, c.DoctorName  
                , case   
                when ha.actualEnteredFor is null then 'NO'  
                else 'YES'   
                end as BusinessdEntered  
                from tblCustomers c   
            inner join tblEmpHospitals eh on eh.hospitalID = c.customerId   
            left  join tblhospitalactuals ha on ha.hospitalID = c.customerId and ha.actualEnteredFor = @addedFor  
            where c.SpecialtyId in (2) AND c.isdisabled = 0 
            --  and eh.EmpID = @empid or @empid is null  
            AND eh.EmpID IN (SELECT empId FROM #empHierarchy)   
            group by eh.empID, c.customerId, c.CENTRENAME, c.DoctorName, actualEnteredFor  
            order by c.customerId ASC  
            -- USP_VALIDATE_TEAM_PROGRESS_REPORT  811  
  
  
            select   
             eh.empID, c.customerId, c.CENTRENAME, c.DoctorName  
                , case   
                when ha.addedfor is null then 'NO'  
                else 'YES'   
                end as MarketInsightdEntered  
                from tblCustomers c   
            inner join tblEmpHospitals eh on eh.hospitalID = c.customerId   
            left  join tblMarketInsights ha on ha.centreId = c.customerId and ha.addedfor = @addedFor  
            where c.SpecialtyId in (2) AND c.isdisabled = 0 
            --  and eh.EmpID = @empid or @empid is null  
            AND eh.EmpID IN (SELECT empId FROM #empHierarchy)   
            order by c.customerId ASC  
  
        -- USP_VALIDATE_TEAM_PROGRESS_REPORT  811  
  
            select   
             eh.empID, c.customerId, c.CENTRENAME, c.DoctorName  
                , case   
                when ha.competitionAddedFor is null then 'NO'  
                else 'YES'   
                end as CompEntered  
                from tblCustomers c   
            inner join tblEmpHospitals eh on eh.hospitalID = c.customerId   
            left  join tblCompetitions ha on ha.centerId = c.customerId and ha.competitionAddedFor = @addedFor  
            where c.SpecialtyId in (2) AND c.isdisabled = 0 
            --  and eh.EmpID = @empid or @empid is null  
            AND eh.EmpID IN (SELECT empId FROM #empHierarchy)   
            group by eh.empID, c.customerId, c.CENTRENAME, c.DoctorName, competitionAddedFor  
            order by c.customerId ASC  
  
  
  
        END  
    --SET NOCOUNT OFF;    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_VALIDATE_TEAM_PROGRESS_REPORTV1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_VALIDATE_TEAM_PROGRESS_REPORTV1  null, 3, 2023  
 -----------------------------------------  
 -- CREATED BY: GURU SINGH  
 -- CREATED DATE: 2-APR-2023  
 -----------------------------------------  
 CREATE PROCEDURE [BSV_IVF].[USP_VALIDATE_TEAM_PROGRESS_REPORTV1]  
 (  
      @empId int = null,     
    @month int = NULL,     
    @Year int = null    
 )  
 AS       
    -- SET NOCOUNT ON;     
        BEGIN    
            if @month is NULL     
                BEGIN     
                set @month =  month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))     
                END     
            if @Year is NULL     
                BEGIN     
                set @Year =  year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))     
                END     
  
              
            CREATE TABLE #empHierarchy      
            (      
                levels smallInt,      
                EmpID INT,      
                ParentId int      
            )      
                  
            ;WITH      
                RecursiveCte      
                AS      
                (      
                    SELECT 1 as Level, H1.EmpID, H1.ParentId      
                        FROM tblHierarchy H1      
                        WHERE (@empid is null or ParentID = @empid)      
                    UNION ALL      
                    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId      
                        FROM tblHierarchy H2      
                            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID      
                )      
  
            insert into #empHierarchy      
                (levels, EmpID, ParentId )      
            SELECT Level, EmpID, ParentId      
            FROM RecursiveCte r      
            ;      
             insert into #empHierarchy      
                (levels, EmpID, ParentId )      
            VALUEs (0, @empId, -1)     
     
    
             -- SELECT count(*) from #empHierarchy    
            /*
                BELOW RECORD SET GETS ALL THE USER AND IVF HOSPITALS COUNT 
            */
            declare @addedFor DATE     
            set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))   
  
            select e.empid,  
            bsv_ivf.getMyZBMInfo(e.empid) AS ZBM,   bsv_ivf.getMyRBMInfo(e.empid) AS RBM,    e.FIRSTname, e.designation ,

            (
                SELECT   
        COUNT(*)
         
        from tblcustomers C  
        INNER JOIN tblState S ON S.STATEID = C.StateID -- 8368   
       INNER JOIN tblSpecialtyType ST ON ST.specialtyId = C.SpecialtyId -- 8352  
       INNER JOIN tblVisitType VT ON VT.VISITiD = C.visitId -- 8352  
       left OUTER JOIN tblAccount A ON A.ACCOUNTID = C.accountID -- 5239  
        inner join tblEmpHospitals eh on eh.hospitalId = c.customerId -- 5747  
        inner join tblEmployees ee on ee.empId = eh.empId and ee.isDisabled = 0 -- 5627  
        where customerId > 30 and c.isdisabled = 0 and c.SpecialtyId =2 
        and ee.EmpID = e.empID
            ) as TotalHospitalcount

            from tblemployees e where   
            1 = 1  
            and isdisabled = 0   
            AND empId IN (SELECT empId FROM #empHierarchy)    
        --  and e.EmpID = @empid or @empid is null  
            and designationid in (3)  
            ORDER BY e.FIRSTname    
  
-- USP_VALIDATE_TEAM_PROGRESS_REPORTV1  74, 3, 2023 

           
  
            select eh.empID, c.customerId, c.CENTRENAME, c.DoctorName,   
                case   
                when hp.potentialenteredfor is null then 'NO'  
                else 'YES'   
                end as PotentialedEntered  
                from tblCustomers c   
            inner join tblEmpHospitals eh on eh.hospitalID = c.customerId   
            left  join TblHospitalsPotentials hp on hp.hospitalID = c.customerId and hp.potentialenteredfor = @addedFor    AND HP.isActive = 0
            where c.SpecialtyId in (2) AND c.isdisabled = 0 
           --  and eh.EmpID = @empid or @empid is null  
            AND eh.EmpID IN (SELECT empId FROM #empHierarchy)   
            order by customerId ASC  
  
  -- USP_VALIDATE_TEAM_PROGRESS_REPORTV1  834, 3, 2023 
            select   
             eh.empID, c.customerId, c.CENTRENAME, c.DoctorName  
                , case   
                when ha.actualEnteredFor is null then 'NO'  
                else 'YES'   
                end as BusinessdEntered  
                from tblCustomers c   
            inner join tblEmpHospitals eh on eh.hospitalID = c.customerId   
            left  join tblhospitalactuals ha on ha.hospitalID = c.customerId and ha.actualEnteredFor = @addedFor  
            where c.SpecialtyId in (2) AND c.isdisabled = 0 
            --  and eh.EmpID = @empid or @empid is null  
            AND eh.EmpID IN (SELECT empId FROM #empHierarchy)   
            group by eh.empID, c.customerId, c.CENTRENAME, c.DoctorName, actualEnteredFor  
            order by c.customerId ASC  
        --     -- USP_VALIDATE_TEAM_PROGRESS_REPORT  811  
  
  
            select   
             eh.empID, c.customerId, c.CENTRENAME, c.DoctorName  
                , case   
                when ha.addedfor is null then 'NO'  
                else 'YES'   
                end as MarketInsightdEntered  
                from tblCustomers c   
            inner join tblEmpHospitals eh on eh.hospitalID = c.customerId   
            left  join tblMarketInsights ha on ha.centreId = c.customerId and ha.addedfor = @addedFor  
            where c.SpecialtyId in (2) AND c.isdisabled = 0 
            --  and eh.EmpID = @empid or @empid is null  
            AND eh.EmpID IN (SELECT empId FROM #empHierarchy)   
            order by c.customerId ASC  
  
        -- -- USP_VALIDATE_TEAM_PROGRESS_REPORT  811  
  
            select   
             eh.empID, c.customerId, c.CENTRENAME, c.DoctorName  
                , case   
                when ha.competitionAddedFor is null then 'NO'  
                else 'YES'   
                end as CompEntered  
                from tblCustomers c   
            inner join tblEmpHospitals eh on eh.hospitalID = c.customerId   
            left  join tblCompetitions ha on ha.centerId = c.customerId and ha.competitionAddedFor = @addedFor  
            where c.SpecialtyId in (2) AND c.isdisabled = 0 
            --  and eh.EmpID = @empid or @empid is null  
            AND eh.EmpID IN (SELECT empId FROM #empHierarchy)   
            group by eh.empID, c.customerId, c.CENTRENAME, c.DoctorName, competitionAddedFor  
            order by c.customerId ASC  
  
  
  
        END  
    --SET NOCOUNT OFF;    

GO
/****** Object:  StoredProcedure [BSV_IVF].[USP_VALIDATE_USER]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- USP_VALIDATE_USER '8345', 'BSV@11223344','127.0.0.1','Mumbai'      
----------------------------------------------      
-- CREATED BY: GURU SINGH      
-- CREATD DATE: 9-SEP-2021      
----------------------------------------------      
CREATE procedure [BSV_IVF].[USP_VALIDATE_USER]
(          
    @email VARCHAR(150),          
    @password varchar(150),
	@Ip varchar(50)=null,
	@IpLocation varchar(500)=null
)      
as
Begin
    declare @EmpID int;
        -- SELECT * FROM tblEmployees WHERE email = @email and password = @password and isDisabled = 0     
IF EXISTS (SELECT 1 FROM tblEmployees e 
				WHERE (e.username is null or e.username = @email) 
					and (e.username is not null or e.email=@email)
				and e.Password = @password and isDisabled = 0)           
        BEGIN
            SELECT @EmpID = EmpID from tblEmployees e
                WHERE (e.username is null or e.username = @email) 
					and (e.username is not null or e.email=@email)
				and e.Password = @password and isDisabled = 0
            -- select * from tblLastLoginDetails WHERE empID = @EmpID AND isLastLogin = 0
            if Exists(select 1 from tblLastLoginDetails WHERE empID = @EmpID AND isLastLogin = 0)              
                BEGIN
                    update tblLastLoginDetails set isLastLogin = 1 WHERE empID = @EmpID AND isLastLogin = 0
                        INSERT into tblLastLoginDetails (EmpID, isLastLogin, IpAddress,IpLocation)
                        VALUES (@EmpID, 0,@Ip,@IpLocation)
                END          
            else               
                BEGIN
                    INSERT into tblLastLoginDetails (EmpID, isLastLogin,IpAddress,IpLocation)
                    VALUES (@EmpID, 0,@Ip,@IpLocation)
                END
        END
    SELECT e.*, l.isLastLogin, l.lastLoginDate,l.IpAddress,IpLocation 
	FROM tblEmployees E 
		left outer JOIN tblLastLoginDetails L ON E.EmpID = L.EMPID    
    WHERE 
	(e.username is null or e.username = @email) 
					and (e.username is not null or e.email=@email) and password = @password and isDisabled = 0 AND L.isLastLogin = 0
End
GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getActualsTargetAchieved]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [BSV_IVF].[getActualsTargetAchieved]    
    (        
            @hospitalId int,        
        @brandGroupId int     
    )    
    RETURNS bigint AS    
        BEGIN         
            DECLARE @retVal float             
            -- select @retVal  = SUM(RATE * qty) from TblHospitalactuals                 
            select @retVal  = SUM(qty) from TblHospitalactuals                 
                where hospitalId = @hospitalId     
                and brandGroupId = @brandGroupId    
                and isDisabled = 0                  
                 AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)           
               --  AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)           
            RETURN isNull(@retVal, 0)    
        END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getActualsTargetAchieved_SKU]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [BSV_IVF].[getActualsTargetAchieved_SKU]    
    (        
            @hospitalId int,        
            @medId int,
            @month int,
            @year int     
    )    
    RETURNS bigint AS    
        BEGIN         
          declare @dateAddedFor smallDateTime    
            set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))  
            DECLARE @retVal float             
            -- select @retVal  = SUM(RATE * qty) from TblHospitalactuals                 
            select @retVal  = SUM(qty) from TblHospitalactuals                 
                where hospitalId = @hospitalId     
                --and brandGroupId = @medId    
                and skuId = @medId    
                and isDisabled = 0                  
                -- AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)           
                -- AND ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)           
                 AND ActualEnteredFor = @dateAddedFor  
            RETURN isNull(@retVal, 0)    
        END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getActualsTargetAchieved_SKU_Employee]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [BSV_IVF].[getActualsTargetAchieved_SKU_Employee]      
    (          
            @hospitalId int,          
            @medId int,
			@Empid int,
			@StartDate datetime=null,
			@EndDate datetime=null     
    )      
    RETURNS bigint AS      
        BEGIN           
			declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end



          --declare @dateAddedFor smallDateTime      
          --  set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))    
            DECLARE @retVal float               
            
            select @retVal  = SUM(qty) from TblHospitalactuals                   
                where hospitalId = @hospitalId       
                --and brandGroupId = @medId      
                and skuId = @medId      
				and empid=@empid
                and isDisabled = 0                                    
                 --AND ActualEnteredFor = @dateAddedFor    
				 and (@fromdate is null or ActualEnteredFor>=@fromdate)
		and (@todate is null or ActualEnteredFor<=@todate)
            RETURN isNull(@retVal, 0)      
        END   

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getBusinessStatusforLastMonth]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION [BSV_IVF].[getBusinessStatusforLastMonth] ( 
    @hospitalId int 
 ) 
RETURNS NVARCHAR(100) 
AS BEGIN 
 
    DECLARE @retVal NVARCHAR(100) = 'New' 
            select @retVal =  
            case isApproved  
                when 1 then 'Pending'  
                when 0 then 'Approved'  
                when 2 then 'Rejected'  
            end   
            from tblhospitalActuals where hospitalId = @hospitalId  
            -- and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)  
            and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  
    RETURN @retVal 
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getBusinessStatusforLastMonthNEW]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [BSV_IVF].[getBusinessStatusforLastMonthNEW] (   
    @hospitalId int   
 )   
RETURNS NVARCHAR(100)   
AS BEGIN   
   
    DECLARE @retVal NVARCHAR(100) = 'New'   
            select @retVal =    
            case finalStatus    
                when 1 then 'Pending'    
                when 0 then 'Approved'    
                when 2 then 'Rejected'    
            end     
            from tblhospitalActuals where hospitalId = @hospitalId    
            and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)    
           -- and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)    
    RETURN @retVal   
END  
 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getBusinessStatusforLastMonthNEWv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [BSV_IVF].[getBusinessStatusforLastMonthNEWv1] (   
    @hospitalId int   
 )   
RETURNS NVARCHAR(100)   
AS BEGIN   
   
    DECLARE @retVal NVARCHAR(100) = 'New'   
            select @retVal =    
            case finalStatus    
     
  

         when 1 then 'Pending'    
                when 0 then 'Approved'    
                when 2 then 'Rejected'    
            end     
            from tblhospitalActuals where hospitalId = @hospitalId    
            --and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)    
           and ActualEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)    
    RETURN @retVal   
END  
 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getCompetationTotalforHospitalAndBrand]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [BSV_IVF].[getCompetationTotalforHospitalAndBrand]      
    (          
        @centerId int,          
        @brandId int ,
         @month int,
        @year int      
    )      
    RETURNS bigint AS      
        BEGIN       
         declare @dateAddedFor smallDateTime    
        set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))      
            DECLARE @retVal float               
            -- select top 1 * from tblCompetitions                   
            select @retVal  = SUM(businessValue) from tblCompetitions                   
                where centerId = @centerId       
                and brandId = @brandId      
                AND competitionAddedFor = @dateAddedFor             
                -- AND competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)             
            RETURN isNull(@retVal, 0)      
        END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getCompetationTotalforHospitalAndBrand_Employee]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [BSV_IVF].[getCompetationTotalforHospitalAndBrand_Employee]        
    (            
        @centerId int,            
        @brandId int ,  
         @Empid int,
		@StartDate datetime=null,
		@EndDate datetime=null     
    )        
    RETURNS bigint AS        
        BEGIN         

		declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end

        -- declare @dateAddedFor smallDateTime      
        --set  @dateAddedFor = (DATEFROMPARTS (@Year, @Month, 1))        
            DECLARE @retVal float                 
            -- select top 1 * from tblCompetitions                     
            select @retVal  = SUM(businessValue) from tblCompetitions                     
                where centerId = @centerId         
                and brandId = @brandId        
                --AND competitionAddedFor = @dateAddedFor   
				and empid=@Empid	
		and (@fromdate is null or competitionAddedFor>=@fromdate)
		and (@todate is null or competitionAddedFor<=@todate)
            RETURN isNull(@retVal, 0)        
        END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getCompetitionStatusforLastMonth]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION [BSV_IVF].[getCompetitionStatusforLastMonth] ( 
    @hospitalId int 
 ) 
RETURNS NVARCHAR(100) 
AS BEGIN 
 
    DECLARE @retVal NVARCHAR(100) = 'New' 
            select top 1 @retVal =  
            case isApproved  
                when 1 then 'Pending'  
                when 0 then 'Approved'  
                when 2 then 'Rejected'  
            end   
            from tblCompetitions where centerId = @hospitalId  
            --and competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)  
            and competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  
            group by isApproved 
    RETURN @retVal 
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getCompetitionStatusforLastMonth_V1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

     
CREATE FUNCTION [BSV_IVF].[getCompetitionStatusforLastMonth_V1] (   
    @hospitalId int   
 )   
RETURNS NVARCHAR(100)   
AS BEGIN   
   
    DECLARE @retVal NVARCHAR(100) = 'New'   
            select top 1 @retVal =    
            --case isApproved    
            case STATUS    
                when 1 then 'Pending'    
                when 0 then 'Approved'    
                when 2 then 'Rejected'    
            end     
            from tblCompetitions where centerId = @hospitalId    
             and competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)    
            -- and competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)    
            group by STATUS   
    RETURN @retVal   
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getCompetitionStatusforLastMonth_V2]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

     
CREATE FUNCTION [BSV_IVF].[getCompetitionStatusforLastMonth_V2] (   
    @hospitalId int   
 )   
RETURNS NVARCHAR(100)   
AS BEGIN   
   
    DECLARE @retVal NVARCHAR(100) = 'New'   
            select top 1 @retVal =    
            --case isApproved    
            case STATUS    
                when 1 then 'Pending'    
                when 0 then 'Approved'    
                when 2 then 'Rejected'    
            end     
            from tblCompetitions where centerId = @hospitalId    
   
          --and competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)    
            and competitionAddedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)    
            group by STATUS   
    RETURN @retVal   
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getEMPInfo]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [BSV_IVF].[getMyRBMInfo](79)
CREATE FUNCTION [BSV_IVF].[getEMPInfo] ( 
    @empId int
 ) 
RETURNS NVARCHAR(200) 
AS BEGIN 
 
    DECLARE @retVal NVARCHAR(200) 
        select @retVal = firstname from tblEmployees where empId  = @empId -- and isDisabled = 0
        RETURN isNull(@retVal, '-NA-') 
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getETL_AccountId]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [BSV_IVF].[getETL_AccountId] ( 
    @AccountName NVARCHAR(100) 
 ) 
RETURNS int 
AS BEGIN 
 
    DECLARE @retVal int 
     SELECT @retVal = accountId FROM tblAccount where trim(AccountName) = TRIM(@AccountName) 
    RETURN isNull(@retVal, 0) 
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getETL_SpecialtyTypeId]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [BSV_IVF].[getETL_SpecialtyTypeId] ( 
    @SpecialtyType NVARCHAR(100) 
 ) 
RETURNS int 
AS BEGIN 
 
    DECLARE @retVal int 
     SELECT @retVal = specialtyId FROM tblSpecialtyType where trim(name) = TRIM(@SpecialtyType) 
    RETURN isNull(@retVal, 0) 
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getETL_StateID]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [BSV_IVF].[getETL_StateID] (
    @stateName NVARCHAR(100)
 )
RETURNS int
AS BEGIN

    DECLARE @retVal int
    
IF exists (SELECT TOP 1 * FROM Tblstate where trim(stateName) = TRIM(@stateName) )
                BEGIN
                    SELECT @retVal = stateID FROM Tblstate where trim(stateName) = TRIM(@stateName)
                END
            ELSE
                BEGIN
                    --INSERT into tblState (StateName, isDisabled)
                    -- VALUES (@stateName, 0)
                    set @retVal = 0
                END
    RETURN isNull(@retVal, 0)
END

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getETL_VisitTypeId]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [BSV_IVF].[getETL_VisitTypeId] ( 
    @visitType NVARCHAR(100) 
 ) 
RETURNS int 
AS BEGIN 
 
    DECLARE @retVal int 
     SELECT @retVal = visitId FROM tblVisitType where trim(name) = TRIM(@visitType) 
    RETURN isNull(@retVal, 0) 
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getMarketInsightStatusforLastMonth]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [BSV_IVF].[getMarketInsightStatusforLastMonth] (  
    @hospitalId int  
 )  
RETURNS NVARCHAR(100)  
AS BEGIN  
  
    DECLARE @retVal NVARCHAR(100) = 'New'  
            select top 1 @retVal =   
            case isApproved   
                when 1 then 'Pending'   
                when 0 then 'Approved'   
                when 2 then 'Rejected'   
            end    
            from tblMarketInsights where centreId = @hospitalId   
            -- and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)   
            and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)   
            group by isApproved  
    RETURN @retVal  
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getMarketInsightStatusforLastMonthNew]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [BSV_IVF].[getMarketInsightStatusforLastMonthNew] 
    (        @hospitalId int     )   
     RETURNS NVARCHAR(100)    AS 
     BEGIN            
        DECLARE @retVal NVARCHAR(100) = 'New'                
        select top 1 @retVal =                 
            case finalStatus 
                        when 1 then 'Pending'     
                        when 0 then 'Approved'                     
                        when 2 then 'Rejected'                 
            end                  
            from tblMarketInsights 
            where centreId = @hospitalId                 
            and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                 
            -- and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                 
            group by finalStatus        
            RETURN @retVal    
    END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getMarketInsightStatusforLastMonthNewv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [BSV_IVF].[getMarketInsightStatusforLastMonthNewv1] 
    (        @hospitalId int     )   
     RETURNS NVARCHAR(100)    AS 
     BEGIN            
        DECLARE @retVal NVARCHAR(100) = 'New'                
        select top 1 @retVal =
                 
            case finalStatus 
                        when 1 then 'Pending'     
                        when 0 then 'Approved'                     
                        when 2 then 'Rejected'                 
            end         
         
            from tblMarketInsights 
            where centreId = @hospitalId                 
            --and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)                 
             and addedFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)                 
            group by finalStatus        
            RETURN @retVal    
    END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getMyRBMInfo]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [BSV_IVF].[getMyRBMInfo](79)
create FUNCTION [BSV_IVF].[getMyRBMInfo] ( 
    @empId int
 ) 
RETURNS NVARCHAR(200) 
AS BEGIN 
 
    DECLARE @retVal NVARCHAR(200) 
        select @retVal = firstname from tblEmployees where empId in (
            select ParentID from tblHierarchy where empId = @empId and isDisabled = 0
        ) and isDisabled = 0
        RETURN isNull(@retVal, '-NA-') 
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getMyZBMInfo]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [BSV_IVF].[getMyZBMInfo](89)
create FUNCTION [BSV_IVF].[getMyZBMInfo] ( 
    @empId int
 ) 
RETURNS NVARCHAR(200) 
AS BEGIN 
 
    DECLARE @retVal NVARCHAR(200) 
        declare @parentID int
        select @parentID  = ParentID from tblHierarchy where empId = @empId and isDisabled = 0 -- rbm
        select @retVal = firstname from tblEmployees where empId in (
            select ParentID from tblHierarchy where empId = @parentID and isDisabled = 0
        ) and isDisabled = 0
        RETURN isNull(@retVal, '-NA-') 
END 

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getPotentialStatusforLastMonth]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [BSV_IVF].[getPotentialStatusforLastMonth] ( 
    @hospitalId int 
 ) 
RETURNS NVARCHAR(100) 
AS BEGIN 
 
    DECLARE @retVal NVARCHAR(100) = 'New' 
            select @retVal =  
            case isApproved  
                when 1 then 'Pending'  
                when 0 then 'Approved'  
                when 2 then 'Rejected'  
                 
            end   
            from TblHospitalsPotentials where hospitalId = @hospitalId  
           -- and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)  
            and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)  
    RETURN @retVal 
END 


GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getPotentialStatusforLastMonthNew]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [BSV_IVF].[getPotentialStatusforLastMonthNew] (   
    @hospitalId int   
 )   
RETURNS NVARCHAR(100)   
AS BEGIN   
   
    DECLARE @retVal NVARCHAR(100) = 'New'   
            select @retVal =    
            case finalStatus    
                when 1 then 'Pending'    
                when 0 then 'Approved'    
                when 2 then 'Rejected'    
                   
            end     
            from TblHospitalsPotentials where hospitalId = @hospitalId    
            and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)    
           --  and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)    
    RETURN @retVal   
END   

GO
/****** Object:  UserDefinedFunction [BSV_IVF].[getPotentialStatusforLastMonthNewv1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [BSV_IVF].[getPotentialStatusforLastMonthNewv1] (   
    @hospitalId int   
 )   
RETURNS NVARCHAR(100)   
AS BEGIN   
   
    DECLARE @retVal NVARCHAR(100) = 'New'   
            select @retVal =    
            case finalStatus    
      
          when 1 then 'Pending'    
                when 0 then 'Approved'    
                when 2 then 'Rejected'    
                   
            end     
            from TblHospitalsPotentials where hospitalId = @hospitalId    
            --and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)    
            and PotentialEnteredFor = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-2, 0)    
    RETURN @retVal   
END 

GO
/****** Object:  Table [BSV_IVF].[dbo.tblempHospitalsBKUP]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[dbo.tblempHospitalsBKUP](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[hospitalId] [varchar](255) NULL,
	[EmpID] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[DoctorImport10012024]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[DoctorImport10012024](
	[Division] [nvarchar](50) NULL,
	[_3rdLevelReportingRegion] [nvarchar](50) NULL,
	[_2ndLevelReportingRegion] [nvarchar](50) NULL,
	[_1stLevelReportingRegion] [nvarchar](50) NULL,
	[StateName] [nvarchar](50) NULL,
	[HQName] [nvarchar](50) NULL,
	[HQCode] [nvarchar](50) NULL,
	[Region_Reference] [nvarchar](1) NULL,
	[UserName] [nvarchar](50) NULL,
	[EmployeeName] [nvarchar](100) NULL,
	[EmployeeNumber] [varchar](50) NULL,
	[Designation] [nvarchar](50) NULL,
	[CustomerCode] [varchar](50) NULL,
	[DoctorName] [nvarchar](50) NULL,
	[VisitCategory] [nvarchar](50) NULL,
	[Specialty] [nvarchar](50) NULL,
	[BusinessCategory] [nvarchar](1) NULL,
	[MDLNumber] [nvarchar](50) NULL,
	[Qualification] [nvarchar](50) NULL,
	[DoctorUniqueCode] [nvarchar](50) NULL,
	[PrimaryMobile] [nvarchar](1) NULL,
	[PrimaryEmailId] [nvarchar](1) NULL,
	[Address1] [varchar](max) NULL,
	[Address2] [varchar](max) NULL,
	[LocalArea] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[DoctorState] [nvarchar](50) NULL,
	[PinCode] [int] NULL,
	[Phone] [varchar](50) NULL,
	[Mobile] [bigint] NULL,
	[Gender] [nvarchar](100) NULL,
	[Email] [nvarchar](50) NULL,
	[DOB] [datetime] NULL,
	[DOA] [datetime] NULL,
	[HospitalName] [nvarchar](100) NULL,
	[HospitalClassification] [nvarchar](100) NULL,
	[Remarks] [nvarchar](50) NULL,
	[RegistrationNumber] [nvarchar](100) NULL,
	[Pan_Number] [nvarchar](100) NULL,
	[ReferenceKey1] [nvarchar](50) NULL,
	[ReferenceKey2] [nvarchar](50) NULL,
	[DoctorImageURL] [varchar](max) NULL,
	[CreatedDate] [date] NULL,
	[AgeingOfDoctorDays] [smallint] NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[UpdatedDate] [date] NULL,
	[MappedMarketingCampaigns] [nvarchar](1) NULL,
	[BeatPlanTagged] [nvarchar](1) NULL,
	[ChemistMapped] [nvarchar](50) NULL,
	[ChemistMCLNumner] [nvarchar](1) NULL,
	[StockistMapped] [nvarchar](1) NULL,
	[StockistRefKey] [nvarchar](1) NULL,
	[SFCCategory] [nvarchar](1) NULL,
	[FromPlace] [nvarchar](1) NULL,
	[ToPlace] [nvarchar](1) NULL,
	[TravelMode] [nvarchar](1) NULL,
	[LocaitonTaggedStatus] [nvarchar](50) NULL,
	[LocaitonTaggedDate] [nvarchar](1) NULL,
	[LocaitonTaggedBy] [nvarchar](1) NULL,
	[LocationTaggedDesignation] [nvarchar](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[Persons]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[Persons](
	[ID] [int] NOT NULL,
	[LastName] [varchar](255) NOT NULL,
	[FirstName] [varchar](255) NULL,
	[Age] [int] NULL,
 CONSTRAINT [PK__Persons__3214EC27E8A033A0] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblBrandcompetitorSKUs]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BSV_IVF].[tblBrandcompetitorSKUs](
	[competitorId] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[brandId] [int] NULL,
	[isDisabled] [bit] NULL,
	[CreatedDate] [smalldatetime] NULL,
 CONSTRAINT [PK_BrandcompetitorSKUs] PRIMARY KEY CLUSTERED 
(
	[competitorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [BSV_IVF].[tblChainAccountType]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BSV_IVF].[tblChainAccountType](
	[accountID] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[contractDoc] [nvarchar](500) NULL,
	[expiryDate] [date] NULL,
	[isApproved] [bit] NULL,
	[approvedOn] [smalldatetime] NULL,
	[rbmId] [int] NULL,
	[customerAccountID] [int] NULL,
	[isDisabled] [int] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[approvedBy] [int] NULL,
	[startDate] [date] NULL,
	[COMMENTS] [nvarchar](1000) NULL,
 CONSTRAINT [PK_tblChainAccountType] PRIMARY KEY CLUSTERED 
(
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [BSV_IVF].[tblCompetitions]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BSV_IVF].[tblCompetitions](
	[CompetitionId] [int] IDENTITY(1,1) NOT NULL,
	[empId] [int] NULL,
	[centerId] [int] NULL,
	[brandId] [int] NULL,
	[CompetitionSkuId] [int] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[isApproved] [tinyint] NULL,
	[approvedBy] [int] NULL,
	[approvedOn] [smalldatetime] NULL,
	[competitionAddedFor] [date] NULL,
	[businessValue] [float] NULL,
	[comments] [ntext] NULL,
	[rejectComments] [ntext] NULL,
	[rejectedBy] [int] NULL,
	[rejectedOn] [smalldatetime] NULL,
	[IsZBMApproved] [tinyint] NULL,
	[ZBMId] [int] NULL,
	[ZBMApprovedOn] [smalldatetime] NULL,
	[status] [tinyint] NULL,
 CONSTRAINT [PK_tblCustomers] PRIMARY KEY CLUSTERED 
(
	[CompetitionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [BSV_IVF].[TblContractDetails]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BSV_IVF].[TblContractDetails](
	[contractId] [int] IDENTITY(1,1) NOT NULL,
	[chainAccountTypeId] [int] NULL,
	[brandId] [int] NULL,
	[brandGroupId] [int] NULL,
	[medId] [int] NULL,
	[price] [float] NULL,
	[isDisabled] [int] NULL,
	[createdDate] [smalldatetime] NULL,
 CONSTRAINT [PK_TblContractDetails] PRIMARY KEY CLUSTERED 
(
	[contractId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [BSV_IVF].[tblDesignation]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblDesignation](
	[DesignationID] [smallint] IDENTITY(1,1) NOT NULL,
	[name] [varchar](255) NULL,
	[Designation] [varchar](255) NULL,
	[isDisabled] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
	[code] [nvarchar](20) NULL,
	[managerCode] [nvarchar](20) NULL,
 CONSTRAINT [PK__tblDesig__BABD603E2569B9D2] PRIMARY KEY CLUSTERED 
(
	[DesignationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblEmpHospitals]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblEmpHospitals](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[hospitalId] [varchar](255) NULL,
	[EmpID] [varchar](255) NULL,
 CONSTRAINT [PK__tblEmpHo__3213E83F3CAD14D8] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblemphospitalsbkup1_apri]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblemphospitalsbkup1_apri](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[hospitalId] [varchar](255) NULL,
	[EmpID] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblEmployees]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblEmployees](
	[EmpID] [smallint] IDENTITY(1,1) NOT NULL,
	[firstName] [varchar](255) NULL,
	[lastName] [varchar](255) NULL,
	[MobileNumber] [varchar](255) NULL,
	[Email] [varchar](255) NULL,
	[Password] [varchar](255) NULL,
	[Designation] [varchar](50) NULL,
	[DesignationID] [smallint] NULL,
	[EmpNumber] [int] NULL,
	[HoCode] [varchar](255) NULL,
	[ZoneID] [smallint] NULL,
	[StateID] [smallint] NULL,
	[isMetro] [bit] NULL,
	[HQName] [varchar](255) NULL,
	[RegionName] [varchar](255) NULL,
	[DOJ] [varchar](50) NULL,
	[createdOn] [smalldatetime] NULL,
	[isDisabled] [bit] NULL,
	[comments] [nvarchar](4000) NULL,
	[username] [nvarchar](100) NULL,
 CONSTRAINT [PK__tblEmplo__AF2DBA79AC27892F] PRIMARY KEY CLUSTERED 
(
	[EmpID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblemployeesbkup]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblemployeesbkup](
	[EmpID] [smallint] IDENTITY(1,1) NOT NULL,
	[firstName] [varchar](255) NULL,
	[lastName] [varchar](255) NULL,
	[MobileNumber] [varchar](255) NULL,
	[Email] [varchar](255) NULL,
	[Password] [varchar](255) NULL,
	[Designation] [varchar](50) NULL,
	[DesignationID] [smallint] NULL,
	[EmpNumber] [int] NULL,
	[HoCode] [varchar](255) NULL,
	[ZoneID] [smallint] NULL,
	[StateID] [smallint] NULL,
	[isMetro] [bit] NULL,
	[HQName] [varchar](255) NULL,
	[RegionName] [varchar](255) NULL,
	[DOJ] [varchar](50) NULL,
	[createdOn] [smalldatetime] NULL,
	[isDisabled] [bit] NULL,
	[comments] [nvarchar](4000) NULL,
	[username] [nvarchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblHierarchy]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BSV_IVF].[tblHierarchy](
	[hierarchyID] [smallint] IDENTITY(1,1) NOT NULL,
	[EmpID] [smallint] NULL,
	[ParentID] [smallint] NULL,
	[isDisabled] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
 CONSTRAINT [PK__tblHiera__76BC92E3B773EAA2] PRIMARY KEY CLUSTERED 
(
	[hierarchyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [BSV_IVF].[tblHospitals]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblHospitals](
	[hospitalId] [smallint] IDENTITY(1,1) NOT NULL,
	[hospitalName] [varchar](255) NULL,
	[regionName] [varchar](255) NULL,
	[isDisabled] [bit] NULL,
	[CreatedOn] [smalldatetime] NULL,
	[bedNo] [int] NULL,
	[ICUbedNo] [int] NULL,
	[DrName] [nvarchar](255) NULL,
	[Embryologist] [nvarchar](255) NULL,
	[ChainStatus] [smallint] NULL,
 CONSTRAINT [PK__tblHospi__C7F8EC25DD834F53] PRIMARY KEY CLUSTERED 
(
	[hospitalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tbljohnsonbkup]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BSV_IVF].[tbljohnsonbkup](
	[Division] [nvarchar](500) NOT NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[State] [nvarchar](500) NOT NULL,
	[HQ_Name] [nvarchar](500) NOT NULL,
	[HQ_Code] [nvarchar](500) NOT NULL,
	[User_Name] [nvarchar](500) NOT NULL,
	[Employee_Name] [nvarchar](500) NOT NULL,
	[Employee_Number] [nvarchar](500) NOT NULL,
	[Designation] [nvarchar](500) NOT NULL,
	[Customer_Code] [nvarchar](500) NOT NULL,
	[Doctor_Name] [nvarchar](500) NOT NULL,
	[Visit_Category] [nvarchar](500) NOT NULL,
	[Specialty] [nvarchar](500) NOT NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NOT NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Hospital_Name] [nvarchar](500) NULL,
	[Hospital_Classification] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NOT NULL,
	[Reference_Key2] [nvarchar](500) NOT NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NOT NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NOT NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NOT NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [BSV_IVF].[tblLastLoginDetails]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblLastLoginDetails](
	[loginLogID] [smallint] IDENTITY(1,1) NOT NULL,
	[EmpID] [smallint] NULL,
	[lastLoginDate] [smalldatetime] NULL,
	[isLastLogin] [bit] NULL,
	[IpAddress] [varchar](50) NULL,
	[IpLocation] [varchar](500) NULL,
 CONSTRAINT [PK__tblLastL__2E697D9B49AD7AC4] PRIMARY KEY CLUSTERED 
(
	[loginLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblSKUs]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblSKUs](
	[medID] [smallint] IDENTITY(1,1) NOT NULL,
	[brandId] [int] NULL,
	[brandGroupId] [int] NULL,
	[medicineName] [varchar](255) NULL,
	[imageURL] [varchar](255) NULL,
	[descp] [varchar](255) NULL,
	[isDisabled] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
	[SortOrder] [smallint] NULL,
	[Price] [float] NULL,
 CONSTRAINT [PK__tmp_ms_x__2D4FA91C86A36CE3] PRIMARY KEY CLUSTERED 
(
	[medID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblSpecialtyTypeBkup]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BSV_IVF].[tblSpecialtyTypeBkup](
	[specialtyId] [int] IDENTITY(1,1) NOT NULL,
	[isDisabled] [int] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[name] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [BSV_IVF].[tblState]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblState](
	[stateID] [smallint] IDENTITY(1,1) NOT NULL,
	[StateName] [varchar](255) NULL,
	[isDisabled] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
 CONSTRAINT [PK__tblState__A667B9C1384284AB] PRIMARY KEY CLUSTERED 
(
	[stateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [BSV_IVF].[tblZone]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [BSV_IVF].[tblZone](
	[zoneID] [smallint] IDENTITY(1,1) NOT NULL,
	[name] [varchar](255) NULL,
	[isDisable] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
 CONSTRAINT [PK__tblZone__2F75DE99BBCD8274] PRIMARY KEY CLUSTERED 
(
	[zoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[soorajjaipur]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[soorajjaipur](
	[Division] [nvarchar](200) NULL,
	[_3rdLevelReporting_Region] [nvarchar](200) NULL,
	[_2ndLevelReportingRegion] [nvarchar](200) NULL,
	[_1stLevelReportingRegion] [nvarchar](200) NULL,
	[State] [nvarchar](200) NULL,
	[HQName] [nvarchar](200) NULL,
	[HQCode] [nvarchar](200) NULL,
	[RegionReference] [nvarchar](200) NULL,
	[UserName] [nvarchar](200) NULL,
	[EmployeeName] [nvarchar](200) NULL,
	[EmployeeNumber] [nvarchar](200) NULL,
	[Designation] [nvarchar](200) NULL,
	[CustomerCode] [nvarchar](200) NULL,
	[DoctorName] [nvarchar](200) NULL,
	[VisitCategory] [nvarchar](200) NULL,
	[Speciality] [nvarchar](200) NULL,
	[BusinessCategory] [nvarchar](200) NULL,
	[MDLNumber] [nvarchar](200) NULL,
	[Qualification] [nvarchar](200) NULL,
	[DoctorUniqueCode] [nvarchar](200) NULL,
	[PrimaryMobile] [nvarchar](200) NULL,
	[PrimaryEmailId] [nvarchar](200) NULL,
	[Address1] [nvarchar](200) NULL,
	[Address2] [nvarchar](200) NULL,
	[LocalArea] [nvarchar](200) NULL,
	[City] [nvarchar](200) NULL,
	[State1] [nvarchar](200) NULL,
	[PinCode] [nvarchar](200) NULL,
	[Phone] [nvarchar](200) NULL,
	[Mobile] [nvarchar](200) NULL,
	[Email] [nvarchar](200) NULL,
	[DateofBirth] [nvarchar](200) NULL,
	[DateofAnniversary] [nvarchar](200) NULL,
	[HospitalName] [nvarchar](200) NULL,
	[HospitalClassification] [nvarchar](200) NULL,
	[Remarks] [nvarchar](200) NULL,
	[RegistrationNumber] [nvarchar](200) NULL,
	[ReferenceKey1] [nvarchar](200) NULL,
	[ReferenceKey2] [nvarchar](200) NULL,
	[DoctorImageURL] [nvarchar](200) NULL,
	[CreatedDate] [date] NULL,
	[AgeingofDoctor] [int] NULL,
	[UpdatedBy] [nvarchar](200) NULL,
	[UpdatedDate] [date] NULL,
	[MappedMarketingCampaigns] [nvarchar](200) NULL,
	[ChemistMapped] [nvarchar](200) NULL,
	[ChemistMCLNumner] [nvarchar](200) NULL,
	[StockistMapped] [nvarchar](200) NULL,
	[StockistRefKey] [nvarchar](200) NULL,
	[SFCCategory] [nvarchar](200) NULL,
	[FromPlace] [nvarchar](200) NULL,
	[ToPlace] [nvarchar](200) NULL,
	[TravelMode] [nvarchar](200) NULL,
	[LocaitonTaggedStatus] [nvarchar](200) NULL,
	[LocaitonTaggedDate] [nvarchar](200) NULL,
	[LocationTaggedBy] [nvarchar](200) NULL,
	[LocaitonTaggedDesignation] [nvarchar](200) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblAccount]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAccount](
	[accountID] [int] IDENTITY(1000,1) NOT NULL,
	[accountName] [nvarchar](500) NULL,
	[createdDate] [date] NULL,
	[isActive] [bit] NULL,
 CONSTRAINT [PK_tblAccount] PRIMARY KEY CLUSTERED 
(
	[accountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblActuals]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblActuals](
	[actualId] [int] IDENTITY(1,1) NOT NULL,
	[empId] [int] NULL,
	[hospitalId] [int] NULL,
	[brandId] [int] NULL,
	[unit] [int] NULL,
	[price] [float] NULL,
	[actualEnteredFor] [smalldatetime] NULL,
	[contractRate] [bit] NULL,
	[ContractEndDate] [smalldatetime] NULL,
	[isDisabled] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
 CONSTRAINT [PK_tblActuals] PRIMARY KEY CLUSTERED 
(
	[actualId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblarun]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblarun](
	[Division] [nvarchar](500) NOT NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[State] [nvarchar](500) NOT NULL,
	[HQ_Name] [nvarchar](500) NOT NULL,
	[HQ_Code] [nvarchar](500) NOT NULL,
	[User_Name] [nvarchar](500) NOT NULL,
	[Employee_Name] [nvarchar](500) NOT NULL,
	[Employee_Number] [nvarchar](500) NOT NULL,
	[Designation] [nvarchar](500) NOT NULL,
	[Customer_Code] [nvarchar](500) NOT NULL,
	[Doctor_Name] [nvarchar](500) NOT NULL,
	[Visit_Category] [nvarchar](500) NOT NULL,
	[Specialty] [nvarchar](500) NOT NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NOT NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NOT NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NOT NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[centre_name] [nvarchar](500) NULL,
	[account_name] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NOT NULL,
	[Reference_Key2] [nvarchar](500) NOT NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NOT NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NOT NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NOT NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblBASANT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBASANT](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblBrandGroups]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBrandGroups](
	[brandGroupId] [int] IDENTITY(1,1) NOT NULL,
	[brandId] [int] NULL,
	[groupName] [nvarchar](200) NULL,
	[imageUrl] [nvarchar](200) NULL,
	[isDisabled] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
 CONSTRAINT [PK_tblBrandGroups] PRIMARY KEY CLUSTERED 
(
	[brandGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblChainStatus]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblChainStatus](
	[chainId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](10) NULL,
	[isDisabled] [int] NULL,
	[CreatedDate] [smalldatetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblCustomers]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCustomers](
	[customerId] [int] IDENTITY(1,1) NOT NULL,
	[code] [nvarchar](10) NULL,
	[DoctorName] [nvarchar](100) NULL,
	[mobile] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[CENTRENAME] [nvarchar](100) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](200) NULL,
	[LocalArea] [nvarchar](200) NULL,
	[City] [nvarchar](200) NULL,
	[StateID] [int] NULL,
	[PinCode] [nvarchar](20) NULL,
	[ChemistMapped] [nvarchar](200) NULL,
	[CreatedDate] [smalldatetime] NULL,
	[isdisabled] [bit] NULL,
	[DoctorUniqueCode] [nvarchar](100) NULL,
	[chainID] [tinyint] NULL,
	[visitId] [tinyint] NULL,
	[SpecialtyId] [tinyint] NULL,
	[chainAccountTypeId] [int] NULL,
	[isApproved] [bit] NULL,
	[approvedBy] [int] NULL,
	[approvedOn] [smalldatetime] NULL,
	[accountID] [int] NULL,
 CONSTRAINT [PK_tblCustomers] PRIMARY KEY CLUSTERED 
(
	[customerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDataDump]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDataDump](
	[id] [smallint] NULL,
	[Month] [nvarchar](50) NULL,
	[ZBM] [nvarchar](50) NULL,
	[RBM] [nvarchar](50) NULL,
	[KAM] [nvarchar](50) NULL,
	[Customer_Code] [nvarchar](1) NULL,
	[Name_of_Dr] [nvarchar](50) NULL,
	[Centre_Name] [nvarchar](50) NULL,
	[Name_of_Embryologist] [nvarchar](50) NULL,
	[No_of_fresh_cycles_JUNE] [float] NULL,
	[Foligraf_vials_PFS_MD] [nvarchar](50) NULL,
	[Foligraf_Pens] [float] NULL,
	[FOLIGRAF_TOTAL] [float] NULL,
	[Gonal_F_vials_PFS_MD] [float] NULL,
	[Gonal_F_Pens] [float] NULL,
	[Folisurge_vials_PFS_MD] [nvarchar](50) NULL,
	[Folisurge_Pens] [float] NULL,
	[Other_r_FSH_vials_PFS_MD] [float] NULL,
	[Other_r_FSH_Pens] [float] NULL,
	[Humog_Group] [float] NULL,
	[Menotas_XP_liq_MD_pfs] [float] NULL,
	[Menotas_Menotas_HP_lyo_vials] [float] NULL,
	[Menopur] [float] NULL,
	[Diva_HMG] [float] NULL,
	[Materna_vials_PFS_MD] [float] NULL,
	[Other_HMG] [float] NULL,
	[Asporelix] [float] NULL,
	[Other_Cetrorelix_acetate_LYO] [nvarchar](50) NULL,
	[Other_Cetrorelix_PFS] [nvarchar](50) NULL,
	[R_Hucog] [nvarchar](50) NULL,
	[No_of_cycles_with_Agonist_trigger] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDelhi]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDelhi](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblEmpHospitals_15022024]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblEmpHospitals_15022024](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[hospitalId] [varchar](255) NULL,
	[EmpID] [varchar](255) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblHITESH]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHITESH](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Centre_name] [nvarchar](500) NULL,
	[Account_name] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblhospitalActuals]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblhospitalActuals](
	[actualId] [int] IDENTITY(1,1) NOT NULL,
	[empId] [int] NULL,
	[hospitalId] [int] NULL,
	[ActualEnteredFor] [date] NULL,
	[brandId] [int] NULL,
	[brandGroupId] [int] NULL,
	[skuId] [int] NULL,
	[rate] [float] NULL,
	[qty] [int] NULL,
	[isContractApplicable] [bit] NULL,
	[isDisabled] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
	[contractEndDate] [nvarchar](20) NULL,
	[isApproved] [tinyint] NULL,
	[approvedBy] [int] NULL,
	[approvedOn] [smalldatetime] NULL,
	[comments] [nvarchar](1000) NULL,
	[rejectedBy] [int] NULL,
	[rejectedOn] [smalldatetime] NULL,
	[rejectComments] [ntext] NULL,
	[ZBMApproved] [tinyint] NULL,
	[ZBMId] [int] NULL,
	[ZBMApprovedOn] [smalldatetime] NULL,
	[finalStatus] [tinyint] NULL,
 CONSTRAINT [PK_tblhospitalActuals] PRIMARY KEY CLUSTERED 
(
	[actualId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TblHospitalsContracts]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TblHospitalsContracts](
	[contractId] [int] IDENTITY(1,1) NOT NULL,
	[hospitalId] [int] NULL,
	[contractEndDate] [smalldatetime] NULL,
	[isContractSubmitted] [bit] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[isApproved] [bit] NULL,
	[approvedBy] [int] NULL,
	[approvedOn] [smalldatetime] NULL,
 CONSTRAINT [PK_TblHospitalsContracts] PRIMARY KEY CLUSTERED 
(
	[contractId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TblHospitalsPotentials]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TblHospitalsPotentials](
	[potentialId] [int] IDENTITY(1,1) NOT NULL,
	[empId] [int] NULL,
	[hospitalId] [int] NULL,
	[IUICycle] [nvarchar](20) NULL,
	[IVFCycle] [nvarchar](20) NULL,
	[FreshPickUps] [int] NULL,
	[SelftCycle] [int] NULL,
	[DonorCycles] [int] NULL,
	[AgonistCycles] [int] NULL,
	[IsActive] [bit] NULL,
	[PotentialEnteredFor] [smalldatetime] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[frozenTransfers] [int] NULL,
	[Antagonistcycles] [int] NULL,
	[isApproved] [tinyint] NULL,
	[approvedBy] [int] NULL,
	[approvedOn] [smalldatetime] NULL,
	[rejectedBy] [int] NULL,
	[rejectedOn] [smalldatetime] NULL,
	[rejectComments] [ntext] NULL,
	[visitID] [tinyint] NULL,
	[ZBMApproved] [tinyint] NULL,
	[ZBMId] [int] NULL,
	[ZBMApprovedOn] [smalldatetime] NULL,
	[finalStatus] [tinyint] NULL,
 CONSTRAINT [PK_TblHospitalsPotentials] PRIMARY KEY CLUSTERED 
(
	[potentialId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblJAYANTA]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblJAYANTA](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblJohnson]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblJohnson](
	[Division] [nvarchar](500) NOT NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[State] [nvarchar](500) NOT NULL,
	[HQ_Name] [nvarchar](500) NOT NULL,
	[HQ_Code] [nvarchar](500) NOT NULL,
	[User_Name] [nvarchar](500) NOT NULL,
	[Employee_Name] [nvarchar](500) NOT NULL,
	[Employee_Number] [nvarchar](500) NOT NULL,
	[Designation] [nvarchar](500) NOT NULL,
	[Customer_Code] [nvarchar](500) NOT NULL,
	[Doctor_Name] [nvarchar](500) NOT NULL,
	[Visit_Category] [nvarchar](500) NOT NULL,
	[Specialty] [nvarchar](500) NOT NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NOT NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Hospital_Name] [nvarchar](500) NULL,
	[Hospital_Classification] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NOT NULL,
	[Reference_Key2] [nvarchar](500) NOT NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NOT NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NOT NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NOT NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblKarthik]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblKarthik](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Hospital_Name] [nvarchar](500) NULL,
	[Hospital_Classification] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblKERALA]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblKERALA](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblMadhu]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMadhu](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblMarketInsights]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMarketInsights](
	[insightId] [int] IDENTITY(1000,1) NOT NULL,
	[empId] [int] NULL,
	[centreId] [int] NULL,
	[addedFor] [date] NULL,
	[answerOne] [bit] NULL,
	[AnswerTwo] [nvarchar](max) NULL,
	[answerThreeRFSH] [nvarchar](50) NULL,
	[answerThreeHMG] [nvarchar](50) NULL,
	[answerFourRHCG] [nvarchar](50) NULL,
	[answerFourAgonistL] [nvarchar](50) NULL,
	[answerFourAgonistT] [nvarchar](50) NULL,
	[answerFourRHCGTriptorelin] [nvarchar](50) NULL,
	[answerFourRHCGLeuprolide] [nvarchar](50) NULL,
	[answerProgesterone] [nvarchar](50) NULL,
	[answerFiveDydrogesterone] [nvarchar](50) NULL,
	[answerFiveCombination] [nvarchar](50) NULL,
	[createdDate] [smalldatetime] NULL,
	[isActive] [bit] NULL,
	[isApproved] [tinyint] NULL,
	[ApprovedBy] [int] NULL,
	[ApprovedOn] [smalldatetime] NULL,
	[RejectedBy] [int] NULL,
	[RejectedOn] [smalldatetime] NULL,
	[ZBMApproved] [tinyint] NULL,
	[ZBMId] [int] NULL,
	[ZBMApprovedOn] [smalldatetime] NULL,
	[rejectComments] [nvarchar](max) NULL,
	[answerFourUHCG] [nvarchar](100) NULL,
	[finalStatus] [tinyint] NULL,
 CONSTRAINT [PK_tblMarketInsights] PRIMARY KEY CLUSTERED 
(
	[insightId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblMinakshi]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMinakshi](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblMSL]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMSL](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblnelson]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblnelson](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](50) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Hospital_Name] [nvarchar](500) NULL,
	[Hospital_Classification] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbloldData]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbloldData](
	[MONTH] [nvarchar](500) NULL,
	[ZBM] [nvarchar](500) NULL,
	[RBM] [nvarchar](500) NULL,
	[KAM] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Name_of_Dr] [nvarchar](500) NULL,
	[Centre_Name] [nvarchar](500) NULL,
	[Name_of_Embryologist] [nvarchar](500) NULL,
	[chain] [nvarchar](500) NULL,
	[city] [nvarchar](500) NULL,
	[KOL_STATUS] [nvarchar](500) NULL,
	[No_of_fresh_cycles] [nvarchar](500) NULL,
	[Foligraf_vials_PFS_MD] [nvarchar](500) NULL,
	[Foligraf_Pens] [nvarchar](500) NULL,
	[Foligraf_all] [nvarchar](500) NULL,
	[Gonal_F_vials_PFS_MD] [nvarchar](500) NULL,
	[Gonal_F_Pens] [nvarchar](500) NULL,
	[Folisurge_vials_PFS_MD] [nvarchar](500) NULL,
	[Folisurge_Pens] [nvarchar](500) NULL,
	[Other_r_FSH_vials_PFS_MD] [nvarchar](500) NULL,
	[Other_r_FSH_Pens] [nvarchar](500) NULL,
	[Humog_Group] [nvarchar](500) NULL,
	[Menotas_XP_liq_MD_pfs] [nvarchar](500) NULL,
	[Menotas_Menotas_HP_lyo_vials] [nvarchar](500) NULL,
	[Menopur] [nvarchar](500) NULL,
	[Diva_HMG] [nvarchar](500) NULL,
	[Materna_vials_PFS_MD] [nvarchar](500) NULL,
	[Other_HMG] [nvarchar](500) NULL,
	[Asporelix] [nvarchar](500) NULL,
	[Other_Cetrorelix_acetate_LYO] [nvarchar](500) NULL,
	[Other_Cetrorelix_PFS] [nvarchar](500) NULL,
	[R_Hucog] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbloldDataNotPorted]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbloldDataNotPorted](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DoctorName] [nvarchar](100) NULL,
	[CENTRENAME] [nvarchar](100) NULL,
	[businessValue] [nvarchar](500) NULL,
	[BRAND] [nvarchar](1000) NULL,
 CONSTRAINT [PK_tbloldDataNotPorted] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblpartha]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblpartha](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblpooja]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblpooja](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPortalConfig]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPortalConfig](
	[ID] [smallint] IDENTITY(100,1) NOT NULL,
	[interval] [int] NULL,
	[LastDate] [date] NULL,
	[code] [nvarchar](20) NULL,
 CONSTRAINT [PK_ttblPortalConfig] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPRAHLAD]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPRAHLAD](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblramesh]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblramesh](
	[Division] [nvarchar](500) NOT NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[State] [nvarchar](500) NOT NULL,
	[HQ_Name] [nvarchar](500) NOT NULL,
	[HQ_Code] [nvarchar](500) NOT NULL,
	[User_Name] [nvarchar](500) NOT NULL,
	[Employee_Name] [nvarchar](500) NOT NULL,
	[Employee_Number] [nvarchar](500) NOT NULL,
	[Designation] [nvarchar](500) NOT NULL,
	[Customer_Code] [nvarchar](500) NOT NULL,
	[Doctor_Name] [nvarchar](500) NOT NULL,
	[Visit_Category] [nvarchar](500) NOT NULL,
	[Specialty] [nvarchar](500) NOT NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NOT NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NOT NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NOT NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[centre_name] [nvarchar](500) NULL,
	[account_name] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NOT NULL,
	[Reference_Key2] [nvarchar](500) NOT NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NOT NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NOT NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NOT NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblRCData]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRCData](
	[RC_Ref_No] [smallint] NULL,
	[RC_Number] [smallint] NULL,
	[RC_Date] [nvarchar](500) NULL,
	[Customer_No] [int] NULL,
	[column5] [smallint] NULL,
	[Customer_Name] [nvarchar](500) NULL,
	[Customer_Acc_Group] [nvarchar](500) NULL,
	[Customer_Acc_Grp_Name] [nvarchar](500) NULL,
	[Material_Code] [int] NULL,
	[Material_Name] [nvarchar](500) NULL,
	[Division_Code] [tinyint] NULL,
	[Division_Name] [nvarchar](500) NULL,
	[Valid_Date_From] [nvarchar](500) NULL,
	[Valid_Date_To] [nvarchar](500) NULL,
	[RC_QTY] [float] NULL,
	[RC_Rate] [float] NULL,
	[STK_Margin] [nvarchar](500) NULL,
	[Status] [nvarchar](500) NULL,
	[RC_Ref_Date] [nvarchar](500) NULL,
	[RbmId] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblrcdataNotPorted]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblrcdataNotPorted](
	[customerId] [int] IDENTITY(1,1) NOT NULL,
	[centername] [nvarchar](500) NULL,
	[grpname] [nvarchar](500) NULL,
	[medname] [nvarchar](500) NULL,
	[price] [nvarchar](500) NULL,
	[STARTDATE] [nvarchar](500) NULL,
	[enddate] [nvarchar](500) NULL,
	[email] [nvarchar](500) NULL,
	[rbmid] [nvarchar](500) NULL,
 CONSTRAINT [PK_tblrcdataNotPorted] PRIMARY KEY CLUSTERED 
(
	[customerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblRCdump]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRCdump](
	[RC_Ref_No] [nvarchar](500) NULL,
	[RC_Number] [nvarchar](500) NULL,
	[RC_Date] [nvarchar](500) NULL,
	[Customer_No] [nvarchar](500) NULL,
	[Customer_Name] [nvarchar](500) NULL,
	[Customer_Acc_Group] [nvarchar](500) NULL,
	[Customer_Acc_Grp_Name] [nvarchar](500) NULL,
	[Material_Code] [nvarchar](500) NULL,
	[Material_Name] [nvarchar](500) NULL,
	[Division_Code] [nvarchar](500) NULL,
	[Division_Name] [nvarchar](500) NULL,
	[Valid_Date_From] [nvarchar](500) NULL,
	[Valid_Date_To] [nvarchar](500) NULL,
	[RC_QTY] [nvarchar](500) NULL,
	[RC_Rate] [nvarchar](500) NULL,
	[STK_Margin] [nvarchar](500) NULL,
	[Status] [nvarchar](500) NULL,
	[RC_Ref_Date] [nvarchar](500) NULL,
	[accountID] [nvarchar](100) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TblRIYSAT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TblRIYSAT](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](1) NULL,
	[Travel_Mode] [nvarchar](1) NULL,
	[Locaiton_Tagged_Status] [nvarchar](50) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblRom2]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRom2](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Centre_Name] [nvarchar](500) NULL,
	[Account_Name] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblsajal]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblsajal](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblsanjeev]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblsanjeev](
	[Division] [nvarchar](500) NOT NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NOT NULL,
	[State] [nvarchar](500) NOT NULL,
	[HQ_Name] [nvarchar](500) NOT NULL,
	[HQ_Code] [nvarchar](500) NOT NULL,
	[User_Name] [nvarchar](500) NOT NULL,
	[Employee_Name] [nvarchar](500) NOT NULL,
	[Employee_Number] [nvarchar](500) NOT NULL,
	[Designation] [nvarchar](500) NOT NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NOT NULL,
	[Visit_Category] [nvarchar](500) NOT NULL,
	[Specialty] [nvarchar](500) NOT NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NOT NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NOT NULL,
	[Address2] [nvarchar](500) NOT NULL,
	[Local_Area] [nvarchar](500) NOT NULL,
	[City] [nvarchar](500) NOT NULL,
	[State1] [nvarchar](500) NOT NULL,
	[Pin_Code] [nvarchar](500) NOT NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NOT NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NOT NULL,
	[ACCOUNT_NAME] [nvarchar](500) NOT NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NOT NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblSkuGroup]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSkuGroup](
	[brandId] [int] IDENTITY(1,1) NOT NULL,
	[brandName] [nvarchar](200) NULL,
	[imageUrl] [nvarchar](200) NULL,
	[IsDisabled] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
	[sortOrder] [tinyint] NULL,
 CONSTRAINT [PK_tblSkuGroup] PRIMARY KEY CLUSTERED 
(
	[brandId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblSpecialtyType]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSpecialtyType](
	[specialtyId] [int] IDENTITY(1,1) NOT NULL,
	[isDisabled] [int] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[name] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblsubhankar]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblsubhankar](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblSubramanian]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSubramanian](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[State1] [nvarchar](50) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Hospital_Name] [nvarchar](500) NULL,
	[Hospital_Classification] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbltempcustomer]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbltempcustomer](
	[SrNo] [smallint] NOT NULL,
	[ZBM] [nvarchar](500) NULL,
	[RBM] [nvarchar](500) NULL,
	[KAM] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Name_of_Dr] [nvarchar](500) NULL,
	[Centre_Name] [nvarchar](500) NULL,
	[Name_of_Embryologist] [nvarchar](500) NULL,
 CONSTRAINT [PK_tbltempcustomer] PRIMARY KEY CLUSTERED 
(
	[SrNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTempData]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTempData](
	[ZBM] [nvarchar](500) NULL,
	[RBM] [nvarchar](500) NULL,
	[KAM] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[Zone] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbltempDatav1]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbltempDatav1](
	[Division] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](50) NULL,
	[Qualification] [nvarchar](50) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[REGISTERED_CENTRE_NAME] [nvarchar](50) NULL,
	[Centre_address] [nvarchar](100) NULL,
	[ASSOCIATED_HOSPITAL_NAME] [nvarchar](50) NULL,
	[Address1] [nvarchar](100) NULL,
	[Address2] [nvarchar](50) NULL,
	[Local_Area] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[State1] [nvarchar](50) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](50) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](50) NULL,
	[Reference_Key2] [nvarchar](50) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTempHospital]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTempHospital](
	[Name_of_Dr] [nvarchar](500) NULL,
	[Centre_Name] [nvarchar](500) NULL,
	[Name_of_Embryologist] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TblThiyagarajan]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TblThiyagarajan](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Centre_name] [nvarchar](500) NULL,
	[Account_name] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbltmpsanjay]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbltmpsanjay](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblVACANT]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblVACANT](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[CENTRE_NAME] [nvarchar](500) NULL,
	[ACCOUNT_NAME] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblvictor]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblvictor](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](50) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Centre_Name] [nvarchar](500) NULL,
	[Account_Name] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblVIKAS]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblVIKAS](
	[Division] [nvarchar](500) NULL,
	[_3rd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_2nd_Level_Reporting_Region] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[State] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[User_Name] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Visit_Category] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Business_Category] [nvarchar](500) NULL,
	[MDL_Number] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[Doctor_Unique_Code] [nvarchar](500) NULL,
	[Primary_Mobile] [nvarchar](500) NULL,
	[Primary_Email_Id] [nvarchar](500) NULL,
	[Address1] [nvarchar](500) NULL,
	[Address2] [nvarchar](500) NULL,
	[Local_Area] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL,
	[Pin_Code] [nvarchar](500) NULL,
	[Phone] [nvarchar](500) NULL,
	[Mobile] [nvarchar](500) NULL,
	[Email] [nvarchar](500) NULL,
	[Date_of_Birth] [nvarchar](500) NULL,
	[Date_of_Anniversary] [nvarchar](500) NULL,
	[Hospital_Name] [nvarchar](500) NULL,
	[Hospital_Classification] [nvarchar](500) NULL,
	[Registration_Number] [nvarchar](500) NULL,
	[Reference_Key1] [nvarchar](500) NULL,
	[Reference_Key2] [nvarchar](500) NULL,
	[Doctor_Image_URL] [nvarchar](500) NULL,
	[Created_Date] [nvarchar](500) NULL,
	[Ageing_of_Doctor_In_Days] [nvarchar](500) NULL,
	[Updated_By] [nvarchar](500) NULL,
	[Updated_Date] [nvarchar](500) NULL,
	[Mapped_Marketing_Campaigns] [nvarchar](500) NULL,
	[Chemist_Mapped] [nvarchar](500) NULL,
	[Chemist_MCL_Numner] [nvarchar](500) NULL,
	[Stockist_Mapped] [nvarchar](500) NULL,
	[Stockist_Ref_Key] [nvarchar](500) NULL,
	[SFC_Category] [nvarchar](500) NULL,
	[From_Place] [nvarchar](500) NULL,
	[To_Place] [nvarchar](500) NULL,
	[Travel_Mode] [nvarchar](500) NULL,
	[Locaiton_Tagged_Status] [nvarchar](500) NULL,
	[Locaiton_Tagged_Date] [nvarchar](500) NULL,
	[Locaiton_Tagged_By] [nvarchar](500) NULL,
	[Locaiton_Tagged_Designation] [nvarchar](500) NULL,
	[Tagged_Latitude] [nvarchar](500) NULL,
	[Tagged_Longitude] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblVisitType]    Script Date: 20-04-2024 11:04:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblVisitType](
	[visitId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](10) NULL,
	[isDisabled] [int] NULL,
	[CreatedDate] [smalldatetime] NULL
) ON [PRIMARY]

GO
ALTER TABLE [BSV_IVF].[tblBrandcompetitorSKUs] ADD  CONSTRAINT [DF__tblBrandc__isDis__3587F3E0]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[tblBrandcompetitorSKUs] ADD  CONSTRAINT [DF__tblBrandc__Creat__367C1819]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [BSV_IVF].[tblChainAccountType] ADD  CONSTRAINT [DEFAULT_tblChainAccountType_isApproved]  DEFAULT ((1)) FOR [isApproved]
GO
ALTER TABLE [BSV_IVF].[tblChainAccountType] ADD  CONSTRAINT [DF__tmp_ms_xx__isDis__5E8A0973]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[tblChainAccountType] ADD  CONSTRAINT [DF__tmp_ms_xx__Creat__5F7E2DAC]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [BSV_IVF].[tblCompetitions] ADD  CONSTRAINT [DF__tmp_ms_xx__Creat__3A4CA8FD]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [BSV_IVF].[tblCompetitions] ADD  CONSTRAINT [DEFAULT_tblCompetitions_isApproved]  DEFAULT ((1)) FOR [isApproved]
GO
ALTER TABLE [BSV_IVF].[TblContractDetails] ADD  CONSTRAINT [DF__TblContra__isDis__25518C17]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[TblContractDetails] ADD  CONSTRAINT [DF__TblContra__creat__2645B050]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [BSV_IVF].[tblDesignation] ADD  CONSTRAINT [DF__tblDesign__isDis__182C9B23]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[tblDesignation] ADD  CONSTRAINT [DF__tblDesign__creat__1920BF5C]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [BSV_IVF].[tblEmployees] ADD  CONSTRAINT [DF__tblEmploy__creat__108B795B]  DEFAULT (getdate()) FOR [createdOn]
GO
ALTER TABLE [BSV_IVF].[tblEmployees] ADD  CONSTRAINT [DF__tblEmploy__isDis__117F9D94]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[tblHierarchy] ADD  CONSTRAINT [DF__tblHierar__isDis__1DE57479]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[tblHierarchy] ADD  CONSTRAINT [DF__tblHierar__creat__1ED998B2]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [BSV_IVF].[tblHospitals] ADD  CONSTRAINT [DF__tblHospit__isDis__21B6055D]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[tblHospitals] ADD  CONSTRAINT [DF__tblHospit__Creat__22AA2996]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [BSV_IVF].[tblLastLoginDetails] ADD  CONSTRAINT [DF__tblLastLo__lastL__25869641]  DEFAULT (getdate()) FOR [lastLoginDate]
GO
ALTER TABLE [BSV_IVF].[tblLastLoginDetails] ADD  CONSTRAINT [DF__tblLastLo__isLas__267ABA7A]  DEFAULT ((0)) FOR [isLastLogin]
GO
ALTER TABLE [BSV_IVF].[tblSKUs] ADD  CONSTRAINT [DF__tmp_ms_xx__isDis__6FE99F9F]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[tblSKUs] ADD  CONSTRAINT [DF__tmp_ms_xx__creat__70DDC3D8]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [BSV_IVF].[tblState] ADD  CONSTRAINT [DF__tblState__isDisa__145C0A3F]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [BSV_IVF].[tblState] ADD  CONSTRAINT [DF__tblState__create__15502E78]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [BSV_IVF].[tblZone] ADD  CONSTRAINT [DF__tblZone__created__2D27B809]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblAccount] ADD  CONSTRAINT [DEFAULT_tblAccount_createdDate]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblAccount] ADD  CONSTRAINT [DEFAULT_tblAccount_isActive]  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[tblActuals] ADD  CONSTRAINT [DF__tblActual__contr__36B12243]  DEFAULT ((1)) FOR [contractRate]
GO
ALTER TABLE [dbo].[tblActuals] ADD  CONSTRAINT [DF__tblActual__isDis__35BCFE0A]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [dbo].[tblActuals] ADD  CONSTRAINT [DF__tblActual__creat__37A5467C]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblBrandGroups] ADD  CONSTRAINT [DF__tblBrandG__isDis__6C190EBB]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [dbo].[tblBrandGroups] ADD  CONSTRAINT [DF__tblBrandG__creat__6D0D32F4]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblChainStatus] ADD  CONSTRAINT [DF__tblChainS__isDis__0C85DE4D]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [dbo].[tblChainStatus] ADD  CONSTRAINT [DF__tblChainS__Creat__0D7A0286]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[tblCustomers] ADD  CONSTRAINT [DF__tblCustom__Creat__09A971A2]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[tblCustomers] ADD  CONSTRAINT [DF__tblCustom__isdis__0A9D95DB]  DEFAULT ((0)) FOR [isdisabled]
GO
ALTER TABLE [dbo].[tblCustomers] ADD  CONSTRAINT [DEFAULT_tblCustomers_isApproved]  DEFAULT ((1)) FOR [isApproved]
GO
ALTER TABLE [dbo].[tblhospitalActuals] ADD  CONSTRAINT [DF__tblhospit__isCon__73BA3083]  DEFAULT ((1)) FOR [isContractApplicable]
GO
ALTER TABLE [dbo].[tblhospitalActuals] ADD  CONSTRAINT [DF__tblhospit__isDis__74AE54BC]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [dbo].[tblhospitalActuals] ADD  CONSTRAINT [DF__tblhospit__creat__75A278F5]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblhospitalActuals] ADD  CONSTRAINT [DEFAULT_tblhospitalActuals_isApproved]  DEFAULT ((1)) FOR [isApproved]
GO
ALTER TABLE [dbo].[TblHospitalsContracts] ADD  CONSTRAINT [DF__TblHospit__Creat__3A81B327]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[TblHospitalsContracts] ADD  CONSTRAINT [DEFAULT_TblHospitalsContracts_isApproved]  DEFAULT ((1)) FOR [isApproved]
GO
ALTER TABLE [dbo].[TblHospitalsPotentials] ADD  CONSTRAINT [DF__TblHospit__IsAct__3E52440B]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[TblHospitalsPotentials] ADD  CONSTRAINT [DF__TblHospit__Creat__3D5E1FD2]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[TblHospitalsPotentials] ADD  CONSTRAINT [DEFAULT_TblHospitalsPotentials_isApproved]  DEFAULT ((1)) FOR [isApproved]
GO
ALTER TABLE [dbo].[tblMarketInsights] ADD  CONSTRAINT [DEFAULT_tblMarketInsights_isActive]  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[tblMarketInsights] ADD  CONSTRAINT [DEFAULT_tblMarketInsights_isApproved]  DEFAULT ((1)) FOR [isApproved]
GO
ALTER TABLE [dbo].[tblSkuGroup] ADD  CONSTRAINT [DF__tblSkuGro__IsDis__68487DD7]  DEFAULT ((0)) FOR [IsDisabled]
GO
ALTER TABLE [dbo].[tblSkuGroup] ADD  CONSTRAINT [DF__tblSkuGro__creat__693CA210]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblSpecialtyType] ADD  CONSTRAINT [DF__tblSpecia__isDis__1332DBDC]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [dbo].[tblSpecialtyType] ADD  CONSTRAINT [DF__tblSpecia__Creat__14270015]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[tblVisitType] ADD  CONSTRAINT [DF__tblVisitT__isDis__10566F31]  DEFAULT ((0)) FOR [isDisabled]
GO
ALTER TABLE [dbo].[tblVisitType] ADD  CONSTRAINT [DF__tblVisitT__Creat__114A936A]  DEFAULT (getdate()) FOR [CreatedDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1= pending, 0=approve 2=rejected (reject comments is mandatory)' , @level0type=N'SCHEMA',@level0name=N'BSV_IVF', @level1type=N'TABLE',@level1name=N'tblCompetitions', @level2type=N'COLUMN',@level2name=N'isApproved'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Center name' , @level0type=N'SCHEMA',@level0name=N'BSV_IVF', @level1type=N'TABLE',@level1name=N'tblHospitals', @level2type=N'COLUMN',@level2name=N'hospitalName'
GO
