# Giai đoạn 1 — Triển khai Domain Controller (DC)

## Mục tiêu
Khởi tạo máy chủ Domain Controller đầu tiên (First DC in New Forest) cho doanh nghiệp với tên miền gốc `khailab.local` trên nền tảng Windows Server 2022 (dựng dưới dạng máy ảo VM 1 trên hệ điều hành máy chủ Ubuntu Linux).

---

## Các bước thực hiện

### 0. Chuẩn bị máy ảo trên Ubuntu Host (VMware / VirtualBox)
- Mở phần mềm ảo hóa (**VMware Workstation** hoặc **VirtualBox**) trên máy chủ **Ubuntu Linux**.
- Tạo VM mới: 2 vCPU, 4GB RAM, 60GB Disk, gắn ISO Windows Server 2022.
- Card mạng máy ảo: Đặt thuộc tính card mạng ở chế độ **Host-Only** hoặc **LAN Segment** (mạng ảo nội bộ dải `192.168.1.0/24`).

### 1. Cấu hình địa chỉ IP tĩnh trên Windows Server
- Mở **Control Panel** > **Network and Sharing Center** > **Change adapter settings**.
- Nhấp chuột phải vào card mạng > **Properties** > chọn **Internet Protocol Version 4 (TCP/IPv4)**.
- Thiết lập thông số theo kế hoạch:
  - **IP Address**: `192.168.1.10`
  - **Subnet Mask**: `255.255.255.0`
  - **Default Gateway**: `192.168.1.1`
  - **Preferred DNS Server**: `127.0.0.1` (sau khi promote, server tự trỏ về chính mình).

### 2. Đổi tên máy chủ Server
- Mở **Server Manager** > **Local Server**.
- Chọn mục **Computer Name** > nhấp **Change...**
- Đổi tên máy thành: `DC01`.
- Khởi động lại máy chủ (Restart).

### 3. Cài đặt Vai trò Active Directory Domain Services (AD DS)
- Mở **Server Manager** > chọn **Add Roles and Features**.
- Ở mục *Installation Type*: Chọn **Role-based or feature-based installation**.
- Ở mục *Server Selection*: Chọn máy `DC01`.
- Ở mục *Server Roles*: Đánh dấu chọn **Active Directory Domain Services** (chấp nhận tự động thêm các RSAT tools kèm theo).
- Nhấn **Next** cho đến bước **Install**.

### 4. Nâng cấp Server thành Domain Controller (Promote Server)
- Sau khi cài xong Role, nhấp vào thông báo ở góc trên Server Manager > chọn **Promote this server to a domain controller**.
- **Deployment Configuration**:
  - Chọn option: **Add a new forest**.
  - Nhập **Root domain name**: `khailab.local`.
- **Domain Controller Options**:
  - *Forest / Domain functional level*: **Windows Server 2016** (hoặc cao hơn).
  - Đảm bảo đánh dấu chọn: **Domain Name System (DNS) server** và **Global Catalog (GC)**.
  - Nhập mật khẩu **Directory Services Restore Mode (DSRM)** (lưu lại mật khẩu này cho mục đích khôi phục).
- Giữ mặc định ở các bước DNS Options, NetBIOS Name (`KHAILAB`), Paths (`C:\Windows\NTDS` và `C:\Windows\SYSVOL`).
- Nhấn **Install** sau khi kiểm tra xong *Prerequisites Check*. Server sẽ tự khởi động lại.

---

## Kiểm thử & Xác nhận kết quả (Verification)
1. Đăng nhập vào Server bằng tài khoản Domain: `KHAILAB\Administrator`.
2. Mở công cụ **Active Directory Users and Computers** (`dsa.msc`) để xác nhận domain `khailab.local` đã hoạt động.
3. Mở **Command Prompt** (Run as Administrator) và chạy lệnh kiểm tra sức khỏe DC:
   ```cmd
   dcdiag /test:dns
   ```
4. Kiểm tra các bản ghi SRV đã đăng ký thành công trong DNS Manager (`dnsmgmt.msc`).
