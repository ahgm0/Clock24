# Kiểm tra nếu không có quyền admin
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # Tạo đối tượng process mới và khởi chạy với quyền admin
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File ""$PSCommandPath"""
    Start-Process PowerShell -ArgumentList $arguments -Verb RunAs
    Exit
}

# Đường dẫn tệp gốc và đích
$source = "$env:TEMP\Clock.exe"
$destination = "$env:SystemRoot\SysWOW64\Clock.exe"

# Lấy tất cả các tệp trong thư mục %temp%, trừ install.ps1
$itemsToDelete = Get-ChildItem -Path "$env:TEMP" | Where-Object { $_.Name -ne "install.ps1" }

# Hàm để tắt Clock.exe nếu nó đang chạy
function Stop-ClockProcess {
    $processName = "Clock"
    $attempts = 0

    while ($attempts -lt 3) {
        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "Tắt Clock.exe - lần thứ $($attempts + 1)"
            Stop-Process -Name $processName -Force
            Start-Sleep -Seconds 1 # Đợi 1 giây trước khi tiếp tục
            $attempts++
        } else {
            Write-Host "Clock.exe không đang chạy, bỏ qua lần thứ $($attempts + 1)"
            $attempts++
        }
    }
}

# Gọi hàm để tắt Clock.exe 3 lần
Stop-ClockProcess

# Kiểm tra tệp nguồn có tồn tại không
If (Test-Path $source) {
    # Sao chép tệp, sử dụng tham số Force để ghi đè nếu tệp đã tồn tại
    Copy-Item -Path $source -Destination $destination -Force
    Write-Host "Tệp đã được sao chép thành công!"

    # Mở tệp Clock.exe sau khi sao chép
} else {
    Write-Host "Tệp Clock.exe không tồn tại trong thư mục %temp%!"    
}


Write-Host "Đang tiến hành xóa các tệp trong %temp% có thể xóa được..."
Start-Sleep -Seconds 1

# Xóa các tệp và thư mục
foreach ($item in $itemsToDelete) {
    try {
        Remove-Item -Path $item.FullName -Recurse -Force
        Write-Host "Đã xóa: $($item.FullName)"
    } catch {
        Write-Host "Không thể xóa: $($item.FullName). Lỗi: $_"
    }
}

Write-Host "Hoàn thành quá trình xóa các tệp và thư mục trong thư mục %temp%."


Start-Process -FilePath $destination
Write-Host "Đã mở Clock.exe!"

Write-Host "5 giây sau sẽ tự tắt..."
Start-Sleep -Seconds 5

# Lệnh dừng yêu cầu người dùng nhấn Enter trước khi kết thúc
# Read-Host -Prompt "Nhấn Enter để thoát"
