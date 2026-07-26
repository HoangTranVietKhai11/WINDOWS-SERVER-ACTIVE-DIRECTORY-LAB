# Giai đoạn 9 — Triển khai Tailscale VPN (Zero-Trust Remote Access)

## Mục tiêu
Cấu hình giải pháp VPN thế hệ mới (Tailscale Subnet Router) cho phép quản trị viên hoặc nhân viên làm việc từ xa (Remote Work) truy cập an toàn vào toàn bộ hạ tầng mạng nội bộ `192.168.1.0/24` mà không cần mở port trực tiếp (No Port Forwarding/Public IP) ra Internet.

---

## Nguyên lý hoạt động (Subnet Routing)

```text
[Remote Laptop] ──(Encrypted Tailscale Mesh)──> [DC01: Tailscale Subnet Router] ──(LAN)──> [File Server / AD DS / DNS]
```

---

## Các bước thực hiện

### 1. Đăng ký & Cài đặt Tailscale trên Domain Controller (`DC01`)
1. Tạo tài khoản quản trị tại [tailscale.com](https://tailscale.com/).
2. Tải và cài đặt ứng dụng Tailscale cho Windows Server.
3. Đăng nhập ứng dụng trên `DC01` để liên kết máy chủ vào mạng riêng ảo (Tailnet).

### 2. Cấu hình Subnet Router trên `DC01`
1. Mở **Command Prompt (Run as Administrator)** trên `DC01`.
2. Thực thi lệnh quảng bá dải mạng nội bộ `192.168.1.0/24`:
   ```cmd
   tailscale up --advertise-routes=192.168.1.0/24 --accept-routes
   ```

### 3. Phê duyệt Route trên Tailscale Admin Console
1. Đăng nhập vào [Tailscale Admin Console](https://login.tailscale.com/admin/machines).
2. Tìm máy **DC01** trong danh sách thiết bị > nhấp chọn dấu `...` > chọn **Edit route settings...**
3. Đánh dấu bật (Enable) dải subnet route `192.168.1.0/24` vừa được quảng bá.
4. (Tùy chọn) Tắt tính năng Key Expiry cho `DC01` để đảm bảo kết nối VPN không bị ngắt quãng.

### 4. Cài đặt trên thiết bị cá nhân ở xa (Remote Client Laptop)
1. Tải và cài đặt Tailscale trên thiết bị cá nhân (Windows/macOS/iOS/Android).
2. Đăng nhập vào cùng tài khoản Tailnet.

---

## Kiểm thử Truy cập từ xa (Verification)
Từ thiết bị cá nhân ở xa (đang kết nối 4G hoặc Wifi mạng khác hoàn toàn):

1. **Kiểm tra Ping IP nội bộ**:
   ```cmd
   ping 192.168.1.10
   ```
   *Kết quả*: Trả về phản hồi thành công từ DC01 qua đường truyền mã hóa Tailscale.

2. **Truy cập Điều khiển từ xa (Remote Desktop - RDP)**:
   - Mở `mstsc`, gõ IP `192.168.1.10`.
   - Kết nối thành công vào giao diện quản trị Server.

3. **Truy cập Tài nguyên File Server**:
   - Nhấn `Win + R`, gõ `\\192.168.1.10\Shares`.
   - Mở và tương tác với các thư mục chia sẻ nội bộ bình thường.
