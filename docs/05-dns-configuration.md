# Giai đoạn 5 — Cấu hình dịch vụ DNS Server

## Mục tiêu
Cấu hình và kiểm tra hệ thống phân giải tên miền DNS hai chiều (Forward Lookup & Reverse Lookup) trên Domain Controller `DC01`. AD không thể hoạt động nếu thiếu DNS — khi cài đặt AD DS, dịch vụ DNS Server đã được tự động tích hợp.

---

## Các bước thực hiện

### 1. Kiểm tra Forward Lookup Zone
- Mở **DNS Manager** (`dnsmgmt.msc`).
- Expand mục `DC01` > **Forward Lookup Zones**.
- Xác nhận zone `corp.local` đã được khởi tạo tự động khi promote Domain Controller.
- Kiểm tra các bản ghi A cơ bản: `dc01.corp.local` -> `192.168.101.10`.
- **Chức năng**: Giúp phân giải tên miền thành IP (VD: `client1.corp.local` → `192.168.101.20`).

### 2. Khởi tạo Reverse Lookup Zone
- Trong **dnsmgmt.msc**, chuột phải vào **Reverse Lookup Zones** > chọn **New Zone...**
- Chọn **Primary zone** > đánh dấu chọn *Store the zone in Active Directory*.
- Chọn phạm vi nhân bản: *To all DNS servers running on domain controllers in this domain: corp.local*.
- Chọn **IPv4 Reverse Lookup Zone**.
- Nhập **Network ID**: `192.168.101` (tương ứng với subnet `192.168.101.0/24`).
- Giữ mặc định chọn *Allow only secure dynamic updates*.
- Hoàn tất wizard. Zone `101.168.192.in-addr.arpa` sẽ được tạo.
- **Chức năng**: Giúp phân giải IP ngược lại thành tên miền (hữu ích cho việc đọc log bảo mật).

### 3. Tạo bản ghi Pointer (PTR) và bản ghi bổ sung
- Mở bản ghi Host (A) của `DC01` trong Forward Lookup Zone > đánh dấu vào ô **Update associated pointer (PTR) record**.
- (Tùy chọn) Tạo thêm bản ghi A cho các Server khác trong hạ tầng nếu có (ví dụ `FS01` -> `192.168.101.11`).

---

## Kiểm thử Phân giải 2 chiều (Forward & Reverse Lookup)
Mở **Command Prompt** trên DC hoặc Client và thực hiện các lệnh `nslookup`:

1. **Kiểm tra Phân giải Thuận (Host Name -> IP)**:
   ```cmd
   nslookup dc01.corp.local
   ```
   *Kết quả mong đợi*: Address trả về đúng `192.168.101.10`.

2. **Kiểm tra Phân giải Nghịch (IP -> Host Name)**:
   ```cmd
   nslookup 192.168.101.10
   ```
   *Kết quả mong đợi*: Name trả về đúng `dc01.corp.local`.
