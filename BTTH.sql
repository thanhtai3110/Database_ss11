CREATE DATABASE RikkeiClinicDB;
USE RikkeiClinicDB;

-- PHẦN 1: KHỞI TẠO CẤU TRÚC BẢNG 

-- 1. Bảng Bệnh nhân (Patients)
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    date_of_birth DATE
);

-- 2. Bảng Nhân sự / Bác sĩ (Employees)
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(18,2) NOT NULL
);

-- 3. Bảng Khoa (Departments)
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

-- 4. Bảng Giường bệnh (Beds)
CREATE TABLE Beds (
    bed_id INT PRIMARY KEY,
    dept_id INT NOT NULL,
    patient_id INT DEFAULT NULL, -- NULL nghĩa là giường trống
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 5. Bảng Lịch khám (Appointments)
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Completed', 'Cancelled'
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Employees(employee_id)
);

-- 6. Bảng Kho Vật tư Y tế (Inventory)
CREATE TABLE Inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0
);

-- 7. Bảng Kho Thuốc (Medicines)
CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 8. Bảng Công nợ Bệnh nhân (Patient_Invoices)
CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) NOT NULL DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 9. Bảng Sản phẩm (Products)
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 10. Bảng Dịch vụ khám (Services) 
CREATE TABLE Services (
    service_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL
);

-- 11. Bảng Ví điện tử (Wallets) 
CREATE TABLE Wallets (
    patient_id INT PRIMARY KEY,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Active', -- 'Active', 'Inactive'
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 12. Bảng Lịch sử sử dụng dịch vụ (Service_Usages) 
CREATE TABLE Service_Usages (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    service_id INT NOT NULL,
    actual_price DECIMAL(18,2) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

-- PHẦN 2: CHÈN DỮ LIỆU MẪU (TEST CASES)
-- Chèn Bệnh nhân
INSERT INTO Patients (patient_id, full_name, phone, date_of_birth) VALUES
(1, 'Nguyen Van An', '0901111222', '1990-05-15'),
(2, 'Tran Thi Binh', '0912222333', '1985-08-20'),
(3, 'Le Hoang Cuong', '0923333444', '2000-12-01');

-- Chèn Nhân sự 
INSERT INTO Employees (employee_id, full_name, position, salary) VALUES
(101, 'Dr. Hoang Minh', 'Doctor', 20000.00),
(102, 'Dr. Lan Anh', 'Doctor', 25000.00),
(103, 'Nurse Thu Ha', 'Nurse', 12000.00);

-- Chèn Khoa
INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'Khoa Ngoai'),
(2, 'Khoa Noi'),
(3, 'Khoa ICU');

-- Chèn Giường bệnh
INSERT INTO Beds (bed_id, dept_id, patient_id) VALUES
(101, 1, 1),    -- Bệnh nhân 1 đang nằm giường 101 Khoa Ngoại
(201, 2, NULL), -- Giường 201 Khoa Nội đang trống
(301, 3, 2);    -- Bệnh nhân 2 đang nằm ICU

-- Chèn Lịch khám 
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status) VALUES
(104, 1, 101, '2026-06-10 08:30:00', 'Pending'),
(105, 2, 102, '2026-05-01 09:00:00', 'Completed'),
(106, 3, 101, '2026-05-02 10:00:00', 'Cancelled');

-- Chèn Vật tư 
INSERT INTO Inventory (item_id, item_name, stock_quantity) VALUES
(10, 'Khau trang y te N95', 1000),
(11, 'Gang tay vo trung', 500),
(12, 'Dung dich sat khuan', 200);

-- Chèn Thuốc
INSERT INTO Medicines (medicine_id, name, price, stock) VALUES
(1, 'Amoxicillin 500mg', 15000, 100),  -- Tồn kho nhiều
(2, 'Panadol Extra', 5000, 5);         -- Tồn kho ít

-- Chèn Công nợ Bệnh nhân
INSERT INTO Patient_Invoices (patient_id, total_due) VALUES
(1, 1500000.00), -- Đã sửa: Nợ 1.5tr để test bài Giải phóng giường bệnh
(2, 0),
(3, 0);

-- Chèn Sản phẩm E-commerce 
INSERT INTO Products (name, price, stock) VALUES
('May do huyet ap Omron', 850000.00, 20),
('May do duong huyet', 450000.00, 15);

-- Chèn Dịch vụ
INSERT INTO Services (service_id, name, price) VALUES
(1, 'Sieu am o bung', 200000.00),
(2, 'Xet nghiem mau', 150000.00),
(3, 'Chup X-Quang', 250000.00);

-- Chèn Ví điện tử
INSERT INTO Wallets (patient_id, balance, status) VALUES
(1, 500000.00, 'Active'),    -- Test Case 1: Đủ tiền thanh toán
(2, 50000.00, 'Active'),     -- Test Case 3: Cháy ví (Chỉ có 50k, không đủ khám 200k)
(3, 1000000.00, 'Inactive'); -- Test Case 2: Nhiều tiền nhưng thẻ bị khóa

-- Phần A: Phân tích & Thiết kế
-- 1. Phân tích I/O (Input/Output)
-- Dữ liệu Đầu vào (Tham số IN):

-- p_patient_id INT: Mã bệnh nhân.

-- p_medicine_id INT: Mã thuốc.

-- p_quantity INT: Số lượng thuốc bác sĩ kê.

-- p_discount_code VARCHAR(50): Mã giảm giá (có thể NULL).

-- Dữ liệu Đầu ra:

-- Sử dụng tham số OUT cho p_status_message VARCHAR(255).

-- Lý do: Tham số OUT được thiết kế chuyên biệt để gán và trả về một giá trị duy nhất cho ứng dụng gọi nó (Backend) mà không cần phải trả về cả một bảng kết quả (Result Set). Điều này tiết kiệm tài nguyên mạng và giúp Backend dễ dàng bắt lấy thông báo trạng thái.

-- 2. Thiết kế luồng xử lý (Flow Design)
-- Quy trình sẽ sử dụng các Biến cục bộ (Local Variables) như v_stock, v_price, v_final_amount để lấy thông tin từ kho và tính toán tạm thời trước khi thực hiện lệnh UPDATE.

-- Bẫy dữ liệu rác (Guard Clause):

-- Kiểm tra nếu p_quantity <= 0. Nếu đúng, trả về thông báo lỗi và kết thúc (ngăn chặn lỗi cộng ngược tồn kho).

-- Đọc dữ liệu kho:

-- Lấy stock và price từ bảng Medicines dựa vào p_medicine_id gán vào biến v_stock và v_price.

-- Kiểm tra tồn kho (Branching):

-- Nhánh 1: Thiếu hàng (v_stock < p_quantity): Gán p_status_message = "Thất bại: Kho không đủ thuốc". KẾT THÚC.

-- Nhánh 2: Đủ hàng (v_stock >= p_quantity): Đi tiếp bước 4.

-- Tính toán và Áp dụng mã giảm giá:

-- Tính v_final_amount = p_quantity * v_price.

-- Kiểm tra p_discount_code. Nếu bằng 'NV-RIKKEI', gán v_final_amount = v_final_amount * 0.5. (Các trường hợp NULL hoặc mã khác sẽ giữ nguyên giá gốc).

-- Cập nhật Database (Dùng Transaction để đảm bảo an toàn):

-- UPDATE Medicines: Trừ stock đi p_quantity.

-- UPDATE Patient_Invoices: Cộng v_final_amount vào total_due.

-- Trả kết quả:

-- Gán p_status_message = "Thành công: Đã xử lý đơn thuốc". KẾT THÚC.

-- Phần B: Triển khai Code & Kiểm thử
-- 1. Khởi tạo Bảng & Dữ liệu mẫu

-- Tạo bảng Thuốc
CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL
);

-- Tạo bảng Hóa đơn Bệnh nhân
CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) NOT NULL DEFAULT 0
);

-- Chèn dữ liệu mẫu
INSERT INTO Medicines (medicine_id, name, price, stock) VALUES 
(1, 'Paracetamol 500mg', 10000, 100),  -- Tồn kho dồi dào
(2, 'Amoxicillin 250mg', 15000, 5);    -- Tồn kho sắp hết

INSERT INTO Patient_Invoices (patient_id, total_due) VALUES 
(101, 0),       -- Bệnh nhân 101, chưa nợ
(102, 50000);   -- Bệnh nhân 102, đang nợ 50k
2. Triển khai Stored Procedure
SQL
DELIMITER $$

CREATE PROCEDURE ProcessPrescription(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    IN p_discount_code VARCHAR(50),
    OUT p_status_message VARCHAR(255)
)
BEGIN
    -- Khai báo các biến cục bộ
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_price DECIMAL(18,2) DEFAULT 0;
    DECLARE v_final_amount DECIMAL(18,2) DEFAULT 0;
    
    -- Xử lý ngoại lệ: Nếu có lỗi trong quá trình UPDATE, rollback lại toàn bộ
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Lỗi hệ thống, đã hoàn tác giao dịch.';
    END;

    -- Bẫy lỗi 1: Ngăn chặn số lượng âm hoặc bằng 0 gây sai lệch tồn kho
    IF p_quantity <= 0 THEN
        SET p_status_message = 'Thất bại: Số lượng thuốc phải lớn hơn 0.';
    ELSE
        -- Bắt đầu Transaction
        START TRANSACTION;

        -- Lấy giá và tồn kho hiện tại (Dùng FOR UPDATE để lock row, tránh race condition)
        SELECT stock, price INTO v_stock, v_price
        FROM Medicines 
        WHERE medicine_id = p_medicine_id
        FOR UPDATE;

        -- Kiểm tra tồn kho
        IF v_stock < p_quantity THEN
            -- Không đủ thuốc, Rollback (giải phóng lock) và báo lỗi
            ROLLBACK;
            SET p_status_message = 'Thất bại: Kho không đủ thuốc';
        ELSE
            -- Đủ thuốc: Tiến hành tính toán
            SET v_final_amount = p_quantity * v_price;

            -- Xử lý mã giảm giá (An toàn với NULL nhờ IFNULL)
            IF IFNULL(p_discount_code, '') = 'NV-RIKKEI' THEN
                SET v_final_amount = v_final_amount * 0.5;
            END IF;

            -- 1. Cập nhật tồn kho
            UPDATE Medicines 
            SET stock = stock - p_quantity 
            WHERE medicine_id = p_medicine_id;

            -- 2. Cập nhật công nợ bệnh nhân
            -- Dùng INSERT ... ON DUPLICATE KEY UPDATE để bao phòng trường hợp bệnh nhân chưa có mã trong bảng hóa đơn
            INSERT INTO Patient_Invoices (patient_id, total_due)
            VALUES (p_patient_id, v_final_amount)
            ON DUPLICATE KEY UPDATE total_due = total_due + v_final_amount;

            -- Commit giao dịch để lưu thay đổi
            COMMIT;
            SET p_status_message = 'Thành công: Đã xử lý đơn thuốc';
        END IF;
    END IF;

END $$

DELIMITER ;

-- 3. Kiểm thử 3 Kịch bản (Nghiệm thu)
-- Kịch bản 1: Kê đơn bình thường, không mã giảm giá (Mua 10 viên Paracetamol - Giá 10k)
-- Kỳ vọng: Tồn kho giảm 10 (còn 90), Nợ bệnh nhân 101 tăng lên 100,000.

CALL ProcessPrescription(101, 1, 10, NULL, @msg1);
SELECT @msg1 AS KichBan1_Status;
-- Kiểm tra dữ liệu: SELECT * FROM Patient_Invoices WHERE patient_id = 101; 
-- Kịch bản 2: Kê đơn có mã NV-RIKKEI (Mua 10 viên Paracetamol - Bệnh nhân 102 đang có sẵn nợ 50k)
-- Kỳ vọng: Tính 50% giá (50,000). Tổng nợ bệnh nhân 102 trở thành 50k (cũ) + 50k (mới) = 100,000.

CALL ProcessPrescription(102, 1, 10, 'NV-RIKKEI', @msg2);
SELECT @msg2 AS KichBan2_Status;
-- Kiểm tra dữ liệu: SELECT * FROM Patient_Invoices WHERE patient_id = 102;
-- Kịch bản 3: Kê đơn vượt tồn kho (Mua 10 viên Amoxicillin nhưng kho chỉ còn 5)
-- Kỳ vọng: Báo lỗi "Kho không đủ thuốc". Database không bị thay đổi.


CALL ProcessPrescription(101, 2, 10, NULL, @msg3);
SELECT @msg3 AS KichBan3_Status;