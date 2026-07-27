# Giai đoạn 12 — Đánh giá Hệ thống, Kết luận & Tài liệu tham khảo

## Mục tiêu
Tổng kết đánh giá ưu/nhược điểm của mô hình Lab, so sánh với môi trường doanh nghiệp thực tế, đề xuất hướng phát triển.

---

## 1. Đánh giá hệ thống (System Evaluation)

### 1.1 Ưu điểm của mô hình Lab

| Ưu điểm | Mô tả |
| :--- | :--- |
| **Tiết kiệm chi phí** | Không tốn chi phí mua sắm thiết bị phần cứng (Server vật lý, Switch, Router). |
| **Môi trường an toàn (Sandboxed)** | Cho phép tự do thử nghiệm các kỹ thuật cấu hình khó hoặc chạy malware/tools tấn công mà không sợ ảnh hưởng đến hệ thống mạng nhà hoặc trường học. |
| **Bao quát kiến thức** | Chạm đến được tất cả các lõi quan trọng của hệ thống hạ tầng IT doanh nghiệp (Identity, Network Services, Security). |

### 1.2 Hạn chế

| Hạn chế | Mô tả |
| :--- | :--- |
| **Single Point of Failure (SPOF)** | Trong lab này chỉ có một Domain Controller. Nếu máy chủ này sập, toàn bộ hệ thống phân giải tên miền và đăng nhập sẽ tê liệt. |
| **Hiệu năng** | Phụ thuộc hoàn toàn vào phần cứng của máy tính Host chạy ảo hóa. |
| **Thiếu thực tế về Network** | Chưa có sự hiện diện của các thiết bị tường lửa vật lý (Firewall Appliance như FortiGate, pfSense) và chia VLAN phức tạp như doanh nghiệp thật. |

### 1.3 So sánh với môi trường doanh nghiệp thực tế

| Tiêu chí | Lab (Mô phỏng) | Doanh nghiệp thực tế |
| :--- | :--- | :--- |
| Domain Controller | 1 DC duy nhất | Ít nhất 2 DC (Primary + Additional) — High Availability |
| Identity Management | AD On-premise | Hybrid Identity (AD + Microsoft Entra ID / Azure AD) |
| Network Security | Không có Firewall vật lý | FortiGate, pfSense, VLAN phân tách |
| Monitoring | Event Viewer thủ công | SIEM (Wazuh, Splunk) — Dashboard trung tâm |

> Doanh nghiệp thực tế luôn có ít nhất **2 Domain Controller** (Primary và Additional DC) để đảm bảo **High Availability** (Tính sẵn sàng cao) và cân bằng tải.

> Hiện nay các doanh nghiệp đang có xu hướng dịch chuyển lên Cloud, sử dụng mô hình **Hybrid Identity** (kết nối AD On-premise đồng bộ lên Microsoft Entra ID / Azure AD) để nhân viên có thể sử dụng 1 tài khoản đăng nhập máy tính nội bộ và đăng nhập cả hệ thống Office 365.

---

## 2. Kết luận & Nhận xét cá nhân

### 2.1 Những gì đã học được
Thông qua quá trình tự tay cài đặt và vận hành mô hình này, các khái niệm lý thuyết trừu tượng trên giảng đường như DNS, DHCP, GPO hay các Event ID giờ đây đã trở thành những thao tác kỹ thuật thực tế và sinh động. Việc đóng vai cả "Kẻ tấn công" và "Người phòng thủ" giúp hình thành tư duy bảo mật hệ thống một cách toàn diện (**Security by Design**) ngay từ khâu thiết kế cơ sở hạ tầng.

### 2.2 Định hướng phát triển thêm (Future Work)
Nếu có thêm tài nguyên phần cứng và thời gian, đồ án có thể được mở rộng bằng cách:

- **Triển khai Additional Domain Controller**: Cấu hình Replication (Đồng bộ) giữa 2 DC để xây dựng hệ thống chịu lỗi.
- **Tích hợp hệ thống SIEM**: Cài đặt Wazuh hoặc Splunk để thu thập log Event Viewer từ Windows Server về một Dashboard trung tâm, cấu hình cảnh báo qua Telegram/Email khi có Event ID 4625 (tấn công Brute-force).
- **Triển khai Enterprise CA (Active Directory Certificate Services)**: Cấp phát chứng chỉ số SSL/TLS nội bộ cho hệ thống mạng.

### 2.3 Nhận xét cá nhân
Việc xây dựng Home Lab là một khoản đầu tư vô giá về mặt kỹ năng đối với một người học CNTT. Khó khăn lớn nhất trong quá trình làm lab không phải là việc bấm "Next" để cài đặt, mà là quá trình **Troubleshooting** (tìm lỗi và sửa lỗi) — ví dụ như khi Client không Join được Domain do sai Option DNS của DHCP, hay khi GPO không nhận do chưa gõ lệnh `gpupdate /force`. Chính những lỗi nhỏ đó đã dạy tính cẩn thận và cách đọc tài liệu chuyên ngành để giải quyết vấn đề tận gốc.

---

## 3. Tài liệu tham khảo (References)

1. Microsoft Learn (n.d.). *Active Directory Domain Services Overview*. Truy xuất từ: [https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)
2. Microsoft Docs (n.d.). *Group Policy Objects*. Truy xuất từ tài liệu cấu hình bảo mật hệ thống Windows.
3. Offensive Security (n.d.). *Kali Linux Documentation*.
4. Porchetta Industries (n.d.). *NetExec Wiki*. Truy xuất từ: [https://www.netexec.wiki/](https://www.netexec.wiki/)
5. Tailscale (n.d.). *What is Tailscale?*. Truy xuất từ: [https://tailscale.com/kb/1151/what-is-tailscale](https://tailscale.com/kb/1151/what-is-tailscale)
