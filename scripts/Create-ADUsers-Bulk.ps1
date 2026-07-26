<#
.SYNOPSIS
    Kịch bản PowerShell tự động hóa khởi tạo tài khoản người dùng Active Directory từ file CSV.
.DESCRIPTION
    Script thực hiện:
    1. Đọc danh sách người dùng từ file users_data.csv.
    2. Kiểm tra và tự động tạo Organizational Unit (OU) nếu chưa tồn tại.
    3. Tạo tài khoản người dùng mới (New-ADUser), kích hoạt tài khoản và đặt mật khẩu.
    4. Thêm tài khoản người dùng vào Security Group tương ứng.
.EXAMPLE
    .\Create-ADUsers-Bulk.ps1 -CsvPath .\users_data.csv
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$CsvPath = ".\users_data.csv"
)

# Import module Active Directory
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module chưa được cài đặt. Vui lòng chạy trên Domain Controller hoặc máy có RSAT."
    exit
}

Import-Module ActiveDirectory

if (-not (Test-Path -Path $CsvPath)) {
    Write-Error "Không tìm thấy file CSV tại đường dẫn: $CsvPath"
    exit
}

$DomainDN = (Get-ADDomain).DistinguishedName
$Users = Import-Csv -Path $CsvPath -Encoding UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " STARTING BULK AD USER CREATION PROCESS " -ForegroundColor Green
Write-Host " Domain DN: $DomainDN" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

foreach ($User in $Users) {
    $SamAccountName = $User.Username
    $GivenName      = $User.FirstName
    $Surname        = $User.LastName
    $DisplayName    = "$Surname $GivenName"
    $OUName         = $User.OU
    $GroupName      = $User.Group
    $PlainTextPass  = $User.Password
    $Title          = $User.Title
    $Department     = $User.Department

    $TargetOUDN = "OU=$OUName,$DomainDN"

    # 1. Kiểm tra & Tạo OU nếu chưa có
    try {
        [void](Get-ADOrganizationalUnit -Identity $TargetOUDN -ErrorAction Stop)
    }
    catch {
        Write-Host "[+] Tạo mới OU: $OUName ($TargetOUDN)" -ForegroundColor Yellow
        New-ADOrganizationalUnit -Name $OUName -Path $DomainDN -ProtectedFromAccidentalDeletion $false
    }

    # 2. Tạo User
    $SecurePassword = ConvertTo-SecureString $PlainTextPass -AsPlainText -Force
    $UserExist = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"

    if ($UserExist) {
        Write-Host "[!] User '$SamAccountName' đã tồn tại. Bỏ qua khởi tạo..." -ForegroundColor DarkYellow
    }
    else {
        try {
            New-ADUser -SamAccountName $SamAccountName `
                       -UserPrincipalName "$SamAccountName@$((Get-ADDomain).DNSRoot)" `
                       -Name $DisplayName `
                       -GivenName $GivenName `
                       -Surname $Surname `
                       -DisplayName $DisplayName `
                       -Path $TargetOUDN `
                       -AccountPassword $SecurePassword `
                       -Enabled $true `
                       -ChangePasswordAtLogon $false `
                       -Title $Title `
                       -Department $Department `
                       -ErrorAction Stop

            Write-Host "[✓] Tạo tài khoản thành công: $SamAccountName ($DisplayName)" -ForegroundColor Green
        }
        catch {
            Write-Host "[X] Lỗi tạo user '$SamAccountName': $_" -ForegroundColor Red
            continue
        }
    }

    # 3. Thêm User vào Group
    if ($GroupName) {
        $GroupExist = Get-ADGroup -Filter "Name -eq '$GroupName'"
        if (-not $GroupExist) {
            Write-Host "[+] Tạo mới Security Group: $GroupName trong OU $OUName" -ForegroundColor Yellow
            New-ADGroup -Name $GroupName -GroupScope Global -GroupCategory Security -Path $TargetOUDN
        }

        try {
            Add-ADGroupMember -Identity $GroupName -Members $SamAccountName -ErrorAction Stop
            Write-Host "    └── [✓] Đã thêm '$SamAccountName' vào nhóm '$GroupName'" -ForegroundColor Cyan
        }
        catch {
            Write-Host "    └── [!] Không thể thêm vào nhóm (có thể user đã thuộc nhóm): $_" -ForegroundColor DarkYellow
        }
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " HOÀN TẤT TRIỂN KHAI USER & GROUP TỰ ĐỘNG! " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
