# PROJECT CHECKLIST — Windows Server & Active Directory Enterprise Lab

Tài liệu này cung cấp danh sách công việc (Checklist) chi tiết từng bước giúp bạn triển khai dự án từ đầu trên máy chủ **Ubuntu Linux** sử dụng phần mềm ảo hóa (**VMware Workstation** hoặc **Oracle VirtualBox**).

---

## Phase 0: Chuẩn bị môi trường Ảo hóa trên Ubuntu Host

- [ ] **0.1** Đảm bảo hệ điều hành **Ubuntu Linux** đã cài đặt phần mềm ảo hóa:
  - VMware Workstation Pro / Player for Linux HOẶC Oracle VirtualBox.
- [ ] **0.2** Tạo **Virtual Network**:
  - Tạo một mạng ảo riêng biệt (dạng **Host-Only** hoặc **Internal Network / LAN Segment**).
  - Đảm bảo các máy ảo trong mạng này có thể giao tiếp với nhau qua dải IP `192.168.1.0/24`.
- [ ] **0.3** Dựng **VM 1: DC01 (Windows Server 2022)**:
  - Cấu hình VM: CPU 2 Cores, RAM 4GB, HDD 60GB.
  - Card mạng: Trỏ về Virtual Network nội bộ đã tạo ở bước 0.2.
- [ ] **0.4** Dựng **VM 2: PC-Client01 (Windows 10/11)**:
  - Cấu hình VM: CPU 2 Cores, RAM 4GB, HDD 40GB.
  - Card mạng: Trỏ về cùng Virtual Network nội bộ.

---

## Phase 1: Triển khai Domain Controller (DC01)
*Chi tiết hướng dẫn: [docs/01-domain-controller.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/01-domain-controller.md)*

- [ ] **1.1** Đổi tên máy chủ Server thành `DC01` và khởi động lại VM.
- [ ] **1.2** Cấu hình IP tĩnh cho `DC01`:
  - IP: `192.168.1.10`
  - Subnet Mask: `255.255.255.0`
  - Preferred DNS: `127.0.0.1`
- [ ] **1.3** Cài đặt Role **Active Directory Domain Services (AD DS)** & **DNS Server** qua Server Manager.
- [ ] **1.4** Thực hiện **Promote this server to a domain controller**:
  - Chọn *Add a new forest*.
  - Root domain name: `khailab.local`.
  - Đặt mật khẩu Directory Services Restore Mode (DSRM).
- [ ] **1.5** Sau khi restart, đăng nhập với tài khoản `KHAILAB\Administrator`.
- [ ] **1.6** Kiểm tra sức khỏe DC qua Command Prompt:
  ```cmd
  dcdiag /test:dns
  ```
- [ ] **1.7** *Chụp ảnh màn hình Server Manager & ADUC khởi tạo thành công* ➔ Lưu thành `screenshots/01-ad-ds-installed.png`.

---

## Phase 2: Cấu trúc OU, User, Group & PowerShell Script
*Chi tiết hướng dẫn: [docs/02-user-ou-structure.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/02-user-ou-structure.md)*

- [ ] **2.1** Mở **Active Directory Users and Computers** (`dsa.msc`).
- [ ] **2.2** Tạo cấu trúc Organizational Units (OU):
  - `OU=IT`, `OU=KinhDoanh`, `OU=NhanSu`, `OU=BanGiamDoc`.
- [ ] **2.3** Tạo các Global Security Groups trong từng OU tương ứng:
  - `G_IT`, `G_KinhDoanh`, `G_NhanSu`, `G_BanGiamDoc`.
- [ ] **2.4** Thử nghiệm tự động hóa tạo User hàng loạt bằng PowerShell:
  - Mở PowerShell (Admin) trên DC01.
  - Chạy script: `scripts/Create-ADUsers-Bulk.ps1 -CsvPath scripts/users_data.csv`.
- [ ] **2.5** Kiểm tra danh sách User (`nva`, `ltt`, `ptm`, `pvh`) đã xuất hiện trong đúng OU và đã thuộc đúng Security Group.
- [ ] **2.6** *Chụp ảnh màn hình cấu trúc OU và danh sách User/Group* ➔ Lưu thành `screenshots/02-ou-structure.png`.

---

## Phase 3 & 4: Tăng cường bảo mật qua GPO & AppLocker
*Chi tiết hướng dẫn: [docs/04-gpo-security-hardening.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/04-gpo-security-hardening.md)*

- [ ] **3.1** Mở **Group Policy Management Console** (`gpmc.msc`).
- [ ] **3.2** Chỉnh sửa **Default Domain Policy**:
  - Thiết lập Password Policy (độ dài tối thiểu 8 ký tự, độ phức tạp Enabled).
  - Thiết lập Account Lockout Policy (khóa tài khoản sau 5 lần nhập sai).
- [ ] **3.3** Tạo GPO mới `GPO_Security_Hardening` và link vào các OU phòng ban.
- [ ] **3.4** **Chặn Command Prompt**:
  - `User Configuration > Policies > Administrative Templates > System > Prevent access to the command prompt` ➔ **Enabled** (Disable script processing = Yes).
- [ ] **3.5** **Khóa thiết bị lưu trữ USB**:
  - `Computer Configuration > Policies > Administrative Templates > System > Removable Storage Access > All Removable Storage classes: Deny all access` ➔ **Enabled**.
- [ ] **3.6** **Cấu hình AppLocker**:
  - `Computer Configuration > Windows Settings > Security Settings > AppLocker`.
  - Tạo *Default Rules* cho Executable Rules.
  - Chuyển dịch vụ `Application Identity (AppIDSvc)` sang chế độ **Automatic** trong GPO System Services.
- [ ] **3.7** Join máy trạm `PC-Client01` vào domain `khailab.local`.
- [ ] **3.8** Đăng nhập bằng user domain trên Client, chạy `gpupdate /force` và kiểm tra:
  - Mở `cmd.exe` ➔ Bị từ chối truy cập.
  - Cắm USB ➔ Bị chặn đọc/ghi.
- [ ] **3.9** *Chụp ảnh màn hình thông báo chặn CMD/USB trên Client* ➔ Lưu thành `screenshots/04-gpo-cmd-blocked.png`.

---

## Phase 5 & 6: Dịch vụ mạng lõi DNS & DHCP Server
*Chi tiết hướng dẫn: [docs/05-dns-configuration.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/05-dns-configuration.md) & [docs/06-dhcp-scope.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/06-dhcp-scope.md)*

- [ ] **5.1** Mở **DNS Manager** (`dnsmgmt.msc`), kiểm tra Forward Zone `khailab.local`.
- [ ] **5.2** Tạo **Reverse Lookup Zone** cho dải `192.168.1.0/24`.
- [ ] **5.3** Tạo bản ghi PTR cho `DC01` và kiểm tra phân giải 2 chiều:
  ```cmd
  nslookup dc01.khailab.local
  nslookup 192.168.1.10
  ```
- [ ] **6.1** Cài đặt Role **DHCP Server** trên DC01 và thực hiện **Authorize** trong AD.
- [ ] **6.2** Tạo Scope mới `LAN_Scope_192.168.1.0`:
  - Dải cấp phát: `192.168.1.100` – `192.168.1.200`.
  - Subnet Mask: `255.255.255.0`.
  - Option 003 (Router): `192.168.1.1`.
  - Option 006 (DNS Server): `192.168.1.10`.
  - Kích hoạt (Activate) Scope.
- [ ] **6.3** Trên Client (`PC-Client01`), đổi card mạng sang Obtain IP automatically. Chạy:
  ```cmd
  ipconfig /release
  ipconfig /renew
  ipconfig /all
  ```
  Xác nhận nhận đúng IP `192.168.1.x` và DNS `192.168.1.10`.
- [ ] **6.4** *Chụp ảnh kết quả `ipconfig /all` trên Client* ➔ Lưu thành `screenshots/06-dhcp-client-ip.png`.

---

## Phase 7: File Server & Phân quyền Share / NTFS
*Chi tiết hướng dẫn: [docs/07-file-server-permissions.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/07-file-server-permissions.md)*

- [ ] **7.1** Tạo cấu trúc thư mục trên `DC01`: `D:\Shares\IT`, `D:\Shares\KinhDoanh`, `D:\Shares\NhanSu`, `D:\Shares\BanGiamDoc`.
- [ ] **7.2** Cấu hình **Share Permissions**:
  - Cấp quyền `Change` cho nhóm `Authenticated Users`.
- [ ] **7.3** Cấu hình **NTFS Permissions** (Tắt inheritance):
  - `D:\Shares\IT`: Cấp `Full Control` cho `G_IT`.
  - `D:\Shares\KinhDoanh`: Cấp `Modify` cho `G_KinhDoanh`.
  - `D:\Shares\NhanSu`: Cấp `Modify` cho `G_NhanSu`.
- [ ] **7.4** Đăng nhập Client bằng các tài khoản khác nhau để kiểm thử:
  - User IT truy cập `\\192.168.1.10\IT` ➔ **Thành công**.
  - User IT truy cập `\\192.168.1.10\NhanSu` ➔ **Bị từ chối (Access Denied)**.
- [ ] **7.5** *Chụp ảnh màn hình cửa sổ NTFS Permissions & kết quả kiểm thử* ➔ Lưu thành `screenshots/07-file-permissions.png`.

---

## Phase 8: Xử lý sự cố thực tế (Troubleshooting)
*Chi tiết hướng dẫn: [docs/08-troubleshooting-guide.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/08-troubleshooting-guide.md)*

- [ ] **8.1** Thử nghiệm và ghi nhận lại cách sửa lỗi "The server is not operational" (Cấu hình DNS client).
- [ ] **8.2** Xử lý lỗi Cache DNS với `ipconfig /flushdns` và `ipconfig /registerdns`.
- [ ] **8.3** Đồng bộ lại thời gian Kerberos clock skew bằng `w32tm /resync`.
- [ ] **8.4** Kiểm tra locator DC bằng `nltest /dsgetdc:khailab.local`.

---

## Phase 9: Triển khai Tailscale VPN (Subnet Router)
*Chi tiết hướng dẫn: [docs/09-vpn-tailscale.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/09-vpn-tailscale.md)*

- [ ] **9.1** Đăng ký tài khoản tại [tailscale.com](https://tailscale.com/).
- [ ] **9.2** Cài đặt Tailscale trên `DC01` (Windows Server) và kích hoạt Subnet Router:
  ```cmd
  tailscale up --advertise-routes=192.168.1.0/24 --accept-routes
  ```
- [ ] **9.3** Truy cập Tailscale Admin Console từ trình duyệt máy **Ubuntu Host**, phê duyệt dải route `192.168.1.0/24`.
- [ ] **9.4** Cài đặt Tailscale trên máy **Ubuntu Host** (hoặc thiết bị ở ngoài dải LAN ảo).
- [ ] **9.5** Thực hiện kiểm thử từ máy Ubuntu Host:
  - Ping IP tĩnh nội bộ: `ping 192.168.1.10` ➔ Thành công.
  - Kết nối Remote Desktop (RDP) hoặc SMB `smb://192.168.1.10/Shares` từ Ubuntu Host vào máy ảo Windows Server ➔ Thành công.
- [ ] **9.6** *Chụp ảnh màn hình Admin Console Tailscale & kết quả ping/RDP từ xa* ➔ Lưu thành `screenshots/09-tailscale-vpn-connected.png`.

---

## Phase 10: Đẩy toàn bộ Dự án lên GitHub

- [ ] **10.1** Đảm bảo tất cả 6 ảnh chụp màn hình minh chứng đã được lưu vào thư mục `screenshots/`.
- [ ] **10.2** Kiểm tra lại file `README.md` và các file trong `docs/`.
- [ ] **10.3** Khởi tạo Git repository và commit trên máy Ubuntu Host:
  ```bash
  cd /home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB
  git add .
  git commit -m "Complete Windows Server & Active Directory Enterprise Lab"
  ```
- [ ] **10.4** Đẩy repo lên GitHub cá nhân:
  ```bash
  git remote add origin https://github.com/HoangTranVietKhai11/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB.git
  git branch -M main
  git push -u origin main
  ```
- [ ] **10.5** Gắn link Repository GitHub vào CV tại mục **Personal Projects / Lab Projects**.
