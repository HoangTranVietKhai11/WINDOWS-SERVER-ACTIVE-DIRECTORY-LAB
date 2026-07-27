# Giai đoạn 10 — Backup & Recovery (Sao lưu & Phục hồi)

## Mục tiêu
Cấu hình dịch vụ Windows Server Backup (WSB) để sao lưu **System State** và **Bare Metal Recovery**, lập lịch tự động, đảm bảo an toàn dữ liệu và khả năng phục hồi hệ thống Active Directory khi gặp sự cố.

---

## Tại sao Backup quan trọng?
An toàn dữ liệu là yếu tố sống còn. Nếu Domain Controller bị lỗi hoặc bị tấn công Ransomware, toàn bộ hệ thống định danh và quản lý truy cập sẽ tê liệt. Việc có bản sao lưu giúp khôi phục nhanh chóng mà không cần tạo lại hàng ngàn user từ đầu.

---

## Các bước thực hiện

### 1. Cài đặt Windows Server Backup (WSB)
- Mở **Server Manager** > **Add Roles and Features**.
- Ở mục *Features*: Đánh dấu chọn **Windows Server Backup**.
- Nhấn **Install**.

### 2. Cấu hình Backup System State & Bare Metal Recovery
- Mở **Windows Server Backup** (`wbadmin.msc`).
- Chọn **Local Backup** > **Backup Schedule...**
- **Backup Configuration**:
  - Chọn **Custom** để cấu hình chi tiết.
  - Thêm **System State** vào danh mục backup.
  - Kích hoạt **Bare Metal Recovery** (tùy chọn).

#### Giải thích các loại backup:
| Loại Backup | Mô tả |
| :--- | :--- |
| **System State** | Chứa toàn bộ cơ sở dữ liệu Active Directory (file `NTDS.DIT`), cấu hình registry và SYSVOL. Rất quan trọng khi AD bị lỗi logic. |
| **Bare Metal Recovery** | Cho phép khôi phục toàn bộ máy chủ từ đầu (từ trạng thái "trắng") bao gồm OS, drivers, và System State. |

### 3. Lập lịch Backup tự động (Backup Schedule)
- Thiết lập lịch chạy tự động vào lúc **02:00 AM** mỗi ngày.
- **Destination**: Chọn lưu trữ ra **ổ cứng ảo riêng biệt (Disk 2)** thay vì phân vùng chứa Hệ điều hành (Drive C:).

> [!WARNING]
> **Không** lưu backup trên cùng ổ đĩa với OS. Nếu ổ C: bị hỏng hoặc mã hóa bởi Ransomware, bản backup cũng sẽ mất.

### 4. Thực hiện Backup thủ công (One-time Backup)
- Trong **wbadmin.msc**, chọn **Backup Once...**
- Cấu hình giống Backup Schedule ở trên.
- Nhấn **Backup** để chạy ngay lập tức.

Hoặc sử dụng dòng lệnh:
```cmd
wbadmin start systemstatebackup -backuptarget:E: -quiet
```

---

## Ý nghĩa trong doanh nghiệp

### RTO (Recovery Time Objective)
Thời gian tối đa để hệ thống hoạt động trở lại sau sự cố. Bản backup cục bộ giúp giảm RTO xuống mức thấp nhất (vài phút đến vài giờ).

### Phòng chống Ransomware
Nếu Domain Controller bị mã hóa dữ liệu, quy trình khôi phục:
1. Cài lại Windows Server mới (trắng).
2. Khôi phục từ bản **System State Backup**.
3. Toàn bộ hệ thống định danh (users, groups, GPOs) được phục hồi nguyên vẹn.

> Việc có bản System State Backup sẽ **cứu sống toàn bộ hệ thống định danh** của doanh nghiệp thay vì phải tạo lại hàng ngàn user từ đầu.

---

## Kiểm thử & Xác nhận kết quả
1. Kiểm tra bản backup đã được tạo thành công trong **wbadmin.msc** > **Local Backup** > **Backup**.
2. Xác nhận dung lượng và thời gian backup trên ổ Disk 2.
3. Kiểm tra log backup:
   ```cmd
   wbadmin get versions
   ```
