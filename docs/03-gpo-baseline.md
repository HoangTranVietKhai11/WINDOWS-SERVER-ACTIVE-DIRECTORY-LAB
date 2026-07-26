# Giai đoạn 3 — Cấu hình Group Policy Object (GPO) cơ bản

## Mục tiêu
Tạo chính sách cơ sở (GPO Baseline) áp dụng cho các máy trạm và người dùng trong Domain, bao gồm chính sách mật khẩu và môi trường làm việc.

---

## Các bước thực hiện

### 1. Cấu hình Default Domain Policy (Chính sách mật khẩu & Khóa tài khoản)
- Mở **Group Policy Management Console** (`gpmc.msc`).
- Duyệt đến: `Forest: khailab.local` > `Domains` > `khailab.local`.
- Chuột phải vào **Default Domain Policy** > chọn **Edit...**
- Điều hướng đến:
  `Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies`

- **Password Policy**:
  - *Enforce password history*: `5 passwords remembered`.
  - *Maximum password age*: `42 days`.
  - *Minimum password length*: `8 characters`.
  - *Password must meet complexity requirements*: **Enabled**.
- **Account Lockout Policy**:
  - *Account lockout duration*: `15 minutes`.
  - *Account lockout threshold*: `5 invalid logon attempts`.
  - *Reset account lockout counter after*: `15 minutes`.

### 2. Tạo GPO Baseline cho NhanVien
- Trong **gpmc.msc**, chuột phải vào OU (ví dụ `OU=NhanSu`) > chọn **Create a GPO in this domain, and Link it here...**
- Đặt tên GPO: `GPO_Baseline_NhanVien`.
- Chuột phải vào `GPO_Baseline_NhanVien` > chọn **Edit...**
- Cấu hình một số thiết lập tùy chỉnh giao diện/desktop:
  - Khóa không cho đổi hình nền desktop.
  - Cấu hình hiển thị các biểu tượng hệ thống mặc định.

---

## Kiểm thử trên Client Machine
1. Đăng nhập vào máy trạm `PC-Client01` bằng tài khoản Domain (ví dụ `KHAILAB\ptm`).
2. Mở **Command Prompt** và ép cập nhật chính sách ngay lập tức:
   ```cmd
   gpupdate /force
   ```
3. Kiểm tra danh sách chính sách đã được áp dụng thành công bằng lệnh:
   ```cmd
   gpresult /r
   ```
   *Xác nhận trong mục "Applied Group Policy Objects" có xuất hiện `GPO_Baseline_NhanVien`.*
