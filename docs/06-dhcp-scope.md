# Giai đoạn 6 — Cấu hình dịch vụ DHCP Server

## Mục tiêu
Cài đặt và cấu hình DHCP Server cấp phát địa chỉ IP tự động cho các máy trạm (Client Workstations) trong dải mạng nội bộ `192.168.101.0/24`. Mục đích giảm tải việc cấp IP bằng tay cho hàng trăm máy Client.

---

## Các bước thực hiện

### 1. Cài đặt Role DHCP Server & Authorize trong Active Directory
- Mở **Server Manager** > **Add Roles and Features**.
- Ở mục *Server Roles*: Đánh dấu chọn **DHCP Server** > **Install**.
- Sau khi cài xong, nhấp vào thông báo chọn **Complete DHCP configuration**.
- Chọn tài khoản `CORP\Administrator` để thực hiện **Authorize DHCP Server** trong Active Directory.

### 2. Khởi tạo DHCP Scope mới (New Scope)
- Mở **DHCP Manager** (`dhcpmgmt.msc`).
- Expand `DC01` > chuột phải vào **IPv4** > chọn **New Scope...**
- **Scope Name**: Nhập `LAN_Scope_192.168.101.0`.
- **IP Address Range**:
  - *Start IP address*: `192.168.101.100`
  - *End IP address*: `192.168.101.200`
  - *Subnet mask*: `255.255.255.0` (Length: 24)
- **Add Exclusions and Delay**: Dành riêng dải `192.168.101.1 - 192.168.101.99` cho Server & thiết bị mạng tĩnh.
- **Lease Duration**: Giữ mặc định `8 days` (hoặc chỉnh theo nhu cầu).

### 3. Cấu hình Scope Options
Ở bước *Configure DHCP Options*, chọn **Yes, I want to configure these options now**:
- **003 Router (Default Gateway)**: Nhập IP Router/Firewall: `192.168.101.1` > chọn **Add**.
- **006 DNS Servers**: Nhập IP Domain Controller: `192.168.101.10` > chọn **Add**.
- Nhấn **Activate Scope Now** để kích hoạt dải cấp phát.

> [!WARNING]
> **Option 006 (DNS Servers)** bắt buộc phải trỏ về IP của DC (`192.168.101.10`). Nếu sai cấu hình này, Client sẽ không thể Join Domain vì không phân giải được tên miền `corp.local`.

---

## Kiểm thử trên Client Machine (`PC-Client01`)
1. Trên máy trạm Client, mở **Network Connections** (`ncpa.cpl`).
2. Chỉnh thuộc tính TCP/IPv4 sang chế độ: **Obtain an IP address automatically** và **Obtain DNS server address automatically**.
3. Mở **Command Prompt** và thực thi các lệnh:
   ```cmd
   ipconfig /release
   ipconfig /renew
   ipconfig /all
   ```
4. *Xác nhận kết quả*:
   - IPv4 Address nằm trong dải `192.168.101.100 - 192.168.101.200`.
   - DHCP Server & DNS Server trỏ về `192.168.101.10`.
   - Default Gateway trỏ về `192.168.101.1`.
