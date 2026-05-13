-- Phần A: Bản vẽ thiết kế kiến trúc
-- 1. Flowchart quy trình nghiệp vụ
-- Quy trình được thiết kế theo nguyên tắc "Kiểm tra trước - Thực hiện sau". Toàn bộ logic được bọc trong một Transaction. Nếu bất kỳ bước nào gặp lỗi, hệ thống sẽ ROLLBACK để trả dữ liệu về trạng thái ban đầu, tránh mất giường cũ khi chưa có giường mới.

-- Chốt 1 (Dữ liệu): Kiểm tra trạng thái bệnh nhân (Phải là 'Active').

-- Chốt 2 (Tài nguyên): Gọi Procedure phụ để tìm giường. Nếu trả về NULL -> Hủy giao dịch.

-- Chốt 3 (Thực thi): Cập nhật song song giải phóng giường cũ và chiếm giữ giường mới.

-- 2. Thiết kế giao tiếp giữa các Procedure
-- Để đảm bảo tính module hóa, chúng ta sử dụng cơ chế tham số như sau:

-- Procedure Phụ (usp_FindAvailableBed):

-- IN p_DeptID: Mã khoa cần tìm.

-- OUT p_BedID: Trả về mã giường trống đầu tiên tìm thấy. Nếu hết giường, trả về NULL.

-- Procedure Master (usp_TransferPatient):

-- Sử dụng biến cục bộ v_NewBedID để nhận giá trị từ tham số OUT của Procedure phụ.

-- Dựa vào giá trị v_NewBedID để quyết định tiếp tục COMMIT hay ROLLBACK.

-- Phần B: Triển khai Code & Kiểm thử
1. Source Code (MySQL/SQL Server Standard)
SQL
-- 1. Procedure phụ: Dò tìm giường trống
DELIMITER //
CREATE PROCEDURE usp_FindAvailableBed(
    IN p_DeptID INT,
    OUT p_BedID INT
)
BEGIN
    -- Tìm 1 giường có trạng thái 'Available' tại khoa chỉ định
    -- Sử dụng FOR UPDATE để khóa dòng, tránh tình trạng 2 y tá cùng nhìn thấy 1 giường trống
    SELECT BedID INTO p_BedID
    FROM Beds
    WHERE DeptID = p_DeptID AND Status = 'Available'
    LIMIT 1
    FOR UPDATE; 
END //

-- 2. Procedure Master: Điều phối chuyển khoa
CREATE PROCEDURE usp_TransferPatient(
    IN p_PatientID INT,
    IN p_TargetDeptID INT,
    OUT p_NewBedID INT,
    OUT p_StatusMessage VARCHAR(255)
)
PROC_MAIN: BEGIN
    DECLARE v_CurrentBedID INT;
    DECLARE v_PatientStatus VARCHAR(50);
    DECLARE v_DeptName VARCHAR(100);
    DECLARE v_FoundBedID INT;

    -- Bắt đầu Transaction để đảm bảo an toàn dữ liệu
    START TRANSACTION;

    -- Kiểm tra sự tồn tại của Khoa
    SELECT DeptName INTO v_DeptName FROM Departments WHERE DeptID = p_TargetDeptID;
    IF v_DeptName IS NULL THEN
        SET p_StatusMessage = 'Error: Target Department does not exist.';
        SET p_NewBedID = NULL;
        ROLLBACK;
        LEAVE PROC_MAIN;
    END IF;

    -- Bẫy dữ liệu: Kiểm tra trạng thái bệnh nhân
    SELECT CurrentBedID, Status INTO v_CurrentBedID, v_PatientStatus 
    FROM Patients WHERE PatientID = p_PatientID;

    IF v_PatientStatus = 'Completed' THEN
        SET p_StatusMessage = 'Rejected: Patient already discharged.';
        ROLLBACK;
        LEAVE PROC_MAIN;
    END IF;

    -- Gọi Procedure phụ để tìm giường (Kiến trúc Module)
    CALL usp_FindAvailableBed(p_TargetDeptID, v_FoundBedID);

    -- Bẫy Overbooking: Nếu không tìm thấy giường
    IF v_FoundBedID IS NULL THEN
        SET p_StatusMessage = CONCAT('Rejected: Department [', v_DeptName, '] is full.');
        ROLLBACK;
        LEAVE PROC_MAIN;
    END IF;

    -- Thực thi chuyển giường (Logic 1 chạm)
    -- Bước A: Giải phóng giường cũ
    UPDATE Beds SET Status = 'Available' WHERE BedID = v_CurrentBedID;
    
    -- Bước B: Khóa giường mới
    UPDATE Beds SET Status = 'Occupied' WHERE BedID = v_FoundBedID;
    
    -- Bước C: Cập nhật thông tin bệnh nhân
    UPDATE Patients SET CurrentBedID = v_FoundBedID WHERE PatientID = p_PatientID;

    -- Hoàn tất
    COMMIT;
    SET p_NewBedID = v_FoundBedID;
    SET p_StatusMessage = 'Success: Patient transferred successfully.';
    
END //
DELIMITER ;
-- 2. Kịch bản kiểm thử (Test Cases)
-- Dưới đây là 4 câu lệnh đại diện cho các kịch bản bạn yêu cầu:


-- Thiết lập biến để hứng kết quả trả về
SET @OutBed = 0;
SET @OutMsg = '';

-- (1) Chuyển khoa thành công
CALL usp_TransferPatient(101, 5, @OutBed, @OutMsg);
SELECT @OutBed AS NewBed, @OutMsg AS Status;

-- (2) Bẫy hết giường trống (Khoa ID: 9 đã đầy)
CALL usp_TransferPatient(102, 9, @OutBed, @OutMsg);
SELECT @OutBed AS NewBed, @OutMsg AS Status;

-- (3) Bẫy bệnh nhân đã xuất viện (Patient ID: 505 có status 'Completed')
CALL usp_TransferPatient(505, 5, @OutBed, @OutMsg);
SELECT @OutBed AS NewBed, @OutMsg AS Status;

-- (4) Chuyển vào Khoa không tồn tại (Dept ID: 999)
CALL usp_TransferPatient(101, 999, @OutBed, @OutMsg);
SELECT @OutBed AS NewBed, @OutMsg AS Status;