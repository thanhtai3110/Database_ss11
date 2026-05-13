-- 1. Xác định dữ liệu và Đề xuất tham số
-- Dữ liệu đầu vào (Nhận từ phần mềm của thu ngân):

-- p_total_cost (Tổng chi phí): Loại tham số IN (Kiểu DECIMAL).

-- p_patient_type (Diện bệnh nhân): Loại tham số IN (Kiểu VARCHAR).

-- Dữ liệu đầu ra (Trả ngược lại hệ thống):

-- p_final_amount (Số tiền cuối cùng phải thu): Loại tham số OUT (Kiểu DECIMAL).

-- p_message (Thông báo trạng thái): Loại tham số OUT (Kiểu VARCHAR).

-- 2. Giải pháp và Các bước thực hiện
-- Bước 1: Kiểm tra tính hợp lệ của dữ liệu đầu vào. Dùng câu lệnh IF kiểm tra giá trị p_total_cost. Nếu nhỏ hơn 0, lập tức gán p_final_amount = 0 và p_message = "Lỗi: Chi phí không hợp lệ", sau đó bỏ qua các bước tính toán.

-- Bước 2: Phân loại diện bệnh nhân. Nếu chi phí hợp lệ (>= 0), tiến hành dùng cấu trúc IF...ELSEIF hoặc CASE...WHEN để rẽ nhánh theo p_patient_type.

-- Bước 3: Thực hiện tính toán. Áp dụng công thức tương ứng:

-- BHYT: Chỉ đóng 20% (Nhân chi phí với 0.2).

-- VIP: Giảm 10% (Nhân chi phí với 0.9).

-- THUONG: Đóng 100% (Giữ nguyên chi phí).

-- Bước 4: Gán thông báo thành công. Sau khi tính toán xong, gán p_message = "Đã tính toán xong".

-- 3. Triển khai mã nguồn

DELIMITER //
CREATE PROCEDURE CalculateFinalBill(
    IN p_total_cost DECIMAL(18,2),
    IN p_patient_type VARCHAR(20),
    OUT p_final_amount DECIMAL(18,2),
    OUT p_message VARCHAR(100)
)
BEGIN
    -- Kiểm tra chi phí đầu vào có hợp lệ không
    IF p_total_cost < 0 THEN
        SET p_final_amount = 0;
        SET p_message = 'Lỗi: Chi phí không hợp lệ';
    ELSE
        -- Xử lý tính toán dựa trên diện bệnh nhân
        IF p_patient_type = 'BHYT' THEN
            SET p_final_amount = p_total_cost * 0.20;
        ELSEIF p_patient_type = 'VIP' THEN
            SET p_final_amount = p_total_cost * 0.90;
        ELSEIF p_patient_type = 'THUONG' THEN
            SET p_final_amount = p_total_cost;
        ELSE
            -- Dự phòng trường hợp nhập sai diện bệnh nhân
            SET p_final_amount = p_total_cost; 
        END IF;
        
        -- Trả về thông báo thành công
        SET p_message = 'Đã tính toán xong';
    END IF;
END //

DELIMITER ;
-- 4. Kiểm thử (Testing)
-- Để kiểm tra thủ tục vừa tạo, bạn chạy lần lượt các câu lệnh CALL sau kết hợp với SELECT để in ra giá trị của các biến chứa kết quả (Output Variables):

-- Trường hợp 1: Bệnh nhân BHYT (Hỗ trợ 80%, thu 20%)


CALL CalculateFinalBill(1000000, 'BHYT', @final_amt, @status_msg);
SELECT 'BHYT Test' AS TestCase, @final_amt AS FinalAmount, @status_msg AS Message;
-- Kết quả kỳ vọng: FinalAmount = 200000.00, Message = 'Đã tính toán xong'
-- Trường hợp 2: Bệnh nhân VIP (Giảm 10%)


CALL CalculateFinalBill(1000000, 'VIP', @final_amt, @status_msg);
SELECT 'VIP Test' AS TestCase, @final_amt AS FinalAmount, @status_msg AS Message;
-- Kết quả kỳ vọng: FinalAmount = 900000.00, Message = 'Đã tính toán xong'
-- Trường hợp 3: Bệnh nhân THUONG (Đóng 100%)

CALL CalculateFinalBill(1000000, 'THUONG', @final_amt, @status_msg);
SELECT 'THUONG Test' AS TestCase, @final_amt AS FinalAmount, @status_msg AS Message;
-- Kết quả kỳ vọng: FinalAmount = 1000000.00, Message = 'Đã tính toán xong'
-- Trường hợp 4: Lỗi nhập chi phí âm


CALL CalculateFinalBill(-500000, 'THUONG', @final_amt, @status_msg);
SELECT 'Negative Cost Test' AS TestCase, @final_amt AS FinalAmount, @status_msg AS Message;
-- Kết quả kỳ vọng: FinalAmount = 0.00, Message = 'Lỗi: Chi phí không hợp lệ'