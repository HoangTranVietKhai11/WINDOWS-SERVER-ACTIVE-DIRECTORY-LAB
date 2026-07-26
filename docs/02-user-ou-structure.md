# Giai đoạn 2 — Quản lý User và Organizational Unit (OU)

## Mục tiêu
Thiết kế quy hoạch cấu trúc đơn vị tổ chức (OU), nhóm bảo mật (Security Groups) theo sơ đồ phòng ban doanh nghiệp và khởi tạo danh sách người dùng.

---

## Cấu trúc OU & Group Thiết kế

```text
khailab.local
├── OU=IT
│   └── Group: G_IT
├── OU=KinhDoanh
│   └── Group: G_KinhDoanh
├── OU=NhanSu
│   └── Group: G_NhanSu
└── OU=BanGiamDoc
    └── Group: G_BanGiamDoc
```

---

## Các bước thực hiện

### Phương pháp 1: Thao tác thủ công qua ADUC GUI
1. Mở **Active Directory Users and Computers** (`dsa.msc`).
2. Chuột phải vào tên miền `khailab.local` > **New** > **Organizational Unit**.
3. Lần lượt tạo các OU: `IT`, `KinhDoanh`, `NhanSu`, `BanGiamDoc`.
4. Trong từng OU tương ứng, nhấp chuột phải > **New** > **Group**:
   - **Group Scope**: Global
   - **Group Type**: Security
   - Đặt tên nhóm: `G_IT`, `G_KinhDoanh`, `G_NhanSu`, `G_BanGiamDoc`.
5. Tạo User mới trong OU (chuột phải > **New** > **User**).
6. Nhấp đúp vào User > tab **Member Of** > chọn **Add...** > nhập tên Security Group tương ứng để gán quyền.

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
1. Kiểm tra lại danh sách trong `dsa.msc`, đảm bảo các OU và Group được tạo đầy đủ.
2. Kiểm tra thuộc tính của user bằng lệnh PowerShell:
   ```powershell
   Get-ADUser -Identity nva -Properties Department, Title, MemberOf
   ```
3. Xác nhận user đã thuộc đúng Security Group tương ứng với phòng ban.
