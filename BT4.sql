-- Phần A: Phân tích & Đề xuất đa giải pháp1. Định nghĩa I/O (Input/Output)Để đảm bảo Stored Procedure nhận đúng dữ liệu và trả về kết quả chuẩn xác cho Frontend, chúng ta cần 4 tham số:Tham số IN (Đầu vào):p_PatientID INT: Mã bệnh nhân (có thể NULL).p_Phone VARCHAR(20): Số điện thoại bệnh nhân (có thể NULL).Tham số OUT (Đầu ra):p_TotalDebt DECIMAL(18,2): Tổng nợ của bệnh nhân (trả về 0 nếu không tìm thấy).p_Message VARCHAR(255): Thông báo trạng thái để Frontend hiển thị trực tiếp.2. Đề xuất 2 giải pháp xử lý logicĐể xử lý yêu cầu "tìm theo ID hoặc Phone", chúng ta có 2 cách viết logic chính bên trong Procedure:Cách 1: Mệnh đề truy vấn linh hoạt (Dynamic Query với OR / COALESCE)Sử dụng một câu lệnh SELECT duy nhất với điều kiện WHERE bao quát mọi trường hợp.Logic: WHERE (PatientID = p_PatientID) OR (Phone = p_Phone)Cách 2: Cấu trúc rẽ nhánh (Branching với IF...ELSEIF)Kiểm tra xem đầu vào nào được truyền vào thì viết câu SELECT tương ứng cho riêng đầu vào đó.Logic: Nếu p_PatientID khác NULL thì query theo ID. Ngược lại, nếu p_Phone khác NULL thì query theo Phone.3. So sánh & Lựa chọnTiêu chí
-- Cách 1: Truy vấn linh hoạt (OR)Cách 2: Cấu trúc rẽ nhánh (IF...ELSEIF)Độ dài CodeNgắn gọn, chỉ cần 1 câu lệnh SELECT.Dài hơn do phải viết nhiều khối IF...ELSE.Hiệu suất (Performance)Thấp. Dễ xảy ra tình trạng "Parameter Sniffing" hoặc Table Scan. Optimizer của DB có thể không tận dụng được Index do mệnh đề OR.Rất cao. 
-- Tách biệt câu truy vấn giúp Optimizer sử dụng chính xác PRIMARY KEY cho ID hoặc INDEX cho Phone.Bảo trìKhó mở rộng nếu sau này thêm các logic phức tạp riêng cho từng loại tìm kiếm.Dễ dàng mở rộng hoặc thêm log/tracking cho từng nhánh.Quyết định: Chọn 
-- Cách 2 (Cấu trúc rẽ nhánh). Trong môi trường bệnh viện, lượng dữ liệu bệnh nhân thường rất lớn. Hiệu suất truy vấn (tận dụng Index) quan trọng hơn việc code ngắn gọn.Phần B: Thiết kế & Triển khai1. Thiết kế luồng xử lý (Flow Design)Quy trình thực thi bên trong GetPatientDebt sẽ diễn ra theo các bước tuần tự sau:Kiểm tra chặn rác (Guard Clause): Kiểm tra nếu cả p_PatientID và p_Phone đều bị bỏ trống (NULL hoặc chuỗi rỗng). Nếu đúng, gán Nợ = 0, xuất thông báo lỗi và kết thúc ngay (Kịch bản 1).Truy xuất dữ liệu (Rẽ nhánh):Nếu có p_PatientID: Tìm bệnh nhân theo ID.Nếu không có ID nhưng có p_Phone: Tìm bệnh nhân theo Phone.(Mẹo: Dùng COUNT và MAX để tránh lỗi No Data Found của DB khi gán vào biến).Xác thực kết quả:Nếu không tìm thấy bản ghi nào (Kịch bản 2): Gán Nợ = 0, xuất thông báo "Không tìm thấy".Nếu tìm thấy: Gán đúng số nợ lấy được, xuất thông báo "Thành công".2. Triển khai Code (Cú pháp chuẩn MySQL)
DELIMITER //

CREATE PROCEDURE GetPatientDebt (
    IN p_PatientID INT,
    IN p_Phone VARCHAR(20),
    OUT p_TotalDebt DECIMAL(18,2),
    OUT p_Message VARCHAR(255)
)
BEGIN
    -- Khai báo biến cục bộ để đếm số lượng record tìm thấy
    DECLARE v_RecordCount INT DEFAULT 0;
    
    -- Bước 1: Kịch bản 1 - Bỏ trống cả ID và Phone
    IF (p_PatientID IS NULL) AND (p_Phone IS NULL OR TRIM(p_Phone) = '') THEN
        SET p_TotalDebt = 0;
        SET p_Message = 'LỖI: Vui lòng nhập Mã bệnh nhân hoặc Số điện thoại để tra cứu.';
    ELSE
        -- Bước 2: Rẽ nhánh truy vấn
        IF p_PatientID IS NOT NULL THEN
            -- Ưu tiên tìm theo ID (vì ID là Khóa chính, quét nhanh nhất)
            SELECT COUNT(*), IFNULL(MAX(TotalDebt), 0) 
            INTO v_RecordCount, p_TotalDebt
            FROM Patients 
            WHERE PatientID = p_PatientID;
            
        ELSEIF p_Phone IS NOT NULL THEN
            -- Nếu không có ID, tìm theo Phone
            SELECT COUNT(*), IFNULL(MAX(TotalDebt), 0) 
            INTO v_RecordCount, p_TotalDebt
            FROM Patients 
            WHERE Phone = p_Phone;
        END IF;

        -- Bước 3: Kịch bản 2 & Thành công - Kiểm tra kết quả trả về
        IF v_RecordCount = 0 THEN
            SET p_TotalDebt = 0;
            SET p_Message = 'KHÔNG TÌM THẤY: Bệnh nhân không tồn tại trong hệ thống.';
        ELSE
            SET p_Message = 'THÀNH CÔNG: Đã lấy thông tin công nợ bệnh nhân.';
        END IF;
    END IF;

END //
DELIMITER ;
-- 3. Nghiệm thu (Test Cases)Dưới đây là 4 lệnh CALL ứng với các kịch bản để Backend hoặc QA có thể kiểm thử (giả định bảng Patients đã có data):Trường hợp 1: Tiếp tân chỉ truyền ID (Bệnh nhân có thật)SQLCALL GetPatientDebt(1001, NULL, @debt, @msg);
SELECT @debt AS TotalDebt, @msg AS StatusMessage;
-- Trường hợp 2: Tiếp tân chỉ truyền Phone (Bệnh nhân có thật)SQLCALL GetPatientDebt(NULL, '0901234567', @debt, @msg);
SELECT @debt AS TotalDebt, @msg AS StatusMessage;
-- Trường hợp 3: Tiếp tân bấm "Tra cứu" nhưng bỏ trống tất cả (Kịch bản 1)SQLCALL GetPatientDebt(NULL, NULL, @debt, @msg);
SELECT @debt AS TotalDebt, @msg AS StatusMessage;
-- Kết quả kỳ vọng: TotalDebt = 0 | StatusMessage = "LỖI: Vui lòng nhập..."
-- Trường hợp 4: Truyền ID không tồn tại (Kịch bản 2)SQLCALL GetPatientDebt(999999, NULL, @debt, @msg);
SELECT @debt AS TotalDebt, @msg AS StatusMessage;
-- Kết quả kỳ vọng: TotalDebt = 0 | StatusMessage = "KHÔNG TÌM THẤY:..."