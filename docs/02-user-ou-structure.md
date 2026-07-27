# Giai đoạn 2 — Quản lý User và Organizational Unit (OU)

## Mục tiêu
Thiết kế quy hoạch cấu trúc đơn vị tổ chức (OU) theo phòng ban thực tế, nhóm bảo mật (Security Groups) và khởi tạo danh sách người dùng theo nguyên tắc RBAC (Role-Based Access Control).

---

## Cấu trúc OU & Group Thiết kế

```text
corp.local
└── OU=CORP (OU gốc)
    ├── OU=IT
    │   └── Group: G_IT
    ├── OU=HR
    │   └── Group: G_HR
    ├── OU=Sales
    │   └── Group: G_Sales
    └── OU=Computers
        └── (Chứa các Computer Account đã join domain)
```

> **Giải thích**: Thay vì để mọi đối tượng vào thư mục `Users` mặc định (Container), mô hình này thiết kế OU theo phòng ban thực tế để dễ dàng áp dụng chính sách (GPO) sau này.

---

## Các bước thực hiện

### Phương pháp 1: Thao tác thủ công qua ADUC GUI
1. Mở **Active Directory Users and Computers** (`dsa.msc`).
2. Chuột phải vào tên miền `corp.local` > **New** > **Organizational Unit**.
3. Tạo OU gốc: `CORP`.
4. Trong OU `CORP`, lần lượt tạo các Sub-OU: `IT`, `HR`, `Sales`, `Computers`.
5. Trong từng OU tương ứng, nhấp chuột phải > **New** > **Group**:
   - **Group Scope**: Global
   - **Group Type**: Security
   - Đặt tên nhóm: `G_IT`, `G_HR`, `G_Sales`.
6. Tạo User mới trong OU (chuột phải > **New** > **User**).
   - VD: `nv.nguyenvan` (trong OU IT), `hr.tranthib` (trong OU HR).
7. Nhấp đúp vào User > tab **Member Of** > chọn **Add...** > nhập tên Security Group tương ứng để gán quyền.

> **Giải thích thuật ngữ (RBAC)**: Việc tạo Group là áp dụng nguyên tắc quản lý quyền truy cập dựa trên vai trò. Khi một nhân viên mới vào, IT chỉ cần thêm User đó vào Group `G_HR`, tự động User đó sẽ có tất cả các quyền của phòng nhân sự mà không cần cấu hình thủ công từng file, từng thư mục.

### Phương pháp 2: Tự động hóa bằng PowerShell Script (Khuyên dùng)
Sử dụng bộ kịch bản tự động hóa nằm trong thư mục `scripts/`:

1. Chuẩn bị file dữ liệu [scripts/users_data.csv](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/scripts/users_data.csv).
2. Mở **PowerShell với quyền Administrator** trên Domain Controller.
3. Điều hướng tới thư mục `scripts/` và thực thi script:
   ```powershell
   Set-ExecutionPolicy Unrestricted -Scope Process -Force
   .\Create-ADUsers-Bulk.ps1 -CsvPath .\users_data.csv
   ```

---

## Kiểm thử & Xác nhận kết quả
1. Kiểm tra lại danh sách trong `dsa.msc`, đảm bảo các OU và Group được tạo đầy đủ dưới `CORP`.
2. Kiểm tra thuộc tính của user bằng lệnh PowerShell:
   ```powershell
   Get-ADUser -Identity nv.nguyenvan -Properties Department, Title, MemberOf
   ```
3. Xác nhận user đã thuộc đúng Security Group tương ứng với phòng ban.
