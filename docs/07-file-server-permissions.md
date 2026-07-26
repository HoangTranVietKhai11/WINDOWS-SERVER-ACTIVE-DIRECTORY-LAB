# Giai đoạn 7 — File Server phân quyền theo Nhóm (Share & NTFS Permissions)

## Mục tiêu
Xây dựng hệ thống lưu trữ chia sẻ tập trung (File Server) và cấu hình phân quyền truy cập chi tiết (Granular Access Control) theo Security Groups của từng phòng ban.

---

## Ma trận phân quyền (Permissions Matrix)

| Đường dẫn thư mục | Nhóm được cấp quyền | Share Permissions | NTFS Permissions |
| :--- | :--- | :--- | :--- |
| `D:\Shares\IT` | `G_IT` | Authenticated Users: **Change** | G_IT: **Full Control** |
| `D:\Shares\KinhDoanh` | `G_KinhDoanh` | Authenticated Users: **Change** | G_KinhDoanh: **Modify** |
| `D:\Shares\NhanSu` | `G_NhanSu` | Authenticated Users: **Change** | G_NhanSu: **Modify** |
| `D:\Shares\BanGiamDoc` | `G_BanGiamDoc` | Authenticated Users: **Change** | G_BanGiamDoc: **Full Control** |

---

## Các bước thực hiện

### 1. Tạo cấu trúc thư mục chia sẻ
Trên server `DC01`, mở **File Explorer** và tạo thư mục:
- `D:\Shares\IT`
- `D:\Shares\KinhDoanh`
- `D:\Shares\NhanSu`
- `D:\Shares\BanGiamDoc`

### 2. Cấu hình Share Permissions
Với mỗi thư mục chia sẻ (ví dụ `D:\Shares\IT`):
1. Chuột phải vào thư mục > **Properties** > chọn tab **Sharing** > nhấp **Advanced Sharing...**
2. Đánh dấu chọn **Share this folder**.
3. Nhấp chọn **Permissions**:
   - Xóa nhóm *Everyone* (hoặc để Read).
   - Thêm nhóm **Authenticated Users** với quyền **Change** và **Read**.
4. Nhấn **OK** để hoàn tất tầng Share Permissions (Quyền chi tiết sẽ do NTFS quản lý).

### 3. Cấu hình NTFS Permissions (Quyền chi tiết tầng File System)
1. Trong cửa sổ Properties > chọn tab **Security** > nhấp **Advanced**.
2. Nhấp chọn **Disable inheritance** > chọn *Convert inherited permissions into explicit permissions on this object*.
3. Bỏ bớt các quyền mặc định không cần thiết của người dùng phổ thông.
4. Chọn **Add** > **Select a principal** > nhập tên Security Group tương ứng (ví dụ `G_IT` cho thư mục IT).
5. Đánh dấu chọn mức quyền mong muốn (ví dụ **Full Control** hoặc **Modify**).
6. Đảm bảo bỏ quyền truy cập của các nhóm phòng ban khác (Deny / Not Listed).

---

## Kiểm thử phân quyền từ máy Client
1. Đăng nhập máy trạm bằng tài khoản IT (`nva` - thuộc `G_IT`).
   - Truy cập đường dẫn mạng: `\\192.168.1.10\IT` ➔ **Thành công** (Đọc, ghi, tạo file thành công).
   - Truy cập đường dẫn mạng: `\\192.168.1.10\NhanSu` ➔ **Bị từ chối (Access is Denied)**.
2. Đăng nhập bằng tài khoản Nhân sự (`ptm` - thuộc `G_NhanSu`).
   - Truy cập `\\192.168.1.10\NhanSu` ➔ **Thành công**.
   - Truy cập `\\192.168.1.10\IT` ➔ **Bị từ chối (Access is Denied)**.
