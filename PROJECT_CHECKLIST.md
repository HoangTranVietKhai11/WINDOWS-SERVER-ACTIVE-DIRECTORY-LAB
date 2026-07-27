# PROJECT CHECKLIST — Windows Server & Active Directory Enterprise Lab

Tài liệu này cung cấp danh sách công việc (Checklist) chi tiết từng bước giúp bạn triển khai dự án từ đầu trên máy chủ **Ubuntu Linux** sử dụng phần mềm ảo hóa (**VMware Workstation** hoặc **Oracle VirtualBox**).

---

## Phase 0: Chuẩn bị môi trường Ảo hóa trên Ubuntu Host

- [ ] **0.1** Đảm bảo hệ điều hành **Ubuntu Linux** đã cài đặt phần mềm ảo hóa:
  - VMware Workstation Pro / Player for Linux HOẶC Oracle VirtualBox.
- [ ] **0.2** Tạo **Virtual Network**:
  - Tạo một mạng ảo riêng biệt (dạng **Host-Only** hoặc **Internal Network / LAN Segment**).
  - Đảm bảo các máy ảo trong mạng này có thể giao tiếp với nhau qua dải IP `192.168.101.0/24`.
- [ ] **0.3** Dựng **VM 1: DC01 (Windows Server 2022)**:
  - Cấu hình VM: CPU 2 Cores, RAM 4GB, HDD 60GB + thêm Disk 2 cho Backup.
  - Card mạng: Trỏ về Virtual Network nội bộ đã tạo ở bước 0.2.
- [ ] **0.4** Dựng **VM 2: PC-Client01 (Windows 10/11)**:
  - Cấu hình VM: CPU 2 Cores, RAM 4GB, HDD 40GB.
  - Card mạng: Trỏ về cùng Virtual Network nội bộ.
- [ ] **0.5** Dựng **VM 3: Kali Linux (Attacker)**:
  - Cấu hình VM: CPU 2 Cores, RAM 2GB, HDD 30GB.
  - Card mạng: Trỏ về cùng Virtual Network nội bộ.
  - IP tĩnh: `192.168.101.50`.

---

## Phase 1: Triển khai Domain Controller (DC01)
*Chi tiết hướng dẫn: [docs/01-domain-controller.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/01-domain-controller.md)*

- [ ] **1.1** Đổi tên máy chủ Server thành `DC01` và khởi động lại VM.
- [ ] **1.2** Cấu hình IP tĩnh cho `DC01`:
  - IP: `192.168.101.10`
  - Subnet Mask: `255.255.255.0`
  - Default Gateway: `192.168.101.1`
  - Preferred DNS: `127.0.0.1`
- [ ] **1.3** Cài đặt Role **Active Directory Domain Services (AD DS)** & **DNS Server** qua Server Manager.
- [ ] **1.4** Thực hiện **Promote this server to a domain controller**:
  - Chọn *Add a new forest*.
  - Root domain name: `corp.local`.
  - NetBIOS name: `CORP`.
  - Đặt mật khẩu Directory Services Restore Mode (DSRM).
- [ ] **1.5** Sau khi restart, đăng nhập với tài khoản `CORP\Administrator`.
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
  - OU gốc: `CORP`
  - Sub-OUs: `IT`, `HR`, `Sales`, `Computers` (nằm dưới `CORP`).
- [ ] **2.3** Tạo các Global Security Groups trong từng OU tương ứng:
  - `G_IT`, `G_HR`, `G_Sales`.
- [ ] **2.4** Thử nghiệm tự động hóa tạo User hàng loạt bằng PowerShell:
  - Mở PowerShell (Admin) trên DC01.
  - Chạy script: `scripts/Create-ADUsers-Bulk.ps1 -CsvPath scripts/users_data.csv`.
- [ ] **2.5** Kiểm tra danh sách User (`nv.nguyenvan`, `it.tranvan`, `hr.tranthib`, `sales.levanc`) đã xuất hiện trong đúng OU dưới `CORP` và đã thuộc đúng Security Group.
- [ ] **2.6** *Chụp ảnh màn hình cấu trúc OU và danh sách User/Group* ➔ Lưu thành `screenshots/02-ou-structure.png`.

---

## Phase 3 & 4: Tăng cường bảo mật qua GPO & AppLocker
*Chi tiết hướng dẫn: [docs/03-gpo-baseline.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/03-gpo-baseline.md) & [docs/04-gpo-security-hardening.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/04-gpo-security-hardening.md)*

- [ ] **3.1** Mở **Group Policy Management Console** (`gpmc.msc`).
- [ ] **3.2** Chỉnh sửa **Default Domain Policy**:
  - Thiết lập Password Policy (độ dài tối thiểu 8 ký tự, độ phức tạp Enabled).
  - Thiết lập Account Lockout Policy (khóa tài khoản sau 5 lần nhập sai, thời gian khóa 30 phút).
- [ ] **3.3** Tạo GPO mới `GPO_Security_Hardening` và link vào OU `CORP`.
- [ ] **3.4** **Chặn Command Prompt**:
  - `User Configuration > Policies > Administrative Templates > System > Prevent access to the command prompt` ➔ **Enabled** (Disable script processing = Yes).
- [ ] **3.5** **Khóa thiết bị lưu trữ USB**:
  - `Computer Configuration > Policies > Administrative Templates > System > Removable Storage Access > All Removable Storage classes: Deny all access` ➔ **Enabled**.
- [ ] **3.6** **Hạn chế Control Panel**:
  - `User Configuration > Policies > Administrative Templates > Control Panel > Prohibit access to Control Panel and PC settings` ➔ **Enabled**.
- [ ] **3.7** **Cấu hình AppLocker**:
  - `Computer Configuration > Windows Settings > Security Settings > AppLocker`.
  - Tạo *Default Rules* cho Executable Rules.
  - Chuyển dịch vụ `Application Identity (AppIDSvc)` sang chế độ **Automatic** trong GPO System Services.
- [ ] **3.8** Join máy trạm `PC-Client01` vào domain `corp.local`.
- [ ] **3.9** Đăng nhập bằng user domain trên Client, chạy `gpupdate /force` và kiểm tra:
  - Mở `cmd.exe` ➔ Bị từ chối truy cập.
  - Cắm USB ➔ Bị chặn đọc/ghi.
  - Mở Control Panel ➔ Bị từ chối.
- [ ] **3.10** *Chụp ảnh màn hình thông báo chặn CMD/USB/Control Panel trên Client* ➔ Lưu thành `screenshots/04-gpo-cmd-blocked.png`.

---

## Phase 5 & 6: Dịch vụ mạng lõi DNS & DHCP Server
*Chi tiết hướng dẫn: [docs/05-dns-configuration.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/05-dns-configuration.md) & [docs/06-dhcp-scope.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/06-dhcp-scope.md)*

- [ ] **5.1** Mở **DNS Manager** (`dnsmgmt.msc`), kiểm tra Forward Zone `corp.local`.
- [ ] **5.2** Tạo **Reverse Lookup Zone** cho dải `192.168.101.0/24` (`101.168.192.in-addr.arpa`).
- [ ] **5.3** Tạo bản ghi PTR cho `DC01` và kiểm tra phân giải 2 chiều:
  ```cmd
  nslookup dc01.corp.local
  nslookup 192.168.101.10
  ```
- [ ] **6.1** Cài đặt Role **DHCP Server** trên DC01 và thực hiện **Authorize** trong AD.
- [ ] **6.2** Tạo Scope mới `LAN_Scope_192.168.101.0`:
  - Dải cấp phát: `192.168.101.100` – `192.168.101.200`.
  - Subnet Mask: `255.255.255.0`.
  - Option 003 (Router): `192.168.101.1`.
  - Option 006 (DNS Server): `192.168.101.10` ⚠️ **Bắt buộc trỏ về DC**.
  - Kích hoạt (Activate) Scope.
- [ ] **6.3** Trên Client (`PC-Client01`), đổi card mạng sang Obtain IP automatically. Chạy:
  ```cmd
  ipconfig /release
  ipconfig /renew
  ipconfig /all
  ```
  Xác nhận nhận đúng IP `192.168.101.x` và DNS `192.168.101.10`.
- [ ] **6.4** *Chụp ảnh kết quả `ipconfig /all` trên Client* ➔ Lưu thành `screenshots/06-dhcp-client-ip.png`.

---

## Phase 7: File Server & Phân quyền AGDLP
*Chi tiết hướng dẫn: [docs/07-file-server-permissions.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/07-file-server-permissions.md)*

- [ ] **7.1** Tạo cấu trúc thư mục trên `DC01`: `D:\CompanyData\Public`, `D:\CompanyData\HR_Only`.
- [ ] **7.2** Cấu hình **Share Permissions** cho `CompanyData`:
  - Cấp quyền `Change` cho nhóm `Authenticated Users`.
- [ ] **7.3** Cấu hình **NTFS Permissions** (Tắt inheritance):
  - `D:\CompanyData\Public`: `Domain Users` có quyền `Read/Write`.
  - `D:\CompanyData\HR_Only`: Cấp `Modify` cho `G_HR`, từ chối các nhóm khác.
- [ ] **7.4** Đăng nhập Client bằng các tài khoản khác nhau để kiểm thử:
  - User HR truy cập `\\192.168.101.10\CompanyData\HR_Only` ➔ **Thành công**.
  - User IT truy cập `\\192.168.101.10\CompanyData\HR_Only` ➔ **Bị từ chối (Access Denied)**.
- [ ] **7.5** *Chụp ảnh màn hình cửa sổ NTFS Permissions & kết quả kiểm thử* ➔ Lưu thành `screenshots/07-file-permissions.png`.

---

## Phase 8: Xử lý sự cố thực tế (Troubleshooting)
*Chi tiết hướng dẫn: [docs/08-troubleshooting-guide.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/08-troubleshooting-guide.md)*

- [ ] **8.1** Thử nghiệm và ghi nhận lại cách sửa lỗi "The server is not operational" (Cấu hình DNS client).
- [ ] **8.2** Xử lý lỗi Cache DNS với `ipconfig /flushdns` và `ipconfig /registerdns`.
- [ ] **8.3** Đồng bộ lại thời gian Kerberos clock skew bằng `w32tm /resync`.
- [ ] **8.4** Kiểm tra locator DC bằng `nltest /dsgetdc:corp.local`.

---

## Phase 9: Triển khai Tailscale VPN (Subnet Router)
*Chi tiết hướng dẫn: [docs/09-vpn-tailscale.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/09-vpn-tailscale.md)*

- [ ] **9.1** Đăng ký tài khoản tại [tailscale.com](https://tailscale.com/).
- [ ] **9.2** Cài đặt Tailscale trên `DC01` (Windows Server) và kích hoạt Subnet Router:
  ```cmd
  tailscale up --advertise-routes=192.168.101.0/24 --accept-routes
  ```
- [ ] **9.3** Truy cập Tailscale Admin Console từ trình duyệt máy **Ubuntu Host**, phê duyệt dải route `192.168.101.0/24`.
- [ ] **9.4** Cài đặt Tailscale trên máy **Ubuntu Host** (hoặc thiết bị ở ngoài dải LAN ảo).
- [ ] **9.5** Thực hiện kiểm thử từ máy Ubuntu Host:
  - Ping IP tĩnh nội bộ: `ping 192.168.101.10` ➔ Thành công.
  - Kết nối Remote Desktop (RDP) hoặc SMB `smb://192.168.101.10/CompanyData` từ Ubuntu Host vào máy ảo Windows Server ➔ Thành công.
- [ ] **9.6** *Chụp ảnh màn hình Admin Console Tailscale & kết quả ping/RDP từ xa* ➔ Lưu thành `screenshots/09-tailscale-vpn-connected.png`.

---

## Phase 10: Backup & Recovery
*Chi tiết hướng dẫn: [docs/10-backup-recovery.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/10-backup-recovery.md)*

- [ ] **10.1** Cài đặt **Windows Server Backup** qua Server Manager > Add Features.
- [ ] **10.2** Cấu hình Backup:
  - Loại: **System State** + **Bare Metal Recovery**.
  - Destination: Ổ cứng ảo **Disk 2** (không lưu trên C:).
- [ ] **10.3** Thiết lập **Backup Schedule** tự động lúc **02:00 AM** mỗi ngày.
- [ ] **10.4** Chạy thử Backup thủ công (Backup Once) và kiểm tra kết quả:
  ```cmd
  wbadmin get versions
  ```

---

## Phase 11: Mô phỏng Tấn công & Phòng thủ (Security Lab)
*Chi tiết hướng dẫn: [docs/11-security-lab.md](file:///home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB/docs/11-security-lab.md)*

- [ ] **11.1** Trên Kali Linux (`192.168.101.50`), cài đặt NetExec (`nxc`).
- [ ] **11.2** Tạo file `users.txt` và `passwords.txt` với danh sách username/password cần dò.
- [ ] **11.3** Thực hiện tấn công Brute-force:
  ```bash
  nxc smb 192.168.101.10 -u users.txt -p passwords.txt
  ```
- [ ] **11.4** Trên DC01, mở **Event Viewer > Windows Logs > Security** và xác nhận:
  - Event ID **4625** (Audit Failure) xuất hiện hàng loạt với IP nguồn `192.168.101.50`.
  - Event ID **4740** (Account Locked Out) khi tài khoản bị khóa.
- [ ] **11.5** Cấu hình **Account Lockout Policy** trong Default Domain Policy:
  - Account lockout threshold: `5 invalid logon attempts`.
  - Account lockout duration: `30 minutes`.
- [ ] **11.6** Chạy lại `nxc` và xác nhận tấn công bị vô hiệu hóa hoàn toàn sau 5 lần sai.

---

## Phase 12: Đẩy toàn bộ Dự án lên GitHub

- [ ] **12.1** Đảm bảo tất cả ảnh chụp màn hình minh chứng đã được lưu vào thư mục `screenshots/`.
- [ ] **12.2** Kiểm tra lại file `README.md` và các file trong `docs/`.
- [ ] **12.3** Khởi tạo Git repository và commit trên máy Ubuntu Host:
  ```bash
  cd /home/khai/Documents/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB
  git add .
  git commit -m "Complete Windows Server & Active Directory Enterprise Lab"
  ```
- [ ] **12.4** Đẩy repo lên GitHub cá nhân:
  ```bash
  git remote add origin https://github.com/HoangTranVietKhai11/WINDOWS-SERVER-ACTIVE-DIRECTORY-LAB.git
  git branch -M main
  git push -u origin main
  ```
- [ ] **12.5** Gắn link Repository GitHub vào CV tại mục **Personal Projects / Lab Projects**.
