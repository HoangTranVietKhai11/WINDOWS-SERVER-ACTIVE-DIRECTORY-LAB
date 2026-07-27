# Giai đoạn 8 — Nhật ký & Hướng dẫn xử lý sự cố (Troubleshooting Guide)

## Mục tiêu
Ghi nhận và hướng dẫn quy trình chẩn đoán các lỗi hạ tầng phổ biến trong môi trường Active Directory & Network Services.

---

## Sự cố 1: Lỗi "The server is not operational" khi máy Client Join Domain

### Triệu chứng
Khi thực hiện Join máy trạm Client vào domain `corp.local`, hệ thống trả về thông báo lỗi:
> *"An Active Directory Domain Controller (AD DC) for the domain corp.local could not be contacted. The server is not operational."*

### Nguyên nhân cốt lõi
Máy Client đang sử dụng IP tĩnh hoặc DNS tự động từ Router ngoài, chưa trỏ địa chỉ **Preferred DNS Server** về IP tĩnh của Domain Controller (`192.168.101.10`).

### Quy trình xử lý
1. Trên máy Client, mở **Network Connections** (`ncpa.cpl`).
2. Mở Properties card mạng > **Internet Protocol Version 4 (TCP/IPv4)**.
3. Chọn *Use the following DNS server addresses*:
   - **Preferred DNS server**: `192.168.101.10`
4. Mở Command Prompt và kiểm tra lại phân giải tên miền:
   ```cmd
   ping corp.local
   ```
5. Thử thực hiện Join Domain lại.

---

## Sự cố 2: Ping tên miền thất bại dù Ping IP tĩnh thành công

### Triệu chứng
Từ máy Client, chạy `ping 192.168.101.10` thành công (0% loss), nhưng chạy `ping corp.local` thì nhận lỗi `Ping request could not find host corp.local`.

### Nguyên nhân cốt lõi
- Bộ nhớ đệm DNS (DNS Cache) trên Client bị lỗi hoặc lưu bản ghi cũ.
- Thiếu DNS Suffix Search List trên máy trạm.

### Quy trình xử lý
1. Xóa bộ nhớ đệm DNS trên Client:
   ```cmd
   ipconfig /flushdns
   ipconfig /registerdns
   ```
2. Kiểm tra thuộc tính DNS Suffix:
   - Mở `ncpa.cpl` > IPv4 Properties > **Advanced...** > tab **DNS**.
   - Nhập vào mục *DNS suffix for this connection*: `corp.local`.

---

## Sự cố 3: Lỗi xác thực Kerberos khi đăng nhập tài khoản Domain

### Triệu chứng
Người dùng không thể đăng nhập tài khoản Domain trên Client, hoặc bị lỗi xác thực dịch vụ nội bộ (Kerberos Authentication Failure).

### Nguyên nhân cốt lõi
Đồng hồ hệ thống (System Time) giữa máy Client và Domain Controller bị lệch vượt quá ngưỡng cho phép của giao thức Kerberos (mặc định là **5 phút**).

### Quy trình xử lý
1. Kiểm tra lại Time Zone trên cả Client và Server (đảm bảo cùng múi giờ UTC+07:00).
2. Thực hiện đồng bộ lại thời gian với Domain Controller bằng lệnh Windows Time Service:
   ```cmd
   w32tm /resync /force
   ```
3. Kiểm tra trạng thái đồng bộ:
   ```cmd
   w32tm /query /status
   ```

---

## Sự cố 4: Không tìm thấy Domain Controller (`nltest` báo lỗi)

### Triệu chứng
Client không thể áp dụng GPO hoặc không thể xác thực tài khoản domain.

### Nguyên nhân cốt lõi
Dịch vụ DNS, Netlogon hoặc KDC (Kerberos Key Distribution Center) trên Domain Controller bị dừng hoặc gặp sự cố bản ghi SRV.

### Quy trình xử lý
1. **Trên Domain Controller (`DC01`)**:
   - Mở CMD (Admin) và kiểm tra sức khỏe DNS & AD:
     ```cmd
     dcdiag /test:dns /v
     ```
   - Khởi động lại dịch vụ Netlogon để đăng ký lại bản ghi SRV:
     ```cmd
     net stop netlogon && net start netlogon
     ```
2. **Trên máy trạm Client**:
   - Sử dụng công cụ `nltest` để xác minh khả năng tìm kiếm DC:
     ```cmd
     nltest /dsgetdc:corp.local
     ```
