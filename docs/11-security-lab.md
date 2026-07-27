# Giai đoạn 11 — Mô phỏng Tấn công & Phòng thủ (Security Lab)

## Mục tiêu
Kết hợp giữa **Quản trị mạng (Blue Team)** và **Kiểm thử xâm nhập (Red Team)** để mô phỏng kịch bản tấn công Brute-force / Password Spraying vào hệ thống Active Directory, sau đó phân tích log và cấu hình chính sách phòng thủ.

---

## Mô hình tấn công & phòng thủ

```text
[Kali Linux - 192.168.101.50]                    [DC01 - 192.168.101.10]
        Red Team                                        Blue Team
           │                                                │
           ├── nxc smb brute-force ──────────────►  Event ID 4625 (Audit Failure)
           │                                        Event ID 4740 (Account Locked)
           │                                                │
           │                                        Account Lockout Policy
           │                                        (5 attempts → 30min lock)
           │                                                │
           └── Tấn công bị vô hiệu hóa ◄───────── Deny All Attempts
```

---

## 1. Kịch bản tấn công (Red Team)

### Giả định
Một nhân viên cắm máy tính cá nhân (chạy Kali Linux) vào mạng LAN công ty, hoặc một máy trạm bị nhiễm mã độc và kẻ tấn công đang cố gắng dò mật khẩu của các tài khoản quản trị bằng kỹ thuật **Brute-Force / Password Spraying** qua giao thức **SMB**.

### Chuẩn bị môi trường
- **VM3: Kali Linux** — IP: `192.168.101.50` (cùng dải mạng nội bộ với DC01).
- Cài đặt công cụ **nxc** (NetExec — bản nâng cấp của CrackMapExec).

### Thực hiện tấn công
Trên Kali Linux, tạo 2 file:
- `users.txt`: Danh sách username cần dò (VD: `Administrator`, `nv.nguyenvan`, `hr.tranthib`).
- `passwords.txt`: Danh sách mật khẩu phổ biến (VD: `Password123`, `P@ssw0rd`, `Welcome1`).

Thực thi lệnh tấn công:
```bash
nxc smb 192.168.101.10 -u users.txt -p passwords.txt
```

> **Giải thích**: Lệnh này yêu cầu `nxc` tấn công vào dịch vụ SMB của máy chủ `192.168.101.10`, thử kết hợp danh sách người dùng (`users.txt`) với các mật khẩu phổ biến (`passwords.txt`).

---

## 2. Phân tích Log trên Domain Controller (Blue Team)

Khi hệ thống bị tấn công, với vai trò Admin, truy cập vào **Event Viewer > Windows Logs > Security** để điều tra:

### Event ID 4625 — Audit Failure (Đăng nhập thất bại)
- Xuất hiện hàng loạt log này.
- Mô tả chi tiết ghi nhận có quá trình đăng nhập thất bại do sai mật khẩu.
- Log chỉ rõ **IP nguồn của kẻ tấn công** là `192.168.101.50`.

### Event ID 4740 — Account Locked Out (Tài khoản bị khóa)
- Ghi nhận tài khoản người dùng đã bị hệ thống **khóa lại** do vượt ngưỡng đăng nhập sai.

---

## 3. Cấu hình phòng thủ (Account Lockout Policy)

Để chặn đứng hoàn toàn cuộc tấn công Brute-force, truy cập vào **Group Policy Management**, chỉnh sửa **Default Domain Policy**:

### Đường dẫn cấu hình:
```
Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies > Account Lockout Policy
```

### Thiết lập:

| Policy | Giá trị |
| :--- | :--- |
| Account lockout threshold | **5 invalid logon attempts** (Khóa tài khoản nếu nhập sai mật khẩu 5 lần) |
| Account lockout duration | **30 minutes** (Thời gian khóa là 30 phút) |
| Reset account lockout counter after | **30 minutes** |

### Áp dụng:
```cmd
gpupdate /force
```

---

## 4. Kết quả phòng thủ

Khi hacker chạy lại lệnh `nxc`:
- Sau **5 lần đoán sai**, tài khoản bị **khóa cứng**.
- Các yêu cầu dò mật khẩu tiếp theo bị hệ thống **từ chối lập tức** mà không cần kiểm tra tính đúng sai của mật khẩu.
- → **Vô hiệu hóa hoàn toàn** phương pháp tấn công Brute-force.

---

## Kiểm thử & Xác nhận
1. Trước khi áp dụng Account Lockout Policy: Chạy `nxc` → Quan sát hàng loạt Event ID 4625.
2. Sau khi áp dụng: Chạy lại `nxc` → Sau 5 lần sai, thấy Event ID 4740 (Account Locked) và tất cả request tiếp theo bị deny.
3. Kiểm tra trạng thái tài khoản bị khóa:
   ```powershell
   Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, LockedOut
   ```
4. Mở khóa tài khoản thủ công (nếu cần):
   ```powershell
   Unlock-ADAccount -Identity nv.nguyenvan
   ```
