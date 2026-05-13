-- Phần A: Phân tích
-- 1. Câu lệnh CALL để tái hiện lỗi hệ thống:
-- Để tái hiện thao tác gõ nhầm số lượng âm vào hệ thống đối với mã vật tư 10, bạn có thể sử dụng câu lệnh sau:
		CALL AddInventory(10, -500);
-- 2. Giải thích nguyên nhân lỗi:
-- Đoạn mã hiện tại sử dụng công thức stock_quantity = stock_quantity + p_quantity. Khi nhân viên nhập số âm (ví dụ: -500), hệ thống sẽ thực hiện phép toán cộng với số âm (+ (-500)), theo nguyên lý toán học điều này tương đương với phép trừ, dẫn đến việc tồn kho bị giảm đi thay vì tăng lên.

-- Phần B: Sửa chữa mã nguồn
-- Dưới đây là mã SQL để xóa thủ tục cũ và tạo lại thủ tục mới. Trong phiên bản mới, tôi đã thêm khối lệnh IF để kiểm tra tính hợp lệ của tham số p_quantity. Hệ thống sẽ chặn đứng giao dịch và trả về lỗi nếu số lượng không tuân thủ quy tắc nghiệp vụ.
-- 1. Xóa thủ tục cũ đang bị hổng logic
DROP PROCEDURE IF EXISTS AddInventory;

-- 2. Tạo mới thủ tục với cơ chế kiểm soát dữ liệu đầu vào
DELIMITER //

CREATE PROCEDURE AddInventory(IN p_item_id INT, IN p_quantity INT)
BEGIN
    -- Kiểm tra quy tắc hệ thống: Số lượng nhập phải lớn hơn 0
    IF p_quantity > 0 THEN
        UPDATE Inventory
        SET stock_quantity = stock_quantity + p_quantity
        WHERE item_id = p_item_id;
        
        SELECT 'Cập nhật số lượng vật tư thành công.' AS Message;
    ELSE
        -- Ném ra lỗi Exception chặn thao tác nếu số lượng <= 0
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Số lượng vật tư nhập kho bắt buộc phải lớn hơn 0.';
    END IF;
    
END //

DELIMITER ;