# Giai đoạn 7 — File Server phân quyền theo mô hình AGDLP

## Mục tiêu
Xây dựng hệ thống lưu trữ chia sẻ tập trung (File Server) với tên `CompanyData` và cấu hình phân quyền truy cập chi tiết theo mô hình **AGDLP** (Account → Global Group → Domain Local Group → Permission) của Microsoft.

---

## Mô hình AGDLP (Microsoft Best Practice)

```text
Account (User) → Global Group (G_HR) → Domain Local Group → Permission (NTFS/Share)
```

> **Phân tích**: Quyền NTFS kết hợp với Share Permissions đảm bảo rằng dù người dùng có ngồi trực tiếp tại máy chủ hay truy cập qua mạng LAN, dữ liệu vẫn được bảo vệ đúng người, đúng chức vụ.

## Ma trận phân quyền (Permissions Matrix)

| Đường dẫn thư mục | Nhóm được cấp quyền | Share Permissions | NTFS Permissions |
| :--- | :--- | :--- | :--- |
| `\CompanyData\Public` | `Domain Users` | Authenticated Users: **Change** | Domain Users: **Read/Write** |
| `\CompanyData\HR_Only` | `G_HR` | Authenticated Users: **Change** | G_HR: **Modify**; Others: **Deny** |

---

## Các bước thực hiện

### 1. Tạo cấu trúc thư mục chia sẻ
Trên server `DC01`, mở **File Explorer** và tạo thư mục:
- `D:\CompanyData\Public`
- `D:\CompanyData\HR_Only`

### 2. Cấu hình Share Permissions
Với thư mục gốc `D:\CompanyData`:
1. Chuột phải vào thư mục > **Properties** > chọn tab **Sharing** > nhấp **Advanced Sharing...**
2. Đánh dấu chọn **Share this folder**. Share name: `CompanyData`.
3. Nhấp chọn **Permissions**:
   - Xóa nhóm *Everyone* (hoặc để Read).
   - Thêm nhóm **Authenticated Users** với quyền **Change** và **Read**.
4. Nhấn **OK** để hoàn tất tầng Share Permissions (Quyền chi tiết sẽ do NTFS quản lý).

### 3. Cấu hình NTFS Permissions (Quyền chi tiết tầng File System)

#### Thư mục `\CompanyData\Public`:
1. Properties > tab **Security** > **Advanced**.
2. Đảm bảo `Domain Users` có quyền **Read & Execute**, **Write**.

#### Thư mục `\CompanyData\HR_Only`:
1. Properties > tab **Security** > nhấp **Advanced**.
2. Nhấp chọn **Disable inheritance** > chọn *Convert inherited permissions into explicit permissions on this object*.
3. Bỏ bớt các quyền mặc định không cần thiết của người dùng phổ thông.
4. Chọn **Add** > **Select a principal** > nhập `G_HR`.
5. Đánh dấu chọn mức quyền **Modify**.
6. Đảm bảo các nhóm phòng ban khác bị từ chối truy cập (Deny / Not Listed).

---

## Kiểm thử phân quyền từ máy Client
1. Đăng nhập máy trạm bằng tài khoản HR (`hr.tranthib` - thuộc `G_HR`).
   - Truy cập đường dẫn mạng: `\\192.168.101.10\CompanyData\Public` ➔ **Thành công** (Đọc, ghi thành công).
   - Truy cập đường dẫn mạng: `\\192.168.101.10\CompanyData\HR_Only` ➔ **Thành công** (Đọc, ghi, sửa thành công).
2. Đăng nhập bằng tài khoản IT (`nv.nguyenvan` - thuộc `G_IT`, **không** thuộc `G_HR`).
   - Truy cập `\\192.168.101.10\CompanyData\Public` ➔ **Thành công**.
   - Truy cập `\\192.168.101.10\CompanyData\HR_Only` ➔ **Bị từ chối (Access is Denied)**.
