# Giai đoạn 4 — Tăng cường bảo mật bằng GPO & AppLocker

## Mục tiêu
Tăng cường mức độ an toàn thông tin cho hệ thống máy trạm bằng cách chặn truy cập Command Prompt, khóa thiết bị lưu trữ USB di động, hạn chế Control Panel, và kiểm soát ứng dụng được phép chạy thông qua AppLocker.

---

## Các bước thực hiện

### 4.1 Chặn quyền truy cập Command Prompt (CMD)
- Mở **gpmc.msc**, tạo hoặc chỉnh sửa GPO áp dụng cho OU `CORP` (ví dụ `GPO_Security_Hardening`).
- Đường dẫn:
  `User Configuration > Policies > Administrative Templates > System`
- Tìm policy: **Prevent access to the command prompt**
  - Chuyển trạng thái sang **Enabled**.
  - Tùy chọn *Also disable the command prompt script processing?*: Chọn **Yes** (chặn luôn thực thi file `.bat` / `.cmd`).
- **Mục đích**: Phòng ngừa việc thực thi các script độc hại (batch file).

### 4.2 Hạn chế truy cập thiết bị lưu trữ USB (Removable Storage Access)
- Đường dẫn:
  `Computer Configuration > Policies > Administrative Templates > System > Removable Storage Access`
- Tìm policy: **All Removable Storage classes: Deny all access**
  - Chuyển trạng thái sang **Enabled**.
- **Mục đích**: Ngăn chặn Data Leakage (rò rỉ dữ liệu) và lây nhiễm virus từ USB cá nhân.

### 4.3 Hạn chế truy cập Control Panel
- Đường dẫn:
  `User Configuration > Policies > Administrative Templates > Control Panel`
- Tìm policy: **Prohibit access to Control Panel and PC settings**
  - Chuyển trạng thái sang **Enabled**.
- **Mục đích**: Ngăn người dùng tự ý thay đổi cấu hình mạng, tắt tường lửa hoặc gỡ bỏ phần mềm diệt virus.

### 4.4 Kiểm soát phần mềm bằng AppLocker
- Đường dẫn:
  `Computer Configuration > Policies > Windows Settings > Security Settings > Application Control Policies > AppLocker`
- **Tạo Default Rules**:
  - Nhấp chuột phải vào **Executable Rules** > chọn **Create Default Rules** (đảm bảo hệ thống không bị khóa các file thực thi hệ thống trong `C:\Windows` và `C:\Program Files`).
- **Thêm Custom Rule (Cấm phần mềm ngoài danh mục)**:
  - Chuột phải **Executable Rules** > **Create New Rule...**
  - *Action*: Deny / Allow tùy theo chính sách.
  - *User or group*: `Everyone` hoặc nhóm chỉ định (ví dụ `G_HR`).
  - *Conditions*: Chọn theo Publisher, Path, hoặc File Hash.
- **Kích hoạt Service trên Client**:
  - AppLocker yêu cầu dịch vụ **Application Identity (`AppIDSvc`)** hoạt động trên Client.
  - Cấu hình qua GPO: `Computer Configuration > Windows Settings > Security Settings > System Services` > tìm `Application Identity` > chuyển sang **Automatic** & **Start**.

---

## Kiểm thử & Xác nhận kết quả
1. Trên máy trạm Client (`PC-Client01`), đăng nhập bằng tài khoản thuộc OU được áp dụng GPO.
2. Chạy ép cập nhật chính sách: `gpupdate /force`.
3. **Thử nghiệm 1 (Test CMD)**: Nhấn `Win + R`, gõ `cmd` và Enter.
   - *Kết quả mong đợi*: Cửa sổ báo thông báo *"The command prompt has been disabled by your administrator."* và lập tức đóng lại.
4. **Thử nghiệm 2 (Test USB)**: Cắm thiết bị USB vào máy Client.
   - *Kết quả mong đợi*: Khi mở ổ đĩa USB trong File Explorer, hệ thống báo *"Location is not accessible. Access is denied."*
5. **Thử nghiệm 3 (Test Control Panel)**: Mở Control Panel.
   - *Kết quả mong đợi*: Hệ thống báo *"This operation has been cancelled due to restrictions in effect on this computer."*
6. **Thử nghiệm 4 (Test AppLocker)**: Chạy file `.exe` không nằm trong danh mục cho phép.
   - *Kết quả mong đợi*: Hệ thống báo lỗi *"This app has been blocked by your system administrator."*
